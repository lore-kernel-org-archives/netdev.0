From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH v2] net: can: Enable xilinx driver for ARM64
Date: Mon,  9 Mar 2015 15:03:32 +0100
Message-ID: <2dd8c07857416d5253296e7254dabc565d0060ef.1425909806.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, monstr@monstr.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable the xilinx driver for ARM64.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
Acked-by: S=C3=B6ren Brinkmann <soren.brinkmann@xilinx.com>
---

Changes in v2:
- Based on discussion with Marc and Jean enable this driver just for
  ARM64.

BTW: Jean suggested to enable it for all ARM platforms but it is
just not needed that's why I am just adding ARM64 and not changing
ARCH_ZYNQ to ARM.
---
 drivers/net/can/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index 98d73aab52fe..58808f651452 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -131,7 +131,7 @@ config CAN_RCAR
=20
 config CAN_XILINXCAN
 	tristate "Xilinx CAN"
-	depends on ARCH_ZYNQ || MICROBLAZE || COMPILE_TEST
+	depends on ARCH_ZYNQ || ARM64 || MICROBLAZE || COMPILE_TEST
 	depends on COMMON_CLK && HAS_IOMEM
 	---help---
 	  Xilinx CAN driver. This driver supports both soft AXI CAN IP and
--=20
1.8.2.3
