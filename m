From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH 4/6] bonding:fix checkpatch warnings braces {}
Date: Fri, 14 Feb 2014 17:15:15 +0800
Message-ID: <1392369317-8072-5-git-send-email-wangyufen@huawei.com>
References: <1392369317-8072-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:64055 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbaBNJPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 04:15:30 -0500
In-Reply-To: <1392369317-8072-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Yufen <wangyufen@huawei.com>


Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 drivers/net/bonding/bond_alb.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index a1d4e7a..cde39f0 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -518,9 +518,8 @@ static void rlb_update_client(struct rlb_client_info *client_info)
 {
 	int i;
 
-	if (!client_info->slave) {
+	if (!client_info->slave)
 		return;
-	}
 
 	for (i = 0; i < RLB_ARP_BURST_SIZE; i++) {
 		struct sk_buff *skb;
@@ -568,9 +567,8 @@ static void rlb_update_rx_clients(struct bonding *bond)
 		client_info = &(bond_info->rx_hashtbl[hash_index]);
 		if (client_info->ntt) {
 			rlb_update_client(client_info);
-			if (bond_info->rlb_update_retry_counter == 0) {
+			if (bond_info->rlb_update_retry_counter == 0)
 				client_info->ntt = 0;
-			}
 		}
 	}
 
@@ -764,9 +762,8 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
 		* rx channel
 		*/
 		tx_slave = rlb_choose_channel(skb, bond);
-		if (tx_slave) {
+		if (tx_slave)
 			memcpy(arp->mac_src, tx_slave->dev->dev_addr, ETH_ALEN);
-		}
 		pr_debug("Server sent ARP Reply packet\n");
 	} else if (arp->op_code == htons(ARPOP_REQUEST)) {
 		/* Create an entry in the rx_hashtbl for this client as a
@@ -818,9 +815,8 @@ static void rlb_rebalance(struct bonding *bond)
 	}
 
 	/* update the team's flag only after the whole iteration */
-	if (ntt) {
+	if (ntt)
 		bond_info->rx_ntt = 1;
-	}
 	_unlock_rx_hashtbl_bh(bond);
 }
 
@@ -951,9 +947,8 @@ static int rlb_initialize(struct bonding *bond)
 
 	bond_info->rx_hashtbl_used_head = RLB_NULL_INDEX;
 
-	for (i = 0; i < RLB_HASH_TABLE_SIZE; i++) {
+	for (i = 0; i < RLB_HASH_TABLE_SIZE; i++)
 		rlb_init_table_entry(bond_info->rx_hashtbl + i);
-	}
 
 	_unlock_rx_hashtbl_bh(bond);
 
@@ -1324,9 +1319,8 @@ int bond_alb_initialize(struct bonding *bond, int rlb_enabled)
 	int res;
 
 	res = tlb_initialize(bond);
-	if (res) {
+	if (res)
 		return res;
-	}
 
 	if (rlb_enabled) {
 		bond->alb_info.rlb_enabled = 1;
-- 
1.7.12
