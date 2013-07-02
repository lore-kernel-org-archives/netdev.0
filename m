From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH v6 5/7] ARM: kirkwood: remove redundant DT board files
Date: Tue,  2 Jul 2013 13:00:22 +0200
Message-ID: <1372762824-12202-6-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1372762824-12202-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Russell King <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372762824-12202-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With DT support for mv643xx_eth board specific init for some boards now
is unneccessary. Remove those board files, Kconfig entries, and
corresponding entries in kirkwood_defconfig.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Changelog:
v5->v6:
- rebase for v3.11-rc1

Cc: Russell King <linux@arm.linux.org.uk>
Cc: Jason Cooper <jason@lakedaemon.net>
Cc: Andrew Lunn <andrew@lunn.ch>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 arch/arm/configs/kirkwood_defconfig           |   22 ----
 arch/arm/mach-kirkwood/Kconfig                |  156 -------------------------
 arch/arm/mach-kirkwood/Makefile               |   23 +----
 arch/arm/mach-kirkwood/board-db88f628x-bp.c   |   24 ----
 arch/arm/mach-kirkwood/board-dnskw.c          |    7 -
 arch/arm/mach-kirkwood/board-dockstar.c       |   32 -----
 arch/arm/mach-kirkwood/board-dreamplug.c      |   35 ------
 arch/arm/mach-kirkwood/board-dt.c             |   84 +-------------
 arch/arm/mach-kirkwood/board-goflexnet.c      |   34 ------
 arch/arm/mach-kirkwood/board-guruplug.c       |   33 -----
 arch/arm/mach-kirkwood/board-ib62x0.c         |   29 -----
 arch/arm/mach-kirkwood/board-iconnect.c       |   24 ----
 arch/arm/mach-kirkwood/board-iomega_ix2_200.c |   34 ------
 arch/arm/mach-kirkwood/board-km_kirkwood.c    |   44 -------
 arch/arm/mach-kirkwood/board-lsxl.c           |   36 ------
 arch/arm/mach-kirkwood/board-mplcec4.c        |   35 ------
 arch/arm/mach-kirkwood/board-ns2.c            |   35 ------
 arch/arm/mach-kirkwood/board-openblocks_a6.c  |   26 ----
 arch/arm/mach-kirkwood/board-readynas.c       |   27 -----
 arch/arm/mach-kirkwood/board-sheevaplug.c     |   27 -----
 arch/arm/mach-kirkwood/board-ts219.c          |   40 -------
 arch/arm/mach-kirkwood/board-usi_topkick.c    |   29 -----
 22 files changed, 2 insertions(+), 834 deletions(-)
 delete mode 100644 arch/arm/mach-kirkwood/board-db88f628x-bp.c
 delete mode 100644 arch/arm/mach-kirkwood/board-dockstar.c
 delete mode 100644 arch/arm/mach-kirkwood/board-dreamplug.c
 delete mode 100644 arch/arm/mach-kirkwood/board-goflexnet.c
 delete mode 100644 arch/arm/mach-kirkwood/board-guruplug.c
 delete mode 100644 arch/arm/mach-kirkwood/board-ib62x0.c
 delete mode 100644 arch/arm/mach-kirkwood/board-iconnect.c
 delete mode 100644 arch/arm/mach-kirkwood/board-iomega_ix2_200.c
 delete mode 100644 arch/arm/mach-kirkwood/board-km_kirkwood.c
 delete mode 100644 arch/arm/mach-kirkwood/board-lsxl.c
 delete mode 100644 arch/arm/mach-kirkwood/board-mplcec4.c
 delete mode 100644 arch/arm/mach-kirkwood/board-ns2.c
 delete mode 100644 arch/arm/mach-kirkwood/board-openblocks_a6.c
 delete mode 100644 arch/arm/mach-kirkwood/board-readynas.c
 delete mode 100644 arch/arm/mach-kirkwood/board-sheevaplug.c
 delete mode 100644 arch/arm/mach-kirkwood/board-ts219.c
 delete mode 100644 arch/arm/mach-kirkwood/board-usi_topkick.c

diff --git a/arch/arm/configs/kirkwood_defconfig b/arch/arm/configs/kirkwood_defconfig
index 0f2aa61..3235808 100644
--- a/arch/arm/configs/kirkwood_defconfig
+++ b/arch/arm/configs/kirkwood_defconfig
@@ -29,29 +29,7 @@ CONFIG_MACH_SHEEVAPLUG=y
 CONFIG_MACH_T5325=y
 CONFIG_MACH_TS219=y
 CONFIG_MACH_TS41X=y
-CONFIG_MACH_CLOUDBOX_DT=y
-CONFIG_MACH_DB88F628X_BP_DT=y
 CONFIG_MACH_DLINK_KIRKWOOD_DT=y
