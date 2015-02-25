From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] e1000e: fixup comments jumbled by i219 support
Date: Wed, 25 Feb 2015 14:11:11 -0500
Message-ID: <1424891471-2833-1-git-send-email-linville@tuxdriver.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Ertman <david.m.ertman@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42804 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752730AbbBYTPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 14:15:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 79849ebc0e06 (e1000e: initial support for i219) jumbled some
comments in e1000_init_nvm_params_ich8lan.  This patch rearranges
them in a way that I think makes more sense.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: David Ertman <david.m.ertman@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 7523f510c7e4..a118ecffe697 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -603,12 +603,12 @@ static s32 e1000_init_nvm_params_ich8lan(struct e1000_hw *hw)
 	u16 i;
 	u32 nvm_size;
 
-	/* Can't read flash registers if the register set isn't mapped. */
 	nvm->type = e1000_nvm_flash_sw;
-	/* in SPT, gfpreg doesn't exist. NVM size is taken from the
-	 * STRAP register
-	 */
+
 	if (hw->mac.type == e1000_pch_spt) {
+		/* in SPT, gfpreg doesn't exist. NVM size is taken from the
+		 * STRAP register
+		 */
 		nvm->flash_base_addr = 0;
 		nvm_size = (((er32(STRAP) >> 1) & 0x1F) + 1)
 		    * NVM_SIZE_MULTIPLIER;
@@ -618,6 +618,7 @@ static s32 e1000_init_nvm_params_ich8lan(struct e1000_hw *hw)
 		/* Set the base address for flash register access */
 		hw->flash_address = hw->hw_addr + E1000_FLASH_BASE_ADDR;
 	} else {
+		/* Can't read flash registers if the register set isn't mapped. */
 		if (!hw->flash_address) {
 			e_dbg("ERROR: Flash registers not mapped\n");
 			return -E1000_ERR_CONFIG;
-- 
2.1.0
