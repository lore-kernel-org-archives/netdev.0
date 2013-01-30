From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/13] e1000e: cleanup: group OR'ed bit settings with parens
Date: Wed, 30 Jan 2013 03:44:42 -0800
Message-ID: <1359546286-18179-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359546286-18179-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33030 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755467Ab3A3LpA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 06:45:00 -0500
In-Reply-To: <1359546286-18179-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

For clarity, wrap OR'ed bit settings with parentheses.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/phy.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index cddfc6b..8dd1da0 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -3106,8 +3106,9 @@ s32 e1000_link_stall_workaround_hv(struct e1000_hw *hw)
 	msleep(200);
 
 	/* flush the packets in the fifo buffer */
-	ret_val = e1e_wphy(hw, HV_MUX_DATA_CTRL, HV_MUX_DATA_CTRL_GEN_TO_MAC |
-			   HV_MUX_DATA_CTRL_FORCE_SPEED);
+	ret_val = e1e_wphy(hw, HV_MUX_DATA_CTRL,
+			   (HV_MUX_DATA_CTRL_GEN_TO_MAC |
+			    HV_MUX_DATA_CTRL_FORCE_SPEED));
 	if (ret_val)
 		return ret_val;
 
-- 
1.7.11.7
