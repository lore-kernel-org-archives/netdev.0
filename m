From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH] stmicro: rename it to dwc to improve future development
Date: Mon, 16 Jan 2017 13:26:31 +0000
Message-ID: <0f5b325a9c8d9e5b6c95f90d833278cfb8f77606.1484571696.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:53196 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751547AbdAPN0m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 08:26:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this patch is to create an oficial Designware Ethernet place
to deploy new drivers based on this family of IPs. stmmac was left
untouched since it is a designware based driver. New ethernet designware
IP based drivers should be placed in this place, improving code organization
and it becomes clear to the kernel user the purpose and scope of each driver.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/Kconfig                                     | 2 +-
 drivers/net/ethernet/Makefile                                    | 2 +-
 drivers/net/ethernet/{stmicro => dwc}/Kconfig                    | 7 ++++---
 drivers/net/ethernet/dwc/Makefile                                | 5 +++++
 drivers/net/ethernet/{stmicro => dwc}/stmmac/Kconfig             | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/Makefile            | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/altr_tse_pcs.c      | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/altr_tse_pcs.h      | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/chain_mode.c        | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/common.h            | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/descs.h             | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/descs_com.h         | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-dwc-qos-eth.c | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-generic.c     | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-ipq806x.c     | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-lpc18xx.c     | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-meson.c       | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-meson8b.c     | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-oxnas.c       | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-rk.c          | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-socfpga.c     | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-sti.c         | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-stm32.c       | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-sunxi.c       | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac100.h          | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac1000.h         | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac1000_core.c    | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac1000_dma.c     | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac100_core.c     | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac100_dma.c      | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac4.h            | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac4_core.c       | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac4_descs.c      | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac4_descs.h      | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac4_dma.c        | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac4_dma.h        | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac4_lib.c        | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac_dma.h         | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac_lib.c         | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/enh_desc.c          | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/mmc.h               | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/mmc_core.c          | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/norm_desc.c         | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/ring_mode.c         | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac.h            | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac_ethtool.c    | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac_hwtstamp.c   | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac_main.c       | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac_mdio.c       | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac_pci.c        | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac_pcs.h        | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac_platform.c   | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac_platform.h   | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac_ptp.c        | 0
 drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac_ptp.h        | 0
 drivers/net/ethernet/stmicro/Makefile                            | 5 -----
 56 files changed, 11 insertions(+), 10 deletions(-)
 rename drivers/net/ethernet/{stmicro => dwc}/Kconfig (68%)
 create mode 100644 drivers/net/ethernet/dwc/Makefile
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/Kconfig (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/Makefile (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/altr_tse_pcs.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/altr_tse_pcs.h (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/chain_mode.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/common.h (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/descs.h (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/descs_com.h (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-dwc-qos-eth.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-generic.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-ipq806x.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-lpc18xx.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-meson.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-meson8b.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-oxnas.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-rk.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-socfpga.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-sti.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-stm32.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac-sunxi.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac100.h (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac1000.h (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac1000_core.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac1000_dma.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac100_core.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac100_dma.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac4.h (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac4_core.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac4_descs.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac4_descs.h (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac4_dma.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac4_dma.h (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac4_lib.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac_dma.h (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/dwmac_lib.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/enh_desc.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/mmc.h (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/mmc_core.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/norm_desc.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/ring_mode.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac.h (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac_ethtool.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac_hwtstamp.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac_main.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac_mdio.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac_pci.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac_pcs.h (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac_platform.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac_platform.h (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac_ptp.c (100%)
 rename drivers/net/ethernet/{stmicro => dwc}/stmmac/stmmac_ptp.h (100%)
 delete mode 100644 drivers/net/ethernet/stmicro/Makefile

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index afc07d4..33fa603 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -168,7 +168,7 @@ source "drivers/net/ethernet/sis/Kconfig"
 source "drivers/net/ethernet/sfc/Kconfig"
 source "drivers/net/ethernet/sgi/Kconfig"
 source "drivers/net/ethernet/smsc/Kconfig"
-source "drivers/net/ethernet/stmicro/Kconfig"
+source "drivers/net/ethernet/dwc/Kconfig"
 source "drivers/net/ethernet/sun/Kconfig"
 source "drivers/net/ethernet/tehuti/Kconfig"
 source "drivers/net/ethernet/ti/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index e7861a8..fc81d9a 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -79,7 +79,7 @@ obj-$(CONFIG_SFC) += sfc/
 obj-$(CONFIG_SFC_FALCON) += sfc/falcon/
 obj-$(CONFIG_NET_VENDOR_SGI) += sgi/
 obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
-obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
+obj-$(CONFIG_NET_VENDOR_STMICRO) += dwc/
 obj-$(CONFIG_NET_VENDOR_SUN) += sun/
 obj-$(CONFIG_NET_VENDOR_TEHUTI) += tehuti/
 obj-$(CONFIG_NET_VENDOR_TI) += ti/
diff --git a/drivers/net/ethernet/stmicro/Kconfig b/drivers/net/ethernet/dwc/Kconfig
similarity index 68%
rename from drivers/net/ethernet/stmicro/Kconfig
rename to drivers/net/ethernet/dwc/Kconfig
index 1c1157d..fe3e630 100644
--- a/drivers/net/ethernet/stmicro/Kconfig
+++ b/drivers/net/ethernet/dwc/Kconfig
@@ -1,5 +1,5 @@
 #
-# STMicroelectronics device configuration
+# Designware based device drivers configuration
 #
 
 config NET_VENDOR_STMICRO
@@ -7,7 +7,8 @@ config NET_VENDOR_STMICRO
 	default y
 	depends on HAS_IOMEM
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y.
+	  If you have a network (Ethernet) card based on Designware
+	  Ethernet 10/100/1G/QoS IPs, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
@@ -16,6 +17,6 @@ config NET_VENDOR_STMICRO
 
 if NET_VENDOR_STMICRO
 
-source "drivers/net/ethernet/stmicro/stmmac/Kconfig"
+source "drivers/net/ethernet/dwc/stmmac/Kconfig"
 
 endif # NET_VENDOR_STMICRO
diff --git a/drivers/net/ethernet/dwc/Makefile b/drivers/net/ethernet/dwc/Makefile
new file mode 100644
index 0000000..788b1ba
--- /dev/null
+++ b/drivers/net/ethernet/dwc/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Designware based device drivers.
+#
+
+obj-$(CONFIG_STMMAC_ETH) += stmmac/
diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/dwc/stmmac/Kconfig
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/Kconfig
rename to drivers/net/ethernet/dwc/stmmac/Kconfig
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/dwc/stmmac/Makefile
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/Makefile
rename to drivers/net/ethernet/dwc/stmmac/Makefile
diff --git a/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c b/drivers/net/ethernet/dwc/stmmac/altr_tse_pcs.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c
rename to drivers/net/ethernet/dwc/stmmac/altr_tse_pcs.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.h b/drivers/net/ethernet/dwc/stmmac/altr_tse_pcs.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.h
rename to drivers/net/ethernet/dwc/stmmac/altr_tse_pcs.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/dwc/stmmac/chain_mode.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/chain_mode.c
rename to drivers/net/ethernet/dwc/stmmac/chain_mode.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/dwc/stmmac/common.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/common.h
rename to drivers/net/ethernet/dwc/stmmac/common.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/descs.h b/drivers/net/ethernet/dwc/stmmac/descs.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/descs.h
rename to drivers/net/ethernet/dwc/stmmac/descs.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/descs_com.h b/drivers/net/ethernet/dwc/stmmac/descs_com.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/descs_com.h
rename to drivers/net/ethernet/dwc/stmmac/descs_com.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c b/drivers/net/ethernet/dwc/stmmac/dwmac-dwc-qos-eth.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
rename to drivers/net/ethernet/dwc/stmmac/dwmac-dwc-qos-eth.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c b/drivers/net/ethernet/dwc/stmmac/dwmac-generic.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
rename to drivers/net/ethernet/dwc/stmmac/dwmac-generic.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c b/drivers/net/ethernet/dwc/stmmac/dwmac-ipq806x.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
rename to drivers/net/ethernet/dwc/stmmac/dwmac-ipq806x.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c b/drivers/net/ethernet/dwc/stmmac/dwmac-lpc18xx.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c
rename to drivers/net/ethernet/dwc/stmmac/dwmac-lpc18xx.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c b/drivers/net/ethernet/dwc/stmmac/dwmac-meson.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c
rename to drivers/net/ethernet/dwc/stmmac/dwmac-meson.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c b/drivers/net/ethernet/dwc/stmmac/dwmac-meson8b.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
rename to drivers/net/ethernet/dwc/stmmac/dwmac-meson8b.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c b/drivers/net/ethernet/dwc/stmmac/dwmac-oxnas.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c
rename to drivers/net/ethernet/dwc/stmmac/dwmac-oxnas.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/dwc/stmmac/dwmac-rk.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
rename to drivers/net/ethernet/dwc/stmmac/dwmac-rk.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/dwc/stmmac/dwmac-socfpga.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
rename to drivers/net/ethernet/dwc/stmmac/dwmac-socfpga.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/dwc/stmmac/dwmac-sti.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
rename to drivers/net/ethernet/dwc/stmmac/dwmac-sti.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c b/drivers/net/ethernet/dwc/stmmac/dwmac-stm32.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c
rename to drivers/net/ethernet/dwc/stmmac/dwmac-stm32.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c b/drivers/net/ethernet/dwc/stmmac/dwmac-sunxi.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
rename to drivers/net/ethernet/dwc/stmmac/dwmac-sunxi.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100.h b/drivers/net/ethernet/dwc/stmmac/dwmac100.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac100.h
rename to drivers/net/ethernet/dwc/stmmac/dwmac100.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/dwc/stmmac/dwmac1000.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
rename to drivers/net/ethernet/dwc/stmmac/dwmac1000.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/dwc/stmmac/dwmac1000_core.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
rename to drivers/net/ethernet/dwc/stmmac/dwmac1000_core.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/dwc/stmmac/dwmac1000_dma.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
rename to drivers/net/ethernet/dwc/stmmac/dwmac1000_dma.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c b/drivers/net/ethernet/dwc/stmmac/dwmac100_core.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
rename to drivers/net/ethernet/dwc/stmmac/dwmac100_core.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c b/drivers/net/ethernet/dwc/stmmac/dwmac100_dma.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
rename to drivers/net/ethernet/dwc/stmmac/dwmac100_dma.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/dwc/stmmac/dwmac4.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac4.h
rename to drivers/net/ethernet/dwc/stmmac/dwmac4.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/dwc/stmmac/dwmac4_core.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
rename to drivers/net/ethernet/dwc/stmmac/dwmac4_core.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c b/drivers/net/ethernet/dwc/stmmac/dwmac4_descs.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
rename to drivers/net/ethernet/dwc/stmmac/dwmac4_descs.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h b/drivers/net/ethernet/dwc/stmmac/dwmac4_descs.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h
rename to drivers/net/ethernet/dwc/stmmac/dwmac4_descs.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/dwc/stmmac/dwmac4_dma.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
rename to drivers/net/ethernet/dwc/stmmac/dwmac4_dma.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h b/drivers/net/ethernet/dwc/stmmac/dwmac4_dma.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
rename to drivers/net/ethernet/dwc/stmmac/dwmac4_dma.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c b/drivers/net/ethernet/dwc/stmmac/dwmac4_lib.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
rename to drivers/net/ethernet/dwc/stmmac/dwmac4_lib.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h b/drivers/net/ethernet/dwc/stmmac/dwmac_dma.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
rename to drivers/net/ethernet/dwc/stmmac/dwmac_dma.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/dwc/stmmac/dwmac_lib.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
rename to drivers/net/ethernet/dwc/stmmac/dwmac_lib.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/dwc/stmmac/enh_desc.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/enh_desc.c
rename to drivers/net/ethernet/dwc/stmmac/enh_desc.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/mmc.h b/drivers/net/ethernet/dwc/stmmac/mmc.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/mmc.h
rename to drivers/net/ethernet/dwc/stmmac/mmc.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c b/drivers/net/ethernet/dwc/stmmac/mmc_core.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/mmc_core.c
rename to drivers/net/ethernet/dwc/stmmac/mmc_core.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/dwc/stmmac/norm_desc.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/norm_desc.c
rename to drivers/net/ethernet/dwc/stmmac/norm_desc.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/dwc/stmmac/ring_mode.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/ring_mode.c
rename to drivers/net/ethernet/dwc/stmmac/ring_mode.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/dwc/stmmac/stmmac.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac.h
rename to drivers/net/ethernet/dwc/stmmac/stmmac.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/dwc/stmmac/stmmac_ethtool.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
rename to drivers/net/ethernet/dwc/stmmac/stmmac_ethtool.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c b/drivers/net/ethernet/dwc/stmmac/stmmac_hwtstamp.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
rename to drivers/net/ethernet/dwc/stmmac/stmmac_hwtstamp.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/dwc/stmmac/stmmac_main.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
rename to drivers/net/ethernet/dwc/stmmac/stmmac_main.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/dwc/stmmac/stmmac_mdio.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
rename to drivers/net/ethernet/dwc/stmmac/stmmac_mdio.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/dwc/stmmac/stmmac_pci.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
rename to drivers/net/ethernet/dwc/stmmac/stmmac_pci.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pcs.h b/drivers/net/ethernet/dwc/stmmac/stmmac_pcs.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac_pcs.h
rename to drivers/net/ethernet/dwc/stmmac/stmmac_pcs.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/dwc/stmmac/stmmac_platform.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
rename to drivers/net/ethernet/dwc/stmmac/stmmac_platform.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h b/drivers/net/ethernet/dwc/stmmac/stmmac_platform.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
rename to drivers/net/ethernet/dwc/stmmac/stmmac_platform.h
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c b/drivers/net/ethernet/dwc/stmmac/stmmac_ptp.c
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
rename to drivers/net/ethernet/dwc/stmmac/stmmac_ptp.c
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h b/drivers/net/ethernet/dwc/stmmac/stmmac_ptp.h
similarity index 100%
rename from drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
rename to drivers/net/ethernet/dwc/stmmac/stmmac_ptp.h
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
-- 
2.9.3
