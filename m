From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 01/13] igb: Cleanups to fix pointer location error
Date: Thu, 24 Apr 2014 18:02:51 -0700
Message-ID: <1398387783-30414-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398387783-30414-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58806 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750756AbaDYBDQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 21:03:16 -0400
In-Reply-To: <1398387783-30414-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes ERROR:POINTER_LOCATION from checkpatch file check.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 49976bf..a83fcad 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -525,7 +525,7 @@ out:
 static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
-	struct e1000_dev_spec_82575 * dev_spec = &hw->dev_spec._82575;
+	struct e1000_dev_spec_82575 *dev_spec = &hw->dev_spec._82575;
 	s32 ret_val;
 	u32 ctrl_ext = 0;
 	u32 link_mode = 0;
-- 
1.9.0
