From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/10] fm10k: address operator not needed when declaring function pointers
Date: Tue, 22 Dec 2015 06:02:07 -0800
Message-ID: <1450792932-96015-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450792932-96015-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53515 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753492AbbLVODO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Dec 2015 09:03:14 -0500
In-Reply-To: <1450792932-96015-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 58 ++++++++++++++---------------
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c | 38 +++++++++----------
 2 files changed, 48 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 7dd7ca8..606c0f1 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -1867,38 +1867,38 @@ static const struct fm10k_msg_data fm10k_msg_data_pf[] = {
 };
 
 static struct fm10k_mac_ops mac_ops_pf = {
-	.get_bus_info		= &fm10k_get_bus_info_generic,
-	.reset_hw		= &fm10k_reset_hw_pf,
-	.init_hw		= &fm10k_init_hw_pf,
-	.start_hw		= &fm10k_start_hw_generic,
-	.stop_hw		= &fm10k_stop_hw_generic,
-	.update_vlan		= &fm10k_update_vlan_pf,
-	.read_mac_addr		= &fm10k_read_mac_addr_pf,
-	.update_uc_addr		= &fm10k_update_uc_addr_pf,
-	.update_mc_addr		= &fm10k_update_mc_addr_pf,
-	.update_xcast_mode	= &fm10k_update_xcast_mode_pf,
-	.update_int_moderator	= &fm10k_update_int_moderator_pf,
-	.update_lport_state	= &fm10k_update_lport_state_pf,
-	.update_hw_stats	= &fm10k_update_hw_stats_pf,
-	.rebind_hw_stats	= &fm10k_rebind_hw_stats_pf,
-	.configure_dglort_map	= &fm10k_configure_dglort_map_pf,
-	.set_dma_mask		= &fm10k_set_dma_mask_pf,
-	.get_fault		= &fm10k_get_fault_pf,
-	.get_host_state		= &fm10k_get_host_state_pf,
-	.adjust_systime		= &fm10k_adjust_systime_pf,
-	.read_systime		= &fm10k_read_systime_pf,
+	.get_bus_info		= fm10k_get_bus_info_generic,
+	.reset_hw		= fm10k_reset_hw_pf,
+	.init_hw		= fm10k_init_hw_pf,
+	.start_hw		= fm10k_start_hw_generic,
+	.stop_hw		= fm10k_stop_hw_generic,
+	.update_vlan		= fm10k_update_vlan_pf,
+	.read_mac_addr		= fm10k_read_mac_addr_pf,
+	.update_uc_addr		= fm10k_update_uc_addr_pf,
+	.update_mc_addr		= fm10k_update_mc_addr_pf,
+	.update_xcast_mode	= fm10k_update_xcast_mode_pf,
+	.update_int_moderator	= fm10k_update_int_moderator_pf,
+	.update_lport_state	= fm10k_update_lport_state_pf,
+	.update_hw_stats	= fm10k_update_hw_stats_pf,
+	.rebind_hw_stats	= fm10k_rebind_hw_stats_pf,
+	.configure_dglort_map	= fm10k_configure_dglort_map_pf,
+	.set_dma_mask		= fm10k_set_dma_mask_pf,
+	.get_fault		= fm10k_get_fault_pf,
+	.get_host_state		= fm10k_get_host_state_pf,
+	.adjust_systime		= fm10k_adjust_systime_pf,
+	.read_systime		= fm10k_read_systime_pf,
 };
 
 static struct fm10k_iov_ops iov_ops_pf = {
-	.assign_resources		= &fm10k_iov_assign_resources_pf,
-	.configure_tc			= &fm10k_iov_configure_tc_pf,
-	.assign_int_moderator		= &fm10k_iov_assign_int_moderator_pf,
+	.assign_resources		= fm10k_iov_assign_resources_pf,
+	.configure_tc			= fm10k_iov_configure_tc_pf,
+	.assign_int_moderator		= fm10k_iov_assign_int_moderator_pf,
 	.assign_default_mac_vlan	= fm10k_iov_assign_default_mac_vlan_pf,
-	.reset_resources		= &fm10k_iov_reset_resources_pf,
-	.set_lport			= &fm10k_iov_set_lport_pf,
-	.reset_lport			= &fm10k_iov_reset_lport_pf,
-	.update_stats			= &fm10k_iov_update_stats_pf,
-	.report_timestamp		= &fm10k_iov_report_timestamp_pf,
+	.reset_resources		= fm10k_iov_reset_resources_pf,
+	.set_lport			= fm10k_iov_set_lport_pf,
+	.reset_lport			= fm10k_iov_reset_lport_pf,
+	.update_stats			= fm10k_iov_update_stats_pf,
+	.report_timestamp		= fm10k_iov_report_timestamp_pf,
 };
 
 static s32 fm10k_get_invariants_pf(struct fm10k_hw *hw)
