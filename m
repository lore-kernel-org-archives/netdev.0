From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 2/4] qlge: Change naming on vlan API.
Date: Fri, 30 Oct 2009 15:13:34 -0700
Message-ID: <1256940816-27540-3-git-send-email-ron.mercer@qlogic.com>
References: <1256940816-27540-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:33628 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932929AbZJ3WTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 18:19:51 -0400
In-Reply-To: <1256940816-27540-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change name on vlan_rx_add, kill, register to match other driver API.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 9e4d3dc..01f78a9 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1985,7 +1985,7 @@ static int ql_napi_poll_msix(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
-static void ql_vlan_rx_register(struct net_device *ndev, struct vlan_group *grp)
+static void qlge_vlan_rx_register(struct net_device *ndev, struct vlan_group *grp)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
 
@@ -2001,7 +2001,7 @@ static void ql_vlan_rx_register(struct net_device *ndev, struct vlan_group *grp)
 	}
 }
 
-static void ql_vlan_rx_add_vid(struct net_device *ndev, u16 vid)
+static void qlge_vlan_rx_add_vid(struct net_device *ndev, u16 vid)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
 	u32 enable_bit = MAC_ADDR_E;
@@ -2017,7 +2017,7 @@ static void ql_vlan_rx_add_vid(struct net_device *ndev, u16 vid)
 	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 }
 
-static void ql_vlan_rx_kill_vid(struct net_device *ndev, u16 vid)
+static void qlge_vlan_rx_kill_vid(struct net_device *ndev, u16 vid)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
 	u32 enable_bit = 0;
@@ -4191,9 +4191,9 @@ static const struct net_device_ops qlge_netdev_ops = {
 	.ndo_set_mac_address	= qlge_set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_tx_timeout		= qlge_tx_timeout,
-	.ndo_vlan_rx_register	= ql_vlan_rx_register,
-	.ndo_vlan_rx_add_vid	= ql_vlan_rx_add_vid,
-	.ndo_vlan_rx_kill_vid	= ql_vlan_rx_kill_vid,
+	.ndo_vlan_rx_register	= qlge_vlan_rx_register,
+	.ndo_vlan_rx_add_vid	= qlge_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= qlge_vlan_rx_kill_vid,
 };
 
 static int __devinit qlge_probe(struct pci_dev *pdev,
-- 
1.6.0.2

