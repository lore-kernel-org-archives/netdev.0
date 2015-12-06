From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 06/15] fm10k: explicitly typecast vlan values to u16
Date: Sun,  6 Dec 2015 00:01:25 -0800
Message-ID: <1449388894-128573-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449388894-128573-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43991 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752040AbbLFIBh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Dec 2015 03:01:37 -0500
In-Reply-To: <1449388894-128573-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index b1e0975..00f7a29 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -1212,7 +1212,7 @@ s32 fm10k_iov_msg_mac_vlan_pf(struct fm10k_hw *hw, u32 **results,
 		set = !(vid & FM10K_VLAN_CLEAR);
 		vid &= ~FM10K_VLAN_CLEAR;
 
-		err = fm10k_iov_select_vid(vf_info, vid);
+		err = fm10k_iov_select_vid(vf_info, (u16)vid);
 		if (err < 0)
 			return err;
 		else
@@ -1242,7 +1242,7 @@ s32 fm10k_iov_msg_mac_vlan_pf(struct fm10k_hw *hw, u32 **results,
 		if (err < 0)
 			return err;
 		else
-			vlan = err;
+			vlan = (u16)err;
 
 		/* notify switch of request for new unicast address */
 		err = hw->mac.ops.update_uc_addr(hw, vf_info->glort,
@@ -1268,7 +1268,7 @@ s32 fm10k_iov_msg_mac_vlan_pf(struct fm10k_hw *hw, u32 **results,
 		if (err < 0)
 			return err;
 		else
-			vlan = err;
+			vlan = (u16)err;
 
 		/* notify switch of request for new multicast address */
 		err = hw->mac.ops.update_mc_addr(hw, vf_info->glort,
-- 
2.5.0
