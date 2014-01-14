From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 4/6] i40e: whitespace fixes
Date: Tue, 14 Jan 2014 00:49:52 -0800
Message-ID: <1389689394-22369-5-git-send-email-aaron.f.brown@intel.com>
References: <1389689394-22369-1-git-send-email-aaron.f.brown@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:37134 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751362AbaANIts (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 03:49:48 -0500
In-Reply-To: <1389689394-22369-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Fix some whitespace and comment issues.

Change-ID: I1587599e50ce66fd389965720e86f9e331d86643
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h            | 1 -
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h | 4 ++--
 drivers/net/ethernet/intel/i40e/i40e_common.c     | 1 -
 drivers/net/ethernet/intel/i40e/i40e_main.c       | 3 +--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c       | 4 ++--
 5 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index c05984d..91b0052 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -93,7 +93,6 @@
 #define I40E_CURRENT_NVM_VERSION_HI 0x2
 #define I40E_CURRENT_NVM_VERSION_LO 0x30
 
-
 /* magic for getting defines into strings */
 #define STRINGIFY(foo)  #foo
 #define XSTRINGIFY(bar) STRINGIFY(bar)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index c009eb4..be61a47 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -1195,8 +1195,8 @@ struct i40e_aqc_add_remove_cloud_filters_element_data {
 		} v4;
 		struct {
 			u8 data[16];
-			} v6;
-		} ipaddr;
+		} v6;
+	} ipaddr;
 	__le16 flags;
 #define I40E_AQC_ADD_CLOUD_FILTER_SHIFT                 0
 #define I40E_AQC_ADD_CLOUD_FILTER_MASK                  (0x3F << \
diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 0b5a75c..aedc71b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -162,7 +162,6 @@ i40e_status i40e_aq_queue_shutdown(struct i40e_hw *hw,
 	return status;
 }
 
-
 /**
  * i40e_init_shared_code - Initialize the shared code
  * @hw: pointer to hardware structure
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 14e4f4a..6a5d4ca 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -356,7 +356,6 @@ static struct rtnl_link_stats64 *i40e_get_netdev_stats_struct(
 	struct rtnl_link_stats64 *vsi_stats = i40e_get_vsi_stats_struct(vsi);
 	int i;
 
-
 	if (test_bit(__I40E_DOWN, &vsi->state))
 		return stats;
 
@@ -3603,7 +3602,7 @@ static int i40e_vsi_get_bw_info(struct i40e_vsi *vsi)
 
 	/* Get the VSI level BW configuration per TC */
 	aq_ret = i40e_aq_query_vsi_ets_sla_config(hw, vsi->seid, &bw_ets_config,
-					          NULL);
+						  NULL);
 	if (aq_ret) {
 		dev_info(&pf->pdev->dev,
 			 "couldn't get pf vsi ets bw config, err %d, aq_err %d\n",
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index a089ac1..f57a8f8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -977,8 +977,8 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 
 	rx_desc = I40E_RX_DESC(rx_ring, i);
 	qword = le64_to_cpu(rx_desc->wb.qword1.status_error_len);
-	rx_status = (qword & I40E_RXD_QW1_STATUS_MASK)
-				>> I40E_RXD_QW1_STATUS_SHIFT;
+	rx_status = (qword & I40E_RXD_QW1_STATUS_MASK) >>
+		    I40E_RXD_QW1_STATUS_SHIFT;
 
 	while (rx_status & (1 << I40E_RX_DESC_STATUS_DD_SHIFT)) {
 		union i40e_rx_desc *next_rxd;
-- 
1.8.5.GIT