@@ -1910,7 +1910,7 @@ static s32 fm10k_get_invariants_pf(struct fm10k_hw *hw)
 
 struct fm10k_info fm10k_pf_info = {
 	.mac		= fm10k_mac_pf,
-	.get_invariants	= &fm10k_get_invariants_pf,
+	.get_invariants	= fm10k_get_invariants_pf,
 	.mac_ops	= &mac_ops_pf,
 	.iov_ops	= &iov_ops_pf,
 };
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
index f1dc6e8..38219f5 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
@@ -563,24 +563,24 @@ static const struct fm10k_msg_data fm10k_msg_data_vf[] = {
 };
 
 static struct fm10k_mac_ops mac_ops_vf = {
-	.get_bus_info		= &fm10k_get_bus_info_generic,
-	.reset_hw		= &fm10k_reset_hw_vf,
-	.init_hw		= &fm10k_init_hw_vf,
-	.start_hw		= &fm10k_start_hw_generic,
-	.stop_hw		= &fm10k_stop_hw_vf,
-	.update_vlan		= &fm10k_update_vlan_vf,
-	.read_mac_addr		= &fm10k_read_mac_addr_vf,
-	.update_uc_addr		= &fm10k_update_uc_addr_vf,
-	.update_mc_addr		= &fm10k_update_mc_addr_vf,
-	.update_xcast_mode	= &fm10k_update_xcast_mode_vf,
-	.update_int_moderator	= &fm10k_update_int_moderator_vf,
-	.update_lport_state	= &fm10k_update_lport_state_vf,
-	.update_hw_stats	= &fm10k_update_hw_stats_vf,
-	.rebind_hw_stats	= &fm10k_rebind_hw_stats_vf,
-	.configure_dglort_map	= &fm10k_configure_dglort_map_vf,
-	.get_host_state		= &fm10k_get_host_state_generic,
-	.adjust_systime		= &fm10k_adjust_systime_vf,
-	.read_systime		= &fm10k_read_systime_vf,
+	.get_bus_info		= fm10k_get_bus_info_generic,
+	.reset_hw		= fm10k_reset_hw_vf,
+	.init_hw		= fm10k_init_hw_vf,
+	.start_hw		= fm10k_start_hw_generic,
+	.stop_hw		= fm10k_stop_hw_vf,
+	.update_vlan		= fm10k_update_vlan_vf,
+	.read_mac_addr		= fm10k_read_mac_addr_vf,
+	.update_uc_addr		= fm10k_update_uc_addr_vf,
+	.update_mc_addr		= fm10k_update_mc_addr_vf,
+	.update_xcast_mode	= fm10k_update_xcast_mode_vf,
+	.update_int_moderator	= fm10k_update_int_moderator_vf,
+	.update_lport_state	= fm10k_update_lport_state_vf,
+	.update_hw_stats	= fm10k_update_hw_stats_vf,
+	.rebind_hw_stats	= fm10k_rebind_hw_stats_vf,
+	.configure_dglort_map	= fm10k_configure_dglort_map_vf,
+	.get_host_state		= fm10k_get_host_state_generic,
+	.adjust_systime		= fm10k_adjust_systime_vf,
+	.read_systime		= fm10k_read_systime_vf,
 };
 
 static s32 fm10k_get_invariants_vf(struct fm10k_hw *hw)
@@ -592,6 +592,6 @@ static s32 fm10k_get_invariants_vf(struct fm10k_hw *hw)
 
 struct fm10k_info fm10k_vf_info = {
 	.mac		= fm10k_mac_vf,
-	.get_invariants	= &fm10k_get_invariants_vf,
+	.get_invariants	= fm10k_get_invariants_vf,
 	.mac_ops	= &mac_ops_vf,
 };
-- 
2.5.0
