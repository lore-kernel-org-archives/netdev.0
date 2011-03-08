From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 11/14] ixgbe: add function description
Date: Mon,  7 Mar 2011 18:25:05 -0800
Message-ID: <1299551108-23663-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37667 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756012Ab1CHC0H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 21:26:07 -0500
In-Reply-To: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Add description for ixgbe_init_eeprom_params_X540 and whitespace fix.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_x540.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
index 2e3a2b4..f47e93f 100644
--- a/drivers/net/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -251,8 +251,11 @@ static u32 ixgbe_get_supported_physical_layer_X540(struct ixgbe_hw *hw)
 }
 
 /**
- * ixgbe_init_eeprom_params_X540 - Initialize EEPROM params
- * @hw: pointer to hardware structure
+ *  ixgbe_init_eeprom_params_X540 - Initialize EEPROM params
+ *  @hw: pointer to hardware structure
+ *
+ *  Initializes the EEPROM parameters ixgbe_eeprom_info within the
+ *  ixgbe_hw struct in order to set up EEPROM access.
  **/
 static s32 ixgbe_init_eeprom_params_X540(struct ixgbe_hw *hw)
 {
@@ -271,7 +274,7 @@ static s32 ixgbe_init_eeprom_params_X540(struct ixgbe_hw *hw)
 		                          IXGBE_EEPROM_WORD_SIZE_SHIFT);
 
 		hw_dbg(hw, "Eeprom params: type = %d, size = %d\n",
-		        eeprom->type, eeprom->word_size);
+		       eeprom->type, eeprom->word_size);
 	}
 
 	return 0;
-- 
1.7.4

