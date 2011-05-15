From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 01/13] e1000e: minor comment cleanups
Date: Sat, 14 May 2011 18:23:35 -0700
Message-ID: <1305422627-9583-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52581 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755999Ab1EOBXt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 21:23:49 -0400
In-Reply-To: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/lib.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 6432dda..dd8ab05 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -144,7 +144,7 @@ void e1000_write_vfta_generic(struct e1000_hw *hw, u32 offset, u32 value)
  *  @hw: pointer to the HW structure
  *  @rar_count: receive address registers
  *
- *  Setups the receive address registers by setting the base receive address
+ *  Setup the receive address registers by setting the base receive address
  *  register to the devices MAC address and clearing all the other receive
  *  address registers to 0.
  **/
@@ -1181,7 +1181,7 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 			 * of pause frames.  In this case, we had to advertise
 			 * FULL flow control because we could not advertise Rx
 			 * ONLY. Hence, we must now check to see if we need to
-			 * turn OFF  the TRANSMISSION of PAUSE frames.
+			 * turn OFF the TRANSMISSION of PAUSE frames.
 			 */
 			if (hw->fc.requested_mode == e1000_fc_full) {
 				hw->fc.current_mode = e1000_fc_full;
-- 
1.7.4.4

