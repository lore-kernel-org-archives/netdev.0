From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 09/20] drivers/net/irda: remove depends on CONFIG_EXPERIMENTAL
Date: Tue, 22 Jan 2013 10:30:33 -0800
Message-ID: <1358879444-25834-10-git-send-email-keescook@chromium.org>
References: <1358879444-25834-1-git-send-email-keescook@chromium.org>
Cc: netdev@vger.kernel.org, Kees Cook <keescook@chromium.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.outflux.net ([198.145.64.163]:59329 "EHLO smtp.outflux.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753899Ab3AVSbe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 13:31:34 -0500
In-Reply-To: <1358879444-25834-1-git-send-email-keescook@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The CONFIG_EXPERIMENTAL config item has not carried much meaning for a
while now and is almost always enabled by default. As agreed during the
Linux kernel summit, remove it from any "depends on" lines in Kconfigs.

CC: Samuel Ortiz <samuel@sortiz.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: NetDev <netdev@vger.kernel.org>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/irda/Kconfig |   36 ++++++++++++++++++------------------
 1 file changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/irda/Kconfig b/drivers/net/irda/Kconfig
index e1454cd..2a30193 100644
--- a/drivers/net/irda/Kconfig
+++ b/drivers/net/irda/Kconfig
@@ -140,7 +140,7 @@ config LITELINK_DONGLE
 
 config MA600_DONGLE
 	tristate "Mobile Action MA600 dongle"
-	depends on IRTTY_SIR && DONGLE && IRDA && EXPERIMENTAL
+	depends on IRTTY_SIR && DONGLE && IRDA
 	help
 	  Say Y here if you want to build support for the Mobile Action MA600
 	  dongle.  To compile it as a module, choose M here. The MA600 dongle
@@ -153,7 +153,7 @@ config MA600_DONGLE
 
 config GIRBIL_DONGLE
 	tristate "Greenwich GIrBIL dongle"
-	depends on IRTTY_SIR && DONGLE && IRDA && EXPERIMENTAL
+	depends on IRTTY_SIR && DONGLE && IRDA
 	help
 	  Say Y here if you want to build support for the Greenwich GIrBIL
 	  dongle.  If you want to compile it as a module, choose M here.
@@ -164,7 +164,7 @@ config GIRBIL_DONGLE
 
 config MCP2120_DONGLE
 	tristate "Microchip MCP2120"
-	depends on IRTTY_SIR && DONGLE && IRDA && EXPERIMENTAL
+	depends on IRTTY_SIR && DONGLE && IRDA
 	help
 	  Say Y here if you want to build support for the Microchip MCP2120
 	  dongle.  If you want to compile it as a module, choose M here.
@@ -178,7 +178,7 @@ config MCP2120_DONGLE
 
 config OLD_BELKIN_DONGLE
 	tristate "Old Belkin dongle"
-	depends on IRTTY_SIR && DONGLE && IRDA && EXPERIMENTAL
+	depends on IRTTY_SIR && DONGLE && IRDA
 	help
 	  Say Y here if you want to build support for the Adaptec Airport 1000
 	  and 2000 dongles.  If you want to compile it as a module, choose
@@ -187,7 +187,7 @@ config OLD_BELKIN_DONGLE
 
 config ACT200L_DONGLE
 	tristate "ACTiSYS IR-200L dongle"
-	depends on IRTTY_SIR && DONGLE && IRDA && EXPERIMENTAL
+	depends on IRTTY_SIR && DONGLE && IRDA
 	help
 	  Say Y here if you want to build support for the ACTiSYS IR-200L
 	  dongle. If you want to compile it as a module, choose M here.
@@ -198,7 +198,7 @@ config ACT200L_DONGLE
 
 config KINGSUN_DONGLE
 	tristate "KingSun/DonShine DS-620 IrDA-USB dongle"
-	depends on IRDA && USB && EXPERIMENTAL
+	depends on IRDA && USB
 	help
 	  Say Y or M here if you want to build support for the KingSun/DonShine
 	  DS-620 IrDA-USB bridge device driver.
@@ -212,14 +212,14 @@ config KINGSUN_DONGLE
 
 config EP7211_DONGLE
 	tristate "Cirrus Logic clps711x I/R support"
-	depends on IRTTY_SIR && ARCH_CLPS711X && IRDA && EXPERIMENTAL
+	depends on IRTTY_SIR && ARCH_CLPS711X && IRDA
 	help
 	  Say Y here if you want to build support for the Cirrus logic
 	  EP7211 chipset's infrared module.
 
 config KSDAZZLE_DONGLE
-	tristate "KingSun Dazzle IrDA-USB dongle (EXPERIMENTAL)"
-	depends on IRDA && USB && EXPERIMENTAL
+	tristate "KingSun Dazzle IrDA-USB dongle"
+	depends on IRDA && USB
 	help
 	  Say Y or M here if you want to build support for the KingSun Dazzle
 	  IrDA-USB bridge device driver.
@@ -232,8 +232,8 @@ config KSDAZZLE_DONGLE
 	  ksdazzle-sir.
 
 config KS959_DONGLE
-	tristate "KingSun KS-959 IrDA-USB dongle (EXPERIMENTAL)"
-	depends on IRDA && USB && EXPERIMENTAL
+	tristate "KingSun KS-959 IrDA-USB dongle"
+	depends on IRDA && USB
 	help
 	  Say Y or M here if you want to build support for the KingSun KS-959
 	  IrDA-USB bridge device driver.
@@ -264,8 +264,8 @@ config USB_IRDA
 	  you will need both USB and IrDA support in your kernel...
 
 config SIGMATEL_FIR
-	tristate "SigmaTel STIr4200 bridge (EXPERIMENTAL)"
-	depends on IRDA && USB && EXPERIMENTAL
+	tristate "SigmaTel STIr4200 bridge"
+	depends on IRDA && USB
 	select CRC32
 	---help---
 	  Say Y here if you want to build support for the SigmaTel STIr4200
@@ -331,8 +331,8 @@ config SMC_IRCC_FIR
 	  smsc-ircc2.o.
 
 config ALI_FIR
-	tristate "ALi M5123 FIR (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && IRDA && ISA_DMA_API
+	tristate "ALi M5123 FIR"
+	depends on IRDA && ISA_DMA_API
 	help
 	  Say Y here if you want to build support for the ALi M5123 FIR
 	  Controller.  The ALi M5123 FIR Controller is embedded in ALi M1543C,
@@ -343,8 +343,8 @@ config ALI_FIR
 	  ali-ircc.
 
 config VLSI_FIR
-	tristate "VLSI 82C147 SIR/MIR/FIR (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && IRDA && PCI
+	tristate "VLSI 82C147 SIR/MIR/FIR"
+	depends on IRDA && PCI
 	help
 	  Say Y here if you want to build support for the VLSI 82C147
 	  PCI-IrDA Controller. This controller is used by the HP OmniBook 800
@@ -387,7 +387,7 @@ config PXA_FICP
 
 config MCS_FIR
 	tristate "MosChip MCS7780 IrDA-USB dongle"
-	depends on IRDA && USB && EXPERIMENTAL
+	depends on IRDA && USB
 	select CRC32
 	help
 	  Say Y or M here if you want to build support for the MosChip
-- 
1.7.9.5
