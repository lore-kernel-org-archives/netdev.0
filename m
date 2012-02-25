From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/11] e1000e: cleanup - remove unnecessary variable
Date: Fri, 24 Feb 2012 21:49:59 -0800
Message-ID: <1330149000-25907-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330149000-25907-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33270 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753416Ab2BYFuG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Feb 2012 00:50:06 -0500
In-Reply-To: <1330149000-25907-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/mac.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethernet/intel/e1000e/mac.c
index d55f588..59ac9f6 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -703,7 +703,6 @@ static s32 e1000_set_default_fc_generic(struct e1000_hw *hw)
  **/
 s32 e1000e_setup_link_generic(struct e1000_hw *hw)
 {
-	struct e1000_mac_info *mac = &hw->mac;
 	s32 ret_val;
 
 	/*
@@ -732,7 +731,7 @@ s32 e1000e_setup_link_generic(struct e1000_hw *hw)
 	e_dbg("After fix-ups FlowControl is now = %x\n", hw->fc.current_mode);
 
 	/* Call the necessary media_type subroutine to configure the link. */
-	ret_val = mac->ops.setup_physical_interface(hw);
+	ret_val = hw->mac.ops.setup_physical_interface(hw);
 	if (ret_val)
 		return ret_val;
 
-- 
1.7.7.6
