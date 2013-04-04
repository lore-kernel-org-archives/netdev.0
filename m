From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/13] igb: Fix sparse warnings on function pointers
Date: Thu,  4 Apr 2013 04:37:58 -0700
Message-ID: <1365075480-20183-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29187 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758885Ab3DDLiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 07:38:25 -0400
In-Reply-To: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

This patch fixes sparse warnings on function pointers that are not
defined as static.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 856364a..3867ba1 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -227,7 +227,7 @@ out:
  *  igb_init_nvm_params_82575 - Init NVM func ptrs.
  *  @hw: pointer to the HW structure
  **/
-s32 igb_init_nvm_params_82575(struct e1000_hw *hw)
+static s32 igb_init_nvm_params_82575(struct e1000_hw *hw)
 {
 	struct e1000_nvm_info *nvm = &hw->nvm;
 	u32 eecd = rd32(E1000_EECD);
@@ -867,7 +867,7 @@ static s32 igb_set_d0_lplu_state_82580(struct e1000_hw *hw, bool active)
  *  During driver activity, SmartSpeed should be enabled so performance is
  *  maintained.
  **/
-s32 igb_set_d3_lplu_state_82580(struct e1000_hw *hw, bool active)
+static s32 igb_set_d3_lplu_state_82580(struct e1000_hw *hw, bool active)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val = 0;
-- 
1.7.11.7
