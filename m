From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] fm10k: remove namespace pollution of fm10k_iov_msg_data_pf
Date: Sun, 13 Dec 2015 16:27:36 -0800
Message-ID: <1450052867-36654-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450052867-36654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:41661 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751478AbbLNA1u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 19:27:50 -0500
In-Reply-To: <1450052867-36654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Reviewed-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 8 --------
 drivers/net/ethernet/intel/fm10k/fm10k_pf.h | 1 -
 2 files changed, 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 76f273a..5bb6185 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -1413,14 +1413,6 @@ s32 fm10k_iov_msg_lport_state_pf(struct fm10k_hw *hw, u32 **results,
 	return err;
 }
 
-const struct fm10k_msg_data fm10k_iov_msg_data_pf[] = {
-	FM10K_TLV_MSG_TEST_HANDLER(fm10k_tlv_msg_test),
-	FM10K_VF_MSG_MSIX_HANDLER(fm10k_iov_msg_msix_pf),
-	FM10K_VF_MSG_MAC_VLAN_HANDLER(fm10k_iov_msg_mac_vlan_pf),
-	FM10K_VF_MSG_LPORT_STATE_HANDLER(fm10k_iov_msg_lport_state_pf),
-	FM10K_TLV_MSG_ERROR_HANDLER(fm10k_tlv_msg_error),
-};
-
 /**
  *  fm10k_update_stats_hw_pf - Updates hardware related statistics of PF
  *  @hw: pointer to hardware structure
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.h b/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
index 40a0dbc..9d77daa 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
@@ -129,7 +129,6 @@ s32 fm10k_iov_msg_mac_vlan_pf(struct fm10k_hw *, u32 **,
 			      struct fm10k_mbx_info *);
 s32 fm10k_iov_msg_lport_state_pf(struct fm10k_hw *, u32 **,
 				 struct fm10k_mbx_info *);
-extern const struct fm10k_msg_data fm10k_iov_msg_data_pf[];
 
 extern struct fm10k_info fm10k_pf_info;
 #endif /* _FM10K_PF_H */
-- 
2.5.0
