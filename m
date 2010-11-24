From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 06/10] tg3: Enable mult rd DMA engine on 5719
Date: Wed, 24 Nov 2010 10:31:50 -0800
Message-ID: <1290623514-18193-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4210 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753053Ab0KXScJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 13:32:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The multiple DMA read engine bugs have been fixed on the 5719.  This
patch reenables support for this feature.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 226e60d..4fa8ee3 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8165,8 +8165,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		      RDMAC_MODE_FIFOURUN_ENAB | RDMAC_MODE_FIFOOREAD_ENAB |
 		      RDMAC_MODE_LNGREAD_ENAB);
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717)
 		rdmac_mode |= RDMAC_MODE_MULT_DMA_RD_DIS;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-- 
1.7.2.2


