From: "Brian Dyson" <brian.dyson@cox.net>
Subject: [PATCH iproute2] ss: Correct state 'listen' to 'listening' in docs and command help
Date: Tue, 9 Jun 2015 19:49:01 -0700
Message-ID: <001001d0a328$01f70690$05e513b0$@cox.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fed1rmfepi106.cox.net ([68.230.241.137]:38517 "EHLO
	fed1rmfepi106.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbbFJD77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 23:59:59 -0400
Received: from fed1rmimpo109 ([68.230.241.158]) by fed1rmfepo203.cox.net
          (InterMail vM.8.01.05.15 201-2260-151-145-20131218) with ESMTP
          id <20150610024916.YXWR11247.fed1rmfepo203.cox.net@fed1rmimpo109>
          for <netdev@vger.kernel.org>; Tue, 9 Jun 2015 22:49:16 -0400
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor change to correct states in ss command documentation and command line
help.
The correct state term is 'listening' not 'listen' (see definition of
sstate_namel in misc/ss.c).

Signed-off-by: Brian Dyson <brian.dyson@cox.net>
---
 doc/ss.sgml   | 4 ++--
 man/man8/ss.8 | 4 ++--
 misc/ss.c     | 4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/doc/ss.sgml b/doc/ss.sgml
index 3024b57..de168f7 100644
--- a/doc/ss.sgml
+++ b/doc/ss.sgml
@@ -371,10 +371,10 @@ Available identifiers are:
 <itemize>
 <item> All standard TCP states: <tt/established/, <tt/syn-sent/,
 <tt/syn-recv/, <tt/fin-wait-1/, <tt/fin-wait-2/, <tt/time-wait/,
-<tt/closed/, <tt/close-wait/, <tt/last-ack/, <tt/listen/ and <tt/closing/.
+<tt/closed/, <tt/close-wait/, <tt/last-ack/, <tt/listening/ and
<tt/closing/.

 <item><tt/all/ - for all the states
-<item><tt/connected/ - all the states except for <tt/listen/ and
<tt/closed/
+<item><tt/connected/ - all the states except for <tt/listening/ and
<tt/closed/
 <item><tt/synchronized/ - all the <tt/connected/ states except for
 <tt/syn-sent/
 <item><tt/bucket/ - states, which are maintained as minisockets, i.e.
diff --git a/man/man8/ss.8 b/man/man8/ss.8
index b7fbaef..4978eff 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -142,14 +142,14 @@ Available identifiers are:

 All standard TCP states:
 .BR established ", " syn-sent ", " syn-recv ", " fin-wait-1 ", " fin-wait-2
", " time-wait ", " closed ", " close-wait ", " last-ack ", "
-.BR  listen " and " closing.
+.BR  listening " and " closing.

 .B all
 - for all the states

 .B connected
 - all the states except for
-.BR listen " and " closed
+.BR listening " and " closed

 .B synchronized
 - all the
diff --git a/misc/ss.c b/misc/ss.c
index 347e3a1..3a0d524 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3411,11 +3411,11 @@ static void _usage(FILE *dest)
 "   -F, --filter=FILE   read filter information from FILE\n"
 "       FILTER := [ state STATE-FILTER ] [ EXPRESSION ]\n"
 "       STATE-FILTER :=
{all|connected|synchronized|bucket|big|TCP-STATES}\n"
-"         TCP-STATES :=
{established|syn-sent|syn-recv|fin-wait-{1,2}|time-wait|closed|close-wait|la
st-ack|listen|closing}\n"
+"         TCP-STATES :=
{established|syn-sent|syn-recv|fin-wait-{1,2}|time-wait|closed|close-wait|la
st-ack|listening|closing}\n"
 "          connected :=
{established|syn-sent|syn-recv|fin-wait-{1,2}|time-wait|close-wait|last-ack|
closing}\n"
 "       synchronized :=
{established|syn-recv|fin-wait-{1,2}|time-wait|close-wait|last-ack|closing}\
n"
 "             bucket := {syn-recv|time-wait}\n"
-"                big :=
{established|syn-sent|fin-wait-{1,2}|closed|close-wait|last-ack|listen|closi
ng}\n"
+"                big :=
{established|syn-sent|fin-wait-{1,2}|closed|close-wait|last-ack|listening|cl
osing}\n"
                );
 }
