From: Eric Nelson <eric@nelint.com>
Subject: [PATCH 1/3] net: fec: remove QUIRK_HAS_RACC from i.mx25
Date: Sat, 24 Sep 2016 07:42:17 -0700
Message-ID: <1474728139-9335-2-git-send-email-eric@nelint.com>
References: <AM4PR0401MB22609D8151C2B63CA7768A1AFFCB0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <1474728139-9335-1-git-send-email-eric@nelint.com>
Cc: linux@arm.linux.org.uk, andrew@lunn.ch, fugang.duan@nxp.com,
        otavio@ossystems.com.br, edumazet@google.com,
        troy.kisky@boundarydevices.com, davem@davemloft.net,
        u.kleine-koenig@pengutronix.de, Eric Nelson <eric@nelint.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fed1rmwml107.cox.net ([68.230.241.177]:57866 "EHLO
        fed1rmwml107.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751004AbcIXO6I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 10:58:08 -0400
Received: from fed1rmimpo306.cox.net ([68.230.241.174])
          by fed1rmfepo201.cox.net
          (InterMail vM.8.01.05.28 201-2260-151-171-20160122) with ESMTP
          id <20160924144426.LJXA6555.fed1rmfepo201.cox.net@fed1rmimpo306.cox.net>
          for <netdev@vger.kernel.org>; Sat, 24 Sep 2016 10:44:26 -0400
In-Reply-To: <1474728139-9335-1-git-send-email-eric@nelint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to the i.MX25 reference manual, this SoC does not have support
for the receive accelerator (RACC) register at offset 0x1C4.

http://www.nxp.com/files/dsp/doc/ref_manual/IMX25RM.pdf

Signed-off-by: Eric Nelson <eric@nelint.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index fb5c638..d193406 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -89,7 +89,7 @@ static struct platform_device_id fec_devtype[] = {
 		.driver_data = 0,
 	}, {
 		.name = "imx25-fec",
-		.driver_data = FEC_QUIRK_USE_GASKET | FEC_QUIRK_HAS_RACC,
+		.driver_data = FEC_QUIRK_USE_GASKET,
 	}, {
 		.name = "imx27-fec",
 		.driver_data = FEC_QUIRK_HAS_RACC,
-- 
2.7.4
