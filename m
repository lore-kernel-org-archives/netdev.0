From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Subject: [PATCH V5 3/4] CS89x0 : remove QQ2440 board support from the CS89x0 driver
Date: Thu, 26 Jan 2012 21:47:11 +0100
Message-ID: <1327610831-26961-1-git-send-email-jaccon.bastiaansen@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
To: kernel@pengutronix.de, u.kleine-koenig@pengutronix.de,
	s.hauer@pengutronix.de, davem@davemloft.net, cavokz@gmail.com,
	linux@arm.linux.org.uk, fabio.estevam@freescale.com,
	festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:54582 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958Ab2AZUrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 15:47:21 -0500
Received: by mail-ee0-f46.google.com with SMTP id c14so323460eek.19
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2012 12:47:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The QQ2440 board isn't supported anymore in the kernel, so support
for this board can be removed from the CS89x0 driver.

Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
---
 drivers/net/ethernet/cirrus/cs89x0.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index 6b3cd24..f7449bd 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -182,11 +182,6 @@ static unsigned int cs8900_irq_map[] = {IRQ_IXDP2351_CS8900, 0, 0, 0};
 #define CS89x0_NONISA_IRQ
 static unsigned int netcard_portlist[] __used __initdata = {IXDP2X01_CS8900_VIRT_BASE, 0};
 static unsigned int cs8900_irq_map[] = {IRQ_IXDP2X01_CS8900, 0, 0, 0};
-#elif defined(CONFIG_MACH_QQ2440)
-#define CS89x0_NONISA_IRQ
-#include <mach/qq2440.h>
-static unsigned int netcard_portlist[] __used __initdata = { QQ2440_CS8900_VIRT_BASE + 0x300, 0 };
-static unsigned int cs8900_irq_map[] = { QQ2440_CS8900_IRQ, 0, 0, 0 };
 #elif defined(CONFIG_MACH_MX31ADS)
 #define CS89x0_NONISA_IRQ
 #include <mach/board-mx31ads.h>
@@ -543,9 +538,6 @@ cs89x0_probe1(struct net_device *dev, unsigned long ioaddr, int modular)
 		lp->force = g_cs89x0_media__force;
 #endif
 
-#if defined(CONFIG_MACH_QQ2440)
-		lp->force |= FORCE_RJ45 | FORCE_FULL;
-#endif
         }
 
 	/* Grab the region so we can find another board if autoIRQ fails. */
-- 
1.7.1
