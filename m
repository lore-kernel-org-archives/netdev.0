From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] e1000e: cleanup: remove unnecessary variable initializations
Date: Mon, 13 Feb 2012 13:47:46 -0800
Message-ID: <1329169670-5403-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1329169670-5403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:45312 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755703Ab2BMVr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 16:47:59 -0500
In-Reply-To: <1329169670-5403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index c80ef41..e45235e 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -2114,7 +2114,7 @@ static s32 e1000_valid_nvm_bank_detect_ich8lan(struct e1000_hw *hw, u32 *bank)
 	u32 bank1_offset = nvm->flash_bank_size * sizeof(u16);
 	u32 act_offset = E1000_ICH_NVM_SIG_WORD * 2 + 1;
 	u8 sig_byte = 0;
-	s32 ret_val = 0;
+	s32 ret_val;
 
 	switch (hw->mac.type) {
 	case e1000_ich8lan:
@@ -2268,7 +2268,7 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 		ew16flash(ICH_FLASH_HSFSTS, hsfsts.regval);
 		ret_val = 0;
 	} else {
-		s32 i = 0;
+		s32 i;
 
 		/*
 		 * Otherwise poll for sometime so the current
-- 
1.7.7.6
