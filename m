From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/18] ixgbe: Allow SFP+ on more than 82598 and 82599
Date: Wed, 23 Sep 2015 23:59:29 -0700
Message-ID: <1443077981-55791-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443077981-55791-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48624 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932695AbbIXG74 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 02:59:56 -0400
In-Reply-To: <1443077981-55791-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Since SFP+ can be used with some X550 devices, permit them to be
detected.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index 7a7ee9d..fb8673d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -1230,7 +1230,7 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 			hw->phy.sfp_type = ixgbe_sfp_type_lr;
 		else
 			hw->phy.sfp_type = ixgbe_sfp_type_unknown;
-	} else if (hw->mac.type == ixgbe_mac_82599EB) {
+	} else {
 		if (cable_tech & IXGBE_SFF_DA_PASSIVE_CABLE) {
 			if (hw->bus.lan_id == 0)
 				hw->phy.sfp_type =
-- 
2.4.3
