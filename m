From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/9] igb: Don't add PHY address to PCDL address
Date: Mon, 14 Dec 2015 21:38:38 -0800
Message-ID: <1450157924-58901-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450157924-58901-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Aaron Sierra <asierra@xes-inc.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59684 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751356AbbLOFit (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2015 00:38:49 -0500
In-Reply-To: <1450157924-58901-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Sierra <asierra@xes-inc.com>

There is no reason to add the PHY address into the PCDL register address.

Signed-off-by: Aaron Sierra <asierra@xes-inc.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_phy.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index c906826..8015f3b 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -1734,8 +1734,7 @@ s32 igb_get_cable_length_m88_gen2(struct e1000_hw *hw)
 			goto out;
 
 		/* Get cable length from PHY Cable Diagnostics Control Reg */
-		ret_val = phy->ops.read_reg(hw, (I347AT4_PCDL + phy->addr),
-					    &phy_data);
+		ret_val = phy->ops.read_reg(hw, I347AT4_PCDL, &phy_data);
 		if (ret_val)
 			goto out;
 
-- 
2.5.0
