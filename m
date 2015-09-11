From: Arthur Gautier <baloo@gandi.net>
Subject: [PATCH] ip link: missing options in bond usage
Date: Fri, 11 Sep 2015 12:48:28 +0000
Message-ID: <1441975708-16726-1-git-send-email-baloo@gandi.net>
Cc: Arthur Gautier <baloo@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:47452 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751677AbbIKMxo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2015 08:53:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Arthur Gautier <baloo@gandi.net>
---
 ip/iplink_bond.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iplink_bond.c b/ip/iplink_bond.c
index 9d96cfeee88b..cb2f045a5a27 100644
--- a/ip/iplink_bond.c
+++ b/ip/iplink_bond.c
@@ -145,7 +145,7 @@ static void print_explain(FILE *f)
 		"ARP_ALL_TARGETS := any|all\n"
 		"PRIMARY_RESELECT := always|better|failure\n"
 		"FAIL_OVER_MAC := none|active|follow\n"
-		"XMIT_HASH_POLICY := layer2|layer2+3|layer3+4\n"
+		"XMIT_HASH_POLICY := layer2|layer2+3|layer3+4|encap2+3|encap3+4\n"
 		"LACP_RATE := slow|fast\n"
 		"AD_SELECT := stable|bandwidth|count\n"
 	);
-- 
2.5.1
