From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/18] i40e: fix bad CEE status shift value
Date: Wed,  7 Oct 2015 15:47:00 -0700
Message-ID: <1444258032-41476-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8249 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751752AbbJGWrY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 18:47:24 -0400
In-Reply-To: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Fix a shift value that was wrong, ending up with a bad bitmask.  Also add
a blank line between two sets of #defines for better readability.

Change-ID: I3e41fa2a2ab904d3a4e6cbf13972ab0036a10601
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index b840fab..785b3db 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -2062,6 +2062,7 @@ I40E_CHECK_CMD_LENGTH(i40e_aqc_lldp_start);
 #define I40E_AQC_CEE_APP_ISCSI_MASK	(0x7 << I40E_AQC_CEE_APP_ISCSI_SHIFT)
 #define I40E_AQC_CEE_APP_FIP_SHIFT	0x8
 #define I40E_AQC_CEE_APP_FIP_MASK	(0x7 << I40E_AQC_CEE_APP_FIP_SHIFT)
+
 #define I40E_AQC_CEE_PG_STATUS_SHIFT	0x0
 #define I40E_AQC_CEE_PG_STATUS_MASK	(0x7 << I40E_AQC_CEE_PG_STATUS_SHIFT)
 #define I40E_AQC_CEE_PFC_STATUS_SHIFT	0x3
@@ -2070,7 +2071,7 @@ I40E_CHECK_CMD_LENGTH(i40e_aqc_lldp_start);
 #define I40E_AQC_CEE_APP_STATUS_MASK	(0x7 << I40E_AQC_CEE_APP_STATUS_SHIFT)
 #define I40E_AQC_CEE_FCOE_STATUS_SHIFT	0x8
 #define I40E_AQC_CEE_FCOE_STATUS_MASK	(0x7 << I40E_AQC_CEE_FCOE_STATUS_SHIFT)
-#define I40E_AQC_CEE_ISCSI_STATUS_SHIFT	0xA
+#define I40E_AQC_CEE_ISCSI_STATUS_SHIFT	0xB
 #define I40E_AQC_CEE_ISCSI_STATUS_MASK	(0x7 << I40E_AQC_CEE_ISCSI_STATUS_SHIFT)
 #define I40E_AQC_CEE_FIP_STATUS_SHIFT	0x10
 #define I40E_AQC_CEE_FIP_STATUS_MASK	(0x7 << I40E_AQC_CEE_FIP_STATUS_SHIFT)
-- 
2.4.3
