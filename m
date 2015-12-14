From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] fm10k: do not inline fm10k_iov_select_vid()
Date: Sun, 13 Dec 2015 16:27:42 -0800
Message-ID: <1450052867-36654-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450052867-36654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:42600 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752043AbbLNA1v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 19:27:51 -0500
In-Reply-To: <1450052867-36654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The function declaration does not need to be 'inline'd here.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index ad6381c..750518d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -1179,7 +1179,7 @@ s32 fm10k_iov_msg_msix_pf(struct fm10k_hw *hw, u32 **results,
  * Will report an error if the VLAN ID is out of range. For VID = 0, it will
  * return either the pf_vid or sw_vid depending on which one is set.
  */
-static inline s32 fm10k_iov_select_vid(struct fm10k_vf_info *vf_info, u16 vid)
+static s32 fm10k_iov_select_vid(struct fm10k_vf_info *vf_info, u16 vid)
 {
 	if (!vid)
 		return vf_info->pf_vid ? vf_info->pf_vid : vf_info->sw_vid;
-- 
2.5.0
