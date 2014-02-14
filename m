From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH 5/6] bonding:fix checkpatch warnings braces {}
Date: Fri, 14 Feb 2014 17:15:16 +0800
Message-ID: <1392369317-8072-6-git-send-email-wangyufen@huawei.com>
References: <1392369317-8072-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:64477 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428AbaBNJPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 04:15:49 -0500
In-Reply-To: <1392369317-8072-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Yufen <wangyufen@huawei.com>


Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 drivers/net/bonding/bond_alb.c | 20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index cde39f0..e7a4600 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1343,9 +1343,8 @@ void bond_alb_deinitialize(struct bonding *bond)
 
 	tlb_deinitialize(bond);
 
-	if (bond_info->rlb_enabled) {
+	if (bond_info->rlb_enabled)
 		rlb_deinitialize(bond);
-	}
 }
 
 int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
@@ -1429,9 +1428,8 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 		break;
 	case ETH_P_ARP:
 		do_tx_balance = 0;
-		if (bond_info->rlb_enabled) {
+		if (bond_info->rlb_enabled)
 			tx_slave = rlb_arp_xmit(skb, bond);
-		}
 		break;
 	default:
 		do_tx_balance = 0;
@@ -1565,11 +1563,10 @@ void bond_alb_monitor(struct work_struct *work)
 				--bond_info->rlb_update_delay_counter;
 			} else {
 				rlb_update_rx_clients(bond);
-				if (bond_info->rlb_update_retry_counter) {
+				if (bond_info->rlb_update_retry_counter)
 					--bond_info->rlb_update_retry_counter;
-				} else {
+				else
 					bond_info->rx_ntt = 0;
-				}
 			}
 		}
 	}
@@ -1586,23 +1583,20 @@ int bond_alb_init_slave(struct bonding *bond, struct slave *slave)
 	int res;
 
 	res = alb_set_slave_mac_addr(slave, slave->perm_hwaddr);
-	if (res) {
+	if (res)
 		return res;
-	}
 
 	res = alb_handle_addr_collision_on_attach(bond, slave);
-	if (res) {
+	if (res)
 		return res;
-	}
 
 	tlb_init_slave(slave);
 
 	/* order a rebalance ASAP */
 	bond->alb_info.tx_rebalance_counter = BOND_TLB_REBALANCE_TICKS;
 
-	if (bond->alb_info.rlb_enabled) {
+	if (bond->alb_info.rlb_enabled)
 		bond->alb_info.rlb_rebalance = 1;
-	}
 
 	return 0;
 }
-- 
1.7.12
