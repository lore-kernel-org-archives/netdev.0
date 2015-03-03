From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH v2] net: cadence: Remove Kconfig dependency on ARCH
Date: Tue,  3 Mar 2015 15:43:00 +0100
Message-ID: <daf443b5c92099b2dd2fc490189bddc51659a0cd.1425393771.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Zach Pfeffer <zachp@xilinx.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, monstr@monstr.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove Kconfig dependency and enable driver for
all ARCHs.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
Acked-by: S=C3=B6ren Brinkmann <soren.brinkmann@xilinx.com>
---

Changes in v2:
- Remove ARCH checking reported by
  Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
- Change patch subject and description
- Tested by Kbuild test system without any reported problem.

 drivers/net/ethernet/cadence/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/etherne=
t/cadence/Kconfig
index 321d2ad235d9..739bb0048ebf 100644
--- a/drivers/net/ethernet/cadence/Kconfig
+++ b/drivers/net/ethernet/cadence/Kconfig
@@ -4,7 +4,7 @@
=20
 config NET_CADENCE
 	bool "Cadence devices"
-	depends on HAS_IOMEM && (ARM || AVR32 || MICROBLAZE || COMPILE_TEST)
+	depends on HAS_IOMEM
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
+	depends on HAS_DMA
 	select PHYLIB
 	---help---
 	  The Cadence MACB ethernet interface is found on many Atmel AT32 and
--=20
1.8.2.3
