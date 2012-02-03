From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 7/9] can: Kconfig: add more information about Intel EG20T PCH CAN controller
Date: Fri,  3 Feb 2012 01:51:56 +0100
Message-ID: <1328230318-8962-8-git-send-email-mkl@pengutronix.de>
References: <1328230318-8962-1-git-send-email-mkl@pengutronix.de>
Cc: Netdev@vger.kernel.org, kernel@pengutronix.de, mkl@blackshift.org,
	linux-can@vger.kernel.org, Tomoya MORINAGA <tomoya.rohm@gmail.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1328230318-8962-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tomoya MORINAGA <tomoya.rohm@gmail.com>

Current menu description, not easy to understand what the description
means. So, add information about the device.

Signed-off-by: Tomoya MORINAGA <tomoya.rohm@gmail.com>
[mkl: Added space before opening parentheses in Kconfig.
      Make commit message more descriptive.]
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/Kconfig |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index ab45758..bb709fd 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -103,11 +103,11 @@ config CAN_FLEXCAN
 	  Say Y here if you want to support for Freescale FlexCAN.
 
 config PCH_CAN
-	tristate "PCH CAN"
+	tristate "Intel EG20T PCH CAN controller"
 	depends on CAN_DEV && PCI
 	---help---
-	  This driver is for PCH CAN of Topcliff which is an IOH for x86
-	  embedded processor.
+	  This driver is for PCH CAN of Topcliff (Intel EG20T PCH) which
+	  is an IOH for x86 embedded processor (Intel Atom E6xx series).
 	  This driver can access CAN bus.
 
 source "drivers/net/can/mscan/Kconfig"
-- 
1.7.4.1

