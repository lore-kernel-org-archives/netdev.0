From: Peter Senna Tschudin <peter.senna@collabora.com>
Subject: [PATCH 1/1] igb: Fix hw_dbg logging in igb_update_flash_i210
Date: Mon,  2 Jan 2017 18:26:06 +0100
Message-ID: <14a3078ac22994d9c3dcd56c822555acfdb53b91.1483377891.git.peter.senna@collabora.com>
Cc: Hannu Lounento <hannu.lounento@ge.com>,
        Peter Senna Tschudin <peter.senna@collabora.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org (moderated list:INTEL ETHERNET DRIVERS),
        netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
        linux-kernel@vger.kernel.org (open list)
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannu Lounento <hannu.lounento@ge.com>

Fix an if statement with hw_dbg lines where the logic was inverted with
regards to the corresponding return value used in the if statement.

Signed-off-by: Hannu Lounento <hannu.lounento@ge.com>
Signed-off-by: Peter Senna Tschudin <peter.senna@collabora.com>
---
 drivers/net/ethernet/intel/igb/e1000_i210.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_i210.c b/drivers/net/ethernet/intel/igb/e1000_i210.c
index 8aa7987..07d48f2 100644
--- a/drivers/net/ethernet/intel/igb/e1000_i210.c
+++ b/drivers/net/ethernet/intel/igb/e1000_i210.c
@@ -699,9 +699,9 @@ static s32 igb_update_flash_i210(struct e1000_hw *hw)
 
 	ret_val = igb_pool_flash_update_done_i210(hw);
 	if (ret_val)
-		hw_dbg("Flash update complete\n");
-	else
 		hw_dbg("Flash update time out\n");
+	else
+		hw_dbg("Flash update complete\n");
 
 out:
 	return ret_val;
-- 
2.5.5
