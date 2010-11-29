From: Petr Sabata <psabata@redhat.com>
Subject: [PATCH] ss(8) improvements by Jiri Popelka <jpopelka@redhat.com>
Date: Mon, 29 Nov 2010 14:00:37 +0100
Message-ID: <1291035637-15274-1-git-send-email-psabata@redhat.com>
To: psabata@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10481 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753948Ab0K2NDD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Nov 2010 08:03:03 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id oATD32N2016271
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 08:03:02 -0500
Received: from beranek.brq.redhat.com (dhcp-24-167.brq.redhat.com [10.34.24.167])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id oATD2wff031395
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 08:03:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 man/man8/ss.8 |   19 +++++++++++--------
 1 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/man/man8/ss.8 b/man/man8/ss.8
index 015feb3..f261cf2 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -12,6 +12,9 @@ to
 It can display more TCP and state informations than other tools.
 
 .SH OPTIONS
+When no option is used ss displays a list of 
+open non-listening TCP sockets that have established connection.
+.TP
 These programs follow the usual GNU command line syntax, with long
 options starting with two dashes (`-').
 A summary of options is included below.
@@ -29,10 +32,10 @@ Do now try to resolve service names.
 Try to resolve numeric address/ports.
 .TP
 .B \-a, \-\-all
-Display all sockets.
+Display both listening and non-listening (for TCP this means established connections) sockets.
 .TP
 .B \-l, \-\-listening
-Display listening sockets.
+Display only listening sockets (these are omitted by default).
 .TP
 .B \-o, \-\-options
 Show timer information.
@@ -61,22 +64,22 @@ Display only IP version 4 sockets (alias for -f inet).
 Display only IP version 6 sockets (alias for -f inet6).
 .TP
 .B \-0, \-\-packet
-Display PACKET sockets.
+Display PACKET sockets (alias for -f link).
 .TP
 .B \-t, \-\-tcp
-Display only TCP sockets.
+Display TCP sockets.
 .TP
 .B \-u, \-\-udp
-Display only UDP sockets.
+Display UDP sockets.
 .TP
 .B \-d, \-\-dccp
-Display only DCCP sockets.
+Display DCCP sockets.
 .TP
 .B \-w, \-\-raw
-Display only RAW sockets.
+Display RAW sockets.
 .TP
 .B \-x, \-\-unix
-Display only Unix domain sockets.
+Display Unix domain sockets (alias for -f unix).
 .TP
 .B \-f FAMILY, \-\-family=FAMILY
 Display sockets of type FAMILY.
-- 
1.7.3.2

