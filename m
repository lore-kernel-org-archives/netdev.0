From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH 3/6] bonding:fix checkpatch warnings braces {}
Date: Fri, 14 Feb 2014 17:15:14 +0800
Message-ID: <1392369317-8072-4-git-send-email-wangyufen@huawei.com>
References: <1392369317-8072-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:64757 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbaBNJQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 04:16:21 -0500
In-Reply-To: <1392369317-8072-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Yufen <wangyufen@huawei.com>


Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 drivers/net/bonding/bond_alb.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index af5ea21..a1d4e7a 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -93,9 +93,8 @@ static inline u8 _simple_hash(const u8 *hash_start, int hash_size)
 	int i;
 	u8 hash = 0;
 
-	for (i = 0; i < hash_size; i++) {
+	for (i = 0; i < hash_size; i++)
 		hash ^= hash_start[i];
-	}
 
 	return hash;
 }
@@ -190,9 +189,8 @@ static int tlb_initialize(struct bonding *bond)
 
 	bond_info->tx_hashtbl = new_hashtbl;
 
-	for (i = 0; i < TLB_HASH_TABLE_SIZE; i++) {
+	for (i = 0; i < TLB_HASH_TABLE_SIZE; i++)
 		tlb_init_table_entry(&bond_info->tx_hashtbl[i], 0);
-	}
 
 	_unlock_tx_hashtbl_bh(bond);
 
@@ -264,9 +262,8 @@ static struct slave *__tlb_choose_channel(struct bonding *bond, u32 hash_index,
 			hash_table[hash_index].next = next_index;
 			hash_table[hash_index].prev = TLB_NULL_INDEX;
 
-			if (next_index != TLB_NULL_INDEX) {
+			if (next_index != TLB_NULL_INDEX)
 				hash_table[next_index].prev = hash_index;
-			}
 
 			slave_info->head = hash_index;
 			slave_info->load +=
@@ -274,9 +271,8 @@ static struct slave *__tlb_choose_channel(struct bonding *bond, u32 hash_index,
 		}
 	}
 
-	if (assigned_slave) {
+	if (assigned_slave)
 		hash_table[hash_index].tx_bytes += skb_len;
-	}
 
 	return assigned_slave;
 }
@@ -451,9 +447,8 @@ static struct slave *__rlb_next_rx_slave(struct bonding *bond)
  */
 static void rlb_teach_disabled_mac_on_primary(struct bonding *bond, u8 addr[])
 {
-	if (!bond->curr_active_slave) {
+	if (!bond->curr_active_slave)
 		return;
-	}
 
 	if (!bond->alb_info.primary_is_promisc) {
 		if (!dev_set_promiscuity(bond->curr_active_slave->dev, 1))
@@ -513,9 +508,8 @@ static void rlb_clear_slave(struct bonding *bond, struct slave *slave)
 
 	write_lock_bh(&bond->curr_slave_lock);
 
-	if (slave != bond->curr_active_slave) {
+	if (slave != bond->curr_active_slave)
 		rlb_teach_disabled_mac_on_primary(bond, slave->dev->dev_addr);
-	}
 
 	write_unlock_bh(&bond->curr_slave_lock);
 }
-- 
1.7.12
