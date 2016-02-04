From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 18/20] i40e: AQ Geneve cloud tunnel type
Date: Thu,  4 Feb 2016 03:49:09 -0800
Message-ID: <1454586551-35919-19-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45387 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965764AbcBDLtT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 06:49:19 -0500
In-Reply-To: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Fix the name of the new cloud tunnel type from the place-holder NGE
name to the official Geneve.  Also fix the spelling of the VXLAN type.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Kevin Scott <kevin.c.scott@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h   | 4 ++--
 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 9e340ca..eab55ea 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -1260,9 +1260,9 @@ struct i40e_aqc_add_remove_cloud_filters_element_data {
 
 #define I40E_AQC_ADD_CLOUD_TNL_TYPE_SHIFT		9
 #define I40E_AQC_ADD_CLOUD_TNL_TYPE_MASK		0x1E00
-#define I40E_AQC_ADD_CLOUD_TNL_TYPE_XVLAN		0
+#define I40E_AQC_ADD_CLOUD_TNL_TYPE_VXLAN		0
 #define I40E_AQC_ADD_CLOUD_TNL_TYPE_NVGRE_OMAC		1
-#define I40E_AQC_ADD_CLOUD_TNL_TYPE_NGE			2
+#define I40E_AQC_ADD_CLOUD_TNL_TYPE_GENEVE		2
 #define I40E_AQC_ADD_CLOUD_TNL_TYPE_IP			3
 
 	__le32	tenant_id;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index 51d83c6..30b5a33 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -1257,9 +1257,9 @@ struct i40e_aqc_add_remove_cloud_filters_element_data {
 
 #define I40E_AQC_ADD_CLOUD_TNL_TYPE_SHIFT		9
 #define I40E_AQC_ADD_CLOUD_TNL_TYPE_MASK		0x1E00
-#define I40E_AQC_ADD_CLOUD_TNL_TYPE_XVLAN		0
+#define I40E_AQC_ADD_CLOUD_TNL_TYPE_VXLAN		0
 #define I40E_AQC_ADD_CLOUD_TNL_TYPE_NVGRE_OMAC		1
-#define I40E_AQC_ADD_CLOUD_TNL_TYPE_NGE			2
+#define I40E_AQC_ADD_CLOUD_TNL_TYPE_GENEVE		2
 #define I40E_AQC_ADD_CLOUD_TNL_TYPE_IP			3
 
 	__le32	tenant_id;
-- 
2.5.0
