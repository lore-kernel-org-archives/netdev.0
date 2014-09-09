From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 1/2] ip/vxlan: add a help for ageing and maxaddress options
Date: Tue,  9 Sep 2014 16:55:10 +0200
Message-ID: <1410274511-17709-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:53430 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932656AbaIIOzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 10:55:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These options were missing in usage and man pages.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/iplink_vxlan.c     |  1 +
 man/man8/ip-link.8.in | 12 ++++++++++++
 2 files changed, 13 insertions(+)

diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 53c50accde89..8aa25cd5fe52 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -28,6 +28,7 @@ static void explain(void)
 	fprintf(stderr, "                 [ dstport PORT ] [ srcport MIN MAX ]\n");
 	fprintf(stderr, "                 [ [no]learning ] [ [no]proxy ] [ [no]rsc ]\n");
 	fprintf(stderr, "                 [ [no]l2miss ] [ [no]l3miss ]\n");
+	fprintf(stderr, "                 [ ageing SECONDS ] [ maxaddress NUMBER ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: VNI := 0-16777215\n");
 	fprintf(stderr, "       ADDR := { IP_ADDRESS | any }\n");
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 29d12fb2c773..383917a63669 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -262,6 +262,10 @@ the following additional arguments are supported:
 .I "[no]l2miss "
 .R " ] [ "
 .I "[no]l3miss "
+.R " ] [ "
+.BI ageing " SECONDS "
+.R " ] [ "
+.BI maxaddress " NUMBER "
 .R " ]"
 
 .in +8
@@ -326,6 +330,14 @@ are entered into the VXLAN device forwarding database.
 .I [no]l3miss
 - specifies if netlink IP ADDR miss notifications are generated.
 
+.sp
+.BI ageing " SECONDS"
+- specifies the lifetime in seconds of FDB entries learnt by the kernel.
+
+.sp
+.BI maxaddress " NUMBER"
+- specifies the maximum number of FDB entries.
+
 .in -8
 
 .TP
-- 
2.1.0
