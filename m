From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] fm10k: remove unnecessary else block from if statements with return
Date: Sun, 13 Dec 2015 16:27:35 -0800
Message-ID: <1450052867-36654-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450052867-36654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:42600 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751938AbbLNA1u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 19:27:50 -0500
In-Reply-To: <1450052867-36654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Improve code style by removing the unnecessary else block of an if
statement which immediately returns.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index bbf0b4a..76f273a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -1232,8 +1232,8 @@ s32 fm10k_iov_msg_mac_vlan_pf(struct fm10k_hw *hw, u32 **results,
 		err = fm10k_iov_select_vid(vf_info, (u16)vid);
 		if (err < 0)
 			return err;
-		else
-			vid = err;
+
+		vid = err;
 
 		/* update VSI info for VF in regards to VLAN table */
 		err = hw->mac.ops.update_vlan(hw, vid, vf_info->vsi, set);
@@ -1258,8 +1258,8 @@ s32 fm10k_iov_msg_mac_vlan_pf(struct fm10k_hw *hw, u32 **results,
 		err = fm10k_iov_select_vid(vf_info, vlan);
 		if (err < 0)
 			return err;
-		else
-			vlan = (u16)err;
+
+		vlan = (u16)err;
 
 		/* notify switch of request for new unicast address */
 		err = hw->mac.ops.update_uc_addr(hw, vf_info->glort,
@@ -1284,8 +1284,8 @@ s32 fm10k_iov_msg_mac_vlan_pf(struct fm10k_hw *hw, u32 **results,
 		err = fm10k_iov_select_vid(vf_info, vlan);
 		if (err < 0)
 			return err;
-		else
-			vlan = (u16)err;
+
+		vlan = (u16)err;
 
 		/* notify switch of request for new multicast address */
 		err = hw->mac.ops.update_mc_addr(hw, vf_info->glort,
-- 
2.5.0
