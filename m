From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH 1/6] bonding:fix checkpatch errors with foo* bar|foo * bar
Date: Fri, 14 Feb 2014 17:15:12 +0800
Message-ID: <1392369317-8072-2-git-send-email-wangyufen@huawei.com>
References: <1392369317-8072-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:64275 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752233AbaBNJPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 04:15:40 -0500
In-Reply-To: <1392369317-8072-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Yufen <wangyufen@huawei.com>


Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 drivers/net/bonding/bond_alb.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index a2c4747..b3b26b0 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -329,7 +329,7 @@ static void rlb_update_entry_from_arp(struct bonding *bond, struct arp_pkt *arp)
 
 	_lock_rx_hashtbl_bh(bond);
 
-	hash_index = _simple_hash((u8*)&(arp->ip_src), sizeof(arp->ip_src));
+	hash_index = _simple_hash((u8 *)&(arp->ip_src), sizeof(arp->ip_src));
 	client_info = &(bond_info->rx_hashtbl[hash_index]);
 
 	if ((client_info->assigned) &&
@@ -923,7 +923,7 @@ static void rlb_src_link(struct bonding *bond, u32 ip_src_hash, u32 ip_dst_hash)
 static void rlb_purge_src_ip(struct bonding *bond, struct arp_pkt *arp)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
-	u32 ip_src_hash = _simple_hash((u8*)&(arp->ip_src), sizeof(arp->ip_src));
+	u32 ip_src_hash = _simple_hash((u8 *)&(arp->ip_src), sizeof(arp->ip_src));
 	u32 index;
 
 	_lock_rx_hashtbl_bh(bond);
@@ -1436,7 +1436,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 			break;
 		}
 
-		hash_start = (char*)eth_data->h_dest;
+		hash_start = (char *)eth_data->h_dest;
 		hash_size = ETH_ALEN;
 		break;
 	case ETH_P_ARP:
-- 
1.7.12
