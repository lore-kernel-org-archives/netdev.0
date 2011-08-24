From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/10] drivers/net/ethernet/*: Enabled vendor Kconfig options
Date: Wed, 24 Aug 2011 02:02:50 -0700
Message-ID: <1314176570-20298-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314176570-20298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Stephen Rothwll <sfc@canb.auug.org.au>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16270 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756457Ab1HXJDG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Aug 2011 05:03:06 -0400
In-Reply-To: <1314176570-20298-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on finds for Stephen Rothwell, where current defconfig's
enable a ethernet driver and it is not compiled due to the newly
added NET_VENDOR_* component of Kconfig.

This patch enables all the "new" Kconfig options so that current
defconfig's will continue to compile the expected drivers.  In
addition, by enabling all the new Kconfig options does not add
any un-expected options.

CC: Stephen Rothwll <sfc@canb.auug.org.au>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/3com/Kconfig      |    1 +
 drivers/net/ethernet/8390/Kconfig      |    1 +
 drivers/net/ethernet/adaptec/Kconfig   |    1 +
 drivers/net/ethernet/alteon/Kconfig    |    1 +
 drivers/net/ethernet/amd/Kconfig       |    1 +
 drivers/net/ethernet/apple/Kconfig     |    1 +
 drivers/net/ethernet/atheros/Kconfig   |    1 +
 drivers/net/ethernet/broadcom/Kconfig  |    1 +
 drivers/net/ethernet/brocade/Kconfig   |    1 +
 drivers/net/ethernet/chelsio/Kconfig   |    1 +
 drivers/net/ethernet/cirrus/Kconfig    |    1 +
 drivers/net/ethernet/cisco/Kconfig     |    1 +
 drivers/net/ethernet/dec/Kconfig       |    1 +
 drivers/net/ethernet/dlink/Kconfig     |    1 +
 drivers/net/ethernet/emulex/Kconfig    |    1 +
 drivers/net/ethernet/faraday/Kconfig   |    1 +
 drivers/net/ethernet/freescale/Kconfig |    1 +
 drivers/net/ethernet/fujitsu/Kconfig   |    1 +
 drivers/net/ethernet/hp/Kconfig        |    1 +
 drivers/net/ethernet/i825xx/Kconfig    |    1 +
 drivers/net/ethernet/ibm/Kconfig       |    1 +
 drivers/net/ethernet/intel/Kconfig     |    1 +
 drivers/net/ethernet/marvell/Kconfig   |    1 +
 drivers/net/ethernet/mellanox/Kconfig  |    1 +
 drivers/net/ethernet/micrel/Kconfig    |    1 +
 drivers/net/ethernet/microchip/Kconfig |    1 +
 drivers/net/ethernet/myricom/Kconfig   |    1 +
 drivers/net/ethernet/natsemi/Kconfig   |    1 +
 drivers/net/ethernet/neterion/Kconfig  |    1 +
 drivers/net/ethernet/nuvoton/Kconfig   |    1 +
 drivers/net/ethernet/nvidia/Kconfig    |    1 +
 drivers/net/ethernet/oki-semi/Kconfig  |    1 +
 drivers/net/ethernet/pasemi/Kconfig    |    1 +
 drivers/net/ethernet/qlogic/Kconfig    |    1 +
 drivers/net/ethernet/racal/Kconfig     |    1 +
 drivers/net/ethernet/rdc/Kconfig       |    1 +
 drivers/net/ethernet/realtek/Kconfig   |    1 +
 drivers/net/ethernet/seeq/Kconfig      |    1 +
 drivers/net/ethernet/sgi/Kconfig       |    1 +
 drivers/net/ethernet/sis/Kconfig       |    1 +
 drivers/net/ethernet/smsc/Kconfig      |    1 +
 drivers/net/ethernet/stmicro/Kconfig   |    1 +
 drivers/net/ethernet/sun/Kconfig       |    1 +
 drivers/net/ethernet/tehuti/Kconfig    |    1 +
 drivers/net/ethernet/ti/Kconfig        |    1 +
 drivers/net/ethernet/toshiba/Kconfig   |    1 +
 drivers/net/ethernet/tundra/Kconfig    |    1 +
 drivers/net/ethernet/via/Kconfig       |    1 +
 drivers/net/ethernet/xilinx/Kconfig    |    1 +
 drivers/net/ethernet/xircom/Kconfig    |    1 +
 drivers/net/ethernet/xscale/Kconfig    |    1 +
 51 files changed, 51 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/3com/Kconfig b/drivers/net/ethernet/3com/Kconfig
index 65cc129..a439cbd 100644
--- a/drivers/net/ethernet/3com/Kconfig
+++ b/drivers/net/ethernet/3com/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_3COM
 	bool "3Com devices"
+	default y
 	depends on ISA || EISA || MCA || PCI || PCMCIA
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/8390/Kconfig b/drivers/net/ethernet/8390/Kconfig
index 5d21698..e04ade4 100644
--- a/drivers/net/ethernet/8390/Kconfig
+++ b/drivers/net/ethernet/8390/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_8390
 	bool "National Semi-conductor 8390 devices"
+	default y
 	depends on NET_VENDOR_NATSEMI && (AMIGA_PCMCIA || PCI || SUPERH || \
 		   ISA || MCA || EISA || MAC || M32R || MACH_TX49XX || \
 		   MCA_LEGACY || H8300 || ARM || MIPS || ZORRO || PCMCIA || \
diff --git a/drivers/net/ethernet/adaptec/Kconfig b/drivers/net/ethernet/adaptec/Kconfig
index 5e9dbe9..5c804bb 100644
--- a/drivers/net/ethernet/adaptec/Kconfig
+++ b/drivers/net/ethernet/adaptec/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_ADAPTEC
 	bool "Adaptec devices"
+	default y
 	depends on PCI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/alteon/Kconfig b/drivers/net/ethernet/alteon/Kconfig
index 68862e4..799a852 100644
--- a/drivers/net/ethernet/alteon/Kconfig
+++ b/drivers/net/ethernet/alteon/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_ALTEON
 	bool "Alteon devices"
+	default y
 	depends on PCI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/amd/Kconfig b/drivers/net/ethernet/amd/Kconfig
index 0513940..8af1c93 100644
--- a/drivers/net/ethernet/amd/Kconfig
+++ b/drivers/net/ethernet/amd/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_AMD
 	bool "AMD devices"
+	default y
 	depends on DIO || MACH_DECSTATION || MVME147 || ATARI || SUN3 || \
 		   SUN3X || SBUS || PCI || ZORRO || (ISA && ISA_DMA_API) || \
 		   (ARM && ARCH_EBSA110) || ISA || EISA || MCA || PCMCIA
diff --git a/drivers/net/ethernet/apple/Kconfig b/drivers/net/ethernet/apple/Kconfig
index fc796bc..59d5c26 100644
--- a/drivers/net/ethernet/apple/Kconfig
+++ b/drivers/net/ethernet/apple/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_APPLE
 	bool "Apple devices"
+	default y
 	depends on (PPC_PMAC && PPC32) || MAC || ISA || EISA || MACH_IXDP2351 \
 		   || ARCH_IXDP2X01 || MACH_MX31ADS || MACH_QQ2440
 	---help---
diff --git a/drivers/net/ethernet/atheros/Kconfig b/drivers/net/ethernet/atheros/Kconfig
index 966c6c7..26ab8ca 100644
--- a/drivers/net/ethernet/atheros/Kconfig
+++ b/drivers/net/ethernet/atheros/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_ATHEROS
 	bool "Atheros devices"
+	default y
 	depends on PCI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index 8986e57..d82ad22 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_BROADCOM
 	bool "Broadcom devices"
+	default y
 	depends on (SSB_POSSIBLE && HAS_DMA) || PCI || BCM63XX || \
 		   SIBYTE_SB1xxx_SOC
 	---help---
diff --git a/drivers/net/ethernet/brocade/Kconfig b/drivers/net/ethernet/brocade/Kconfig
index 03f0b17..2641557 100644
--- a/drivers/net/ethernet/brocade/Kconfig
+++ b/drivers/net/ethernet/brocade/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_BROCADE
 	bool "Brocade devices"
+	default y
 	depends on PCI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/chelsio/Kconfig b/drivers/net/ethernet/chelsio/Kconfig
index 7b54574..2de50f9 100644
--- a/drivers/net/ethernet/chelsio/Kconfig
+++ b/drivers/net/ethernet/chelsio/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_CHELSIO
 	bool "Chelsio devices"
+	default y
 	depends on PCI || INET
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/cirrus/Kconfig b/drivers/net/ethernet/cirrus/Kconfig
index 53ebe78..e0cacf6 100644
--- a/drivers/net/ethernet/cirrus/Kconfig
+++ b/drivers/net/ethernet/cirrus/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_CIRRUS
 	bool "Cirrus devices"
+	default y
 	depends on ARM && ARCH_EP93XX
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/cisco/Kconfig b/drivers/net/ethernet/cisco/Kconfig
index bbd5348..94606f7 100644
--- a/drivers/net/ethernet/cisco/Kconfig
+++ b/drivers/net/ethernet/cisco/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_CISCO
 	bool "Cisco devices"
+	default y
 	depends on PCI && INET
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/dec/Kconfig b/drivers/net/ethernet/dec/Kconfig
index 40e8df9..3794027 100644
--- a/drivers/net/ethernet/dec/Kconfig
+++ b/drivers/net/ethernet/dec/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_DEC
 	bool "Digital Equipment devices"
+	default y
 	depends on PCI || EISA || CARDBUS
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/dlink/Kconfig b/drivers/net/ethernet/dlink/Kconfig
index 9fdb66b..84a28a6 100644
--- a/drivers/net/ethernet/dlink/Kconfig
+++ b/drivers/net/ethernet/dlink/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_DLINK
 	bool "D-Link devices"
+	default y
 	depends on PCI || PARPORT
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/emulex/Kconfig b/drivers/net/ethernet/emulex/Kconfig
index 018ac94..7a28a64 100644
--- a/drivers/net/ethernet/emulex/Kconfig
+++ b/drivers/net/ethernet/emulex/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_EMULEX
 	bool "Emulex devices"
+	default y
 	depends on PCI && INET
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/faraday/Kconfig b/drivers/net/ethernet/faraday/Kconfig
index b0d76f0..5918c68 100644
--- a/drivers/net/ethernet/faraday/Kconfig
+++ b/drivers/net/ethernet/faraday/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_FARADAY
 	bool "Faraday devices"
+	default y
 	depends on ARM
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
index 2fd2c61..4dbe41f 100644
--- a/drivers/net/ethernet/freescale/Kconfig
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_FREESCALE
 	bool "Freescale devices"
+	default y
 	depends on FSL_SOC || QUICC_ENGINE || CPM1 || CPM2 || PPC_MPC512x || \
 		   M523x || M527x || M5272 || M528x || M520x || M532x || \
 		   IMX_HAVE_PLATFORM_FEC || MXS_HAVE_PLATFORM_FEC || \
diff --git a/drivers/net/ethernet/fujitsu/Kconfig b/drivers/net/ethernet/fujitsu/Kconfig
index 2cd968e..dffee9d 100644
--- a/drivers/net/ethernet/fujitsu/Kconfig
+++ b/drivers/net/ethernet/fujitsu/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_FUJITSU
 	bool "Fujitsu devices"
+	default y
 	depends on ISA || PCMCIA || ((ISA || MCA_LEGACY) && EXPERIMENTAL)
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/hp/Kconfig b/drivers/net/ethernet/hp/Kconfig
index 07b42e9..a0b8ece 100644
--- a/drivers/net/ethernet/hp/Kconfig
+++ b/drivers/net/ethernet/hp/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_HP
 	bool "HP devices"
+	default y
 	depends on ISA || EISA || PCI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/i825xx/Kconfig b/drivers/net/ethernet/i825xx/Kconfig
index 5c30a5b..2be4698 100644
--- a/drivers/net/ethernet/i825xx/Kconfig
+++ b/drivers/net/ethernet/i825xx/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_I825XX
 	bool "Intel (82586/82593/82596) devices"
+	default y
 	depends on NET_VENDOR_INTEL && (ISA || ISA_DMA_API || ARM || \
 		   ARCH_ACORN || MCA || MCA_LEGACY || SNI_RM || SUN3 || \
 		   GSC || BVME6000 || MVME16x || EXPERIMENTAL)
diff --git a/drivers/net/ethernet/ibm/Kconfig b/drivers/net/ethernet/ibm/Kconfig
index 4c7ef98..9e16f3f 100644
--- a/drivers/net/ethernet/ibm/Kconfig
+++ b/drivers/net/ethernet/ibm/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_IBM
 	bool "IBM devices"
+	default y
 	depends on MCA || PPC_PSERIES || PPC_PSERIES || PPC_DCR || \
 		   (IBMEBUS && INET && SPARSEMEM)
 	---help---
diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 5fe185b..4a98e83 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_INTEL
 	bool "Intel devices"
+	default y
 	depends on PCI || PCI_MSI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index e525408..0029934 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_MARVELL
 	bool "Marvell devices"
+	default y
 	depends on PCI || CPU_PXA168 || MV64X60 || PPC32 || PLAT_ORION || INET
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/mellanox/Kconfig b/drivers/net/ethernet/mellanox/Kconfig
index e069491..d8099a7 100644
--- a/drivers/net/ethernet/mellanox/Kconfig
+++ b/drivers/net/ethernet/mellanox/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_MELLANOX
 	bool "Mellanox devices"
+	default y
 	depends on PCI && INET
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/micrel/Kconfig b/drivers/net/ethernet/micrel/Kconfig
index 4227de6..bd090db 100644
--- a/drivers/net/ethernet/micrel/Kconfig
+++ b/drivers/net/ethernet/micrel/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_MICREL
 	bool "Micrel devices"
+	default y
 	depends on (HAS_IOMEM && DMA_ENGINE) || SPI || PCI || HAS_IOMEM || \
 		   (ARM && ARCH_KS8695)
 	---help---
diff --git a/drivers/net/ethernet/microchip/Kconfig b/drivers/net/ethernet/microchip/Kconfig
index 53b0b04..8163fd0 100644
--- a/drivers/net/ethernet/microchip/Kconfig
+++ b/drivers/net/ethernet/microchip/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_MICROCHIP
 	bool "Microchip devices"
+	default y
 	depends on SPI && EXPERIMENTAL
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/myricom/Kconfig b/drivers/net/ethernet/myricom/Kconfig
index 1816ae1..540f0c6 100644
--- a/drivers/net/ethernet/myricom/Kconfig
+++ b/drivers/net/ethernet/myricom/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_MYRI
 	bool "Myricom devices"
+	default y
 	depends on PCI && INET
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say
diff --git a/drivers/net/ethernet/natsemi/Kconfig b/drivers/net/ethernet/natsemi/Kconfig
index 1e5c1e1..4a6b9fd 100644
--- a/drivers/net/ethernet/natsemi/Kconfig
+++ b/drivers/net/ethernet/natsemi/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_NATSEMI
 	bool "National Semi-conductor devices"
+	default y
 	depends on MCA || MAC || MACH_JAZZ || PCI || XTENSA_PLATFORM_XT2000
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/neterion/Kconfig b/drivers/net/ethernet/neterion/Kconfig
index 3d98e62..ff26b54 100644
--- a/drivers/net/ethernet/neterion/Kconfig
+++ b/drivers/net/ethernet/neterion/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_EXAR
 	bool "Exar devices"
+	default y
 	depends on PCI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say
diff --git a/drivers/net/ethernet/nuvoton/Kconfig b/drivers/net/ethernet/nuvoton/Kconfig
index 3b91c3b..01182b5 100644
--- a/drivers/net/ethernet/nuvoton/Kconfig
+++ b/drivers/net/ethernet/nuvoton/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_NUVOTON
 	bool "Nuvoton devices"
+	default y
 	depends on ARM && ARCH_W90X900
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/nvidia/Kconfig b/drivers/net/ethernet/nvidia/Kconfig
index 0a18e73..ace19e7 100644
--- a/drivers/net/ethernet/nvidia/Kconfig
+++ b/drivers/net/ethernet/nvidia/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_NVIDIA
 	bool "NVIDIA devices"
+	default y
 	depends on PCI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/oki-semi/Kconfig b/drivers/net/ethernet/oki-semi/Kconfig
index 97f5e72..ecd45f9 100644
--- a/drivers/net/ethernet/oki-semi/Kconfig
+++ b/drivers/net/ethernet/oki-semi/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_OKI
 	bool "OKI Semiconductor devices"
+	default y
 	depends on PCI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/pasemi/Kconfig b/drivers/net/ethernet/pasemi/Kconfig
index ccb79b8..01e6c32 100644
--- a/drivers/net/ethernet/pasemi/Kconfig
+++ b/drivers/net/ethernet/pasemi/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_PASEMI
 	bool "PA Semi devices"
+	default y
 	depends on PPC_PASEMI && PCI && INET
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
index a7c4424..a8669ad 100644
--- a/drivers/net/ethernet/qlogic/Kconfig
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_QLOGIC
 	bool "QLogic devices"
+	default y
 	depends on PCI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/racal/Kconfig b/drivers/net/ethernet/racal/Kconfig
index 45d4930..01969e0 100644
--- a/drivers/net/ethernet/racal/Kconfig
+++ b/drivers/net/ethernet/racal/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_RACAL
 	bool "Racal-Interlan (Micom) NI devices"
+	default y
 	depends on ISA
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, such
diff --git a/drivers/net/ethernet/rdc/Kconfig b/drivers/net/ethernet/rdc/Kconfig
index b15ebac..2055f7e 100644
--- a/drivers/net/ethernet/rdc/Kconfig
+++ b/drivers/net/ethernet/rdc/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_RDC
 	bool "RDC devices"
+	default y
 	depends on PCI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/realtek/Kconfig b/drivers/net/ethernet/realtek/Kconfig
index a5f67a09..d8df67a 100644
--- a/drivers/net/ethernet/realtek/Kconfig
+++ b/drivers/net/ethernet/realtek/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_REALTEK
 	bool "Realtek devices"
+	default y
 	depends on PCI || (PARPORT && X86)
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/seeq/Kconfig b/drivers/net/ethernet/seeq/Kconfig
index 0266791..49b6d5b 100644
--- a/drivers/net/ethernet/seeq/Kconfig
+++ b/drivers/net/ethernet/seeq/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_SEEQ
 	bool "SEEQ devices"
+	default y
 	depends on (ARM && ARCH_ACORN) || SGI_HAS_SEEQ || EXPERIMENTAL
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/sgi/Kconfig b/drivers/net/ethernet/sgi/Kconfig
index 3098594..e832f46 100644
--- a/drivers/net/ethernet/sgi/Kconfig
+++ b/drivers/net/ethernet/sgi/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_SGI
 	bool "SGI devices"
+	default y
 	depends on (PCI && SGI_IP27) || SGI_IP32
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/sis/Kconfig b/drivers/net/ethernet/sis/Kconfig
index 01d43e8..68d052b 100644
--- a/drivers/net/ethernet/sis/Kconfig
+++ b/drivers/net/ethernet/sis/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_SIS
 	bool "Silicon Integrated Systems (SiS) devices"
+	default y
 	depends on PCI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/smsc/Kconfig b/drivers/net/ethernet/smsc/Kconfig
index 702efe6..f961928 100644
--- a/drivers/net/ethernet/smsc/Kconfig
+++ b/drivers/net/ethernet/smsc/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_SMSC
 	bool "SMC (SMSC)/Western Digital devices"
+	default y
 	depends on ARM || ISA || MAC || ARM || MIPS || M32R || SUPERH || \
 		BLACKFIN || MN10300 || COLDFIRE || PCI || PCMCIA
 	---help---
diff --git a/drivers/net/ethernet/stmicro/Kconfig b/drivers/net/ethernet/stmicro/Kconfig
index e40df64..f4a80da 100644
--- a/drivers/net/ethernet/stmicro/Kconfig
+++ b/drivers/net/ethernet/stmicro/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_STMICRO
 	bool "STMicroelectronics devices"
+	default y
 	depends on HAS_IOMEM
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/sun/Kconfig b/drivers/net/ethernet/sun/Kconfig
index 5132fa6..57bfd85 100644
--- a/drivers/net/ethernet/sun/Kconfig
+++ b/drivers/net/ethernet/sun/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_SUN
 	bool "Sun devices"
+	default y
 	depends on SUN3 || SBUS || PCI || SUN_LDOMS
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say
diff --git a/drivers/net/ethernet/tehuti/Kconfig b/drivers/net/ethernet/tehuti/Kconfig
index 914ad4059..1fc027e 100644
--- a/drivers/net/ethernet/tehuti/Kconfig
+++ b/drivers/net/ethernet/tehuti/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_TEHUTI
 	bool "Tehuti devices"
+	default y
 	depends on PCI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index 1284319..de76c70 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_TI
 	bool "Texas Instruments (TI) devices"
+	default y
 	depends on PCI || EISA || AR7 || (ARM && (ARCH_DAVINCI || ARCH_OMAP3))
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/toshiba/Kconfig b/drivers/net/ethernet/toshiba/Kconfig
index 6ef2ce2..0517647 100644
--- a/drivers/net/ethernet/toshiba/Kconfig
+++ b/drivers/net/ethernet/toshiba/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_TOSHIBA
 	bool "Toshiba devices"
+	default y
 	depends on PCI && (PPC_IBM_CELL_BLADE || PPC_CELLEB) || PPC_PS3
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/tundra/Kconfig b/drivers/net/ethernet/tundra/Kconfig
index 03925d1..cf7d69b 100644
--- a/drivers/net/ethernet/tundra/Kconfig
+++ b/drivers/net/ethernet/tundra/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_TUNDRA
 	bool "Tundra devices"
+	default y
 	depends on TSI108_BRIDGE
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/via/Kconfig b/drivers/net/ethernet/via/Kconfig
index 7199194..e5d82a5 100644
--- a/drivers/net/ethernet/via/Kconfig
+++ b/drivers/net/ethernet/via/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_VIA
 	bool "VIA devices"
+	default y
 	depends on PCI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/xilinx/Kconfig b/drivers/net/ethernet/xilinx/Kconfig
index 4e3aad4..d5a8260 100644
--- a/drivers/net/ethernet/xilinx/Kconfig
+++ b/drivers/net/ethernet/xilinx/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_XILINX
 	bool "Xilinx devices"
+	default y
 	depends on PPC || PPC32 || MICROBLAZE
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/xircom/Kconfig b/drivers/net/ethernet/xircom/Kconfig
index 3d64e58..69f56a6 100644
--- a/drivers/net/ethernet/xircom/Kconfig
+++ b/drivers/net/ethernet/xircom/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_XIRCOM
 	bool "Xircom devices"
+	default y
 	depends on PCMCIA
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
diff --git a/drivers/net/ethernet/xscale/Kconfig b/drivers/net/ethernet/xscale/Kconfig
index 6bbcc54..cf67352 100644
--- a/drivers/net/ethernet/xscale/Kconfig
+++ b/drivers/net/ethernet/xscale/Kconfig
@@ -4,6 +4,7 @@
 
 config NET_VENDOR_XSCALE
 	bool "Intel XScale IXP devices"
+	default y
 	depends on NET_VENDOR_INTEL && ((ARM && ARCH_IXP4XX && \
 		   IXP4XX_NPE && IXP4XX_QMGR) || ARCH_ENP2611)
 	---help---
-- 
1.7.6
