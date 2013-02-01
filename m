From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/11] e1000e: cleanup: group OR'ed bit settings with parens
Date: Thu, 31 Jan 2013 23:53:27 -0800
Message-ID: <1359705211-11342-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359705211-11342-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53335 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755703Ab3BAHyM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 02:54:12 -0500
In-Reply-To: <1359705211-11342-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
