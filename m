From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/16] i40e: Bump AQ minor version to 1.5 for new FW features
Date: Tue, 16 Feb 2016 21:34:11 -0800
Message-ID: <1455687262-20453-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:14537 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754085AbcBQFe0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 00:34:26 -0500
In-Reply-To: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Bump AQ minor version to 1.5 for new FW features.

Change-ID: I5a790f7f519a2a8921aaa1c5663727dd1897ffec
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Kevin Scott <kevin.c.scott@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h   | 2 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 9684572..5699299 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -34,7 +34,7 @@
  */
 
 #define I40E_FW_API_VERSION_MAJOR	0x0001
-#define I40E_FW_API_VERSION_MINOR	0x0004
+#define I40E_FW_API_VERSION_MINOR	0x0005
 
 struct i40e_aq_desc {
 	__le16 flags;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index 6468537..ed963bc 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -34,7 +34,7 @@
  */
 
 #define I40E_FW_API_VERSION_MAJOR	0x0001
-#define I40E_FW_API_VERSION_MINOR	0x0004
+#define I40E_FW_API_VERSION_MINOR	0x0005
 
 struct i40e_aq_desc {
 	__le16 flags;
-- 
2.5.0