-CONFIG_MACH_DOCKSTAR_DT=y
-CONFIG_MACH_DREAMPLUG_DT=y
-CONFIG_MACH_GOFLEXNET_DT=y
-CONFIG_MACH_GURUPLUG_DT=y
-CONFIG_MACH_IB62X0_DT=y
-CONFIG_MACH_ICONNECT_DT=y
-CONFIG_MACH_INETSPACE_V2_DT=y
-CONFIG_MACH_IOMEGA_IX2_200_DT=y
-CONFIG_MACH_KM_KIRKWOOD_DT=y
-CONFIG_MACH_LSXL_DT=y
-CONFIG_MACH_MPLCEC4_DT=y
-CONFIG_MACH_NETSPACE_LITE_V2_DT=y
-CONFIG_MACH_NETSPACE_MAX_V2_DT=y
-CONFIG_MACH_NETSPACE_MINI_V2_DT=y
-CONFIG_MACH_NETSPACE_V2_DT=y
-CONFIG_MACH_NSA310_DT=y
-CONFIG_MACH_OPENBLOCKS_A6_DT=y
-CONFIG_MACH_READYNAS_DT=y
-CONFIG_MACH_SHEEVAPLUG_DT=y
-CONFIG_MACH_TOPKICK_DT=y
 CONFIG_MACH_TS219_DT=y
 # CONFIG_CPU_FEROCEON_OLD_ID is not set
 CONFIG_PCI_MVEBU=y
diff --git a/arch/arm/mach-kirkwood/Kconfig b/arch/arm/mach-kirkwood/Kconfig
index b634f96..493c71a 100644
--- a/arch/arm/mach-kirkwood/Kconfig
+++ b/arch/arm/mach-kirkwood/Kconfig
@@ -139,20 +139,6 @@ config ARCH_KIRKWOOD_DT
 	  Say 'Y' here if you want your kernel to support the
 	  Marvell Kirkwood using flattened device tree.
 
-config MACH_CLOUDBOX_DT
-	bool "LaCie CloudBox NAS (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	help
-	  Say 'Y' here if you want your kernel to support the LaCie
-	  CloudBox NAS, using Flattened Device Tree.
-
-config MACH_DB88F628X_BP_DT
-	bool "Marvell DB-88F628x-BP Development Board (Flattened Device Tree)"
-	help
-	  Say 'Y' here if you want your kernel to support the Marvell
-	  DB-88F6281-BP and DB-88F6282-BP Development Board (Flattened
-	  Device Tree).
-
 config MACH_DLINK_KIRKWOOD_DT
 	bool "D-Link Kirkwood-based NAS (Flattened Device Tree)"
 	select ARCH_KIRKWOOD_DT
@@ -161,148 +147,6 @@ config MACH_DLINK_KIRKWOOD_DT
 	  Kirkwood-based D-Link NASes such as DNS-320 & DNS-325,
 	  using Flattened Device Tree.
 
-config MACH_DOCKSTAR_DT
-	bool "Seagate FreeAgent Dockstar (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	help
-	  Say 'Y' here if you want your kernel to support the
-	  Seagate FreeAgent Dockstar (Flattened Device Tree).
-
-config MACH_DREAMPLUG_DT
-	bool "Marvell DreamPlug (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	help
-	  Say 'Y' here if you want your kernel to support the
-	  Marvell DreamPlug (Flattened Device Tree).
-
-config MACH_GOFLEXNET_DT
-	bool "Seagate GoFlex Net (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	help
-	  Say 'Y' here if you want your kernel to support the
-	  Seagate GoFlex Net (Flattened Device Tree).
-
-config MACH_GURUPLUG_DT
-	bool "Marvell GuruPlug Reference Board (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	help
-	  Say 'Y' here if you want your kernel to support the
-	  Marvell GuruPlug Reference Board (Flattened Device Tree).
-
-config MACH_IB62X0_DT
-	bool "RaidSonic IB-NAS6210, IB-NAS6220 (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	help
-	  Say 'Y' here if you want your kernel to support the
-	  RaidSonic IB-NAS6210 & IB-NAS6220 devices, using
-	  Flattened Device Tree.
-
-config MACH_ICONNECT_DT
-	bool "Iomega Iconnect (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	help
-	  Say 'Y' here to enable Iomega Iconnect support.
-
-config MACH_INETSPACE_V2_DT
-	bool "LaCie Internet Space v2 NAS (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	help
-	  Say 'Y' here if you want your kernel to support the LaCie
-	  Internet Space v2 NAS, using Flattened Device Tree.
-
-config MACH_IOMEGA_IX2_200_DT
-	bool "Iomega StorCenter ix2-200 (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	help
-	  Say 'Y' here if you want your kernel to support the
-	  Iomega StorCenter ix2-200 (Flattened Device Tree).
-
-config MACH_KM_KIRKWOOD_DT
-	bool "Keymile Kirkwood Reference Design (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	help
-	  Say 'Y' here if you want your kernel to support the
-	  Keymile Kirkwood Reference Desgin, using Flattened Device Tree.
-
-config MACH_LSXL_DT
-	bool "Buffalo Linkstation LS-XHL, LS-CHLv2 (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	select POWER_RESET_RESTART
-	help
-	  Say 'Y' here if you want your kernel to support the
-	  Buffalo Linkstation LS-XHL & LS-CHLv2 devices, using
-	  Flattened Device Tree.
-
-config MACH_MPLCEC4_DT
-	bool "MPL CEC4 (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	help
-	  Say 'Y' here if you want your kernel to support the
-	  MPL CEC4 (Flattened Device Tree).
-
-config MACH_NETSPACE_LITE_V2_DT
-	bool "LaCie Network Space Lite v2 NAS (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	help
-	  Say 'Y' here if you want your kernel to support the LaCie
-	  Network Space Lite v2 NAS, using Flattened Device Tree.
-
-config MACH_NETSPACE_MAX_V2_DT
-	bool "LaCie Network Space Max v2 NAS (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	help
-	  Say 'Y' here if you want your kernel to support the LaCie
-	  Network Space Max v2 NAS, using Flattened Device Tree.
-
-config MACH_NETSPACE_MINI_V2_DT
-	bool "LaCie Network Space Mini v2 NAS (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	help
-	  Say 'Y' here if you want your kernel to support the LaCie
-	  Network Space Mini v2 NAS using Flattened Device Tree.
-
-	  This board is embedded in a product named CloudBox, which
-	  provides automatic backup on a 100GB cloud storage. This
-	  should not confused with a more recent LaCie NAS also named
-	  CloudBox. For this last, the disk capacity is 1TB or above.
-
-config MACH_NETSPACE_V2_DT
-	bool "LaCie Network Space v2 NAS (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	help
-	  Say 'Y' here if you want your kernel to support the LaCie
-	  Network Space v2 NAS, using Flattened Device Tree.
-
-config MACH_OPENBLOCKS_A6_DT
-	bool "Plat'Home OpenBlocks A6 (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	help
-	  Say 'Y' here if you want your kernel to support the
-	  Plat'Home OpenBlocks A6 (Flattened Device Tree).
-
-config MACH_READYNAS_DT
-	bool "NETGEAR ReadyNAS Duo v2 (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	select ARM_APPENDED_DTB
-	select ARM_ATAG_DTB_COMPAT
-	help
-	  Say 'Y' here if you want your kernel to support the
-	  NETGEAR ReadyNAS Duo v2 using Fattened Device Tree.
-
-config MACH_SHEEVAPLUG_DT
-	bool "Marvell (eSATA) SheevaPlug (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	help
-	  Say 'Y' here if you want your kernel to support the
-	  Marvell (eSATA) SheevaPlug (Flattened Device Tree).
-
-config MACH_TOPKICK_DT
-	bool "USI Topkick (Flattened Device Tree)"
-	select ARCH_KIRKWOOD_DT
-	help
-	  Say 'Y' here if you want your kernel to support the
-	  USI Topkick, using Flattened Device Tree
-
 config MACH_TS219_DT
 	bool "Device Tree for QNAP TS-11X, TS-21X NAS"
 	select ARCH_KIRKWOOD_DT
