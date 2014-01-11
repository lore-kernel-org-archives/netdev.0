From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 05/17] i40e: fix long lines
Date: Fri, 10 Jan 2014 16:47:18 -0800
Message-ID: <1389401250-11509-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389401250-11509-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23274 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751572AbaAKAri (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 19:47:38 -0500
In-Reply-To: <1389401250-11509-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Avoid over-length lines in order to appease checkpatch.

Change-ID: I63820a710acf798f49d2f85c610228711af84f72
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c    | 3 ++-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h | 4 ++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 6bfbeec..1bf0ec1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -681,7 +681,8 @@ aq_add_vsi_exit:
  * @cmd_details: pointer to command details structure or NULL
  **/
 i40e_status i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw,
-				u16 seid, bool set, struct i40e_asq_cmd_details *cmd_details)
+				u16 seid, bool set,
+				struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_set_vsi_promiscuous_modes *cmd =
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index c7c3d82..f8c53a6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -93,9 +93,9 @@ i40e_status i40e_aq_set_vsi_broadcast(struct i40e_hw *hw,
 				u16 vsi_id, bool set_filter,
 				struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw,
-				u16 vsi_id, bool set, struct i40e_asq_cmd_details *cmd_details);
+		u16 vsi_id, bool set, struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_set_vsi_multicast_promiscuous(struct i40e_hw *hw,
-				u16 vsi_id, bool set, struct i40e_asq_cmd_details *cmd_details);
+		u16 vsi_id, bool set, struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_get_vsi_params(struct i40e_hw *hw,
 				struct i40e_vsi_context *vsi_ctx,
 				struct i40e_asq_cmd_details *cmd_details);
-- 
1.8.3.1
