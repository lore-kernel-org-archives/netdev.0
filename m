From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH 6/6] bonding:fix checkpatch warnings braces {}
Date: Fri, 14 Feb 2014 17:15:17 +0800
Message-ID: <1392369317-8072-7-git-send-email-wangyufen@huawei.com>
References: <1392369317-8072-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:64330 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752256AbaBNJPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 04:15:42 -0500
In-Reply-To: <1392369317-8072-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Yufen <wangyufen@huawei.com>


Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 drivers/net/bonding/bond_alb.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index e7a4600..a212860 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1627,9 +1627,8 @@ void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char
 
 	if (link == BOND_LINK_DOWN) {
 		tlb_clear_slave(bond, slave, 0);
-		if (bond->alb_info.rlb_enabled) {
+		if (bond->alb_info.rlb_enabled)
 			rlb_clear_slave(bond, slave);
-		}
 	} else if (link == BOND_LINK_UP) {
 		/* order a rebalance ASAP */
 		bond_info->tx_rebalance_counter = BOND_TLB_REBALANCE_TICKS;
@@ -1741,14 +1740,12 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 	struct slave *swap_slave;
 	int res;
 
-	if (!is_valid_ether_addr(sa->sa_data)) {
+	if (!is_valid_ether_addr(sa->sa_data))
 		return -EADDRNOTAVAIL;
-	}
 
 	res = alb_set_mac_address(bond, addr);
-	if (res) {
+	if (res)
 		return res;
-	}
 
 	memcpy(bond_dev->dev_addr, sa->sa_data, bond_dev->addr_len);
 
@@ -1756,9 +1753,8 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 	 * Otherwise we'll need to pass the new address to it and handle
 	 * duplications.
 	 */
-	if (!bond->curr_active_slave) {
+	if (!bond->curr_active_slave)
 		return 0;
-	}
 
 	swap_slave = bond_slave_has_mac(bond, bond_dev->dev_addr);
 
@@ -1782,8 +1778,7 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 
 void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
 {
-	if (bond->alb_info.rlb_enabled) {
+	if (bond->alb_info.rlb_enabled)
 		rlb_clear_vlan(bond, vlan_id);
-	}
 }
 
-- 
1.7.12