diff --git a/arch/arm/mach-kirkwood/Makefile b/arch/arm/mach-kirkwood/Makefile
index ac4cd75..062f8c7 100644
--- a/arch/arm/mach-kirkwood/Makefile
+++ b/arch/arm/mach-kirkwood/Makefile
@@ -19,26 +19,5 @@ obj-$(CONFIG_MACH_TS219)		+= ts219-setup.o tsx1x-common.o
 obj-$(CONFIG_MACH_TS41X)		+= ts41x-setup.o tsx1x-common.o
 
 obj-$(CONFIG_ARCH_KIRKWOOD_DT)		+= board-dt.o
-obj-$(CONFIG_MACH_CLOUDBOX_DT)		+= board-ns2.o
-obj-$(CONFIG_MACH_DB88F628X_BP_DT)	+= board-db88f628x-bp.o
 obj-$(CONFIG_MACH_DLINK_KIRKWOOD_DT)	+= board-dnskw.o
-obj-$(CONFIG_MACH_DOCKSTAR_DT)		+= board-dockstar.o
-obj-$(CONFIG_MACH_DREAMPLUG_DT)		+= board-dreamplug.o
-obj-$(CONFIG_MACH_GOFLEXNET_DT)		+= board-goflexnet.o
-obj-$(CONFIG_MACH_GURUPLUG_DT)		+= board-guruplug.o
-obj-$(CONFIG_MACH_IB62X0_DT)		+= board-ib62x0.o
-obj-$(CONFIG_MACH_ICONNECT_DT)		+= board-iconnect.o
-obj-$(CONFIG_MACH_INETSPACE_V2_DT)	+= board-ns2.o
-obj-$(CONFIG_MACH_IOMEGA_IX2_200_DT)	+= board-iomega_ix2_200.o
-obj-$(CONFIG_MACH_KM_KIRKWOOD_DT)	+= board-km_kirkwood.o
-obj-$(CONFIG_MACH_LSXL_DT)		+= board-lsxl.o
-obj-$(CONFIG_MACH_MPLCEC4_DT)		+= board-mplcec4.o
-obj-$(CONFIG_MACH_NETSPACE_LITE_V2_DT)	+= board-ns2.o
-obj-$(CONFIG_MACH_NETSPACE_MAX_V2_DT)	+= board-ns2.o
-obj-$(CONFIG_MACH_NETSPACE_MINI_V2_DT)	+= board-ns2.o
-obj-$(CONFIG_MACH_NETSPACE_V2_DT)	+= board-ns2.o
-obj-$(CONFIG_MACH_OPENBLOCKS_A6_DT)	+= board-openblocks_a6.o
-obj-$(CONFIG_MACH_READYNAS_DT)		+= board-readynas.o
-obj-$(CONFIG_MACH_SHEEVAPLUG_DT)	+= board-sheevaplug.o
-obj-$(CONFIG_MACH_TOPKICK_DT)		+= board-usi_topkick.o
-obj-$(CONFIG_MACH_TS219_DT)		+= board-ts219.o tsx1x-common.o
+obj-$(CONFIG_MACH_TS219_DT)		+= tsx1x-common.o
diff --git a/arch/arm/mach-kirkwood/board-db88f628x-bp.c b/arch/arm/mach-kirkwood/board-db88f628x-bp.c
deleted file mode 100644
index 2f574bc..0000000
--- a/arch/arm/mach-kirkwood/board-db88f628x-bp.c
+++ /dev/null
@@ -1,24 +0,0 @@
-/*
- * Saeed Bishara <saeed@marvell.com>
- *
- * Marvell DB-88F628{1,2}-BP Development Board Setup
- *
- * This file is licensed under the terms of the GNU General Public
- * License version 2.  This program is licensed "as is" without any
- * warranty of any kind, whether express or implied.
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/of.h>
-#include <linux/mv643xx_eth.h>
-#include "common.h"
-
-static struct mv643xx_eth_platform_data db88f628x_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
-};
-
-void __init db88f628x_init(void)
-{
-	kirkwood_ge00_init(&db88f628x_ge00_data);
-}
diff --git a/arch/arm/mach-kirkwood/board-dnskw.c b/arch/arm/mach-kirkwood/board-dnskw.c
index a1aa87f..2af7a95 100644
--- a/arch/arm/mach-kirkwood/board-dnskw.c
+++ b/arch/arm/mach-kirkwood/board-dnskw.c
@@ -14,14 +14,9 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/platform_device.h>
-#include <linux/mv643xx_eth.h>
 #include <linux/gpio.h>
 #include "common.h"
 
-static struct mv643xx_eth_platform_data dnskw_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
-};
-
 /* Register any GPIO for output and set the value */
 static void __init dnskw_gpio_register(unsigned gpio, char *name, int def)
 {
@@ -36,8 +31,6 @@ static void __init dnskw_gpio_register(unsigned gpio, char *name, int def)
 
 void __init dnskw_init(void)
 {
-	kirkwood_ge00_init(&dnskw_ge00_data);
-
 	/* Set NAS to turn back on after a power failure */
 	dnskw_gpio_register(37, "dnskw:power:recover", 1);
 }
diff --git a/arch/arm/mach-kirkwood/board-dockstar.c b/arch/arm/mach-kirkwood/board-dockstar.c
deleted file mode 100644
index d7196db..0000000
--- a/arch/arm/mach-kirkwood/board-dockstar.c
+++ /dev/null
@@ -1,32 +0,0 @@
-/*
- * arch/arm/mach-kirkwood/board-dockstar.c
- *
- * Seagate FreeAgent Dockstar Board Init for drivers not converted to
- * flattened device tree yet.
- *
- * This file is licensed under the terms of the GNU General Public
- * License version 2.  This program is licensed "as is" without any
- * warranty of any kind, whether express or implied.
- *
- * Copied and modified for Seagate GoFlex Net support by
- * Joshua Coombs <josh.coombs@gmail.com> based on ArchLinux ARM's
- * GoFlex kernel patches.
- *
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/mv643xx_eth.h>
-#include "common.h"
-
-static struct mv643xx_eth_platform_data dockstar_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
-void __init dockstar_dt_init(void)
-{
-	/*
-	 * Basic setup. Needs to be called early.
-	 */
-	kirkwood_ge00_init(&dockstar_ge00_data);
-}
diff --git a/arch/arm/mach-kirkwood/board-dreamplug.c b/arch/arm/mach-kirkwood/board-dreamplug.c
deleted file mode 100644
index 0903242..0000000
--- a/arch/arm/mach-kirkwood/board-dreamplug.c
+++ /dev/null
@@ -1,35 +0,0 @@
-/*
- * Copyright 2012 (C), Jason Cooper <jason@lakedaemon.net>
- *
- * arch/arm/mach-kirkwood/board-dreamplug.c
- *
- * Marvell DreamPlug Reference Board Init for drivers not converted to
- * flattened device tree yet.
- *
- * This file is licensed under the terms of the GNU General Public
- * License version 2.  This program is licensed "as is" without any
- * warranty of any kind, whether express or implied.
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/mv643xx_eth.h>
-#include <linux/gpio.h>
-#include "common.h"
-
-static struct mv643xx_eth_platform_data dreamplug_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
-static struct mv643xx_eth_platform_data dreamplug_ge01_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(1),
-};
-
-void __init dreamplug_init(void)
-{
-	/*
-	 * Basic setup. Needs to be called early.
-	 */
-	kirkwood_ge00_init(&dreamplug_ge00_data);
-	kirkwood_ge01_init(&dreamplug_ge01_data);
-}
diff --git a/arch/arm/mach-kirkwood/board-dt.c b/arch/arm/mach-kirkwood/board-dt.c
index 6e122ed..a3271f6 100644
--- a/arch/arm/mach-kirkwood/board-dt.c
+++ b/arch/arm/mach-kirkwood/board-dt.c
@@ -102,96 +102,14 @@ static void __init kirkwood_dt_init(void)
 	kexec_reinit = kirkwood_enable_pcie;
 #endif
 
