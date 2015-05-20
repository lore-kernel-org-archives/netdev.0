From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2-next 2/6] man: update ip monitor page
Date: Wed, 20 May 2015 16:19:57 +0200
Message-ID: <1432131601-4641-3-git-send-email-nicolas.dichtel@6wind.com>
References: <20150509.221554.38834063932093195.davem@davemloft.net>
 <1432131601-4641-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:44031 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753565AbbETOUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 10:20:09 -0400
In-Reply-To: <1432131601-4641-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add label option.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 man/man8/ip-monitor.8 | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/man/man8/ip-monitor.8 b/man/man8/ip-monitor.8
index 9663349fe9c7..3123b4014cc2 100644
--- a/man/man8/ip-monitor.8
+++ b/man/man8/ip-monitor.8
@@ -12,6 +12,8 @@ ip-monitor, rtmon \- state monitoring
 .IR OBJECT-LIST " ] ["
 .BI file " FILENAME "
 ] [
+.BI label
+] [
 .BI dev " DEVICE "
 ]
 .sp
@@ -42,6 +44,8 @@ command is the first in the command line and then the object list follows:
 .IR OBJECT-LIST " ] ["
 .BI file " FILENAME "
 ] [
+.BI label
+] [
 .BI dev " DEVICE "
 ]
 
@@ -59,6 +63,19 @@ described in previous sections.
 
 .P
 If the
+.BI label
+option is set, a prefix is displayed before each message to
+show the family of the message. For example:
+.sp
+.in +2
+[NEIGH]10.16.0.112 dev eth0 lladdr 00:04:23:df:2f:d0 REACHABLE
+[LINK]3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default
+    link/ether 52:54:00:12:34:57 brd ff:ff:ff:ff:ff:ff
+.in -2
+.sp
+
+.P
+If the
 .BI file
 option is given, the program does not listen on RTNETLINK,
 but opens the given file, and dumps its contents. The file
@@ -97,3 +114,5 @@ option is given, the program prints only events related to this device.
 
 .SH AUTHOR
 Original Manpage by Michail Litvak <mci@owl.openwall.com>
+.br
+Manpage revised by Nicolas Dichtel <nicolas.dichtel@6wind.com>
-- 
2.2.2
