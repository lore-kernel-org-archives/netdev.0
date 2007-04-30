From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 5/5] MIPS: Drop unnecessary CONFIG_ISA from RBTX49XX
Date: Tue, 01 May 2007 00:28:03 +0900 (JST)
Message-ID: <20070501.002803.95061116.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, ralf@linux-mips.org,
	sshtylyov@ru.mvista.com, akpm@linux-foundation.org
To: linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.175.29]:55970 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423372AbXD3P2D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 11:28:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Those boards do not need CONFIG_ISA if the ne driver could be
selectable without it.  Disable it and update a defconfig.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 arch/mips/Kconfig                     |    2 --
 arch/mips/configs/rbhma4500_defconfig |   31 -------------------------------
 2 files changed, 0 insertions(+), 33 deletions(-)

diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index c78b143..e1e08dc 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -786,7 +786,6 @@ config TOSHIBA_RBTX4927
 	select HAS_TXX9_SERIAL
 	select HW_HAS_PCI
 	select I8259
-	select ISA
 	select SWAP_IO_SPACE
 	select SYS_HAS_CPU_TX49XX
 	select SYS_SUPPORTS_32BIT_KERNEL
@@ -808,7 +807,6 @@ config TOSHIBA_RBTX4938
 	select HAS_TXX9_SERIAL
 	select HW_HAS_PCI
 	select I8259
-	select ISA
 	select SWAP_IO_SPACE
 	select SYS_HAS_CPU_TX49XX
 	select SYS_SUPPORTS_32BIT_KERNEL
diff --git a/arch/mips/configs/rbhma4500_defconfig b/arch/mips/configs/rbhma4500_defconfig
index 29e0df9..7d0f217 100644
--- a/arch/mips/configs/rbhma4500_defconfig
+++ b/arch/mips/configs/rbhma4500_defconfig
@@ -245,7 +245,6 @@ CONFIG_DEFAULT_IOSCHED="anticipatory"
 #
 CONFIG_HW_HAS_PCI=y
 CONFIG_PCI=y
-CONFIG_ISA=y
 CONFIG_MMU=y
 
 #
@@ -573,7 +572,6 @@ CONFIG_MTD_CFI_UTIL=y
 #
 # Plug and Play support
 #
-# CONFIG_PNP is not set
 # CONFIG_PNPACPI is not set
 
 #
@@ -658,7 +656,6 @@ CONFIG_BLK_DEV_IT8213=m
 # CONFIG_BLK_DEV_VIA82CXXX is not set
 CONFIG_BLK_DEV_TC86C001=m
 # CONFIG_IDE_ARM is not set
-# CONFIG_IDE_CHIPSETS is not set
 CONFIG_BLK_DEV_IDEDMA=y
 # CONFIG_IDEDMA_IVB is not set
 # CONFIG_IDEDMA_AUTO is not set
@@ -677,11 +674,6 @@ CONFIG_RAID_ATTRS=m
 # CONFIG_ATA is not set
 
 #
-# Old CD-ROM drivers (not SCSI, not IDE)
-#
-# CONFIG_CD_NO_IDESCSI is not set
-
-#
 # Multi-device support (RAID and LVM)
 #
 # CONFIG_MD is not set
@@ -742,37 +734,20 @@ CONFIG_NET_ETHERNET=y
 # CONFIG_SUNGEM is not set
 # CONFIG_CASSINI is not set
 # CONFIG_NET_VENDOR_3COM is not set
-# CONFIG_NET_VENDOR_SMC is not set
 # CONFIG_DM9000 is not set
-# CONFIG_NET_VENDOR_RACAL is not set
 
 #
 # Tulip family network device support
 #
 # CONFIG_NET_TULIP is not set
-# CONFIG_AT1700 is not set
-# CONFIG_DEPCA is not set
 # CONFIG_HP100 is not set
-CONFIG_NET_ISA=y
-# CONFIG_E2100 is not set
-# CONFIG_EWRK3 is not set
-# CONFIG_EEXPRESS is not set
-# CONFIG_EEXPRESS_PRO is not set
-# CONFIG_HPLAN_PLUS is not set
-# CONFIG_HPLAN is not set
-# CONFIG_LP486E is not set
-# CONFIG_ETH16I is not set
 CONFIG_NE2000=y
-# CONFIG_SEEQ8005 is not set
 CONFIG_NET_PCI=y
 # CONFIG_PCNET32 is not set
 # CONFIG_AMD8111_ETH is not set
 # CONFIG_ADAPTEC_STARFIRE is not set
-# CONFIG_AC3200 is not set
-# CONFIG_APRICOT is not set
 # CONFIG_B44 is not set
 # CONFIG_FORCEDETH is not set
-# CONFIG_CS89x0 is not set
 # CONFIG_DGRS is not set
 # CONFIG_EEPRO100 is not set
 # CONFIG_E100 is not set
@@ -833,8 +808,6 @@ CONFIG_NET_RADIO=y
 # Obsolete Wireless cards support (pre-802.11)
 #
 # CONFIG_STRIP is not set
-# CONFIG_ARLAN is not set
-# CONFIG_WAVELAN is not set
 
 #
 # Wireless 802.11b ISA/PCI cards support
@@ -920,9 +893,6 @@ CONFIG_KEYBOARD_ATKBD=y
 CONFIG_INPUT_MOUSE=y
 CONFIG_MOUSE_PS2=y
 # CONFIG_MOUSE_SERIAL is not set
-# CONFIG_MOUSE_INPORT is not set
-# CONFIG_MOUSE_LOGIBM is not set
-# CONFIG_MOUSE_PC110PAD is not set
 # CONFIG_MOUSE_VSXXXAA is not set
 # CONFIG_INPUT_JOYSTICK is not set
 # CONFIG_INPUT_TOUCHSCREEN is not set
@@ -1072,7 +1042,6 @@ CONFIG_FB_ATY_CT=y
 #
 CONFIG_VGA_CONSOLE=y
 # CONFIG_VGACON_SOFT_SCROLLBACK is not set
-# CONFIG_MDA_CONSOLE is not set
 CONFIG_DUMMY_CONSOLE=y
 # CONFIG_FRAMEBUFFER_CONSOLE is not set
 



