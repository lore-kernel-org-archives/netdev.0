From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 1/2] vxlan: fix help and man text
Date: Thu, 14 Jan 2016 18:10:19 +0100
Message-ID: <1452791420-10771-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Thomas Faivre <thomas.faivre@6wind.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:42626 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754344AbcANRLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 12:11:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Faivre <thomas.faivre@6wind.com>

Options 'group' and 'remote' cannot take 'any' as value but 'local' can.

Signed-off-by: Thomas Faivre <thomas.faivre@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/iplink_vxlan.c     | 2 +-
 man/man8/ip-link.8.in | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index aa4d5198d78d..ede8482439d5 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -23,7 +23,7 @@
 
 static void print_explain(FILE *f)
 {
-	fprintf(f, "Usage: ... vxlan id VNI [ { group | remote } ADDR ] [ local ADDR ]\n");
+	fprintf(f, "Usage: ... vxlan id VNI [ { group | remote } IP_ADDRESS ] [ local ADDR ]\n");
 	fprintf(f, "                 [ ttl TTL ] [ tos TOS ] [ dev PHYS_DEV ]\n");
 	fprintf(f, "                 [ dstport PORT ] [ srcport MIN MAX ]\n");
 	fprintf(f, "                 [ [no]learning ] [ [no]proxy ] [ [no]rsc ]\n");
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index ac6f4813a329..a3d90f796a67 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -391,7 +391,8 @@ the following additional arguments are supported:
 .RB " ] [ { " group " | " remote " } "
 .I IPADDR
 .R " ] [ "
-.BI local " IPADDR "
+.B local
+.RI "{ "IPADDR " | "any " } "
 .R " ] [ "
 .BI ttl " TTL "
 .R " ] [ "
-- 
2.4.2
