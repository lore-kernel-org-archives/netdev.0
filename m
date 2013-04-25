From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] igb: Remove dead code path
Date: Wed, 24 Apr 2013 21:08:45 -0700
Message-ID: <1366862927-1855-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366862927-1855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:15281 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751442Ab3DYEJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 00:09:12 -0400
In-Reply-To: <1366862927-1855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

The 82575 manual initialization scripts are not supported on 82580 and
above. Rather than call the function to immediately return, clarify the
code by removing this pointless function call.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 6cb0ca2..d3d72e0 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -2052,10 +2052,6 @@ static s32 igb_reset_hw_82580(struct e1000_hw *hw)
 		hw_dbg("Auto Read Done did not complete\n");
 	}
 
-	/* If EEPROM is not present, run manual init scripts */
-	if ((rd32(E1000_EECD) & E1000_EECD_PRES) == 0)
-		igb_reset_init_script_82575(hw);
-
 	/* clear global device reset status bit */
 	wr32(E1000_STATUS, E1000_STAT_DEV_RST_SET);
 
-- 
1.7.11.7
