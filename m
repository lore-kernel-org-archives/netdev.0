From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH 2/6] bonding:fix checkpatch errors comments and space
Date: Fri, 14 Feb 2014 17:15:13 +0800
Message-ID: <1392369317-8072-3-git-send-email-wangyufen@huawei.com>
References: <1392369317-8072-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:64458 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376AbaBNJPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 04:15:48 -0500
In-Reply-To: <1392369317-8072-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Yufen <wangyufen@huawei.com>


Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 drivers/net/bonding/bond_alb.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index b3b26b0..af5ea21 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -610,10 +610,10 @@ static void rlb_req_update_slave_clients(struct bonding *bond, struct slave *sla
 		}
 	}
 
-	// update the team's flag only after the whole iteration
+	/* update the team's flag only after the whole iteration */
 	if (ntt) {
 		bond_info->rx_ntt = 1;
-		//fasten the change
+		/* fasten the change */
 		bond_info->rlb_update_retry_counter = RLB_UPDATE_RETRY;
 	}
 
@@ -771,7 +771,7 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
 		*/
 		tx_slave = rlb_choose_channel(skb, bond);
 		if (tx_slave) {
-			memcpy(arp->mac_src,tx_slave->dev->dev_addr, ETH_ALEN);
+			memcpy(arp->mac_src, tx_slave->dev->dev_addr, ETH_ALEN);
 		}
 		pr_debug("Server sent ARP Reply packet\n");
 	} else if (arp->op_code == htons(ARPOP_REQUEST)) {
-- 
1.7.12