-	if (of_machine_is_compatible("globalscale,dreamplug"))
-		dreamplug_init();
-
-	if (of_machine_is_compatible("globalscale,guruplug"))
-		guruplug_dt_init();
-
-	if (of_machine_is_compatible("globalscale,sheevaplug"))
-		sheevaplug_dt_init();
-
 	if (of_machine_is_compatible("dlink,dns-kirkwood"))
 		dnskw_init();
 
-	if (of_machine_is_compatible("iom,iconnect"))
-		iconnect_init();
-
-	if (of_machine_is_compatible("raidsonic,ib-nas62x0"))
-		ib62x0_init();
-
-	if (of_machine_is_compatible("qnap,ts219"))
-		qnap_dt_ts219_init();
-
-	if (of_machine_is_compatible("seagate,dockstar"))
-		dockstar_dt_init();
-
-	if (of_machine_is_compatible("seagate,goflexnet"))
-		goflexnet_init();
-
-	if (of_machine_is_compatible("buffalo,lsxl"))
-		lsxl_init();
-
-	if (of_machine_is_compatible("iom,ix2-200"))
-		iomega_ix2_200_init();
-
-	if (of_machine_is_compatible("keymile,km_kirkwood"))
-		km_kirkwood_init();
-
-	if (of_machine_is_compatible("lacie,cloudbox") ||
-	    of_machine_is_compatible("lacie,inetspace_v2") ||
-	    of_machine_is_compatible("lacie,netspace_lite_v2") ||
-	    of_machine_is_compatible("lacie,netspace_max_v2") ||
-	    of_machine_is_compatible("lacie,netspace_mini_v2") ||
-	    of_machine_is_compatible("lacie,netspace_v2"))
-		ns2_init();
-
-	if (of_machine_is_compatible("marvell,db-88f6281-bp") ||
-	    of_machine_is_compatible("marvell,db-88f6282-bp"))
-		db88f628x_init();
-
-	if (of_machine_is_compatible("mpl,cec4"))
-		mplcec4_init();
-
-	if (of_machine_is_compatible("netgear,readynas-duo-v2"))
-		netgear_readynas_init();
-
-	if (of_machine_is_compatible("plathome,openblocks-a6"))
-		openblocks_a6_init();
-
-	if (of_machine_is_compatible("usi,topkick"))
-		usi_topkick_init();
-
 	of_platform_populate(NULL, of_default_bus_match_table, NULL, NULL);
 }
 
 static const char * const kirkwood_dt_board_compat[] = {
-	"globalscale,dreamplug",
-	"globalscale,guruplug",
-	"globalscale,sheevaplug",
-	"dlink,dns-320",
-	"dlink,dns-325",
-	"iom,iconnect",
-	"raidsonic,ib-nas62x0",
-	"qnap,ts219",
-	"seagate,dockstar",
-	"seagate,goflexnet",
-	"buffalo,lsxl",
-	"iom,ix2-200",
-	"keymile,km_kirkwood",
-	"lacie,cloudbox",
-	"lacie,inetspace_v2",
-	"lacie,netspace_lite_v2",
-	"lacie,netspace_max_v2",
-	"lacie,netspace_mini_v2",
-	"lacie,netspace_v2",
-	"marvell,db-88f6281-bp",
-	"marvell,db-88f6282-bp",
-	"mpl,cec4",
-	"netgear,readynas-duo-v2",
-	"plathome,openblocks-a6",
-	"usi,topkick",
-	"zyxel,nsa310",
+	"marvell,kirkwood",
 	NULL
 };
 
