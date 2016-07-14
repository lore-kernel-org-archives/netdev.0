From: Colin King <colin.king@canonical.com>
Subject: [PATCH] ixgbe: remove redundant check on ret_val
Date: Thu, 14 Jul 2016 12:47:09 +0100
Message-ID: <1468496829-18912-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The last check on ret_val is redundant since ret_val has not changed
since the previous check, so remove it as it is extraneous.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 47afed7..63b2500 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -1813,9 +1813,6 @@ static s32 ixgbe_start_hw_82599(struct ixgbe_hw *hw)
 	/* We need to run link autotry after the driver loads */
 	hw->mac.autotry_restart = true;
 
-	if (ret_val)
-		return ret_val;
-
 	return ixgbe_verify_fw_version_82599(hw);
 }
 
-- 
2.8.1
