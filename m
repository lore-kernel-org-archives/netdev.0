From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/10] igb: Fix hw_dbg logging in igb_update_flash_i210
Date: Fri,  6 Jan 2017 02:48:52 -0800
Message-ID: <20170106104852.10363-11-jeffrey.t.kirsher@intel.com>
References: <20170106104852.10363-1-jeffrey.t.kirsher@intel.com>
Cc: Hannu Lounento <hannu.lounento@ge.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Peter Senna Tschudin <peter.senna@collabora.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:16460 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S939957AbdAFKtS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 05:49:18 -0500
In-Reply-To: <20170106104852.10363-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannu Lounento <hannu.lounento@ge.com>

Fix an if statement with hw_dbg lines where the logic was inverted with
regards to the corresponding return value used in the if statement.

Signed-off-by: Hannu Lounento <hannu.lounento@ge.com>
Signed-off-by: Peter Senna Tschudin <peter.senna@collabora.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
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
2.9.3
