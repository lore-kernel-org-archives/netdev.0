From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 5/6] tg3: Whitespace cleanups
Date: Mon, 25 Apr 2011 15:42:49 -0700
Message-ID: <1303771370-32579-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2578 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756706Ab1DYWai (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2011 18:30:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch gets rid of some harmless whitespace errors.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6bc43ed..696be59 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7666,8 +7666,6 @@ static int tg3_load_5701_a0_firmware_fix(struct tg3 *tp)
 	return 0;
 }
 
-/* 5705 needs a special version of the TSO firmware.  */
-
 /* tp->lock is held. */
 static int tg3_load_tso_firmware(struct tg3 *tp)
 {
@@ -10179,7 +10177,6 @@ static int tg3_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 		tp->tg3_flags &= ~TG3_FLAG_WOL_ENABLE;
 	spin_unlock_bh(&tp->lock);
 
-
 	return 0;
 }
 
@@ -12925,7 +12922,7 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 done:
 	if (tp->tg3_flags & TG3_FLAG_WOL_CAP)
 		device_set_wakeup_enable(&tp->pdev->dev,
-				 tp->tg3_flags & TG3_FLAG_WOL_ENABLE);
+					 tp->tg3_flags & TG3_FLAG_WOL_ENABLE);
 	else
 		device_set_wakeup_capable(&tp->pdev->dev, false);
 }
@@ -13749,7 +13746,6 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    (tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
 		tp->tg3_flags2 |= TG3_FLG2_5750_PLUS;
 
-
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) ||
 	    (tp->tg3_flags2 & TG3_FLG2_5750_PLUS))
 		tp->tg3_flags2 |= TG3_FLG2_5705_PLUS;
@@ -14034,7 +14030,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    (tp->tg3_flags3 & TG3_FLG3_57765_PLUS))
 		tp->tg3_flags |= TG3_FLAG_CPMU_PRESENT;
 
-	/* Set up tp->grc_local_ctrl before calling tg_power_up().
+	/* Set up tp->grc_local_ctrl before calling tg3_power_up().
 	 * GPIO1 driven high will bring 5700's external PHY out of reset.
 	 * It is also used as eeprom write protect on LOMs.
 	 */
@@ -14829,7 +14825,6 @@ static int __devinit tg3_test_dma(struct tg3 *tp)
 	}
 	if ((tp->dma_rwctrl & DMA_RWCTRL_WRITE_BNDRY_MASK) !=
 	    DMA_RWCTRL_WRITE_BNDRY_16) {
-
 		/* DMA test passed without adjusting DMA boundary,
 		 * now look for chipsets that are known to expose the
 		 * DMA bug without failing the test.
-- 
1.7.3.4


