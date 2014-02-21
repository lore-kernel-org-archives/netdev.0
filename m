From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next v2 10/14] i40evf: remove errant space
Date: Thu, 20 Feb 2014 19:29:14 -0800
Message-ID: <1392953358-23908-11-git-send-email-aaron.f.brown@intel.com>
References: <1392953358-23908-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18044 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752933AbaBUDcS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Feb 2014 22:32:18 -0500
In-Reply-To: <1392953358-23908-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch A Williams <mitch.a.williams@intel.com>

Remove a bogus space.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index f7cea1b..97662b6 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -1229,7 +1229,7 @@ struct i40e_aqc_add_remove_cloud_filters_element_data {
 #define I40E_AQC_ADD_CLOUD_TNL_TYPE_NGE                 2
 #define I40E_AQC_ADD_CLOUD_TNL_TYPE_IP                  3
 
-	__le32 tenant_id ;
+	__le32 tenant_id;
 	u8     reserved[4];
 	__le16 queue_number;
 #define I40E_AQC_ADD_CLOUD_QUEUE_SHIFT                  0
-- 
1.8.5.GIT
