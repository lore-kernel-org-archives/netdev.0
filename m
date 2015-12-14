From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] fm10k: whitespace cleanups
Date: Sun, 13 Dec 2015 16:27:43 -0800
Message-ID: <1450052867-36654-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450052867-36654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:41661 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752047AbbLNA1w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 19:27:52 -0500
In-Reply-To: <1450052867-36654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c     | 1 +
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     | 5 ++---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c      | 1 +
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c      | 1 +
 7 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 109e211..3b857f4 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -127,7 +127,7 @@ static const struct fm10k_stats fm10k_gstrings_mbx_stats[] = {
 #define FM10K_MBX_STATS_LEN ARRAY_SIZE(fm10k_gstrings_mbx_stats)
 
 #define FM10K_QUEUE_STATS_LEN(_n) \
-	( (_n) * 2 * (sizeof(struct fm10k_queue_stats) / sizeof(u64)))
+	((_n) * 2 * (sizeof(struct fm10k_queue_stats) / sizeof(u64)))
 
 #define FM10K_STATIC_STATS_LEN (FM10K_GLOBAL_STATS_LEN + \
 				FM10K_NETDEV_STATS_LEN + \
@@ -322,6 +322,7 @@ static void fm10k_get_ethtool_stats(struct net_device *netdev,
 	if ((interface->flags & FM10K_FLAG_DEBUG_STATS) && iov_data) {
 		for (i = 0; i < iov_data->num_vfs; i++) {
 			struct fm10k_vf_info *vf_info;
+
 			vf_info = &iov_data->vf_info[i];
 
 			/* skip stats if we don't have a vf info */
@@ -1020,7 +1021,6 @@ static int fm10k_set_priv_flags(struct net_device *netdev, u32 priv_flags)
 	return 0;
 }
 
-
 static u32 fm10k_get_reta_size(struct net_device __always_unused *netdev)
 {
 	return FM10K_RETA_SIZE * FM10K_RETA_ENTRIES_PER_REG;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index d8b7800..75ff109 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -917,7 +917,7 @@ static u8 fm10k_tx_desc_flags(struct sk_buff *skb, u32 tx_flags)
 	/* set timestamping bits */
 	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
 	    likely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
-			desc_flags |= FM10K_TXD_FLAG_TIME;
+		desc_flags |= FM10K_TXD_FLAG_TIME;
 
 	/* set checksum offload bits */
 	desc_flags |= FM10K_SET_FLAG(tx_flags, FM10K_TX_FLAGS_CSUM,
@@ -1462,7 +1462,7 @@ static int fm10k_poll(struct napi_struct *napi, int budget)
 	 * allow the budget to go below 1 because we'll exit polling
 	 */
 	if (q_vector->rx.count > 1)
-		per_ring_budget = max(budget/q_vector->rx.count, 1);
+		per_ring_budget = max(budget / q_vector->rx.count, 1);
 	else
 		per_ring_budget = budget;
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
index 2bce474..b31bbc2 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
@@ -2140,6 +2140,7 @@ s32 fm10k_sm_mbx_init(struct fm10k_hw *hw, struct fm10k_mbx_info *mbx,
 {
 	mbx->mbx_reg = FM10K_GMBX;
 	mbx->mbmem_reg = FM10K_MBMEM_PF(0);
+
 	/* start out in closed state */
 	mbx->state = FM10K_STATE_CLOSED;
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index c60b553..c9c94c4 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -608,7 +608,7 @@ static netdev_tx_t fm10k_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 	unsigned int r_idx = skb->queue_mapping;
 	int err;
 
-	if ((skb->protocol ==  htons(ETH_P_8021Q)) &&
+	if ((skb->protocol == htons(ETH_P_8021Q)) &&
 	    !skb_vlan_tag_present(skb)) {
 		/* FM10K only supports hardware tagging, any tags in frame
 		 * are considered 2nd level or "outer" tags
@@ -705,7 +705,7 @@ static void fm10k_tx_timeout(struct net_device *netdev)
 	} else {
 		netif_info(interface, drv, netdev,
 			   "Fake Tx hang detected with timeout of %d seconds\n",
-			   netdev->watchdog_timeo/HZ);
+			   netdev->watchdog_timeo / HZ);
 
 		/* fake Tx hang - increase the kernel timeout */
 		if (netdev->watchdog_timeo < TX_TIMEO_LIMIT)
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 694c648..84424a8 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -919,7 +919,7 @@ void fm10k_netpoll(struct net_device *netdev)
 #endif
 #define FM10K_ERR_MSG(type) case (type): error = #type; break
 static void fm10k_handle_fault(struct fm10k_intfc *interface, int type,
-			      struct fm10k_fault *fault)
+			       struct fm10k_fault *fault)
 {
 	struct pci_dev *pdev = interface->pdev;
 	struct fm10k_hw *hw = &interface->hw;
@@ -1890,8 +1890,7 @@ static void fm10k_slot_warn(struct fm10k_intfc *interface)
  * The OS initialization, configuring of the interface private structure,
  * and a hardware reset occur.
  **/
-static int fm10k_probe(struct pci_dev *pdev,
-		       const struct pci_device_id *ent)
+static int fm10k_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
 	struct fm10k_intfc *interface;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 750518d..523fe70 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -414,6 +414,7 @@ static s32 fm10k_update_xcast_mode_pf(struct fm10k_hw *hw, u16 glort, u8 mode)
 
 	if (mode > FM10K_XCAST_MODE_NONE)
 		return FM10K_ERR_PARAM;
+
 	/* if glort is not valid return error */
 	if (!fm10k_glort_valid_pf(hw, glort))
 		return FM10K_ERR_PARAM;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
index 2af697d..5445c0f 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
@@ -442,6 +442,7 @@ static s32 fm10k_update_xcast_mode_vf(struct fm10k_hw *hw, u16 glort, u8 mode)
 
 	if (mode > FM10K_XCAST_MODE_NONE)
 		return FM10K_ERR_PARAM;
+
 	/* generate message requesting to change xcast mode */
 	fm10k_tlv_msg_init(msg, FM10K_VF_MSG_ID_LPORT_STATE);
 	fm10k_tlv_attr_put_u8(msg, FM10K_LPORT_STATE_MSG_XCAST_MODE, mode);
-- 
2.5.0
