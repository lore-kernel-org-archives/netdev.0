From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] iproute2: update ip-link.8 for geneve tunnels
Date: Fri, 22 May 2015 14:46:46 -0400
Message-ID: <1432320406-28121-1-git-send-email-linville@tuxdriver.com>
References: <20150521151901.7c4f6b2e@urahara>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45580 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756510AbbEVSrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 14:47:10 -0400
In-Reply-To: <20150521151901.7c4f6b2e@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 man/man8/ip-link.8.in | 26 +++++++++++++++++++++++++-
 1 file changed, 25 insertions(+), 1 deletion(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 714aab488d4a..8cac246d7296 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -76,7 +76,8 @@ ip-link \- network device configuration
 .BR vti " |"
 .BR nlmon " |"
 .BR ipvlan " |"
-.BR lowpan " ]"
+.BR lowpan " |"
+.BR geneve " ]"
 
 .ti -8
 .BR "ip link delete " {
@@ -247,6 +248,9 @@ Link types:
 .sp
 .BR lowpan
 - Interface for 6LoWPAN (IPv6) over IEEE 802.15.4 / Bluetooth
+.sp
+.BR geneve
+- GEneric NEtwork Virtualization Encapsulation
 .in -8
 
 .TP
@@ -594,6 +598,26 @@ the following additional arguments are supported:
 .BI  mode " MODE "
 - specifies the mode (datagram or connected) to use.
 
+.TP
+GENEVE Type Support
+For a link of type
+.I GENEVE
+the following additional arguments are supported:
+
+.BI "ip link add " DEVICE
+.BI type " geneve " id " ID " remote " IPADDR"
+
+.in +8
+.sp
+.BI  id " VNI "
+- specifies the Virtual Network Identifer to use.
+
+.sp
+.BI remote " IPADDR"
+- specifies the unicast destination IP address to use in outgoing packets.
+
+.in -8
+
 .SS ip link delete - delete virtual link
 
 .TP
-- 
2.1.0
