From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/17] ixgbevf: remove unnecessary ampersands
Date: Sun, 19 Jun 2011 17:58:26 -0700
Message-ID: <1308531518-17298-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308531518-17298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51969 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751554Ab1FTA7C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jun 2011 20:59:02 -0400
In-Reply-To: <1308531518-17298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>

Use standard format for net_device_ops (without &)

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Greg Rose <Gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbevf/ixgbevf_main.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index c1f9fa6..e3e25bd 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -3263,19 +3263,19 @@ static struct rtnl_link_stats64 *ixgbevf_get_stats(struct net_device *netdev,
 }
 
 static const struct net_device_ops ixgbe_netdev_ops = {
-	.ndo_open		= &ixgbevf_open,
-	.ndo_stop		= &ixgbevf_close,
-	.ndo_start_xmit		= &ixgbevf_xmit_frame,
-	.ndo_set_rx_mode	= &ixgbevf_set_rx_mode,
+	.ndo_open		= ixgbevf_open,
+	.ndo_stop		= ixgbevf_close,
+	.ndo_start_xmit		= ixgbevf_xmit_frame,
+	.ndo_set_rx_mode	= ixgbevf_set_rx_mode,
 	.ndo_get_stats64	= ixgbevf_get_stats,
-	.ndo_set_multicast_list	= &ixgbevf_set_rx_mode,
+	.ndo_set_multicast_list	= ixgbevf_set_rx_mode,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address	= &ixgbevf_set_mac,
-	.ndo_change_mtu		= &ixgbevf_change_mtu,
-	.ndo_tx_timeout		= &ixgbevf_tx_timeout,
-	.ndo_vlan_rx_register	= &ixgbevf_vlan_rx_register,
-	.ndo_vlan_rx_add_vid	= &ixgbevf_vlan_rx_add_vid,
-	.ndo_vlan_rx_kill_vid	= &ixgbevf_vlan_rx_kill_vid,
+	.ndo_set_mac_address	= ixgbevf_set_mac,
+	.ndo_change_mtu		= ixgbevf_change_mtu,
+	.ndo_tx_timeout		= ixgbevf_tx_timeout,
+	.ndo_vlan_rx_register	= ixgbevf_vlan_rx_register,
+	.ndo_vlan_rx_add_vid	= ixgbevf_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= ixgbevf_vlan_rx_kill_vid,
 };
 
 static void ixgbevf_assign_netdev_ops(struct net_device *dev)
-- 
1.7.5.4

