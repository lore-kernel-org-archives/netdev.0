From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 4/6] ip: update man pages for 'ip link'
Date: Thu, 13 Dec 2012 14:42:52 +0100
Message-ID: <1355406174-10586-4-git-send-email-nicolas.dichtel@6wind.com>
References: <1355406174-10586-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40565 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753303Ab2LMNpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 08:45:18 -0500
In-Reply-To: <1355406174-10586-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now 'ip link' supports ipip, sit and ip6tnl.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 man/man8/ip-link.8.in | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 43c4ac6..8d2a6f9 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -1,4 +1,4 @@
-.TH IP\-LINK 8 "20 Dec 2011" "iproute2" "Linux"
+.TH IP\-LINK 8 "13 Dec 2012" "iproute2" "Linux"
 .SH "NAME"
 ip-link \- network device configuration
 .SH "SYNOPSIS"
@@ -59,7 +59,10 @@ ip-link \- network device configuration
 .BR vcan " | "
 .BR veth " | "
 .BR vlan " | "
-.BR vxlan " ]"
+.BR vxlan " |"
+.BR ip6tnl " |"
+.BR ipip " |"
+.BR sit " ]"
 
 .ti -8
 .BI "ip link delete " DEVICE
@@ -174,6 +177,15 @@ Link types:
 .sp
 .BR vxlan
 - Virtual eXtended LAN
+.sp
+.BR ip6tnl
+- Virtual tunnel interface IPv4|IPv6 over IPv6
+.sp
+.BR ipip
+- Virtual tunnel interface IPv4 over IPv4
+.sp
+.BR sit
+- Virtual tunnel interface IPv6 over IPv4
 .in -8
 
 .TP
-- 
1.8.0.1