diff --git a/arch/arm/mach-kirkwood/board-goflexnet.c b/arch/arm/mach-kirkwood/board-goflexnet.c
deleted file mode 100644
index 9db979a..0000000
--- a/arch/arm/mach-kirkwood/board-goflexnet.c
+++ /dev/null
@@ -1,34 +0,0 @@
-/*
- * Copyright 2012 (C), Jason Cooper <jason@lakedaemon.net>
- *
- * arch/arm/mach-kirkwood/board-goflexnet.c
- *
- * Seagate GoFlext Net Board Init for drivers not converted to
- * flattened device tree yet.
- *
- * This file is licensed under the terms of the GNU General Public
- * License version 2.  This program is licensed "as is" without any
- * warranty of any kind, whether express or implied.
- *
- * Copied and modified for Seagate GoFlex Net support by
- * Joshua Coombs <josh.coombs@gmail.com> based on ArchLinux ARM's
- * GoFlex kernel patches.
- *
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/mv643xx_eth.h>
-#include "common.h"
-
-static struct mv643xx_eth_platform_data goflexnet_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
-void __init goflexnet_init(void)
-{
-	/*
-	 * Basic setup. Needs to be called early.
-	 */
-	kirkwood_ge00_init(&goflexnet_ge00_data);
-}
diff --git a/arch/arm/mach-kirkwood/board-guruplug.c b/arch/arm/mach-kirkwood/board-guruplug.c
deleted file mode 100644
index a857163..0000000
--- a/arch/arm/mach-kirkwood/board-guruplug.c
+++ /dev/null
@@ -1,33 +0,0 @@
-/*
- * arch/arm/mach-kirkwood/board-guruplug.c
- *
- * Marvell Guruplug Reference Board Init for drivers not converted to
- * flattened device tree yet.
- *
- * This file is licensed under the terms of the GNU General Public
- * License version 2.  This program is licensed "as is" without any
- * warranty of any kind, whether express or implied.
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/mv643xx_eth.h>
-#include <linux/gpio.h>
-#include "common.h"
-
-static struct mv643xx_eth_platform_data guruplug_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
-static struct mv643xx_eth_platform_data guruplug_ge01_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(1),
-};
-
-void __init guruplug_dt_init(void)
-{
-	/*
-	 * Basic setup. Needs to be called early.
-	 */
-	kirkwood_ge00_init(&guruplug_ge00_data);
-	kirkwood_ge01_init(&guruplug_ge01_data);
-}
diff --git a/arch/arm/mach-kirkwood/board-ib62x0.c b/arch/arm/mach-kirkwood/board-ib62x0.c
deleted file mode 100644
index 9a857ae..0000000
--- a/arch/arm/mach-kirkwood/board-ib62x0.c
+++ /dev/null
@@ -1,29 +0,0 @@
-/*
- * Copyright 2012 (C), Simon Baatz <gmbnomis@gmail.com>
- *
- * arch/arm/mach-kirkwood/board-ib62x0.c
- *
- * RaidSonic ICY BOX IB-NAS6210 & IB-NAS6220 init for drivers not
- * converted to flattened device tree yet.
- *
- * This file is licensed under the terms of the GNU General Public
- * License version 2.  This program is licensed "as is" without any
- * warranty of any kind, whether express or implied.
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/mv643xx_eth.h>
-#include "common.h"
-
-static struct mv643xx_eth_platform_data ib62x0_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
-};
-
-void __init ib62x0_init(void)
-{
-	/*
-	 * Basic setup. Needs to be called early.
-	 */
-	kirkwood_ge00_init(&ib62x0_ge00_data);
-}
diff --git a/arch/arm/mach-kirkwood/board-iconnect.c b/arch/arm/mach-kirkwood/board-iconnect.c
deleted file mode 100644
index 98b5ad1..0000000
--- a/arch/arm/mach-kirkwood/board-iconnect.c
+++ /dev/null
@@ -1,24 +0,0 @@
-/*
- * arch/arm/mach-kirkwood/board-iconnect.c
- *
- * Iomega i-connect Board Setup
- *
- * This file is licensed under the terms of the GNU General Public
- * License version 2.  This program is licensed "as is" without any
- * warranty of any kind, whether express or implied.
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/of.h>
-#include <linux/mv643xx_eth.h>
-#include "common.h"
-
-static struct mv643xx_eth_platform_data iconnect_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(11),
-};
-
-void __init iconnect_init(void)
-{
-	kirkwood_ge00_init(&iconnect_ge00_data);
-}
diff --git a/arch/arm/mach-kirkwood/board-iomega_ix2_200.c b/arch/arm/mach-kirkwood/board-iomega_ix2_200.c
deleted file mode 100644
index e5f7041..0000000
--- a/arch/arm/mach-kirkwood/board-iomega_ix2_200.c
+++ /dev/null
@@ -1,34 +0,0 @@
-/*
- * arch/arm/mach-kirkwood/board-iomega_ix2_200.c
- *
- * Iomega StorCenter ix2-200
- *
- * This file is licensed under the terms of the GNU General Public
- * License version 2.  This program is licensed "as is" without any
- * warranty of any kind, whether express or implied.
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/mv643xx_eth.h>
-#include <linux/ethtool.h>
-#include "common.h"
-
-static struct mv643xx_eth_platform_data iomega_ix2_200_ge00_data = {
-	.phy_addr       = MV643XX_ETH_PHY_NONE,
-	.speed          = SPEED_1000,
-	.duplex         = DUPLEX_FULL,
-};
-
-static struct mv643xx_eth_platform_data iomega_ix2_200_ge01_data = {
-        .phy_addr       = MV643XX_ETH_PHY_ADDR(11),
-};
-
-void __init iomega_ix2_200_init(void)
-{
-	/*
-	 * Basic setup. Needs to be called early.
-	 */
-	kirkwood_ge00_init(&iomega_ix2_200_ge00_data);
-	kirkwood_ge01_init(&iomega_ix2_200_ge01_data);
-}
diff --git a/arch/arm/mach-kirkwood/board-km_kirkwood.c b/arch/arm/mach-kirkwood/board-km_kirkwood.c
deleted file mode 100644
index 44e4605..0000000
--- a/arch/arm/mach-kirkwood/board-km_kirkwood.c
+++ /dev/null
@@ -1,44 +0,0 @@
-/*
- * Copyright 2012 2012 KEYMILE AG, CH-3097 Bern
- * Valentin Longchamp <valentin.longchamp@keymile.com>
- *
- * arch/arm/mach-kirkwood/board-km_kirkwood.c
- *
- * Keymile km_kirkwood Reference Desing Init for drivers not converted to
- * flattened device tree yet.
- *
- * This file is licensed under the terms of the GNU General Public
- * License version 2.  This program is licensed "as is" without any
- * warranty of any kind, whether express or implied.
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/mv643xx_eth.h>
-#include <linux/clk.h>
-#include <linux/clk-private.h>
-#include "common.h"
-
-static struct mv643xx_eth_platform_data km_kirkwood_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
-void __init km_kirkwood_init(void)
-{
-	struct clk *sata_clk;
-	/*
-	 * Our variant of kirkwood (integrated in the Bobcat) hangs on accessing
-	 * SATA bits (14-15) of the Clock Gating Control Register. Since these
-	 * devices are also not present in this variant, their clocks get
-	 * disabled because unused when clk_disable_unused() gets called.
-	 * That's why we change the flags to these clocks to CLK_IGNORE_UNUSED
-	 */
-	sata_clk = clk_get_sys("sata_mv.0", "0");
-	if (!IS_ERR(sata_clk))
-		sata_clk->flags |= CLK_IGNORE_UNUSED;
-	sata_clk = clk_get_sys("sata_mv.0", "1");
-	if (!IS_ERR(sata_clk))
-		sata_clk->flags |= CLK_IGNORE_UNUSED;
-
-	kirkwood_ge00_init(&km_kirkwood_ge00_data);
-}
diff --git a/arch/arm/mach-kirkwood/board-lsxl.c b/arch/arm/mach-kirkwood/board-lsxl.c
deleted file mode 100644
index 3483952..0000000
--- a/arch/arm/mach-kirkwood/board-lsxl.c
+++ /dev/null
@@ -1,36 +0,0 @@
-/*
- * Copyright 2012 (C), Michael Walle <michael@walle.cc>
- *
- * arch/arm/mach-kirkwood/board-lsxl.c
- *
- * Buffalo Linkstation LS-XHL and LS-CHLv2 init for drivers not
- * converted to flattened device tree yet.
- *
- * This file is licensed under the terms of the GNU General Public
- * License version 2.  This program is licensed "as is" without any
- * warranty of any kind, whether express or implied.
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/platform_device.h>
-#include <linux/mv643xx_eth.h>
-#include "common.h"
-
-static struct mv643xx_eth_platform_data lsxl_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
-static struct mv643xx_eth_platform_data lsxl_ge01_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
-};
-
-void __init lsxl_init(void)
-{
-	/*
-	 * Basic setup. Needs to be called early.
-	 */
-
-	kirkwood_ge00_init(&lsxl_ge00_data);
-	kirkwood_ge01_init(&lsxl_ge01_data);
-}
diff --git a/arch/arm/mach-kirkwood/board-mplcec4.c b/arch/arm/mach-kirkwood/board-mplcec4.c
deleted file mode 100644
index 938712e..0000000
--- a/arch/arm/mach-kirkwood/board-mplcec4.c
+++ /dev/null
@@ -1,35 +0,0 @@
-/*
- * Copyright (C) 2012 MPL AG, Switzerland
- * Stefan Peter <s.peter@mpl.ch>
- *
- * arch/arm/mach-kirkwood/board-mplcec4.c
- *
- * This file is licensed under the terms of the GNU General Public
- * License version 2.  This program is licensed "as is" without any
- * warranty of any kind, whether express or implied.
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/mv643xx_eth.h>
-#include "common.h"
-
-static struct mv643xx_eth_platform_data mplcec4_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(1),
-};
-
-static struct mv643xx_eth_platform_data mplcec4_ge01_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(2),
-};
-
-void __init mplcec4_init(void)
-{
-	/*
-	 * Basic setup. Needs to be called early.
-	 */
-	kirkwood_ge00_init(&mplcec4_ge00_data);
-	kirkwood_ge01_init(&mplcec4_ge01_data);
-}
-
-
-
diff --git a/arch/arm/mach-kirkwood/board-ns2.c b/arch/arm/mach-kirkwood/board-ns2.c
deleted file mode 100644
index f8f6605..0000000
--- a/arch/arm/mach-kirkwood/board-ns2.c
+++ /dev/null
@@ -1,35 +0,0 @@
-/*
- * Copyright 2012 (C), Simon Guinot <simon.guinot@sequanux.org>
- *
- * arch/arm/mach-kirkwood/board-ns2.c
- *
- * LaCie Network Space v2 board (and parents) initialization for drivers
- * not converted to flattened device tree yet.
- *
- * This file is licensed under the terms of the GNU General Public
- * License version 2.  This program is licensed "as is" without any
- * warranty of any kind, whether express or implied.
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/platform_device.h>
-#include <linux/mv643xx_eth.h>
-#include <linux/of.h>
-#include "common.h"
-
-static struct mv643xx_eth_platform_data ns2_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
-};
-
-void __init ns2_init(void)
-{
-	/*
-	 * Basic setup. Needs to be called early.
-	 */
-	if (of_machine_is_compatible("lacie,cloudbox") ||
-	    of_machine_is_compatible("lacie,netspace_lite_v2") ||
-	    of_machine_is_compatible("lacie,netspace_mini_v2"))
-		ns2_ge00_data.phy_addr = MV643XX_ETH_PHY_ADDR(0);
-	kirkwood_ge00_init(&ns2_ge00_data);
-}
diff --git a/arch/arm/mach-kirkwood/board-openblocks_a6.c b/arch/arm/mach-kirkwood/board-openblocks_a6.c
deleted file mode 100644
index b11d8fd..0000000
--- a/arch/arm/mach-kirkwood/board-openblocks_a6.c
+++ /dev/null
@@ -1,26 +0,0 @@
-/*
- * Copyright 2012 Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
- *
- * arch/arm/mach-kirkwood/board-openblocks_a6.c
- *
- * This file is licensed under the terms of the GNU General Public
- * License version 2.  This program is licensed "as is" without any
- * warranty of any kind, whether express or implied.
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/mv643xx_eth.h>
-#include "common.h"
-
-static struct mv643xx_eth_platform_data openblocks_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
-void __init openblocks_a6_init(void)
-{
-	/*
-	 * Basic setup. Needs to be called early.
-	 */
-	kirkwood_ge00_init(&openblocks_ge00_data);
-}
diff --git a/arch/arm/mach-kirkwood/board-readynas.c b/arch/arm/mach-kirkwood/board-readynas.c
deleted file mode 100644
index 341b82d..0000000
--- a/arch/arm/mach-kirkwood/board-readynas.c
+++ /dev/null
@@ -1,27 +0,0 @@
-/*
- * NETGEAR ReadyNAS Duo v2 Board setup for drivers not already
- * converted to DT.
- *
- * Copyright (C) 2013, Arnaud EBALARD <arno@natisbad.org>
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/platform_device.h>
-#include <linux/mv643xx_eth.h>
-#include <mach/kirkwood.h>
-#include "common.h"
-
-static struct mv643xx_eth_platform_data netgear_readynas_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
-void __init netgear_readynas_init(void)
-{
-	kirkwood_ge00_init(&netgear_readynas_ge00_data);
-}
diff --git a/arch/arm/mach-kirkwood/board-sheevaplug.c b/arch/arm/mach-kirkwood/board-sheevaplug.c
deleted file mode 100644
index fa38937..0000000
--- a/arch/arm/mach-kirkwood/board-sheevaplug.c
+++ /dev/null
@@ -1,27 +0,0 @@
-/*
- * arch/arm/mach-kirkwood/board-sheevaplug.c
- *
- * Marvell Sheevaplug Reference Board Init for drivers not converted to
- * flattened device tree yet.
- *
- * This file is licensed under the terms of the GNU General Public
- * License version 2.  This program is licensed "as is" without any
- * warranty of any kind, whether express or implied.
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/mv643xx_eth.h>
-#include "common.h"
-
-static struct mv643xx_eth_platform_data sheevaplug_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
-void __init sheevaplug_dt_init(void)
-{
-	/*
-	 * Basic setup. Needs to be called early.
-	 */
-	kirkwood_ge00_init(&sheevaplug_ge00_data);
-}
diff --git a/arch/arm/mach-kirkwood/board-ts219.c b/arch/arm/mach-kirkwood/board-ts219.c
deleted file mode 100644
index 860f44a..0000000
--- a/arch/arm/mach-kirkwood/board-ts219.c
+++ /dev/null
@@ -1,40 +0,0 @@
-/*
- *
- * QNAP TS-11x/TS-21x Turbo NAS Board Setup via DT
- *
- * Copyright (C) 2012 Andrew Lunn <andrew@lunn.ch>
- *
- * Based on the board file ts219-setup.c:
- *
- * Copyright (C) 2009  Martin Michlmayr <tbm@cyrius.com>
- * Copyright (C) 2008  Byron Bradley <byron.bbradley@gmail.com>
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/platform_device.h>
-#include <linux/mv643xx_eth.h>
-#include <asm/mach-types.h>
-#include <asm/mach/arch.h>
-#include <mach/kirkwood.h>
-#include "common.h"
-
-static struct mv643xx_eth_platform_data qnap_ts219_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
-};
-
-void __init qnap_dt_ts219_init(void)
-{
-	u32 dev, rev;
-
-	kirkwood_pcie_id(&dev, &rev);
-	if (dev == MV88F6282_DEV_ID)
-		qnap_ts219_ge00_data.phy_addr = MV643XX_ETH_PHY_ADDR(0);
-
-	kirkwood_ge00_init(&qnap_ts219_ge00_data);
-}
diff --git a/arch/arm/mach-kirkwood/board-usi_topkick.c b/arch/arm/mach-kirkwood/board-usi_topkick.c
deleted file mode 100644
index 1cc04ec..0000000
--- a/arch/arm/mach-kirkwood/board-usi_topkick.c
+++ /dev/null
@@ -1,29 +0,0 @@
-/*
- * Copyright 2012 (C), Jason Cooper <jason@lakedaemon.net>
- *
- * arch/arm/mach-kirkwood/board-usi_topkick.c
- *
- * USI Topkick Init for drivers not converted to flattened device tree yet.
- *
- * This file is licensed under the terms of the GNU General Public
- * License version 2.  This program is licensed "as is" without any
- * warranty of any kind, whether express or implied.
- */
-
-#include <linux/kernel.h>
-#include <linux/init.h>
-#include <linux/mv643xx_eth.h>
-#include <linux/gpio.h>
-#include "common.h"
-
-static struct mv643xx_eth_platform_data topkick_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
-void __init usi_topkick_init(void)
-{
-	/*
-	 * Basic setup. Needs to be called early.
-	 */
-	kirkwood_ge00_init(&topkick_ge00_data);
-}
-- 
1.7.2.5
