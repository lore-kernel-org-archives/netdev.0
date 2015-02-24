From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH] net: cadence: Enable MACB driver for ARM64
Date: Tue, 24 Feb 2015 08:45:52 +0100
Message-ID: <5a2ef83a03f6df78c8de643a19fb3f6105d892f4.1424763946.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, monstr@monstr.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This driver is used on new Xilinx ZynqMP SoC.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
Acked-by: S=C3=B6ren Brinkmann <soren.brinkmann@xilinx.com>
---

 drivers/net/ethernet/cadence/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/etherne=
t/cadence/Kconfig
index 321d2ad235d9..4562f90c0348 100644
--- a/drivers/net/ethernet/cadence/Kconfig
+++ b/drivers/net/ethernet/cadence/Kconfig
@@ -4,7 +4,7 @@
=20
 config NET_CADENCE
 	bool "Cadence devices"
-	depends on HAS_IOMEM && (ARM || AVR32 || MICROBLAZE || COMPILE_TEST)
+	depends on HAS_IOMEM && (ARM || ARM64 || AVR32 || MICROBLAZE || COMPI=
LE_TEST)
 	default y
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say =
Y.
@@ -30,7 +30,7 @@ config ARM_AT91_ETHER
=20
 config MACB
 	tristate "Cadence MACB/GEM support"
-	depends on HAS_DMA && (PLATFORM_AT32AP || ARCH_AT91 || ARCH_PICOXCELL=
 || ARCH_ZYNQ || MICROBLAZE || COMPILE_TEST)
+	depends on HAS_DMA && (PLATFORM_AT32AP || ARCH_AT91 || ARCH_PICOXCELL=
 || ARCH_ZYNQ || ARM64 || MICROBLAZE || COMPILE_TEST)
 	select PHYLIB
 	---help---
 	  The Cadence MACB ethernet interface is found on many Atmel AT32 and
--=20
1.8.2.3
