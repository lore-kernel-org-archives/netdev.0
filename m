From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net] bonding: trivial: style fixes
Date: Wed,  3 Feb 2016 02:02:32 +0000
Message-ID: <1454464952-25807-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: j.vosburgh@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:4113 "EHLO
	cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754270AbcBCCBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 21:01:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

remove some redudant brackets, use sizeof(*) instead of sizeof(struct x).

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/bonding/bond_main.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index fb4c52f..bcc7b19 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -928,11 +928,10 @@ void bond_select_active_slave(struct bonding *bond)
 		if (!rv)
 			return;
 
-		if (netif_carrier_ok(bond->dev)) {
+		if (netif_carrier_ok(bond->dev))
 			netdev_info(bond->dev, "first active interface up!\n");
-		} else {
+		else
 			netdev_info(bond->dev, "now running without any active interface!\n");
-		}
 	}
 }
 
@@ -1178,9 +1177,8 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
 		}
 	}
 
-	if (bond_should_deliver_exact_match(skb, slave, bond)) {
+	if (bond_should_deliver_exact_match(skb, slave, bond))
 		return RX_HANDLER_EXACT;
-	}
 
 	skb->dev = bond->dev;
 
@@ -1241,7 +1239,7 @@ static struct slave *bond_alloc_slave(struct bonding *bond)
 {
 	struct slave *slave = NULL;
 
-	slave = kzalloc(sizeof(struct slave), GFP_KERNEL);
+	slave = kzalloc(sizeof(*slave), GFP_KERNEL);
 	if (!slave)
 		return NULL;
 
-- 
1.8.3.1
