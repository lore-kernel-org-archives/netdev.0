From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/20] i40e: add new proxy-wol bit for X722
Date: Thu,  4 Feb 2016 03:49:06 -0800
Message-ID: <1454586551-35919-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50262 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965778AbcBDLtV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 06:49:21 -0500
In-Reply-To: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add the new proxy-wake-on-lan capability bit available with the
new X722 device.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h   | 1 +
 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index 256ce65..bff0995 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -402,6 +402,7 @@ struct i40e_aqc_list_capabilities_element_resp {
 #define I40E_AQ_CAP_ID_OS2BMC_CAP	0x0004
 #define I40E_AQ_CAP_ID_FUNCTIONS_VALID	0x0005
 #define I40E_AQ_CAP_ID_ALTERNATE_RAM	0x0006
+#define I40E_AQ_CAP_ID_WOL_AND_PROXY	0x0008
 #define I40E_AQ_CAP_ID_SRIOV		0x0012
 #define I40E_AQ_CAP_ID_VF		0x0013
 #define I40E_AQ_CAP_ID_VMDQ		0x0014
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index 0d3bc3b..365a7d6 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -399,6 +399,7 @@ struct i40e_aqc_list_capabilities_element_resp {
 #define I40E_AQ_CAP_ID_OS2BMC_CAP	0x0004
 #define I40E_AQ_CAP_ID_FUNCTIONS_VALID	0x0005
 #define I40E_AQ_CAP_ID_ALTERNATE_RAM	0x0006
+#define I40E_AQ_CAP_ID_WOL_AND_PROXY	0x0008
 #define I40E_AQ_CAP_ID_SRIOV		0x0012
 #define I40E_AQ_CAP_ID_VF		0x0013
 #define I40E_AQ_CAP_ID_VMDQ		0x0014
-- 
2.5.0
