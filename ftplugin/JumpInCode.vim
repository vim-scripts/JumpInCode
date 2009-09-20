" Name:     JumpInCode.vim
" Brief:    Usefull tools for Doxygen (comment, author, license).
" Version:  1.0.0
" Date:     Fri Sep 18 12:10:16 2009
" Author:   Chen Zuopeng
" Email:    rlxtime.com@gmail.com or chenzuopeng@gmail.com
"
" License:  Public domain, no restrictions whatsoever
"
"Copyright: Copyright (C) 2001-2008 Chen Zuopeng
"           Permission is hereby granted to use and distribute this code,
"           with or without modifications, provided that this copyright
"           notice is copied with it. Like anything else that's free,
"           bufexplorer.vim is provided *as is* and comes with no
"           warranty of any kind, either expressed or implied. In no
"           event will the copyright holder be liable for any damages
"           resulting from the use of this software.
"
" TODO:     Auto generate ctags and cscope database, and easy to use
"
" NOTE:     
"
"
"Initialization {{{
if exists("g:JumpInCodeVersion")
    finish
endif

let g:JumpInCodeVersion = "1.0.0"
" Check for Vim version 600 or greater
if v:version < 600
    echo "Sorry, JumpInCode" . g:JumpInCodeVersion . "\nONLY runs with Vim 7.0 and greater."
    finish
endif
"}}}

"Initialization local variable platform independence {{{
if has ("WIN32")
    let s:executable_postfix = '.exe'
    let s:path_prefix = '\'
    let s:slash = '\'
    let s:quotation = '"'
else
    let s:executable_postfix = ''
    let s:path_prefix = $HOME . '/'
    let s:slash = '/'
    let s:quotation = ''
endif
"}}}

"Generate the shell command {{{
"Support types
function! s:GenerateRansackCmd ()
    let l:cur_full_path = getcwd ()
    if has ("WIN32")
        return '!dir ' .
                \l:cur_full_path . s:slash . '*.h ' .
                \l:cur_full_path . s:slash . '*.hpp ' .
                \l:cur_full_path . s:slash . '*.c ' .
                \l:cur_full_path . s:slash . '*.cpp ' .
                \l:cur_full_path . s:slash . '*.java ' .
                \'/b /s' .
                \' > ' . 
                \s:GetListFileFullPath ()
    else
        return '!find ' . 
                \l:cur_full_path . 
                \' -name "*.h" ' .
                \' -o -name "*.hpp"' . 
                \' -o -name "*.c"' .
                \' -o -name "*.cpp"' .
                \' -o -name "*.java"' .
                \' | tee ' . 
                \s:GetListFileFullPath  ()
    endif
endfunction
"}}}

"Generate ctags cmd {{{
function! s:GenerateCtagsCmd ()
    "tags args variable
    "!ctags -f $HOME/.rd/***/tags -R --c++-kinds=+p --fields=+iaS --extra=+q --tag-relative=no'
    let s:ctags_args = ' -f ' . s:GetCurTagsDatabaseFullPath () .
                \' -R --c++-kinds=+p --fields=+aiS --extra=+q --tag-relative=no' . 
                \' -L ' . s:GetListFileFullPath ()
    return s:ctags_exe_name . s:ctags_args
endfunction
"}}}

"Generate cscope shell command {{{
function! s:GenerateCscopeCmd ()
    "!cscope -Rbqk -f $HOME/.rd/***/cscope.out'
    return s:cscope_exe_name . ' -Rbk ' . ' -i ' . s:GetListFileFullPath ()  . ' -f ' . s:GetCurCscopeDatabaseFullPath ()
endfunction
"}}}

