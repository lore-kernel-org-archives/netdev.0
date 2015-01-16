From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 12/17] i40e: AQ API updates
Date: Fri, 16 Jan 2015 05:29:01 -0800
Message-ID: <1421414946-22179-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421414946-22179-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	gerlitz.or@gmail.com, Shannon Nelson <shannon.nelson@intel.com>,
	Kamil Krawczyk <kamil.krawczyk@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5724 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756040AbbAPN3a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jan 2015 08:29:30 -0500
In-Reply-To: <1421414946-22179-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix up NVM config read and write data structs.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Kamil Krawczyk <kamil.krawczyk@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h   | 10 +++++-----
 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h | 10 +++++-----
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 20cada5..70b8e55 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -1831,12 +1831,12 @@ I40E_CHECK_CMD_LENGTH(i40e_aqc_nvm_update);
 /* NVM Config Read (indirect 0x0704) */
 struct i40e_aqc_nvm_config_read {
 	__le16	cmd_flags;
-#define ANVM_SINGLE_OR_MULTIPLE_FEATURES_MASK	1
-#define ANVM_READ_SINGLE_FEATURE		0
-#define ANVM_READ_MULTIPLE_FEATURES		1
+#define I40E_AQ_ANVM_SINGLE_OR_MULTIPLE_FEATURES_MASK	1 
+#define I40E_AQ_ANVM_READ_SINGLE_FEATURE		0 
+#define I40E_AQ_ANVM_READ_MULTIPLE_FEATURES		1
 	__le16	element_count;
-	__le16	element_id; /* Feature/field ID */
-	u8	reserved[2];
+	__le16	element_id;	/* Feature/field ID */
+	__le16	element_id_msw;	/* MSWord of field ID */
 	__le32	address_high;
 	__le32	address_low;
 };
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index 1b80846..5363cbf 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -1831,12 +1831,12 @@ I40E_CHECK_CMD_LENGTH(i40e_aqc_nvm_update);
 /* NVM Config Read (indirect 0x0704) */
 struct i40e_aqc_nvm_config_read {
 	__le16	cmd_flags;
-#define ANVM_SINGLE_OR_MULTIPLE_FEATURES_MASK	1
-#define ANVM_READ_SINGLE_FEATURE		0
-#define ANVM_READ_MULTIPLE_FEATURES		1
+#define I40E_AQ_ANVM_SINGLE_OR_MULTIPLE_FEATURES_MASK	1
+#define I40E_AQ_ANVM_READ_SINGLE_FEATURE		0
+#define I40E_AQ_ANVM_READ_MULTIPLE_FEATURES		1
 	__le16	element_count;
-	__le16	element_id; /* Feature/field ID */
-	u8	reserved[2];
+	__le16	element_id;	/* Feature/field ID */
+	__le16	element_id_msw;	/* MSWord of field ID */
 	__le32	address_high;
 	__le32	address_low;
 };
-- 
1.9.3
