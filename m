From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40e: I40E_FLAG_MQ_ENABLED is not used
Date: Sun,  5 Jan 2014 02:47:05 -0800
Message-ID: <1388918827-13430-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <Neerav.Parikh@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55938 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751245AbaAEKrR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 05:47:17 -0500
In-Reply-To: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <Neerav.Parikh@intel.com>

Remove references to I40E_FLAG_MQ_ENABLED from the code
as it doesn't seem to be used anywhere.

Change-Id: I4c89fb65b2cdd26fbb0c58fccbbb4b03f0e5f1b3
Signed-off-by: Neerav Parikh <Neerav.Parikh@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 27 +++++++++++++--------------
 drivers/net/ethernet/intel/i40e/i40e_main.c |  6 +-----
 2 files changed, 14 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 7de6e01..73f6faf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -230,20 +230,19 @@ struct i40e_pf {
 #define I40E_FLAG_RX_1BUF_ENABLED              (u64)(1 << 4)
 #define I40E_FLAG_RX_PS_ENABLED                (u64)(1 << 5)
 #define I40E_FLAG_RSS_ENABLED                  (u64)(1 << 6)
-#define I40E_FLAG_MQ_ENABLED                   (u64)(1 << 7)
-#define I40E_FLAG_VMDQ_ENABLED                 (u64)(1 << 8)
-#define I40E_FLAG_FDIR_REQUIRES_REINIT         (u64)(1 << 9)
-#define I40E_FLAG_NEED_LINK_UPDATE             (u64)(1 << 10)
-#define I40E_FLAG_IN_NETPOLL                   (u64)(1 << 13)
-#define I40E_FLAG_16BYTE_RX_DESC_ENABLED       (u64)(1 << 14)
-#define I40E_FLAG_CLEAN_ADMINQ                 (u64)(1 << 15)
-#define I40E_FLAG_FILTER_SYNC                  (u64)(1 << 16)
-#define I40E_FLAG_PROCESS_MDD_EVENT            (u64)(1 << 18)
-#define I40E_FLAG_PROCESS_VFLR_EVENT           (u64)(1 << 19)
-#define I40E_FLAG_SRIOV_ENABLED                (u64)(1 << 20)
-#define I40E_FLAG_DCB_ENABLED                  (u64)(1 << 21)
-#define I40E_FLAG_FDIR_ENABLED                 (u64)(1 << 22)
-#define I40E_FLAG_FDIR_ATR_ENABLED             (u64)(1 << 23)
+#define I40E_FLAG_VMDQ_ENABLED                 (u64)(1 << 7)
+#define I40E_FLAG_FDIR_REQUIRES_REINIT         (u64)(1 << 8)
+#define I40E_FLAG_NEED_LINK_UPDATE             (u64)(1 << 9)
+#define I40E_FLAG_IN_NETPOLL                   (u64)(1 << 12)
+#define I40E_FLAG_16BYTE_RX_DESC_ENABLED       (u64)(1 << 13)
+#define I40E_FLAG_CLEAN_ADMINQ                 (u64)(1 << 14)
+#define I40E_FLAG_FILTER_SYNC                  (u64)(1 << 15)
+#define I40E_FLAG_PROCESS_MDD_EVENT            (u64)(1 << 17)
+#define I40E_FLAG_PROCESS_VFLR_EVENT           (u64)(1 << 18)
+#define I40E_FLAG_SRIOV_ENABLED                (u64)(1 << 19)
+#define I40E_FLAG_DCB_ENABLED                  (u64)(1 << 20)
+#define I40E_FLAG_FDIR_ENABLED                 (u64)(1 << 21)
+#define I40E_FLAG_FDIR_ATR_ENABLED             (u64)(1 << 22)
 #define I40E_FLAG_MFP_ENABLED                  (u64)(1 << 26)
 #ifdef CONFIG_I40E_VXLAN
 #define I40E_FLAG_VXLAN_FILTER_SYNC            (u64)(1 << 27)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 13df3fa..4fcd55c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5643,7 +5643,6 @@ static void i40e_init_interrupt_scheme(struct i40e_pf *pf)
 		if (err) {
 			pf->flags &= ~(I40E_FLAG_MSIX_ENABLED	   |
 					I40E_FLAG_RSS_ENABLED	   |
-					I40E_FLAG_MQ_ENABLED	   |
 					I40E_FLAG_DCB_ENABLED	   |
 					I40E_FLAG_SRIOV_ENABLED	   |
 					I40E_FLAG_FDIR_ENABLED	   |
@@ -5826,7 +5825,6 @@ static int i40e_sw_init(struct i40e_pf *pf)
 		    I40E_FLAG_MSI_ENABLED     |
 		    I40E_FLAG_MSIX_ENABLED    |
 		    I40E_FLAG_RX_PS_ENABLED   |
-		    I40E_FLAG_MQ_ENABLED      |
 		    I40E_FLAG_RX_1BUF_ENABLED;
 
 	/* Depending on PF configurations, it is possible that the RSS
@@ -7349,8 +7347,7 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
 	 */
 	queues_left = pf->hw.func_caps.num_tx_qp;
 
-	if   (!((pf->flags & I40E_FLAG_MSIX_ENABLED)		 &&
-		(pf->flags & I40E_FLAG_MQ_ENABLED))		 ||
+	if   (!(pf->flags & I40E_FLAG_MSIX_ENABLED) ||
 		!(pf->flags & (I40E_FLAG_RSS_ENABLED |
 		I40E_FLAG_FDIR_ENABLED | I40E_FLAG_DCB_ENABLED)) ||
 		(queues_left == 1)) {
@@ -7361,7 +7358,6 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
 
 		/* make sure all the fancies are disabled */
 		pf->flags &= ~(I40E_FLAG_RSS_ENABLED       |
-				I40E_FLAG_MQ_ENABLED	   |
 				I40E_FLAG_FDIR_ENABLED	   |
 				I40E_FLAG_FDIR_ATR_ENABLED |
 				I40E_FLAG_DCB_ENABLED	   |
-- 
1.8.3.1
