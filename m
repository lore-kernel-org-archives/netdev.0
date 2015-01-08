From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ss: Usage filter state names, options alignment
Date: Thu,  8 Jan 2015 04:30:43 +0200
Message-ID: <1420684243-23921-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:45169 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752382AbbAHClI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 21:41:08 -0500
Received: by mail-lb0-f181.google.com with SMTP id l4so698856lbv.12
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 18:41:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 40 +++++++++++++++++++++++-----------------
 1 file changed, 23 insertions(+), 17 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 08d210a..40a6cd0 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3192,30 +3192,30 @@ static void _usage(FILE *dest)
 	fprintf(dest,
 "Usage: ss [ OPTIONS ]\n"
 "       ss [ OPTIONS ] [ FILTER ]\n"
-"   -h, --help		this message\n"
-"   -V, --version	output version information\n"
-"   -n, --numeric	don't resolve service names\n"
+"   -h, --help          this message\n"
+"   -V, --version       output version information\n"
+"   -n, --numeric       don't resolve service names\n"
 "   -r, --resolve       resolve host names\n"
-"   -a, --all		display all sockets\n"
-"   -l, --listening	display listening sockets\n"
+"   -a, --all           display all sockets\n"
+"   -l, --listening     display listening sockets\n"
 "   -o, --options       show timer information\n"
 "   -e, --extended      show detailed socket information\n"
 "   -m, --memory        show socket memory usage\n"
-"   -p, --processes	show process using socket\n"
-"   -i, --info		show internal TCP information\n"
-"   -s, --summary	show socket usage summary\n"
+"   -p, --processes     show process using socket\n"
+"   -i, --info          show internal TCP information\n"
+"   -s, --summary       show socket usage summary\n"
 "   -b, --bpf           show bpf filter socket information\n"
-"   -Z, --context	display process SELinux security contexts\n"
-"   -z, --contexts	display process and socket SELinux security contexts\n"
+"   -Z, --context       display process SELinux security contexts\n"
+"   -z, --contexts      display process and socket SELinux security contexts\n"
 "\n"
 "   -4, --ipv4          display only IP version 4 sockets\n"
 "   -6, --ipv6          display only IP version 6 sockets\n"
-"   -0, --packet	display PACKET sockets\n"
-"   -t, --tcp		display only TCP sockets\n"
-"   -u, --udp		display only UDP sockets\n"
-"   -d, --dccp		display only DCCP sockets\n"
-"   -w, --raw		display only RAW sockets\n"
-"   -x, --unix		display only Unix domain sockets\n"
+"   -0, --packet        display PACKET sockets\n"
+"   -t, --tcp           display only TCP sockets\n"
+"   -u, --udp           display only UDP sockets\n"
+"   -d, --dccp          display only DCCP sockets\n"
+"   -w, --raw           display only RAW sockets\n"
+"   -x, --unix          display only Unix domain sockets\n"
 "   -f, --family=FAMILY display sockets of type FAMILY\n"
 "\n"
 "   -A, --query=QUERY, --socket=QUERY\n"
@@ -3223,7 +3223,13 @@ static void _usage(FILE *dest)
 "\n"
 "   -D, --diag=FILE     Dump raw information about TCP sockets to FILE\n"
 "   -F, --filter=FILE   read filter information from FILE\n"
-"       FILTER := [ state TCP-STATE ] [ EXPRESSION ]\n"
+"       FILTER := [ state STATE-FILTER ] [ EXPRESSION ]\n"
+"       STATE-FILTER := {all|connected|synchronized|bucket|big|TCP-STATES}\n"
+"         TCP-STATES := {established|syn-sent|syn-recv|fin-wait-{1,2}|time-wait|closed|close-wait|last-ack|listen|closing}\n"
+"          connected := {established|syn-sent|syn-recv|fin-wait-{1,2}|time-wait|close-wait|last-ack|closing}\n"
+"       synchronized := {established|syn-recv|fin-wait-{1,2}|time-wait|close-wait|last-ack|closing}\n"
+"             bucket := {syn-recv|time-wait}\n"
+"                big := {established|syn-sent|fin-wait-{1,2}|closed|close-wait|last-ack|listen|closing}\n"
 		);
 }
 
-- 
2.1.3
