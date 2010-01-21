From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 08/10] tg3: Turn off the debug UART for 57765
Date: Wed, 20 Jan 2010 18:58:09 -0800
Message-ID: <1264042691-28284-9-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1427 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753774Ab0AUC6b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 21:58:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the debug UART is left enabled, the LEDs will not work properly.
This patch disables the debug UART.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index dffa51a..075d21a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -13328,7 +13328,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tp->grc_local_ctrl |= GRC_LCLCTRL_GPIO_OE3;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
 		tp->grc_local_ctrl |= GRC_LCLCTRL_GPIO_UART_SEL;
 
 	if (tp->pdev->device == PCI_DEVICE_ID_TIGON3_5761 ||
-- 
1.6.4.4


