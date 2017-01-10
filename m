From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH 2/2] stmmac: rename it to synopsys
Date: Tue, 10 Jan 2017 11:42:29 +0000
Message-ID: <e054fff2aa9b4e0f12fe76917d95d8111301f0fa.1484047430.git.jpinto@synopsys.com>
References: <cover.1484047430.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <lars.persson@axis.com>, <niklass@axis.com>,
        <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.60.111]:38936 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760997AbdAJLmm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 06:42:42 -0500
In-Reply-To: <cover.1484047430.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch renames stmicro/stmmac to synopsys/ since it is a standard
ethernet software package regarding synopsys ethernet controllers, supporting
the majority of Synopsys Ethernet IPs. The config IDs remain the same, for
retro-compatibility, only the description was changed.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 .../bindings/net/{stmmac.txt => synopsys.txt}       |  0
 MAINTAINERS                                         |  4 ++--
 drivers/net/ethernet/Kconfig                        |  2 +-
 drivers/net/ethernet/Makefile                       |  2 +-
 drivers/net/ethernet/stmicro/Kconfig                | 21 ---------------------
 drivers/net/ethernet/stmicro/Makefile               |  5 -----
 .../ethernet/{stmicro/stmmac => synopsys}/Kconfig   |  8 ++++----
 .../ethernet/{stmicro/stmmac => synopsys}/Makefile  |  0
 .../{stmicro/stmmac => synopsys}/altr_tse_pcs.c     |  0
 .../{stmicro/stmmac => synopsys}/altr_tse_pcs.h     |  0
 .../{stmicro/stmmac => synopsys}/chain_mode.c       |  0
 .../ethernet/{stmicro/stmmac => synopsys}/common.h  |  0
 .../ethernet/{stmicro/stmmac => synopsys}/descs.h   |  0
 .../{stmicro/stmmac => synopsys}/descs_com.h        |  0
 .../stmmac => synopsys}/dwmac-dwc-qos-eth.c         |  0
 .../{stmicro/stmmac => synopsys}/dwmac-generic.c    |  0
 .../{stmicro/stmmac => synopsys}/dwmac-ipq806x.c    |  0
 .../{stmicro/stmmac => synopsys}/dwmac-lpc18xx.c    |  0
 .../{stmicro/stmmac => synopsys}/dwmac-meson.c      |  0
 .../{stmicro/stmmac => synopsys}/dwmac-meson8b.c    |  0
 .../{stmicro/stmmac => synopsys}/dwmac-oxnas.c      |  0
 .../{stmicro/stmmac => synopsys}/dwmac-rk.c         |  0
 .../{stmicro/stmmac => synopsys}/dwmac-socfpga.c    |  0
 .../{stmicro/stmmac => synopsys}/dwmac-sti.c        |  0
 .../{stmicro/stmmac => synopsys}/dwmac-stm32.c      |  0
 .../{stmicro/stmmac => synopsys}/dwmac-sunxi.c      |  0
 .../{stmicro/stmmac => synopsys}/dwmac100.h         |  0
 .../{stmicro/stmmac => synopsys}/dwmac1000.h        |  0
 .../{stmicro/stmmac => synopsys}/dwmac1000_core.c   |  0
 .../{stmicro/stmmac => synopsys}/dwmac1000_dma.c    |  0
 .../{stmicro/stmmac => synopsys}/dwmac100_core.c    |  0
 .../{stmicro/stmmac => synopsys}/dwmac100_dma.c     |  0
 .../ethernet/{stmicro/stmmac => synopsys}/dwmac4.h  |  0
 .../{stmicro/stmmac => synopsys}/dwmac4_core.c      |  0
 .../{stmicro/stmmac => synopsys}/dwmac4_descs.c     |  0
 .../{stmicro/stmmac => synopsys}/dwmac4_descs.h     |  0
 .../{stmicro/stmmac => synopsys}/dwmac4_dma.c       |  0
 .../{stmicro/stmmac => synopsys}/dwmac4_dma.h       |  0
 .../{stmicro/stmmac => synopsys}/dwmac4_lib.c       |  0
 .../{stmicro/stmmac => synopsys}/dwmac_dma.h        |  0
 .../{stmicro/stmmac => synopsys}/dwmac_lib.c        |  0
 .../{stmicro/stmmac => synopsys}/enh_desc.c         |  0
 .../net/ethernet/{stmicro/stmmac => synopsys}/mmc.h |  0
 .../{stmicro/stmmac => synopsys}/mmc_core.c         |  0
 .../{stmicro/stmmac => synopsys}/norm_desc.c        |  0
 .../{stmicro/stmmac => synopsys}/ring_mode.c        |  0
 .../ethernet/{stmicro/stmmac => synopsys}/stmmac.h  |  0
 .../{stmicro/stmmac => synopsys}/stmmac_ethtool.c   |  0
 .../{stmicro/stmmac => synopsys}/stmmac_hwtstamp.c  |  0
 .../{stmicro/stmmac => synopsys}/stmmac_main.c      |  0
 .../{stmicro/stmmac => synopsys}/stmmac_mdio.c      |  0
 .../{stmicro/stmmac => synopsys}/stmmac_pci.c       |  0
 .../{stmicro/stmmac => synopsys}/stmmac_pcs.h       |  0
 .../{stmicro/stmmac => synopsys}/stmmac_platform.c  |  0
 .../{stmicro/stmmac => synopsys}/stmmac_platform.h  |  0
 .../{stmicro/stmmac => synopsys}/stmmac_ptp.c       |  0
 .../{stmicro/stmmac => synopsys}/stmmac_ptp.h       |  0
 57 files changed, 8 insertions(+), 34 deletions(-)
 rename Documentation/devicetree/bindings/net/{stmmac.txt => synopsys.txt} (100%)
 delete mode 100644 drivers/net/ethernet/stmicro/Kconfig
 delete mode 100644 drivers/net/ethernet/stmicro/Makefile
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/Kconfig (95%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/Makefile (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/altr_tse_pcs.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/altr_tse_pcs.h (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/chain_mode.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/common.h (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/descs.h (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/descs_com.h (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-dwc-qos-eth.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-generic.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-ipq806x.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-lpc18xx.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-meson.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-meson8b.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-oxnas.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-rk.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-socfpga.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-sti.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-stm32.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac-sunxi.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac100.h (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac1000.h (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac1000_core.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac1000_dma.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac100_core.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac100_dma.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac4.h (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac4_core.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac4_descs.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac4_descs.h (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac4_dma.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac4_dma.h (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac4_lib.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac_dma.h (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/dwmac_lib.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/enh_desc.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/mmc.h (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/mmc_core.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/norm_desc.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/ring_mode.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac.h (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac_ethtool.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac_hwtstamp.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac_main.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac_mdio.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac_pci.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac_pcs.h (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac_platform.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac_platform.h (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac_ptp.c (100%)
 rename drivers/net/ethernet/{stmicro/stmmac => synopsys}/stmmac_ptp.h (100%)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/synopsys.txt
similarity index 100%
rename from Documentation/devicetree/bindings/net/stmmac.txt
rename to Documentation/devicetree/bindings/net/synopsys.txt
diff --git a/MAINTAINERS b/MAINTAINERS
index c8df0e1..1adca56 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3629,13 +3629,13 @@ F:	drivers/scsi/cxlflash/
 F:	include/uapi/scsi/cxlflash_ioctls.h
 F:	Documentation/powerpc/cxlflash.txt
 
-STMMAC ETHERNET DRIVER
+SYNOPSYS ETHERNET DRIVER
 M:	Giuseppe Cavallaro <peppe.cavallaro@st.com>
 M:	Alexandre Torgue <alexandre.torgue@st.com>
 L:	netdev@vger.kernel.org
 W:	http://www.stlinux.com
 S:	Supported
-F:	drivers/net/ethernet/stmicro/stmmac/
+F:	drivers/net/ethernet/synopsys/
 
 CYBERPRO FB DRIVER
 M:	Russell King <linux@armlinux.org.uk>
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index afc07d4..c86c46d 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -168,7 +168,7 @@ source "drivers/net/ethernet/sis/Kconfig"
 source "drivers/net/ethernet/sfc/Kconfig"
 source "drivers/net/ethernet/sgi/Kconfig"
 source "drivers/net/ethernet/smsc/Kconfig"
-source "drivers/net/ethernet/stmicro/Kconfig"
+source "drivers/net/ethernet/synopsys/Kconfig"
 source "drivers/net/ethernet/sun/Kconfig"
 source "drivers/net/ethernet/tehuti/Kconfig"
 source "drivers/net/ethernet/ti/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index e7861a8..4afea0f 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -79,7 +79,7 @@ obj-$(CONFIG_SFC) += sfc/
 obj-$(CONFIG_SFC_FALCON) += sfc/falcon/
 obj-$(CONFIG_NET_VENDOR_SGI) += sgi/
 obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
-obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
+obj-y += synopsys/
 obj-$(CONFIG_NET_VENDOR_SUN) += sun/
 obj-$(CONFIG_NET_VENDOR_TEHUTI) += tehuti/
 obj-$(CONFIG_NET_VENDOR_TI) += ti/
diff --git a/drivers/net/ethernet/stmicro/Kconfig b/drivers/net/ethernet/stmicro/Kconfig
deleted file mode 100644
index 1c1157d..0000000
--- a/drivers/net/ethernet/stmicro/Kconfig
+++ /dev/null
@@ -1,21 +0,0 @@
-#
-# STMicroelectronics device configuration
-#
-
-config NET_VENDOR_STMICRO
-	bool "STMicroelectronics devices"
-	default y
-	depends on HAS_IOMEM
-	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y.
-
-	  Note that the answer to this question doesn't directly affect the
-	  kernel: saying N will just cause the configurator to skip all
-	  the questions about STMicroelectronics cards. If you say Y, you will
-	  be asked for your specific card in the following questions.
-
-if NET_VENDOR_STMICRO
-
-source "drivers/net/ethernet/stmicro/stmmac/Kconfig"
-
-endif # NET_VENDOR_STMICRO
diff --git a/drivers/net/ethernet/stmicro/Makefile b/drivers/net/ethernet/stmicro/Makefile
deleted file mode 100644
index 9b3bfdd..0000000
--- a/drivers/net/ethernet/stmicro/Makefile
+++ /dev/null
@@ -1,5 +0,0 @@
-#
-# Makefile for the STMicroelectronics device drivers.
-#
-
-obj-$(CONFIG_STMMAC_ETH) += stmmac/
diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/synopsys/Kconfig
similarity index 95%
rename from drivers/net/ethernet/stmicro/stmmac/Kconfig
rename to drivers/net/ethernet/synopsys/Kconfig
index 99594e3..16db88e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/synopsys/Kconfig
@@ -1,5 +1,5 @@
 config STMMAC_ETH
-	tristate "STMicroelectronics 10/100/1000 Ethernet driver"
+	tristate "Synopsys Ethernet drivers"
 	depends on HAS_IOMEM && HAS_DMA
 	select MII
 	select PHYLIB
@@ -14,7 +14,7 @@ config STMMAC_ETH
 if STMMAC_ETH
 
 config STMMAC_PLATFORM
-	tristate "STMMAC Platform bus support"
+	tristate "Platform bus support"
 	depends on STMMAC_ETH
 	select MFD_SYSCON
 	default y
@@ -149,13 +149,13 @@ config DWMAC_SUNXI
 endif
 
 config STMMAC_PCI
-	tristate "STMMAC PCI bus support"
+	tristate "PCI bus support"
 	depends on STMMAC_ETH && PCI
 	---help---
 	  This is to select the Synopsys DWMAC available on PCI devices,
 	  if you have a controller with this interface, say Y or M here.
 
-	  This PCI support is tested on XLINX XC2V3000 FF1152AMT0221
+	  This PCI support was tested on XLINX XC2V3000 FF1152AMT0221
 	  D1215994A VIRTEX FPGA board.
 
 	  If unsure, say N.
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/synopsys/Makefile
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/Makefile
rename to drivers/net/ethernet/synopsys/Makefile
diff --git a/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c b/drivers/net/ethernet/synopsys/altr_tse_pcs.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c
rename to drivers/net/ethernet/synopsys/altr_tse_pcs.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.h b/drivers/net/ethernet/synopsys/altr_tse_pcs.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.h
rename to drivers/net/ethernet/synopsys/altr_tse_pcs.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/synopsys/chain_mode.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/chain_mode.c
rename to drivers/net/ethernet/synopsys/chain_mode.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/synopsys/common.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/common.h
rename to drivers/net/ethernet/synopsys/common.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/descs.h b/drivers/net/ethernet/synopsys/descs.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/descs.h
rename to drivers/net/ethernet/synopsys/descs.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/descs_com.h b/drivers/net/ethernet/synopsys/descs_com.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/descs_com.h
rename to drivers/net/ethernet/synopsys/descs_com.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c b/drivers/net/ethernet/synopsys/dwmac-dwc-qos-eth.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
rename to drivers/net/ethernet/synopsys/dwmac-dwc-qos-eth.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c b/drivers/net/ethernet/synopsys/dwmac-generic.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
rename to drivers/net/ethernet/synopsys/dwmac-generic.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c b/drivers/net/ethernet/synopsys/dwmac-ipq806x.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
rename to drivers/net/ethernet/synopsys/dwmac-ipq806x.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c b/drivers/net/ethernet/synopsys/dwmac-lpc18xx.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c
rename to drivers/net/ethernet/synopsys/dwmac-lpc18xx.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c b/drivers/net/ethernet/synopsys/dwmac-meson.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c
rename to drivers/net/ethernet/synopsys/dwmac-meson.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c b/drivers/net/ethernet/synopsys/dwmac-meson8b.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
rename to drivers/net/ethernet/synopsys/dwmac-meson8b.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c b/drivers/net/ethernet/synopsys/dwmac-oxnas.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c
rename to drivers/net/ethernet/synopsys/dwmac-oxnas.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/synopsys/dwmac-rk.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
rename to drivers/net/ethernet/synopsys/dwmac-rk.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/synopsys/dwmac-socfpga.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
rename to drivers/net/ethernet/synopsys/dwmac-socfpga.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/synopsys/dwmac-sti.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
rename to drivers/net/ethernet/synopsys/dwmac-sti.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c b/drivers/net/ethernet/synopsys/dwmac-stm32.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c
rename to drivers/net/ethernet/synopsys/dwmac-stm32.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c b/drivers/net/ethernet/synopsys/dwmac-sunxi.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
rename to drivers/net/ethernet/synopsys/dwmac-sunxi.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100.h b/drivers/net/ethernet/synopsys/dwmac100.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac100.h
rename to drivers/net/ethernet/synopsys/dwmac100.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/synopsys/dwmac1000.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
rename to drivers/net/ethernet/synopsys/dwmac1000.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/synopsys/dwmac1000_core.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
rename to drivers/net/ethernet/synopsys/dwmac1000_core.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/synopsys/dwmac1000_dma.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
rename to drivers/net/ethernet/synopsys/dwmac1000_dma.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c b/drivers/net/ethernet/synopsys/dwmac100_core.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
rename to drivers/net/ethernet/synopsys/dwmac100_core.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c b/drivers/net/ethernet/synopsys/dwmac100_dma.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
rename to drivers/net/ethernet/synopsys/dwmac100_dma.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/synopsys/dwmac4.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac4.h
rename to drivers/net/ethernet/synopsys/dwmac4.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/synopsys/dwmac4_core.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
rename to drivers/net/ethernet/synopsys/dwmac4_core.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c b/drivers/net/ethernet/synopsys/dwmac4_descs.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
rename to drivers/net/ethernet/synopsys/dwmac4_descs.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h b/drivers/net/ethernet/synopsys/dwmac4_descs.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h
rename to drivers/net/ethernet/synopsys/dwmac4_descs.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/synopsys/dwmac4_dma.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
rename to drivers/net/ethernet/synopsys/dwmac4_dma.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h b/drivers/net/ethernet/synopsys/dwmac4_dma.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
rename to drivers/net/ethernet/synopsys/dwmac4_dma.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c b/drivers/net/ethernet/synopsys/dwmac4_lib.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
rename to drivers/net/ethernet/synopsys/dwmac4_lib.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h b/drivers/net/ethernet/synopsys/dwmac_dma.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
rename to drivers/net/ethernet/synopsys/dwmac_dma.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/synopsys/dwmac_lib.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
rename to drivers/net/ethernet/synopsys/dwmac_lib.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/synopsys/enh_desc.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/enh_desc.c
rename to drivers/net/ethernet/synopsys/enh_desc.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/mmc.h b/drivers/net/ethernet/synopsys/mmc.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/mmc.h
rename to drivers/net/ethernet/synopsys/mmc.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c b/drivers/net/ethernet/synopsys/mmc_core.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/mmc_core.c
rename to drivers/net/ethernet/synopsys/mmc_core.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/synopsys/norm_desc.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/norm_desc.c
rename to drivers/net/ethernet/synopsys/norm_desc.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/synopsys/ring_mode.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/ring_mode.c
rename to drivers/net/ethernet/synopsys/ring_mode.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/synopsys/stmmac.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac.h
rename to drivers/net/ethernet/synopsys/stmmac.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/synopsys/stmmac_ethtool.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
rename to drivers/net/ethernet/synopsys/stmmac_ethtool.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c b/drivers/net/ethernet/synopsys/stmmac_hwtstamp.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
rename to drivers/net/ethernet/synopsys/stmmac_hwtstamp.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/synopsys/stmmac_main.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
rename to drivers/net/ethernet/synopsys/stmmac_main.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/synopsys/stmmac_mdio.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
rename to drivers/net/ethernet/synopsys/stmmac_mdio.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/synopsys/stmmac_pci.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
rename to drivers/net/ethernet/synopsys/stmmac_pci.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pcs.h b/drivers/net/ethernet/synopsys/stmmac_pcs.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac_pcs.h
rename to drivers/net/ethernet/synopsys/stmmac_pcs.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/synopsys/stmmac_platform.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
rename to drivers/net/ethernet/synopsys/stmmac_platform.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h b/drivers/net/ethernet/synopsys/stmmac_platform.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
rename to drivers/net/ethernet/synopsys/stmmac_platform.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c b/drivers/net/ethernet/synopsys/stmmac_ptp.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
rename to drivers/net/ethernet/synopsys/stmmac_ptp.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h b/drivers/net/ethernet/synopsys/stmmac_ptp.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
rename to drivers/net/ethernet/synopsys/stmmac_ptp.h
-- 
2.9.3
