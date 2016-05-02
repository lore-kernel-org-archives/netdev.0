From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] i40evf: make use of BIT() macro to avoid signed left shift
Date: Sun,  1 May 2016 17:06:20 -0700
Message-ID: <1462147581-135254-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462147581-135254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:1786 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752668AbcEBAGg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 May 2016 20:06:36 -0400
In-Reply-To: <1462147581-135254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    | 44 +++++++++++-----------
 1 file changed, 22 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index 180ae57..3114dcf 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -78,17 +78,17 @@ struct i40e_aq_desc {
 #define I40E_AQ_FLAG_EI_SHIFT	14
 #define I40E_AQ_FLAG_FE_SHIFT	15
 
-#define I40E_AQ_FLAG_DD		(1 << I40E_AQ_FLAG_DD_SHIFT)  /* 0x1    */
-#define I40E_AQ_FLAG_CMP	(1 << I40E_AQ_FLAG_CMP_SHIFT) /* 0x2    */
-#define I40E_AQ_FLAG_ERR	(1 << I40E_AQ_FLAG_ERR_SHIFT) /* 0x4    */
-#define I40E_AQ_FLAG_VFE	(1 << I40E_AQ_FLAG_VFE_SHIFT) /* 0x8    */
-#define I40E_AQ_FLAG_LB		(1 << I40E_AQ_FLAG_LB_SHIFT)  /* 0x200  */
-#define I40E_AQ_FLAG_RD		(1 << I40E_AQ_FLAG_RD_SHIFT)  /* 0x400  */
-#define I40E_AQ_FLAG_VFC	(1 << I40E_AQ_FLAG_VFC_SHIFT) /* 0x800  */
-#define I40E_AQ_FLAG_BUF	(1 << I40E_AQ_FLAG_BUF_SHIFT) /* 0x1000 */
-#define I40E_AQ_FLAG_SI		(1 << I40E_AQ_FLAG_SI_SHIFT)  /* 0x2000 */
-#define I40E_AQ_FLAG_EI		(1 << I40E_AQ_FLAG_EI_SHIFT)  /* 0x4000 */
-#define I40E_AQ_FLAG_FE		(1 << I40E_AQ_FLAG_FE_SHIFT)  /* 0x8000 */
+#define I40E_AQ_FLAG_DD		BIT(I40E_AQ_FLAG_DD_SHIFT)  /* 0x1    */
+#define I40E_AQ_FLAG_CMP	BIT(I40E_AQ_FLAG_CMP_SHIFT) /* 0x2    */
+#define I40E_AQ_FLAG_ERR	BIT(I40E_AQ_FLAG_ERR_SHIFT) /* 0x4    */
+#define I40E_AQ_FLAG_VFE	BIT(I40E_AQ_FLAG_VFE_SHIFT) /* 0x8    */
+#define I40E_AQ_FLAG_LB		BIT(I40E_AQ_FLAG_LB_SHIFT)  /* 0x200  */
+#define I40E_AQ_FLAG_RD		BIT(I40E_AQ_FLAG_RD_SHIFT)  /* 0x400  */
+#define I40E_AQ_FLAG_VFC	BIT(I40E_AQ_FLAG_VFC_SHIFT) /* 0x800  */
+#define I40E_AQ_FLAG_BUF	BIT(I40E_AQ_FLAG_BUF_SHIFT) /* 0x1000 */
+#define I40E_AQ_FLAG_SI		BIT(I40E_AQ_FLAG_SI_SHIFT)  /* 0x2000 */
+#define I40E_AQ_FLAG_EI		BIT(I40E_AQ_FLAG_EI_SHIFT)  /* 0x4000 */
+#define I40E_AQ_FLAG_FE		BIT(I40E_AQ_FLAG_FE_SHIFT)  /* 0x8000 */
 
 /* error codes */
 enum i40e_admin_queue_err {
@@ -1625,11 +1625,11 @@ enum i40e_aq_phy_type {
 
 enum i40e_aq_link_speed {
 	I40E_LINK_SPEED_UNKNOWN	= 0,
-	I40E_LINK_SPEED_100MB	= (1 << I40E_LINK_SPEED_100MB_SHIFT),
-	I40E_LINK_SPEED_1GB	= (1 << I40E_LINK_SPEED_1000MB_SHIFT),
-	I40E_LINK_SPEED_10GB	= (1 << I40E_LINK_SPEED_10GB_SHIFT),
-	I40E_LINK_SPEED_40GB	= (1 << I40E_LINK_SPEED_40GB_SHIFT),
-	I40E_LINK_SPEED_20GB	= (1 << I40E_LINK_SPEED_20GB_SHIFT)
+	I40E_LINK_SPEED_100MB	= BIT(I40E_LINK_SPEED_100MB_SHIFT),
+	I40E_LINK_SPEED_1GB	= BIT(I40E_LINK_SPEED_1000MB_SHIFT),
+	I40E_LINK_SPEED_10GB	= BIT(I40E_LINK_SPEED_10GB_SHIFT),
+	I40E_LINK_SPEED_40GB	= BIT(I40E_LINK_SPEED_40GB_SHIFT),
+	I40E_LINK_SPEED_20GB	= BIT(I40E_LINK_SPEED_20GB_SHIFT)
 };
 
 struct i40e_aqc_module_desc {
@@ -1900,9 +1900,9 @@ I40E_CHECK_CMD_LENGTH(i40e_aqc_nvm_config_write);
 /* Used for 0x0704 as well as for 0x0705 commands */
 #define I40E_AQ_ANVM_FEATURE_OR_IMMEDIATE_SHIFT		1
 #define I40E_AQ_ANVM_FEATURE_OR_IMMEDIATE_MASK \
-				(1 << I40E_AQ_ANVM_FEATURE_OR_IMMEDIATE_SHIFT)
+				BIT(I40E_AQ_ANVM_FEATURE_OR_IMMEDIATE_SHIFT)
 #define I40E_AQ_ANVM_FEATURE		0
-#define I40E_AQ_ANVM_IMMEDIATE_FIELD	(1 << FEATURE_OR_IMMEDIATE_SHIFT)
+#define I40E_AQ_ANVM_IMMEDIATE_FIELD	BIT(FEATURE_OR_IMMEDIATE_SHIFT)
 struct i40e_aqc_nvm_config_data_feature {
 	__le16 feature_id;
 #define I40E_AQ_ANVM_FEATURE_OPTION_OEM_ONLY		0x01
@@ -2171,7 +2171,7 @@ struct i40e_aqc_del_udp_tunnel_completion {
 I40E_CHECK_CMD_LENGTH(i40e_aqc_del_udp_tunnel_completion);
 
 struct i40e_aqc_get_set_rss_key {
-#define I40E_AQC_SET_RSS_KEY_VSI_VALID		(0x1 << 15)
+#define I40E_AQC_SET_RSS_KEY_VSI_VALID		BIT(15)
 #define I40E_AQC_SET_RSS_KEY_VSI_ID_SHIFT	0
 #define I40E_AQC_SET_RSS_KEY_VSI_ID_MASK	(0x3FF << \
 					I40E_AQC_SET_RSS_KEY_VSI_ID_SHIFT)
@@ -2191,14 +2191,14 @@ struct i40e_aqc_get_set_rss_key_data {
 I40E_CHECK_STRUCT_LEN(0x34, i40e_aqc_get_set_rss_key_data);
 
 struct  i40e_aqc_get_set_rss_lut {
-#define I40E_AQC_SET_RSS_LUT_VSI_VALID		(0x1 << 15)
+#define I40E_AQC_SET_RSS_LUT_VSI_VALID		BIT(15)
 #define I40E_AQC_SET_RSS_LUT_VSI_ID_SHIFT	0
 #define I40E_AQC_SET_RSS_LUT_VSI_ID_MASK	(0x3FF << \
 					I40E_AQC_SET_RSS_LUT_VSI_ID_SHIFT)
 	__le16	vsi_id;
 #define I40E_AQC_SET_RSS_LUT_TABLE_TYPE_SHIFT	0
-#define I40E_AQC_SET_RSS_LUT_TABLE_TYPE_MASK	(0x1 << \
-					I40E_AQC_SET_RSS_LUT_TABLE_TYPE_SHIFT)
+#define I40E_AQC_SET_RSS_LUT_TABLE_TYPE_MASK \
+				BIT(I40E_AQC_SET_RSS_LUT_TABLE_TYPE_SHIFT)
 
 #define I40E_AQC_SET_RSS_LUT_TABLE_TYPE_VSI	0
 #define I40E_AQC_SET_RSS_LUT_TABLE_TYPE_PF	1
-- 
2.5.5