"Local vaiable declare {{{
"Name of file to record all tags database path infomation {{{
let s:tags_record_file_name = '.jic_tags_db_list'
"}}}
"Name of file to record all cscope database path infomation {{{
let s:cscope_db_record_file_name = '.jic_cscope_db_list'
"}}}
"The name of the file save a list of files to be read {{{
let s:list_file_name = 'file.list'
"}}}
"tags and cscope database path {{{
let s:database_path = s:path_prefix . '.rd'
"}}}
"ctags executable file name {{{
let s:ctags_exe_name   = 'ctags' . s:executable_postfix
"}}}
"cscope executable file name {{{
let s:cscope_exe_name = 'cscope' . s:executable_postfix
"}}}
"The generate tags name {{{
let s:tags_name = 'tags'
"}}}
"The generate cscope database prefix name {{{
let s:cscope_db_name = "cscope.out"
"}}}
"}}}

"Exame software environment {{{
if !executable (s:ctags_exe_name)
    echomsg 'Taglist: Exuberant ctags (http://ctags.sf.net) ' .
            \ 'not found in PATH. Plugin is not full loaded.'
endif

if !executable (s:cscope_exe_name)
    echomsg 'cscope: cscope (http://cscope.sourceforge.net/) ' .
            \ 'not found in PATH. Plugin is not full loaded.'
endif

if !executable (s:ctags_exe_name) && !executable (s:cscope_exe_name)
    finish
endif
"}}}

"Exame vim feature {{{
if !has ('cscope')
    echomsg 'cscope: vim is not support cscope feathure, ' . 
                \'please recompile vim with cscope support'
endif
"}}}

"Create direcory {{{
function! s:CreateDirectory (path)
    if !isdirectory (a:path)
        "Exam vim feature, if can make directory
        if exists ('*mkdir')
            call mkdir (a:path, 'p')
            return 'true'
        else
            echomsg 'mkdir: this version vim is not support mkdir, ' . 
                        \'please recompile vim or create director: ' . 
                        \a:path 
            return 'false'
        endif
    endif
endfunction
"}}}

"Generate the name of current directory {{{
function! s:GetCurrectDirectoryName ()
    let l:regular_expr = "^.*" . s:slash
    let l:cur_dir_name = substitute (getcwd (), l:regular_expr, "", "g")
    return l:cur_dir_name
endfunction
"}}}

"Get list file full path {{{
function! s:GetListFileFullPath ()
    return s:quotation . 
                \s:database_path . 
                \s:slash . 
                \s:GetCurrectDirectoryName () . 
                \s:slash . 
                \s:list_file_name . 
                \s:quotation
endfunction
"}}}

"Get current tags database full path {{{
function! s:GetCurTagsDatabaseFullPath ()
    return s:quotation . 
                \s:database_path . 
                \s:slash . 
                \s:GetCurrectDirectoryName () . 
                \s:slash . 
                \s:tags_name . 
                \s:quotation
endfunction
"}}}

"Get current cscope database full path {{{
function! s:GetCurCscopeDatabaseFullPath ()
    return s:quotation . 
                \s:database_path . 
                \s:slash . 
                \s:GetCurrectDirectoryName () . 
                \s:slash . 
                \s:cscope_db_name . 
                \s:quotation
endfunction
"}}}

"Get tags record file full path {{{
function! s:GetTagRecordFileFullPath ()
    return s:database_path . 
                \s:slash . 
                \s:tags_record_file_name
endfunction
"}}}

"Get cscope database record file full path {{{
function! s:GetCscopeDBRecordFileFullPath ()
    return s:database_path . 
                \s:slash . 
                \s:cscope_db_record_file_name
endfunction
"}}}

"Create tags file {{{
function! s:TagsDatabaseCreate ()
    if executable (s:ctags_exe_name)
        if s:CreateDirectory (s:database_path . s:slash . s:GetCurrectDirectoryName ()) == 'true'
            echo s:GenerateCtagsCmd ()
            call system (s:GenerateCtagsCmd ())
            "Write the new record to record file
            call WriteRecoredToFile (s:GetCurTagsDatabaseFullPath (), s:GetTagRecordFileFullPath ())
        endif
    else
        "do nothing
    endif
endfunction
"}}}

