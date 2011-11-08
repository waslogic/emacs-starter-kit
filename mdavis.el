;; ENV VARIABLES
(setenv "MANPATH" (concat (getenv "MANPATH") ":/opt/local/share/man:/usr/share/man:/usr/local/share/man:/usr/X11/man"))
(setenv "INFOPATH" (concat (getenv "INFOPATH") ":/opt/local/share/info"))
(setenv "PATH" (concat (getenv "PATH") ":/opt/local/bin:/opt/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin"))
;; "/sw/bin:/sw/sbin:/usr/local/ImageMagick/bin:/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin:/usr/local/mysql/bin:/usr/local/oracle:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin:/usr/local/git/bin:/usr/X11R6/bin")
(setq exec-path (append exec-path (split-string (getenv "PATH") ":" t)))
(setenv "ORACLE_HOME" "/opt/oracle/instantclient")
(setenv "DYLD_LIBRARY_PATH" "/opt/oracle/instantclient")
(setenv "TNS_ADMIN" "/opt/oracle/instantclient")

;; MISC VARIABLES
(setq mac-command-modifier 'meta)
(setq visible-bell nil)
(setq x-select-enable-clipboard t)
(setq confirm-kill-emacs 'y-or-n-p)
(setq eval-expression-print-length nil)
;; (setq max-lisp-eval-depth 1000) ; only needed if I run into a recursion depth problem
(set-face-background 'region "blue3")
(set-face-background 'highlight "#003300")
(setq bookmark-default-file "~/.emacs.d/bookmarks"
      bookmark-save-flag 1)
(setq org-log-done t)
(setq org-startup-indented t)
(setq-default fill-column 140)

;; FRAMES
(defvar my-frame-alist
  '((foreground-color . "green")
    (background-color . "black")
    (vertical-scroll-bars . right)
    (menu-bar-lines . 0)
    (tool-bar-lines . 0)
    (cursor-type . bar)
    (cursor-color . "Red")
    (left-fringe . 0)
    (right-fringe . 0))
  "DRYing up an aspect of my config")
(setq initial-frame-alist (append '((top . 0) (left . 0) (width . 240) (height . 100)) my-frame-alist))
(setq default-frame-alist my-frame-alist)

;; HOOKS
(add-hook 'write-file-functions 'delete-trailing-whitespace)
(add-hook 'ruby-mode-hook 'hs-minor-mode)
(add-hook 'javascript-mode-hook 'hs-minor-mode)
(add-hook 'espresso-mode-hook 'hs-minor-mode)
(add-hook 'org-mode-hook 'hl-line-mode)
(add-hook 'graphviz-dot-mode-hook 'hl-line-mode)

;; REQUIRES
(add-to-list 'load-path (concat dotfiles-dir "/vendor"))
(if (boundp 'erlang-root-dir) (require 'erlang-start))
(if (executable-find "growlnotify") (require 'growl))
(require 'rspec-mode) ; TODO: use growl to notify on finish
(require 'ruby-hacks) ; NOTE: really only interested in the hide-show overlay stuff

;; KEY BINDINGS
(global-set-key "\C-x\t" 'fixup-whitespace)
(global-set-key "\C-z" 'advertised-undo)
(global-set-key "\M-z" 'advertised-undo)
(global-set-key "\C-cc" 'comment-or-uncomment-region-or-line)
(global-set-key [C-kp-delete] 'kill-word)
(global-set-key [kp-delete] 'delete-char)
(global-set-key [home] 'move-beginning-of-line)
(global-set-key [end] 'move-end-of-line)
;;; NOTE: some modes seem to be overwriting these... how do I stop them?
(global-set-key [C-left] 'backward-word)
(global-set-key [C-right] 'forward-word)
;;; NOTE: this doesn't seem to be working as well as I'd
;;; like... perhaps (global-set-key [M-right] 'windmove-right) etc
;;; would be better?
(windmove-default-keybindings 'meta)

;; SHELL
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
(eval-after-load 'shell
  '(progn
     (define-key shell-mode-map [up] 'comint-previous-input)
     (define-key shell-mode-map [down] 'comint-next-input)
     (define-key shell-mode-map [C-up] 'previous-line)
     (define-key shell-mode-map [C-down] 'next-line)
     (setq comint-input-ignoredups t)
     (setq comint-move-point-for-output t)
     (setq comint-scroll-to-bottom-on-input t)))

;; HIDE-SHOW
(eval-after-load 'hideshow
  '(progn
     (define-key hs-minor-mode-map (kbd "C-c <left>") 'hs-hide-block)
     (define-key hs-minor-mode-map (kbd "C-c <right>") 'hs-show-block)
     (define-key hs-minor-mode-map (kbd "C-c <down>") 'hs-hide-level)
     (define-key hs-minor-mode-map (kbd "C-c <up>") 'hs-show-all)))

(setq hs-special-modes-alist
      (append '((ruby-mode "class\\|module\\|def\\|if\\|unless\\|case\\|while\\|until\\|for\\|begin\\|do" "end" "#" ruby-forward-sexp)) hs-special-modes-alist))

(setq hs-special-modes-alist
      (append '((javascript-mode "{" "}" "/[*/]" nil hs-c-like-adjust-block-beginning)) hs-special-modes-alist))

;; NXHTML
(eval-after-load 'nxhtml
  '(progn
     (define-key nxhtml-mode-map [return] 'reindent-then-newline-and-indent)
     (define-key nxhtml-mode-map "\C-j" 'reindent-then-newline-and-indent)))

;; ESPRESSO
(eval-after-load 'espresso
  '(progn
     (define-key espresso-mode-map [return] 'reindent-then-newline-and-indent)
     (define-key espresso-mode-map "\C-j" 'reindent-then-newline-and-indent)))

;; FUNCTIONS
;;; from Aquamac's osxkeys.el, licensed under the GPL
(unless (fboundp 'comment-or-uncomment-region-or-line)
  (defun comment-or-uncomment-region-or-line ()
    "Like `comment-or-uncomment-region', but acts on the current line if mark is not active."
    (interactive)
    (if mark-active
        (call-interactively (function comment-or-uncomment-region))
      (save-excursion
        (beginning-of-line)
        (set-mark (point))
        (end-of-line)
        (call-interactively (function comment-or-uncomment-region))))))

(defun uniquify-buffer-lines ()
  (interactive)
  (while
      (progn
        (goto-char (point-min))
        (re-search-forward "^\\(.*\\)\n\\(\\(.*\n\\)*\\)\\1$" nil t))
    (if (= 0 (length (match-string 1)))
        (replace-match "\\2")
      (replace-match "\\1\n\\2"))))

;;; SlickCopy -- http://www.emacswiki.org/emacs/SlickCopy
(defadvice kill-ring-save (before slick-copy activate compile)
  "When called interactively with no active region, copy a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (message "Copied line")
     (list (line-beginning-position)
           (line-beginning-position 2)))))

(defadvice kill-region (before slick-cut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))

(defadvice yank (before slick-copy activate)
  "Position point when yanking lines."
  (let ((kill (current-kill 0 t)))
    (when (eq ?\n (elt kill (1- (length kill))))
      (beginning-of-line))))

;;; attempting to get back a little bit of the vim love
(defun vim-df (arg char)
  "wrapping zap-to-char in order to get vim's df functionality"
  (interactive "p\nc ")
  (zap-to-char arg char))

(defun vim-dF (arg char)
  "wrapping zap-to-char in order to get vim's dF functionality"
  (interactive "p\nc ")
  (zap-to-char (- arg) char))

(defun vim-dt (arg char)
  "wrapping zap-to-char in order to get vim's dt functionality"
  (interactive "p\nc ")
  (progn
    (zap-to-char arg char)
    (insert char)
    (backward-char)))

(defun vim-dT (arg char)
  "wrapping zap-to-char in order to get vim's dT functionality"
  (interactive "p\nc ")
  (progn
    (zap-to-char (- arg) char)
    (insert char)))

(global-set-key "\C-cf" 'vim-df)
(global-set-key "\C-cF" 'vim-dF)
(global-set-key "\C-ct" 'vim-dt)
(global-set-key "\C-cT" 'vim-dT)
