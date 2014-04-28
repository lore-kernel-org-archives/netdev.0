From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40e: Update function formal parameters
Date: Mon, 28 Apr 2014 06:52:36 -0700
Message-ID: <1398693158-2815-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kevin Scott <kevin.c.scott@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28779 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753758AbaD1Nws (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 09:52:48 -0400
In-Reply-To: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Scott <kevin.c.scott@intel.com>

Change the formal parameters to remove argument which is no longer used.

Change-ID: I493b56eba74a1f396fa1b7d24c0a4acbe536b5bf
Signed-off-by: Kevin Scott <kevin.c.scott@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c    | 4 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c      | 2 --
 drivers/net/ethernet/intel/i40e/i40e_prototype.h | 4 ++--
 3 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index e19df8f..55d029f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -2102,8 +2102,8 @@ i40e_status i40e_aq_start_lldp(struct i40e_hw *hw,
  * @cmd_details: pointer to command details structure or NULL
  **/
 i40e_status i40e_aq_add_udp_tunnel(struct i40e_hw *hw,
-				u16 udp_port, u8 header_len,
-				u8 protocol_index, u8 *filter_index,
+				u16 udp_port, u8 protocol_index,
+				u8 *filter_index,
 				struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 5506561..b27162b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5608,7 +5608,6 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
  **/
 static void i40e_sync_vxlan_filters_subtask(struct i40e_pf *pf)
 {
-	const int vxlan_hdr_qwords = 4;
 	struct i40e_hw *hw = &pf->hw;
 	i40e_status ret;
 	u8 filter_index;
@@ -5626,7 +5625,6 @@ static void i40e_sync_vxlan_filters_subtask(struct i40e_pf *pf)
 			port = pf->vxlan_ports[i];
 			ret = port ?
 			      i40e_aq_add_udp_tunnel(hw, ntohs(port),
-						     vxlan_hdr_qwords,
 						     I40E_AQC_TUNNEL_TYPE_VXLAN,
 						     &filter_index, NULL)
 			      : i40e_aq_del_udp_tunnel(hw, i, NULL);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index 10652f6..d351832 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -157,8 +157,8 @@ i40e_status i40e_aq_stop_lldp(struct i40e_hw *hw, bool shutdown_agent,
 i40e_status i40e_aq_start_lldp(struct i40e_hw *hw,
 				struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_add_udp_tunnel(struct i40e_hw *hw,
-				u16 udp_port, u8 header_len,
-				u8 protocol_index, u8 *filter_index,
+				u16 udp_port, u8 protocol_index,
+				u8 *filter_index,
 				struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_del_udp_tunnel(struct i40e_hw *hw, u8 index,
 				struct i40e_asq_cmd_details *cmd_details);
-- 
1.9.0