"Setup tags environment {{{
function! s:SetupTagsEnv ()
    let s:cur_tags_full_path_no_quotation = substitute (s:GetCurTagsDatabaseFullPath (), "\"", "", "g")

    if !file_readable (s:cur_tags_full_path_no_quotation)
        echo s:cur_tags_full_path_no_quotation . ' is not exist' . ' call DatabaseCreate first'
        return
    endif

    let s:cur_tags_full_path_no_quotation = substitute (s:cur_tags_full_path_no_quotation, "\\\\", "\\\\\\\\", "g")

    exec 'let $TAGS_PATH="./tags,tags,' . s:cur_tags_full_path_no_quotation . '"'
    echo ':set tags=' . $TAGS_PATH
    set tags=$TAGS_PATH
endfunction
"}}}

"Create cscope database {{{
function! s:CscopeDatabaseCreate ()
    if executable (s:cscope_exe_name)
        :cs kill -1
        if s:CreateDirectory (s:database_path . s:slash . s:GetCurrectDirectoryName ()) == 'true'
            "echo s:cscope_exe_name . s:cscope_args
            echo s:GenerateCscopeCmd ()
            call system (s:GenerateCscopeCmd ())

            call WriteRecoredToFile (s:GetCurCscopeDatabaseFullPath (), s:GetCscopeDBRecordFileFullPath ())
        endif
    else
        "do nothing
    endif
endfunction
"}}}

"Add new cscope {{{
function! s:SetupCscopeEnv ()
    let s:cur_cscope_db_full_path_no_quotation = substitute (s:GetCurCscopeDatabaseFullPath (), "\"", "", "g")

    if !file_readable (s:cur_cscope_db_full_path_no_quotation)
        echo s:cur_cscope_db_full_path_no_quotation . ' is not exist' . ' call DatabaseCreate first'
        return
    endif

    let s:cur_cscope_db_full_path_no_quotation = substitute (s:cur_cscope_db_full_path_no_quotation, "\\\\", "\\\\\\\\", "g")

    exec 'let $CSCOPE_DB="' . s:cur_cscope_db_full_path_no_quotation . '"'
    :cs kill -1
    echo ':cs add ' . $CSCOPE_DB
    cs add $CSCOPE_DB
endfunction
"}}}

"Find file from current directory recursivly save them to a list file {{{
function! s:ListFileNameToFile ()
    if s:CreateDirectory (s:database_path . s:slash . s:GetCurrectDirectoryName ()) == 'true'
        exec s:GenerateRansackCmd ()
    endif
endfunction
"}}}

"Write a new record to file {{{
function! WriteRecoredToFile (record, record_file_full_path)
    if a:record == '' 
        return 'false'
    endif
    let s:append_record = [a:record]
    if filereadable (a:record_file_full_path)
        let l:record_list = readfile (a:record_file_full_path)
    else
        let l:record_list = []
    endif
    for i in l:record_list
        if i == a:record
            return
        endif
    endfor
    call extend (l:record_list, s:append_record)
    call writefile (l:record_list, a:record_file_full_path)
endfunction
"}}}

"Read records from record file and remove invalid data {{{
function! s:ReadRecordFromFile (record_file_full_path)
    if filereadable (a:record_file_full_path)
        let l:record_list = readfile (a:record_file_full_path)
        if !empty (l:record_list)
            for i in l:record_list
                if !filereadable (i)
                    "Remove record from record_list
                    call filter (l:record_list, 'v:val !~ ' . "'" . i . "'")
                endi
            endfor
        endif
        "Write record back
        call writefile (l:record_list, a:record_file_full_path)
        return l:record_list
    else
        echo 'Not found any database record, please create first.'
    endif
endfunction
"}}}

