From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 3/6] ip: update mand pages and usage() for 'ip mroute'
Date: Thu, 13 Dec 2012 14:42:51 +0100
Message-ID: <1355406174-10586-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1355406174-10586-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40567 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753489Ab2LMNpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 08:45:18 -0500
In-Reply-To: <1355406174-10586-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sync with the current code.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ipmroute.c        |  2 ++
 man/man8/ip-mroute.8 | 14 +++++++++++---
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/ip/ipmroute.c b/ip/ipmroute.c
index defcfc5..345576d 100644
--- a/ip/ipmroute.c
+++ b/ip/ipmroute.c
@@ -36,6 +36,8 @@ static void usage(void) __attribute__((noreturn));
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip mroute show [ [ to ] PREFIX ] [ from PREFIX ] [ iif DEVICE ]\n");
+	fprintf(stderr, "                      [ table TABLE_ID ]\n");
+	fprintf(stderr, "TABLE_ID := [ local | main | default | all | NUMBER ]\n");
 #if 0
 	fprintf(stderr, "Usage: ip mroute [ add | del ] DESTINATION from SOURCE [ iif DEVICE ] [ oif DEVICE ]\n");
 #endif
diff --git a/man/man8/ip-mroute.8 b/man/man8/ip-mroute.8
index 98aab88..870df5e 100644
--- a/man/man8/ip-mroute.8
+++ b/man/man8/ip-mroute.8
@@ -1,4 +1,4 @@
-.TH IP\-MROUTE 8 "20 Dec 2011" "iproute2" "Linux"
+.TH IP\-MROUTE 8 "13 Dec 2012" "iproute2" "Linux"
 .SH "NAME"
 ip-mroute \- multicast routing cache management
 .SH "SYNOPSIS"
@@ -6,12 +6,15 @@ ip-mroute \- multicast routing cache management
 .ad l
 .in +8
 .ti -8
-.BR "ip mroute show" " ["
+.BR "ip " " [ ip-OPTIONS ] " "mroute show" " [ [ "
+.BR " to " " ] "
 .IR PREFIX " ] [ "
 .B  from
 .IR PREFIX " ] [ "
 .B  iif
-.IR DEVICE " ]"
+.IR DEVICE " ] [ "
+.B table
+.IR TABLE_ID " ] "
 
 .SH DESCRIPTION
 .B mroute
@@ -42,6 +45,11 @@ the interface on which multicast packets are received.
 .BI from " PREFIX"
 the prefix selecting the IP source addresses of the multicast route.
 
+.TP
+.BI table " TABLE_ID"
+the table id selecting the multicast table. It can be
+.BR local ", " main ", " default ", " all " or a number."
+
 .SH SEE ALSO
 .br
 .BR ip (8)
-- 
1.8.0.1
