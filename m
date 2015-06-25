From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: Correct state 'listen' to 'listening' in
 docs and command help
Date: Wed, 24 Jun 2015 23:28:28 -0400
Message-ID: <20150624232828.7f05225c@uryu.home.lan>
References: <001001d0a328$01f70690$05e513b0$@cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Brian Dyson" <brian.dyson@cox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:34593 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbbFYD2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 23:28:31 -0400
Received: by qkeo142 with SMTP id o142so32318345qke.1
        for <netdev@vger.kernel.org>; Wed, 24 Jun 2015 20:28:31 -0700 (PDT)
In-Reply-To: <001001d0a328$01f70690$05e513b0$@cox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 9 Jun 2015 19:49:01 -0700
"Brian Dyson" <brian.dyson@cox.net> wrote:

> Minor change to correct states in ss command documentation and command line
> help.
> The correct state term is 'listening' not 'listen' (see definition of
> sstate_namel in misc/ss.c).
> 
> Signed-off-by: Brian Dyson <brian.dyson@cox.net>
> ---
>  doc/ss.sgml   | 4 ++--
>  man/man8/ss.8 | 4 ++--
>  misc/ss.c     | 4 ++--
>  3 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/doc/ss.sgml b/doc/ss.sgml
> index 3024b57..de168f7 100644
> --- a/doc/ss.sgml
> +++ b/doc/ss.sgml
> @@ -371,10 +371,10 @@ Available identifiers are:
>  <itemize>
>  <item> All standard TCP states: <tt/established/, <tt/syn-sent/,
>  <tt/syn-recv/, <tt/fin-wait-1/, <tt/fin-wait-2/, <tt/time-wait/,
> -<tt/closed/, <tt/close-wait/, <tt/last-ack/, <tt/listen/ and <tt/closing/.
> +<tt/closed/, <tt/close-wait/, <tt/last-ack/, <tt/listening/ and
> <tt/closing/.
> 
>  <item><tt/all/ - for all the states
> -<item><tt/connected/ - all the states except for <tt/listen/ and
> <tt/closed/
> +<item><tt/connected/ - all the states except for <tt/listening/ and
> <tt/closed/
>  <item><tt/synchronized/ - all the <tt/connected/ states except for
>  <tt/syn-sent/
>  <item><tt/bucket/ - states, which are maintained as minisockets, i.e.
> diff --git a/man/man8/ss.8 b/man/man8/ss.8
> index b7fbaef..4978eff 100644
> --- a/man/man8/ss.8
> +++ b/man/man8/ss.8
> @@ -142,14 +142,14 @@ Available identifiers are:
> 
>  All standard TCP states:
>  .BR established ", " syn-sent ", " syn-recv ", " fin-wait-1 ", " fin-wait-2
> ", " time-wait ", " closed ", " close-wait ", " last-ack ", "
> -.BR  listen " and " closing.
> +.BR  listening " and " closing.
> 
>  .B all
>  - for all the states
> 
>  .B connected
>  - all the states except for
> -.BR listen " and " closed
> +.BR listening " and " closed
> 
>  .B synchronized
>  - all the
> diff --git a/misc/ss.c b/misc/ss.c
> index 347e3a1..3a0d524 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -3411,11 +3411,11 @@ static void _usage(FILE *dest)
>  "   -F, --filter=FILE   read filter information from FILE\n"
>  "       FILTER := [ state STATE-FILTER ] [ EXPRESSION ]\n"
>  "       STATE-FILTER :=
> {all|connected|synchronized|bucket|big|TCP-STATES}\n"
> -"         TCP-STATES :=
> {established|syn-sent|syn-recv|fin-wait-{1,2}|time-wait|closed|close-wait|la
> st-ack|listen|closing}\n"
> +"         TCP-STATES :=
> {established|syn-sent|syn-recv|fin-wait-{1,2}|time-wait|closed|close-wait|la
> st-ack|listening|closing}\n"
>  "          connected :=
> {established|syn-sent|syn-recv|fin-wait-{1,2}|time-wait|close-wait|last-ack|
> closing}\n"
>  "       synchronized :=
> {established|syn-recv|fin-wait-{1,2}|time-wait|close-wait|last-ack|closing}\
> n"
>  "             bucket := {syn-recv|time-wait}\n"
> -"                big :=
> {established|syn-sent|fin-wait-{1,2}|closed|close-wait|last-ack|listen|closi
> ng}\n"
> +"                big :=
> {established|syn-sent|fin-wait-{1,2}|closed|close-wait|last-ack|listening|cl
> osing}\n"
>                 );
>  }

The patch has been corrupted by linewrapping in your mailer and therefore
can not be applied. Please figure out how to send a patch that does not
cause extra line breaks.