"Show list window {{{
function! s:ShowListWindow (record_list, type_env)
    if a:record_list == []
        return
    endif

    let l:bname = 'jump_in_code_list_window'
    let l:winnum =  bufwinnr (l:bname)
    "If the list window is open
    if l:winnum != -1
        if winnr() != winnum
            " If not already in the window, jump to it
            exe winnum . 'wincmd w'
        endif
        "Focuse alread int the list window
        "Close window and start a new
        :q!
    endi
    
    setlocal modifiable
    " Open a new window at the bottom
    exe 'silent! botright ' . 8 . 'split ' .l:bname

    0put = a:record_list

    " Mark the buffer as scratch
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal noswapfile
    setlocal nowrap
    setlocal nobuflisted

    normal! gg
    setlocal nomodifiable

    " Create a mapping to jump to the file
    if a:type_env == 'tags'
        nnoremap <buffer><silent><CR> :call <SID>SetupTagsDatabaseEnvironment (getline('.'), 'add')<CR>
    elseif a:type_env == 'cscope'
        nnoremap <buffer><silent><CR> :call <SID>SetupCscopeDatabaseEnvironment (getline('.'), 'add')<CR>
    else
        echo 'E1003: Inernal parameter error'
        return
    endif
    nnoremap <buffer><silent><ESC> :close!<CR>
endfunction
"}}}

"Normal function to create tags and cscope databasea {{{
function! DatabaseCreate ()
    call s:ListFileNameToFile ()
    call s:CscopeDatabaseCreate ()
    call s:TagsDatabaseCreate ()
    call s:SetCurrentEnvironment ()
endfunction
"}}}

"Set current tags and cscope environment {{{
function! s:SetCurrentEnvironment ()
    call s:SetupTagsEnv ()
    call s:SetupCscopeEnv ()
endfunction
"}}}

"Set tags environment from selected {{{
function! <SID>SetupTagsDatabaseEnvironment (db_full_name, operation_type)
    let s:cur_tags_full_path_no_quotation = substitute (a:db_full_name, "\"", "", "g")

    if !file_readable (s:cur_tags_full_path_no_quotation)
        echo s:cur_tags_full_path_no_quotation . ' is not exist' . ' call DatabaseCreate first'
        return
    endif

    let s:cur_tags_full_path_no_quotation = substitute (s:cur_tags_full_path_no_quotation, "\\\\", "\\\\\\\\", "g")

    exec 'let $TAGS_PATH="./tags,tags,' . s:cur_tags_full_path_no_quotation . '"'
    echo ':set tags=' . $TAGS_PATH
    set tags=$TAGS_PATH
    :q!
endfunction
"}}}

"Set cscope database environment from selected {{{
function! <SID>SetupCscopeDatabaseEnvironment (db_full_name, operation_type)
    let l:cur_cscope_db_full_path_no_quotation = substitute (a:db_full_name, "\"", "", "g")

    if !file_readable (l:cur_cscope_db_full_path_no_quotation)
        echo l:cur_cscope_db_full_path_no_quotation . ' is not exist' . ' call DatabaseCreate first'
        return
    endif

    let l:cur_cscope_db_full_path_no_quotation = substitute (l:cur_cscope_db_full_path_no_quotation, "\\\\", "\\\\\\\\", "g")

    exec 'let $CSCOPE_DB="' . l:cur_cscope_db_full_path_no_quotation . '"'
    :cs kill -1
    echo ':cs add ' . $CSCOPE_DB
    cs add $CSCOPE_DB
    :q!
endfunction
"}}}

"Show list windows {{{
function! ShowSetupEvnironmentWindow (type_env)
    if a:type_env == 'tags' || a:type_env == 'cscope'
        if a:type_env == 'tags'
            let l:record_file_full_path = s:GetTagRecordFileFullPath ()
        endif

        if a:type_env == 'cscope'
            let l:record_file_full_path = s:GetCscopeDBRecordFileFullPath()
        endif
    else
        return
    endif

    let l:record_list = s:ReadRecordFromFile (l:record_file_full_path)
    if !empty (l:record_list)
        call s:ShowListWindow (l:record_list, a:type_env)
    else
        echo 'No database found, :h JumpInCode for help'
    endif
endfunction
"}}}

"hot key set {{{
"Show cscope setup window
:map <Leader>jsc :call ShowSetupEvnironmentWindow('cscope')<CR>
"Show tags setup window
:map <Leader>jst :call ShowSetupEvnironmentWindow('tags')<CR>
"Create ctags and cscope database
:map <Leader>jc :call DatabaseCreate ()<CR>
"}}}

"EOF
