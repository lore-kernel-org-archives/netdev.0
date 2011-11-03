From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 03/10] igb: Fix for I347AT4 PHY cable length unit detection
Date: Wed,  2 Nov 2011 17:19:54 -0700
Message-ID: <1320279601-1276-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1320279601-1276-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Kantecki, Tomasz" <tomasz.kantecki@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37902 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754393Ab1KCAUF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 20:20:05 -0400
In-Reply-To: <1320279601-1276-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kantecki, Tomasz" <tomasz.kantecki@intel.com>

The PHY cable length unit detection was not using the correct
the correct PHY data variable for I347AT4.

Signed-off-by: Tomasz Kantecki <tomasz.kantecki@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_phy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index 7edf31e..b17d7c2 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -1687,7 +1687,7 @@ s32 igb_get_cable_length_m88_gen2(struct e1000_hw *hw)
 		if (ret_val)
 			goto out;
 
-		is_cm = !(phy_data & I347AT4_PCDC_CABLE_LENGTH_UNIT);
+		is_cm = !(phy_data2 & I347AT4_PCDC_CABLE_LENGTH_UNIT);
 
 		/* Populate the phy structure with cable length in meters */
 		phy->min_cable_length = phy_data / (is_cm ? 100 : 1);
-- 
1.7.6.4
