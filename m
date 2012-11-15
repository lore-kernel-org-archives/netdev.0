From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/9] ixgbevf: White space and comments clean up
Date: Thu, 15 Nov 2012 06:39:45 -0800
Message-ID: <1352990387-3872-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1352990387-3872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5538 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1768068Ab2KOOjz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 09:39:55 -0500
In-Reply-To: <1352990387-3872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 19 ++++++-------------
 1 file changed, 6 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 592fe99..57ae5cd 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -121,7 +121,6 @@ static inline void ixgbevf_release_rx_desc(struct ixgbe_hw *hw,
  * @direction: 0 for Rx, 1 for Tx, -1 for other causes
  * @queue: queue to map the corresponding interrupt to
  * @msix_vector: the vector to map to the corresponding queue
- *
  */
 static void ixgbevf_set_ivar(struct ixgbevf_adapter *adapter, s8 direction,
 			     u8 queue, u8 msix_vector)
@@ -380,7 +379,6 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_adapter *adapter,
 no_buffers:
 	if (rx_ring->next_to_use != i) {
 		rx_ring->next_to_use = i;
-
 		ixgbevf_release_rx_desc(&adapter->hw, rx_ring, i);
 	}
 }
@@ -765,7 +763,6 @@ static irqreturn_t ixgbevf_msix_other(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-
 /**
  * ixgbevf_msix_clean_rings - single unshared vector rx clean (all queues)
  * @irq: unused
@@ -1224,12 +1221,13 @@ static int ixgbevf_write_uc_addr_list(struct net_device *netdev)
 }
 
 /**
- * ixgbevf_set_rx_mode - Multicast set
+ * ixgbevf_set_rx_mode - Multicast and unicast set
  * @netdev: network interface device structure
  *
  * The set_rx_method entry point is called whenever the multicast address
- * list or the network interface flags are updated.  This routine is
- * responsible for configuring the hardware for proper multicast mode.
+ * list, unicast address list or the network interface flags are updated.
+ * This routine is responsible for configuring the hardware for proper
+ * multicast mode and configuring requested unicast filters.
  **/
 static void ixgbevf_set_rx_mode(struct net_device *netdev)
 {
@@ -1588,7 +1586,6 @@ static void ixgbevf_clean_tx_ring(struct ixgbevf_adapter *adapter,
 		return;
 
 	/* Free all the Tx ring sk_buffs */
-
 	for (i = 0; i < tx_ring->count; i++) {
 		tx_buffer_info = &tx_ring->tx_buffer_info[i];
 		ixgbevf_unmap_and_free_tx_resource(tx_ring, tx_buffer_info);
@@ -1757,6 +1754,7 @@ static int ixgbevf_acquire_msix_vectors(struct ixgbevf_adapter *adapter,
 		 */
 		adapter->num_msix_vectors = vectors;
 	}
+
 	return err;
 }
 
@@ -2053,7 +2051,7 @@ static int __devinit ixgbevf_sw_init(struct ixgbevf_adapter *adapter)
 			goto out;
 		}
 		memcpy(adapter->netdev->dev_addr, adapter->hw.mac.addr,
-			adapter->netdev->addr_len);
+		       adapter->netdev->addr_len);
 	}
 
 	/* lock to protect mailbox accesses */
@@ -2198,7 +2196,6 @@ static void ixgbevf_watchdog_task(struct work_struct *work)
 	 * Always check the link on the watchdog because we have
 	 * no LSC interrupt
 	 */
-
 	spin_lock_bh(&adapter->mbx_lock);
 
 	need_reset = hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
@@ -2704,9 +2701,6 @@ static int ixgbevf_tso(struct ixgbevf_ring *tx_ring,
 static bool ixgbevf_tx_csum(struct ixgbevf_ring *tx_ring,
 			    struct sk_buff *skb, u32 tx_flags)
 {
-
-
-
 	u32 vlan_macip_lens = 0;
 	u32 mss_l4len_idx = 0;
 	u32 type_tucmd = 0;
@@ -2896,7 +2890,6 @@ static void ixgbevf_tx_queue(struct ixgbevf_ring *tx_ring, int tx_flags,
 		olinfo_status |= (1 << IXGBE_ADVTXD_IDX_SHIFT);
 		if (tx_flags & IXGBE_TX_FLAGS_IPV4)
 			olinfo_status |= IXGBE_ADVTXD_POPTS_IXSM;
-
 	}
 
 	/*
-- 
1.7.11.7
