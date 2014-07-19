From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH iproute2]  iplink: macvtap: fix man page
Date: Sat, 19 Jul 2014 12:00:25 +0300
Message-ID: <1405760425-7816-1-git-send-email-ramirose@gmail.com>
Cc: Rami Rosen <ramirose@gmail.com>
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:45086 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756350AbaGSJAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2014 05:00:37 -0400
Received: by mail-we0-f179.google.com with SMTP id u57so5416051wes.38
        for <netdev@vger.kernel.org>; Sat, 19 Jul 2014 02:00:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds description about macvtap to ip-link.8 man page.  

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 man/man8/ip-link.8.in | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index f89785c..6df0f8f 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -60,6 +60,7 @@ ip-link \- network device configuration
 .BR ifb " | "
 .BR ipoib " |"
 .BR macvlan  " | "
+.BR macvtap  " | "
 .BR vcan " | "
 .BR veth " | "
 .BR vlan " | "
@@ -179,6 +180,9 @@ Link types:
 .B macvlan
 - Virtual interface base on link layer address (MAC)
 .sp
+.B macvtap
+- Virtual interface based on link layer address (MAC) and TAP.
+.sp
 .B vcan
 - Virtual Controller Area Network interface
 .sp
-- 
1.9.0
