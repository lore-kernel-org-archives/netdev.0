From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] man: ip, ip-link: Fix ip option location
Date: Mon, 30 May 2016 20:46:27 +0200
Message-ID: <1464633987-2977-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:44902 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161869AbcE3Sql (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 May 2016 14:46:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch drops the redundant description of some of ip's options in
ip-link.8's description of the 'show' subcommand, preserving the
description of -iec (but appending it to the list in ip.8 with minor
fixes).

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-link.8.in | 21 ---------------------
 man/man8/ip.8         |  4 ++++
 2 files changed, 4 insertions(+), 21 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 984fb2eb0d63a..d3881e55d73c0 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -1119,27 +1119,6 @@ specifies the master device which enslaves devices to show.
 .I TYPE
 specifies the type of devices to show.
 
-.TP
-The show command has additional formatting options:
-
-.RS
-.TP
-.BR "\-s" , " \-stats", " \-statistics"
-output more statistics about packet usage.
-
-.TP
-.BR "\-d", " \-details"
-output more detailed information.
-
-.TP
-.BR "\-h", " \-human", " \-human-readable"
-output statistics with human readable values number followed by suffix
-
-.TP
-.BR "\-iec"
-print human readable rates in IEC units (ie. 1K = 1024).
-.RE
-
 .SS  ip link help - display help
 
 .PP
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index aa2bc68c81ab6..f11fc0b9cf444 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -201,6 +201,10 @@ but use shorter format.
 .BR "\-rc" , " \-rcvbuf" <SIZE>
 Set the netlink socket receive buffer size, defaults to 1MB.
 
+.TP
+.BR "\-iec"
+print human readable rates in IEC units (e.g. 1Ki = 1024).
+
 .SH IP - COMMAND SYNTAX
 
 .SS
-- 
2.8.2
