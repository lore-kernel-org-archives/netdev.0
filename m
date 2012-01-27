From: Tomoya MORINAGA <tomoya.rohm@gmail.com>
Subject: [PATCH 2/2] Kconfig: add information
Date: Fri, 27 Jan 2012 20:05:22 +0900
Message-ID: <1327662322-5425-2-git-send-email-tomoya.rohm@gmail.com>
References: <1327662322-5425-1-git-send-email-tomoya.rohm@gmail.com>
Cc: Tomoya MORINAGA <tomoya.rohm@gmail.com>
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327662322-5425-1-git-send-email-tomoya.rohm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Current menu description, not easy to understand what the description
means.
So, add information about the device.

Signed-off-by: Tomoya MORINAGA <tomoya.rohm@gmail.com>
---
 drivers/net/can/Kconfig |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index ab45758..fb985205 100644
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
+	  This driver is for PCH CAN of Topcliff(Intel EG20T PCH) which
+	  is an IOH for x86 embedded processor(Intel Atom E6xx series).
 	  This driver can access CAN bus.
 
 source "drivers/net/can/mscan/Kconfig"
-- 
1.7.7.6
