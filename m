From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 17/20] i40e: AQ Add Run PHY Activity struct
Date: Thu,  4 Feb 2016 03:49:08 -0800
Message-ID: <1454586551-35919-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45387 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965738AbcBDLtQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 06:49:16 -0500
In-Reply-To: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add the AQ opcode and struct definitions for the Run PHY Activity command

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Kevin Scott <kevin.c.scott@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h   | 13 +++++++++++++
 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h | 13 +++++++++++++
 2 files changed, 26 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index bff0995..9e340ca 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -220,6 +220,7 @@ enum i40e_admin_queue_opc {
 	i40e_aqc_opc_get_phy_wol_caps		= 0x0621,
 	i40e_aqc_opc_set_phy_debug		= 0x0622,
 	i40e_aqc_opc_upload_ext_phy_fm		= 0x0625,
+	i40e_aqc_opc_run_phy_activity		= 0x0626,
 
 	/* NVM commands */
 	i40e_aqc_opc_nvm_read			= 0x0701,
@@ -1825,6 +1826,18 @@ enum i40e_aq_phy_reg_type {
 	I40E_AQC_PHY_REG_EXERNAL_MODULE	= 0x3
 };
 
+/* Run PHY Activity (0x0626) */
+struct i40e_aqc_run_phy_activity {
+	__le16  activity_id;
+	u8      flags;
+	u8      reserved1;
+	__le32  control;
+	__le32  data;
+	u8      reserved2[4];
+};
+
+I40E_CHECK_CMD_LENGTH(i40e_aqc_run_phy_activity);
+
 /* NVM Read command (indirect 0x0701)
  * NVM Erase commands (direct 0x0702)
  * NVM Update commands (indirect 0x0703)
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index 365a7d6..51d83c6 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -220,6 +220,7 @@ enum i40e_admin_queue_opc {
 	i40e_aqc_opc_get_phy_wol_caps		= 0x0621,
 	i40e_aqc_opc_set_phy_debug		= 0x0622,
 	i40e_aqc_opc_upload_ext_phy_fm		= 0x0625,
+	i40e_aqc_opc_run_phy_activity		= 0x0626,
 
 	/* NVM commands */
 	i40e_aqc_opc_nvm_read			= 0x0701,
@@ -1822,6 +1823,18 @@ enum i40e_aq_phy_reg_type {
 	I40E_AQC_PHY_REG_EXERNAL_MODULE	= 0x3
 };
 
+/* Run PHY Activity (0x0626) */
+struct i40e_aqc_run_phy_activity {
+	__le16  activity_id;
+	u8      flags;
+	u8      reserved1;
+	__le32  control;
+	__le32  data;
+	u8      reserved2[4];
+};
+
+I40E_CHECK_CMD_LENGTH(i40e_aqc_run_phy_activity);
+
 /* NVM Read command (indirect 0x0701)
  * NVM Erase commands (direct 0x0702)
  * NVM Update commands (indirect 0x0703)
-- 
2.5.0
