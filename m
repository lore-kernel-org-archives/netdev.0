From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH v2] can: ti_hecc: Replace platform dependency with ARM dependency
Date: Fri, 20 Dec 2013 17:14:20 -0300
Message-ID: <1387570460-18409-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OMAP's ti_hecc driver is used to support the CAN controller on many omap2plus
SoCs (OMAP2430, OMAP3, OMAP4, OMAP5 and AM335x), so it's wrong to make this
depend on OMAP3 only. Take an extra step, to get wider build coverage, and make
the driver depend on ARM.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/can/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index 3c06947..9e7d95d 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -71,7 +71,7 @@ config CAN_AT91
 	  and AT91SAM9X5 processors.
 
 config CAN_TI_HECC
-	depends on ARCH_OMAP3
+	depends on ARM
 	tristate "TI High End CAN Controller"
 	---help---
 	  Driver for TI HECC (High End CAN Controller) module found on many
-- 
1.8.1.5

