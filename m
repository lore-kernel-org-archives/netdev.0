From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/10] ixgbe: Whitespace cleanups
Date: Mon, 19 Mar 2012 14:22:35 -0700
Message-ID: <1332192158-14771-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1332192158-14771-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:57948 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755495Ab2CSVWo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 17:22:44 -0400
In-Reply-To: <1332192158-14771-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch contains several fixes for formatting in regards to whitespace.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   17 +++++++----------
 1 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index eb58f13..1d22c9f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6233,7 +6233,7 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
  *                               print link down message
  * @adapter - pointer to the adapter structure
  **/
-static void ixgbe_watchdog_link_is_down(struct ixgbe_adapter* adapter)
+static void ixgbe_watchdog_link_is_down(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -7332,8 +7332,8 @@ static void ixgbe_netpoll(struct net_device *netdev)
 	}
 	adapter->flags &= ~IXGBE_FLAG_IN_NETPOLL;
 }
-#endif
 
+#endif
 static struct rtnl_link_stats64 *ixgbe_get_stats64(struct net_device *netdev,
 						   struct rtnl_link_stats64 *stats)
 {
@@ -7418,7 +7418,6 @@ static void ixgbe_validate_rtr(struct ixgbe_adapter *adapter, u8 tc)
 	return;
 }
 
-
 /* ixgbe_setup_tc - routine to configure net_device for multiple traffic
  * classes.
  *
@@ -7438,7 +7437,8 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 
 	/* Hardware supports up to 8 traffic classes */
 	if (tc > adapter->dcb_cfg.num_tcs.pg_tcs ||
-	    (hw->mac.type == ixgbe_mac_82598EB && tc < MAX_TRAFFIC_CLASS))
+	    (hw->mac.type == ixgbe_mac_82598EB &&
+	     tc < MAX_TRAFFIC_CLASS))
 		return -EINVAL;
 
 	/* Hardware has to reinitialize queues and interrupts to
@@ -7452,7 +7452,6 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 	if (tc) {
 		netdev_set_num_tc(dev, tc);
 		adapter->last_lfc_mode = adapter->hw.fc.current_mode;
-
 		adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
 		adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
 
@@ -7460,7 +7459,6 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 			adapter->hw.fc.requested_mode = ixgbe_fc_none;
 	} else {
 		netdev_reset_tc(dev);
-
 		adapter->hw.fc.requested_mode = adapter->last_lfc_mode;
 
 		adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
@@ -7576,7 +7574,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_stop		= ixgbe_close,
 	.ndo_start_xmit		= ixgbe_xmit_frame,
 	.ndo_select_queue	= ixgbe_select_queue,
-	.ndo_set_rx_mode        = ixgbe_set_rx_mode,
+	.ndo_set_rx_mode	= ixgbe_set_rx_mode,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= ixgbe_set_mac,
 	.ndo_change_mtu		= ixgbe_change_mtu,
@@ -7587,7 +7585,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_vf_mac		= ixgbe_ndo_set_vf_mac,
 	.ndo_set_vf_vlan	= ixgbe_ndo_set_vf_vlan,
 	.ndo_set_vf_tx_rate	= ixgbe_ndo_set_vf_bw,
-	.ndo_set_vf_spoofchk    = ixgbe_ndo_set_vf_spoofchk,
+	.ndo_set_vf_spoofchk	= ixgbe_ndo_set_vf_spoofchk,
 	.ndo_get_vf_config	= ixgbe_ndo_get_vf_config,
 	.ndo_get_stats64	= ixgbe_get_stats64,
 	.ndo_setup_tc		= ixgbe_setup_tc,
@@ -7902,7 +7900,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	}
 
 	setup_timer(&adapter->service_timer, &ixgbe_service_timer,
-	            (unsigned long) adapter);
+		    (unsigned long) adapter);
 
 	INIT_WORK(&adapter->service_task, ixgbe_service_task);
 	clear_bit(__IXGBE_SERVICE_SCHED, &adapter->state);
@@ -7990,7 +7988,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	/* reset the hardware with the new settings */
 	err = hw->mac.ops.start_hw(hw);
-
 	if (err == IXGBE_ERR_EEPROM_VERSION) {
 		/* We are running on a pre-production device, log a warning */
 		e_dev_warn("This device is a pre-production adapter/LOM. "
-- 
1.7.7.6
