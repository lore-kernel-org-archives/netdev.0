From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH next] drivers/net: remove all references to obsolete Ethernet-HOWTO
Date: Sun, 21 Jun 2015 16:28:02 -0400
Message-ID: <1434918482-22874-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:41286 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752258AbbFUUaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 16:30:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This howto made sense in the 1990s when users had to manually configure
ISA cards with jumpers or vendor utilities, but with the implementation
of PCI it became increasingly less and less relevant, to the point where
it has been well over a decade since I last updated it.  And there is
no value in anyone else taking over updating it either.

However the references to it continue to spread as boiler plate text
from one Kconfig file into the next.  We are not doing end users any
favours by pointing them at this old document, so lets kill it with
fire, once and for all, to hopefully stop any further spread.

No code is changed in this commit, just Kconfig help text.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---

[ridiculously long Cc: list intentionally omitted for what should
 be a non-contentious and essentially mindless improvement.]

 drivers/net/arcnet/Kconfig                 |  4 ----
 drivers/net/ethernet/3com/Kconfig          | 18 +++++-------------
 drivers/net/ethernet/8390/Kconfig          | 26 ++++++++------------------
 drivers/net/ethernet/adaptec/Kconfig       |  4 +---
 drivers/net/ethernet/adi/Kconfig           |  2 --
 drivers/net/ethernet/agere/Kconfig         |  4 +---
 drivers/net/ethernet/allwinner/Kconfig     |  3 +--
 drivers/net/ethernet/alteon/Kconfig        |  4 +---
 drivers/net/ethernet/amd/Kconfig           | 16 +++++-----------
 drivers/net/ethernet/apple/Kconfig         |  7 ++-----
 drivers/net/ethernet/arc/Kconfig           |  4 +---
 drivers/net/ethernet/atheros/Kconfig       |  4 +---
 drivers/net/ethernet/broadcom/Kconfig      |  3 +--
 drivers/net/ethernet/brocade/Kconfig       |  4 +---
 drivers/net/ethernet/cadence/Kconfig       |  2 --
 drivers/net/ethernet/chelsio/Kconfig       |  4 +---
 drivers/net/ethernet/cirrus/Kconfig        | 12 +++---------
 drivers/net/ethernet/cisco/Kconfig         |  4 +---
 drivers/net/ethernet/dec/Kconfig           |  4 +---
 drivers/net/ethernet/dec/tulip/Kconfig     | 10 +++-------
 drivers/net/ethernet/dlink/Kconfig         |  4 +---
 drivers/net/ethernet/emulex/Kconfig        |  4 +---
 drivers/net/ethernet/faraday/Kconfig       |  4 +---
 drivers/net/ethernet/freescale/Kconfig     |  4 +---
 drivers/net/ethernet/fujitsu/Kconfig       |  4 +---
 drivers/net/ethernet/hisilicon/Kconfig     |  4 +---
 drivers/net/ethernet/hp/Kconfig            |  8 ++------
 drivers/net/ethernet/i825xx/Kconfig        |  4 +---
 drivers/net/ethernet/ibm/Kconfig           |  4 +---
 drivers/net/ethernet/intel/Kconfig         |  4 +---
 drivers/net/ethernet/marvell/Kconfig       |  4 +---
 drivers/net/ethernet/mellanox/Kconfig      |  4 +---
 drivers/net/ethernet/micrel/Kconfig        |  4 +---
 drivers/net/ethernet/microchip/Kconfig     |  4 +---
 drivers/net/ethernet/moxa/Kconfig          |  4 +---
 drivers/net/ethernet/myricom/Kconfig       |  4 +---
 drivers/net/ethernet/natsemi/Kconfig       |  7 ++-----
 drivers/net/ethernet/neterion/Kconfig      |  4 +---
 drivers/net/ethernet/nuvoton/Kconfig       |  4 +---
 drivers/net/ethernet/nvidia/Kconfig        |  8 ++------
 drivers/net/ethernet/oki-semi/Kconfig      |  4 +---
 drivers/net/ethernet/packetengines/Kconfig |  8 ++------
 drivers/net/ethernet/pasemi/Kconfig        |  4 +---
 drivers/net/ethernet/qlogic/Kconfig        |  4 +---
 drivers/net/ethernet/qualcomm/Kconfig      |  4 +---
 drivers/net/ethernet/rdc/Kconfig           |  4 +---
 drivers/net/ethernet/realtek/Kconfig       | 14 ++++----------
 drivers/net/ethernet/renesas/Kconfig       |  4 +---
 drivers/net/ethernet/seeq/Kconfig          |  4 +---
 drivers/net/ethernet/sgi/Kconfig           |  8 ++------
 drivers/net/ethernet/silan/Kconfig         |  4 +---
 drivers/net/ethernet/sis/Kconfig           |  4 +---
 drivers/net/ethernet/smsc/Kconfig          | 18 +++++-------------
 drivers/net/ethernet/stmicro/Kconfig       |  4 +---
 drivers/net/ethernet/sun/Kconfig           |  4 +---
 drivers/net/ethernet/tehuti/Kconfig        |  4 +---
 drivers/net/ethernet/ti/Kconfig            |  8 ++------
 drivers/net/ethernet/toshiba/Kconfig       |  4 +---
 drivers/net/ethernet/tundra/Kconfig        |  4 +---
 drivers/net/ethernet/via/Kconfig           |  4 +---
 drivers/net/ethernet/wiznet/Kconfig        |  4 +---
 drivers/net/ethernet/xilinx/Kconfig        |  4 +---
 drivers/net/ethernet/xircom/Kconfig        |  4 +---
 drivers/net/ethernet/xscale/Kconfig        |  4 +---
 64 files changed, 94 insertions(+), 268 deletions(-)

diff --git a/drivers/net/arcnet/Kconfig b/drivers/net/arcnet/Kconfig
index 84fb6349a59a..2a9c3c3abe9b 100644
--- a/drivers/net/arcnet/Kconfig
+++ b/drivers/net/arcnet/Kconfig
@@ -15,10 +15,6 @@ menuconfig ARCNET
 	  COM90xx type card, so say Y (or M) to "ARCnet COM90xx chipset
 	  support" below.
 
-	  You might also want to have a look at the Ethernet-HOWTO, available
-	  from <http://www.tldp.org/docs.html#howto>(even though ARCnet
-	  is not really Ethernet).
-
 	  To compile this driver as a module, choose M here. The module will
 	  be called arcnet.
 
diff --git a/drivers/net/ethernet/3com/Kconfig b/drivers/net/ethernet/3com/Kconfig
index afaab4b2333f..5b7658bcf020 100644
--- a/drivers/net/ethernet/3com/Kconfig
+++ b/drivers/net/ethernet/3com/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_3COM
 	default y
 	depends on ISA || EISA || PCI || PCMCIA
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
@@ -23,8 +21,7 @@ config EL3
 	depends on (ISA || EISA)
 	---help---
 	  If you have a network (Ethernet) card belonging to the 3Com
-	  EtherLinkIII series, say Y and read the Ethernet-HOWTO, available
-	  from <http://www.tldp.org/docs.html#howto>.
+	  EtherLinkIII series, say Y here.
 
 	  If your card is not working you may need to use the DOS
 	  setup disk to disable Plug & Play mode, and to select the default
@@ -38,8 +35,7 @@ config 3C515
 	depends on ISA && ISA_DMA_API
 	---help---
 	  If you have a 3Com ISA EtherLink XL "Corkscrew" 3c515 Fast Ethernet
-	  network card, say Y and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  network card, say Y here.
 
 	  To compile this driver as a module, choose M here. The module
 	  will be called 3c515.
@@ -78,9 +74,7 @@ config VORTEX
 	  "Tornado"   (3c905)                                  PCI
 	  "Hurricane" (3c555/3cSOHO)                           PCI
 
-	  If you have such a card, say Y and read the Ethernet-HOWTO,
-	  available from <http://www.tldp.org/docs.html#howto>. More
-	  specific information is in
+	  If you have such a card, say Y here.  More specific information is in
 	  <file:Documentation/networking/vortex.txt> and in the comments at
 	  the beginning of <file:drivers/net/ethernet/3com/3c59x.c>.
 
@@ -97,9 +91,7 @@ config TYPHOON
 	  3CR990SVR, 3CR990SVR95, 3CR990SVR97, 3CR990-FX-95 Server,
 	  3CR990-FX-97 Server, 3C990B-TX-M, 3C990BSVR
 
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card of this type, say Y here.
 
 	  To compile this driver as a module, choose M here. The module
 	  will be called typhoon.
diff --git a/drivers/net/ethernet/8390/Kconfig b/drivers/net/ethernet/8390/Kconfig
index 2d89bd00de61..edf72258ab1d 100644
--- a/drivers/net/ethernet/8390/Kconfig
+++ b/drivers/net/ethernet/8390/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_8390
 	default y
 	depends on NET_VENDOR_NATSEMI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
@@ -71,9 +69,7 @@ config MAC8390
 	select CRC32
 	---help---
 	  If you want to include a driver to support Nubus or LC-PDS
-	  Ethernet cards using an NS8390 chipset or its equivalent, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  Ethernet cards using an NS8390 chipset or its equivalent, say Y.
 
 config MCF8390
 	tristate "ColdFire NS8390 based Ethernet support"
@@ -95,10 +91,9 @@ config NE2000
 		    ATARI_ETHERNEC)
 	select CRC32
 	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.  Many Ethernet cards
-	  without a specific driver are compatible with NE2000.
+	  If you have a network (Ethernet) card of this type, say Y here.
+	  Many Ethernet cards without a specific driver are compatible with
+	  the NE2000.
 
 	  If you have a PCI NE2000 card however, say N here and Y to "PCI
 	  NE2000 and clone support" below.
@@ -114,8 +109,7 @@ config NE2K_PCI
 	  This driver is for NE2000 compatible PCI cards. It will not work
 	  with ISA NE2000 cards (they have their own driver, "NE2000/NE1000
 	  support" below). If you have a PCI NE2000 network (Ethernet) card,
-	  say Y and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  say Y here.
 
 	  This driver also works for the following NE2000 clone cards:
 	  RealTek RTL-8029  Winbond 89C940  Compex RL2000  KTI ET32P2
@@ -164,9 +158,7 @@ config ULTRA
 	depends on ISA
 	select CRC32
 	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card of this type, say Y here.
 
 	  Important: There have been many reports that, with some motherboards
 	  mixing an SMC Ultra and an Adaptec AHA154x SCSI card (or compatible,
@@ -183,9 +175,7 @@ config WD80x3
 	depends on ISA
 	select CRC32
 	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card of this type, say Y here.
 
 	  To compile this driver as a module, choose M here. The module
 	  will be called wd.
diff --git a/drivers/net/ethernet/adaptec/Kconfig b/drivers/net/ethernet/adaptec/Kconfig
index 5c804bbe3dab..822cffb4174c 100644
--- a/drivers/net/ethernet/adaptec/Kconfig
+++ b/drivers/net/ethernet/adaptec/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_ADAPTEC
 	default y
 	depends on PCI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/adi/Kconfig b/drivers/net/ethernet/adi/Kconfig
index c9cd3592ab73..6b94ba610399 100644
--- a/drivers/net/ethernet/adi/Kconfig
+++ b/drivers/net/ethernet/adi/Kconfig
@@ -7,8 +7,6 @@ config NET_BFIN
 	depends on BF516 || BF518 || BF526 || BF527 || BF536 || BF537
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
-	  Make sure you know the name of your card. Read the Ethernet-HOWTO,
-	  available from <http://www.tldp.org/docs.html#howto>.
 
 	  If unsure, say Y.
 
diff --git a/drivers/net/ethernet/agere/Kconfig b/drivers/net/ethernet/agere/Kconfig
index 63e805de619e..b6fe9200355a 100644
--- a/drivers/net/ethernet/agere/Kconfig
+++ b/drivers/net/ethernet/agere/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_AGERE
 	default y
 	depends on PCI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/allwinner/Kconfig b/drivers/net/ethernet/allwinner/Kconfig
index d8d95d4cd45a..47da7e7a5b6a 100644
--- a/drivers/net/ethernet/allwinner/Kconfig
+++ b/drivers/net/ethernet/allwinner/Kconfig
@@ -9,8 +9,7 @@ config NET_VENDOR_ALLWINNER
 	depends on ARCH_SUNXI
 	---help---
 	  If you have a network (Ethernet) card belonging to this
-	  class, say Y and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  class, say Y here.
 
 	  Note that the answer to this question doesn't directly
 	  affect the kernel: saying N will just cause the configurator
diff --git a/drivers/net/ethernet/alteon/Kconfig b/drivers/net/ethernet/alteon/Kconfig
index 799a85282070..e06ccab354b5 100644
--- a/drivers/net/ethernet/alteon/Kconfig
+++ b/drivers/net/ethernet/alteon/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_ALTEON
 	default y
 	depends on PCI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/amd/Kconfig b/drivers/net/ethernet/amd/Kconfig
index acd53173fcc0..afc62ea804fc 100644
--- a/drivers/net/ethernet/amd/Kconfig
+++ b/drivers/net/ethernet/amd/Kconfig
@@ -37,8 +37,7 @@ config AMD8111_ETH
 	select MII
 	---help---
 	  If you have an AMD 8111-based PCI LANCE ethernet card,
-	  answer Y here and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  answer Y here.
 
 	  To compile this driver as a module, choose M here. The module
 	  will be called amd8111e.
@@ -47,10 +46,8 @@ config LANCE
 	tristate "AMD LANCE and PCnet (AT1500 and NE2100) support"
 	depends on ISA && ISA_DMA_API && !ARM
 	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>. Some LinkSys cards are
-	  of this type.
+	  If you have a network (Ethernet) card of this type, say Y here.
+	  Some LinkSys cards are of this type.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called lance.  This is recommended.
@@ -62,8 +59,7 @@ config PCNET32
 	select MII
 	---help---
 	  If you have a PCnet32 or PCnetPCI based network (Ethernet) card,
-	  answer Y here and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  answer Y here.
 
 	  To compile this driver as a module, choose M here. The module
 	  will be called pcnet32.
@@ -144,9 +140,7 @@ config NI65
 	tristate "NI6510 support"
 	depends on ISA && ISA_DMA_API && !ARM
 	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card of this type, say Y here.
 
 	  To compile this driver as a module, choose M here. The module
 	  will be called ni65.
diff --git a/drivers/net/ethernet/apple/Kconfig b/drivers/net/ethernet/apple/Kconfig
index 1375e2dc9468..d19a41b0c6d2 100644
--- a/drivers/net/ethernet/apple/Kconfig
+++ b/drivers/net/ethernet/apple/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_APPLE
 	default y
 	depends on (PPC_PMAC && PPC32) || MAC
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
@@ -59,7 +57,6 @@ config MACMACE
 	---help---
 	  Support for the onboard AMD 79C940 MACE Ethernet controller used in
 	  the 660AV and 840AV Macintosh.  If you have one of these Macintoshes
-	  say Y and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  say Y here.
 
 endif # NET_VENDOR_APPLE
diff --git a/drivers/net/ethernet/arc/Kconfig b/drivers/net/ethernet/arc/Kconfig
index dea29ee24da4..52a6b16f57d2 100644
--- a/drivers/net/ethernet/arc/Kconfig
+++ b/drivers/net/ethernet/arc/Kconfig
@@ -6,9 +6,7 @@ config NET_VENDOR_ARC
 	bool "ARC devices"
 	default y
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/atheros/Kconfig b/drivers/net/ethernet/atheros/Kconfig
index 58ad37c733bc..e05b25675333 100644
--- a/drivers/net/ethernet/atheros/Kconfig
+++ b/drivers/net/ethernet/atheros/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_ATHEROS
 	default y
 	depends on PCI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index a6f9142b9048..8be9eab73320 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -26,8 +26,7 @@ config B44
 	select PHYLIB
 	---help---
 	  If you have a network (Ethernet) controller of this type, say Y
-	  or M and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  or M here.
 
 	  To compile this driver as a module, choose M here. The module
 	  will be called b44.
diff --git a/drivers/net/ethernet/brocade/Kconfig b/drivers/net/ethernet/brocade/Kconfig
index 4e8c0b6c57d0..c4bbe54e2cad 100644
--- a/drivers/net/ethernet/brocade/Kconfig
+++ b/drivers/net/ethernet/brocade/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_BROCADE
 	default y
 	depends on PCI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
index 1ba3e3a67389..f0bcb15d3fec 100644
--- a/drivers/net/ethernet/cadence/Kconfig
+++ b/drivers/net/ethernet/cadence/Kconfig
@@ -8,8 +8,6 @@ config NET_CADENCE
 	default y
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
-	  Make sure you know the name of your card. Read the Ethernet-HOWTO,
-	  available from <http://www.tldp.org/docs.html#howto>.
 
 	  If unsure, say Y.
 
diff --git a/drivers/net/ethernet/chelsio/Kconfig b/drivers/net/ethernet/chelsio/Kconfig
index 7daa088a9bb7..a79813a17b6e 100644
--- a/drivers/net/ethernet/chelsio/Kconfig
+++ b/drivers/net/ethernet/chelsio/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_CHELSIO
 	default y
 	depends on PCI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/cirrus/Kconfig b/drivers/net/ethernet/cirrus/Kconfig
index 905ac5f5d9a6..5ab912937aff 100644
--- a/drivers/net/ethernet/cirrus/Kconfig
+++ b/drivers/net/ethernet/cirrus/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_CIRRUS
 	default y
 	depends on ISA || EISA || ARM || MAC
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
@@ -23,9 +21,7 @@ config CS89x0
 	depends on ISA || EISA || ARM
 	---help---
 	  Support for CS89x0 chipset based Ethernet cards. If you have a
-	  network (Ethernet) card of this type, say Y and read the
-	  Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto> as well as
+	  network (Ethernet) card of this type, say Y and read the file
 	  <file:Documentation/networking/cs89x0.txt>.
 
 	  To compile this driver as a module, choose M here. The module
@@ -55,9 +51,7 @@ config MAC89x0
 	depends on MAC
 	---help---
 	  Support for CS89x0 chipset based Ethernet cards.  If you have a
-	  Nubus or LC-PDS network (Ethernet) card of this type, say Y and
-	  read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  Nubus or LC-PDS network (Ethernet) card of this type, say Y here.
 
 	  To compile this driver as a module, choose M here. This module will
 	  be called mac89x0.
diff --git a/drivers/net/ethernet/cisco/Kconfig b/drivers/net/ethernet/cisco/Kconfig
index 1c7b884e3371..15b713a89620 100644
--- a/drivers/net/ethernet/cisco/Kconfig
+++ b/drivers/net/ethernet/cisco/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_CISCO
 	default y
 	depends on PCI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/dec/Kconfig b/drivers/net/ethernet/dec/Kconfig
index 68262aa57d01..740bbad5ed38 100644
--- a/drivers/net/ethernet/dec/Kconfig
+++ b/drivers/net/ethernet/dec/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_DEC
 	default y
 	depends on PCI || EISA || CARDBUS
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/dec/tulip/Kconfig b/drivers/net/ethernet/dec/tulip/Kconfig
index eb9ba6e97d04..1003201b5d80 100644
--- a/drivers/net/ethernet/dec/tulip/Kconfig
+++ b/drivers/net/ethernet/dec/tulip/Kconfig
@@ -21,8 +21,7 @@ config DE2104X
 	  of this type.  (If your card is NOT SMC EtherPower 10/100 PCI
 	  (smc9332dst), you can also try the driver for "Generic DECchip"
 	  cards, below.  However, most people with a network card of this type
-	  will say Y here.) Do read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  will say Y here.)
 
 	  To compile this driver as a module, choose M here. The module will
 	  be called de2104x.
@@ -50,8 +49,7 @@ config TULIP
 	  of this type.  (If your card is NOT SMC EtherPower 10/100 PCI
 	  (smc9332dst), you can also try the driver for "Generic DECchip"
 	  cards, above.  However, most people with a network card of this type
-	  will say Y here.) Do read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  will say Y here.)
 
 	  To compile this driver as a module, choose M here. The module will
 	  be called tulip.
@@ -113,9 +111,7 @@ config DE4X5
 	---help---
 	  This is support for the DIGITAL series of PCI/EISA Ethernet cards.
 	  These include the DE425, DE434, DE435, DE450 and DE500 models.  If
-	  you have a network card of this type, say Y and read the
-	  Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>. More specific
+	  you have a network card of this type, say Y.  More specific
 	  information is contained in
 	  <file:Documentation/networking/de4x5.txt>.
 
diff --git a/drivers/net/ethernet/dlink/Kconfig b/drivers/net/ethernet/dlink/Kconfig
index c543ac11ce08..f6e858d0b9d4 100644
--- a/drivers/net/ethernet/dlink/Kconfig
+++ b/drivers/net/ethernet/dlink/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_DLINK
 	default y
 	depends on PCI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/emulex/Kconfig b/drivers/net/ethernet/emulex/Kconfig
index 1b8d638c6cb1..fdbb27ceb02f 100644
--- a/drivers/net/ethernet/emulex/Kconfig
+++ b/drivers/net/ethernet/emulex/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_EMULEX
 	default y
 	depends on PCI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/faraday/Kconfig b/drivers/net/ethernet/faraday/Kconfig
index 5918c6891694..040c7f163325 100644
--- a/drivers/net/ethernet/faraday/Kconfig
+++ b/drivers/net/ethernet/faraday/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_FARADAY
 	default y
 	depends on ARM
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
index 25e3425729d0..b8de87b03046 100644
--- a/drivers/net/ethernet/freescale/Kconfig
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -9,9 +9,7 @@ config NET_VENDOR_FREESCALE
 		   M523x || M527x || M5272 || M528x || M520x || M532x || \
 		   ARCH_MXC || ARCH_MXS || (PPC_MPC52xx && PPC_BESTCOMM)
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/fujitsu/Kconfig b/drivers/net/ethernet/fujitsu/Kconfig
index 1085257385d2..faee34e44a35 100644
--- a/drivers/net/ethernet/fujitsu/Kconfig
+++ b/drivers/net/ethernet/fujitsu/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_FUJITSU
 	default y
 	depends on PCMCIA
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  the questions about Fujitsu cards. If you say Y, you will be asked for
diff --git a/drivers/net/ethernet/hisilicon/Kconfig b/drivers/net/ethernet/hisilicon/Kconfig
index a54d89791311..dead17b5d769 100644
--- a/drivers/net/ethernet/hisilicon/Kconfig
+++ b/drivers/net/ethernet/hisilicon/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_HISILICON
 	default y
 	depends on ARM
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/hp/Kconfig b/drivers/net/ethernet/hp/Kconfig
index a0b8ece1e3bc..d4df78c2abce 100644
--- a/drivers/net/ethernet/hp/Kconfig
+++ b/drivers/net/ethernet/hp/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_HP
 	default y
 	depends on ISA || EISA || PCI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
@@ -22,9 +20,7 @@ config HP100
 	tristate "HP 10/100VG PCLAN (ISA, EISA, PCI) support"
 	depends on (ISA || EISA || PCI)
 	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card of this type, say Y here.
 
 	  To compile this driver as a module, choose M here. The module
 	  will be called hp100.
diff --git a/drivers/net/ethernet/i825xx/Kconfig b/drivers/net/ethernet/i825xx/Kconfig
index 9521e68aa3b3..e8d61f670479 100644
--- a/drivers/net/ethernet/i825xx/Kconfig
+++ b/drivers/net/ethernet/i825xx/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_I825XX
 	default y
 	depends on NET_VENDOR_INTEL
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question does not directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/ibm/Kconfig b/drivers/net/ethernet/ibm/Kconfig
index 563a1ac71dbc..99c1cebd002d 100644
--- a/drivers/net/ethernet/ibm/Kconfig
+++ b/drivers/net/ethernet/ibm/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_IBM
 	default y
 	depends on PPC_PSERIES || PPC_DCR || (IBMEBUS && SPARSEMEM)
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index f4ff465584a0..4163b16489b3 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -6,9 +6,7 @@ config NET_VENDOR_INTEL
 	bool "Intel devices"
 	default y
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index d323a695dfbc..80af9ffce5ea 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_MARVELL
 	default y
 	depends on PCI || CPU_PXA168 || MV64X60 || PPC32 || PLAT_ORION || INET
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/mellanox/Kconfig b/drivers/net/ethernet/mellanox/Kconfig
index 8cf7563a8d92..52a6665b7abf 100644
--- a/drivers/net/ethernet/mellanox/Kconfig
+++ b/drivers/net/ethernet/mellanox/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_MELLANOX
 	default y
 	depends on PCI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/micrel/Kconfig b/drivers/net/ethernet/micrel/Kconfig
index d16b11ed2e52..b7e2f49696b7 100644
--- a/drivers/net/ethernet/micrel/Kconfig
+++ b/drivers/net/ethernet/micrel/Kconfig
@@ -8,9 +8,7 @@ config NET_VENDOR_MICREL
 	depends on (HAS_IOMEM && DMA_ENGINE) || SPI || PCI || HAS_IOMEM || \
 		   (ARM && ARCH_KS8695)
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/microchip/Kconfig b/drivers/net/ethernet/microchip/Kconfig
index afaf0c07f37f..3fd8ca6d4e7c 100644
--- a/drivers/net/ethernet/microchip/Kconfig
+++ b/drivers/net/ethernet/microchip/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_MICROCHIP
 	default y
 	depends on SPI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/moxa/Kconfig b/drivers/net/ethernet/moxa/Kconfig
index 1731e050fa27..5b531da36933 100644
--- a/drivers/net/ethernet/moxa/Kconfig
+++ b/drivers/net/ethernet/moxa/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_MOXART
 	default y
 	depends on (ARM && ARCH_MOXART)
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/myricom/Kconfig b/drivers/net/ethernet/myricom/Kconfig
index 3932d081fa21..9645c7245bbf 100644
--- a/drivers/net/ethernet/myricom/Kconfig
+++ b/drivers/net/ethernet/myricom/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_MYRI
 	default y
 	depends on PCI && INET
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say
-	  Y and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/natsemi/Kconfig b/drivers/net/ethernet/natsemi/Kconfig
index a100860d45e6..a10ef50e4f12 100644
--- a/drivers/net/ethernet/natsemi/Kconfig
+++ b/drivers/net/ethernet/natsemi/Kconfig
@@ -6,9 +6,7 @@ config NET_VENDOR_NATSEMI
 	bool "National Semi-conductor devices"
 	default y
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
@@ -24,8 +22,7 @@ config MACSONIC
 	  Support for NatSemi SONIC based Ethernet devices.  This includes
 	  the onboard Ethernet in many Quadras as well as some LC-PDS,
 	  a few Nubus and all known Comm Slot Ethernet cards.  If you have
-	  one of these say Y and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  one of these say Y here.
 
 	  To compile this driver as a module, choose M here. This module will
 	  be called macsonic.
diff --git a/drivers/net/ethernet/neterion/Kconfig b/drivers/net/ethernet/neterion/Kconfig
index 87abb4f10c43..71899009c468 100644
--- a/drivers/net/ethernet/neterion/Kconfig
+++ b/drivers/net/ethernet/neterion/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_EXAR
 	default y
 	depends on PCI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say
-	  Y and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/nuvoton/Kconfig b/drivers/net/ethernet/nuvoton/Kconfig
index 01182b559473..71c973f8e50f 100644
--- a/drivers/net/ethernet/nuvoton/Kconfig
+++ b/drivers/net/ethernet/nuvoton/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_NUVOTON
 	default y
 	depends on ARM && ARCH_W90X900
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/nvidia/Kconfig b/drivers/net/ethernet/nvidia/Kconfig
index ace19e7f6d13..4efc9fe84785 100644
--- a/drivers/net/ethernet/nvidia/Kconfig
+++ b/drivers/net/ethernet/nvidia/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_NVIDIA
 	default y
 	depends on PCI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
@@ -22,9 +20,7 @@ config FORCEDETH
 	tristate "nForce Ethernet support"
 	depends on PCI
 	---help---
-	  If you have a network (Ethernet) controller of this type, say Y and
-	  read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) controller of this type, say Y here.
 
 	  To compile this driver as a module, choose M here. The module
 	  will be called forcedeth.
diff --git a/drivers/net/ethernet/oki-semi/Kconfig b/drivers/net/ethernet/oki-semi/Kconfig
index ecd45f9ea9d9..5a975af4824b 100644
--- a/drivers/net/ethernet/oki-semi/Kconfig
+++ b/drivers/net/ethernet/oki-semi/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_OKI
 	default y
 	depends on PCI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/packetengines/Kconfig b/drivers/net/ethernet/packetengines/Kconfig
index 8d5180043c70..b5ea2a56106e 100644
--- a/drivers/net/ethernet/packetengines/Kconfig
+++ b/drivers/net/ethernet/packetengines/Kconfig
@@ -7,9 +7,7 @@ config NET_PACKET_ENGINE
 	default y
 	depends on PCI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
@@ -23,9 +21,7 @@ config HAMACHI
 	depends on PCI
 	select MII
 	---help---
-	  If you have a Gigabit Ethernet card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a Gigabit Ethernet card of this type, say Y here.
 
 	  To compile this driver as a module, choose M here. The module will be
 	  called hamachi.
diff --git a/drivers/net/ethernet/pasemi/Kconfig b/drivers/net/ethernet/pasemi/Kconfig
index 01e6c329d78c..db19c6f49859 100644
--- a/drivers/net/ethernet/pasemi/Kconfig
+++ b/drivers/net/ethernet/pasemi/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_PASEMI
 	default y
 	depends on PPC_PASEMI && PCI && INET
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
index d49cba129081..f1f0108c275d 100644
--- a/drivers/net/ethernet/qlogic/Kconfig
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_QLOGIC
 	default y
 	depends on PCI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/qualcomm/Kconfig b/drivers/net/ethernet/qualcomm/Kconfig
index 9a49f42ac2ba..a76e380cf89a 100644
--- a/drivers/net/ethernet/qualcomm/Kconfig
+++ b/drivers/net/ethernet/qualcomm/Kconfig
@@ -6,9 +6,7 @@ config NET_VENDOR_QUALCOMM
 	bool "Qualcomm devices"
 	default y
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/rdc/Kconfig b/drivers/net/ethernet/rdc/Kconfig
index 2055f7eb2ba9..a9c4e990d29b 100644
--- a/drivers/net/ethernet/rdc/Kconfig
+++ b/drivers/net/ethernet/rdc/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_RDC
 	default y
 	depends on PCI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/realtek/Kconfig b/drivers/net/ethernet/realtek/Kconfig
index ae5d027096ed..7c69f4c8134d 100644
--- a/drivers/net/ethernet/realtek/Kconfig
+++ b/drivers/net/ethernet/realtek/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_REALTEK
 	default y
 	depends on PCI || (PARPORT && X86)
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
@@ -24,8 +22,7 @@ config ATP
 	select CRC32
 	---help---
 	  This is a network (Ethernet) device which attaches to your parallel
-	  port. Read <file:drivers/net/ethernet/realtek/atp.c> as well as the
-	  Ethernet-HOWTO, available from <http://www.tldp.org/docs.html#howto>,
+	  port. Read the file <file:drivers/net/ethernet/realtek/atp.c>
 	  if you want to use this.  If you intend to use this driver, you
 	  should have said N to the "Parallel printer support", because the two
 	  drivers don't like each other.
@@ -40,9 +37,7 @@ config 8139CP
 	select MII
 	---help---
 	  This is a driver for the Fast Ethernet PCI network cards based on
-	  the RTL8139C+ chips. If you have one of those, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  the RTL8139C+ chips. If you have one of those, say Y here.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called 8139cp.  This is recommended.
@@ -54,8 +49,7 @@ config 8139TOO
 	select MII
 	---help---
 	  This is a driver for the Fast Ethernet PCI network cards based on
-	  the RTL 8129/8130/8139 chips. If you have one of those, say Y and
-	  read the Ethernet-HOWTO <http://www.tldp.org/docs.html#howto>.
+	  the RTL 8129/8130/8139 chips. If you have one of those, say Y here.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called 8139too.  This is recommended.
diff --git a/drivers/net/ethernet/renesas/Kconfig b/drivers/net/ethernet/renesas/Kconfig
index 8e8031a1c6c7..270c4c9cac7f 100644
--- a/drivers/net/ethernet/renesas/Kconfig
+++ b/drivers/net/ethernet/renesas/Kconfig
@@ -6,9 +6,7 @@ config NET_VENDOR_RENESAS
 	bool "Renesas devices"
 	default y
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/seeq/Kconfig b/drivers/net/ethernet/seeq/Kconfig
index 11f168e46ebe..69c62d89295e 100644
--- a/drivers/net/ethernet/seeq/Kconfig
+++ b/drivers/net/ethernet/seeq/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_SEEQ
 	default y
 	depends on HAS_IOMEM
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/sgi/Kconfig b/drivers/net/ethernet/sgi/Kconfig
index e832f46660c9..fbbb21c13e95 100644
--- a/drivers/net/ethernet/sgi/Kconfig
+++ b/drivers/net/ethernet/sgi/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_SGI
 	default y
 	depends on (PCI && SGI_IP27) || SGI_IP32
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
@@ -24,9 +22,7 @@ config SGI_IOC3_ETH
 	select CRC32
 	select MII
 	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card of this type, say Y here.
 
 config SGI_O2MACE_ETH
 	tristate "SGI O2 MACE Fast Ethernet support"
diff --git a/drivers/net/ethernet/silan/Kconfig b/drivers/net/ethernet/silan/Kconfig
index 3409b3f97a1b..ac982be38510 100644
--- a/drivers/net/ethernet/silan/Kconfig
+++ b/drivers/net/ethernet/silan/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_SILAN
 	default y
 	depends on PCI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/sis/Kconfig b/drivers/net/ethernet/sis/Kconfig
index 68d052b09af1..22ec98ec9d3e 100644
--- a/drivers/net/ethernet/sis/Kconfig
+++ b/drivers/net/ethernet/sis/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_SIS
 	default y
 	depends on PCI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/smsc/Kconfig b/drivers/net/ethernet/smsc/Kconfig
index 3e97a8b43147..eb9230e2092f 100644
--- a/drivers/net/ethernet/smsc/Kconfig
+++ b/drivers/net/ethernet/smsc/Kconfig
@@ -9,9 +9,7 @@ config NET_VENDOR_SMSC
 		   ISA || M32R || MAC || MIPS || MN10300 || NIOS2 || PCI || \
 		   PCMCIA || SUPERH || XTENSA
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
@@ -29,8 +27,7 @@ config SMC9194
 	  option if you have a DELL laptop with the docking station, or
 	  another SMC9192/9194 based chipset.  Say Y if you want it compiled
 	  into the kernel, and read the file
-	  <file:Documentation/networking/smc9.txt> and the Ethernet-HOWTO,
-	  available from <http://www.tldp.org/docs.html#howto>.
+	  <file:Documentation/networking/smc9.txt>.
 
 	  To compile this driver as a module, choose M here. The module
 	  will be called smc9194.
@@ -46,8 +43,7 @@ config SMC91X
 	  This is a driver for SMC's 91x series of Ethernet chipsets,
 	  including the SMC91C94 and the SMC91C111. Say Y if you want it
 	  compiled into the kernel, and read the file
-	  <file:Documentation/networking/smc9.txt>  and the Ethernet-HOWTO,
-	  available from  <http://www.tldp.org/docs.html#howto>.
+	  <file:Documentation/networking/smc9.txt>.
 
 	  This driver is also available as a module ( = code which can be
 	  inserted in and removed from the running kernel whenever you want).
@@ -85,9 +81,7 @@ config SMC911X
 	---help---
 	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
 	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.
-	  Say Y if you want it compiled into the kernel,
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  Say Y here if you want it compiled into the kernel.
 
 	  This driver is also available as a module. The module will be
 	  called smc911x.  If you want to compile it as a module, say M
@@ -122,9 +116,7 @@ config SMSC9420
 	select SMSC_PHY
 	---help---
 	  This is a driver for SMSC's LAN9420 PCI ethernet adapter.
-	  Say Y if you want it compiled into the kernel,
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  Say Y here if you want it compiled into the kernel.
 
 	  This driver is also available as a module. The module will be
 	  called smsc9420.  If you want to compile it as a module, say M
diff --git a/drivers/net/ethernet/stmicro/Kconfig b/drivers/net/ethernet/stmicro/Kconfig
index f4a80da00650..1c1157d2bd40 100644
--- a/drivers/net/ethernet/stmicro/Kconfig
+++ b/drivers/net/ethernet/stmicro/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_STMICRO
 	default y
 	depends on HAS_IOMEM
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/sun/Kconfig b/drivers/net/ethernet/sun/Kconfig
index 3074aa374c6b..dee94b67638c 100644
--- a/drivers/net/ethernet/sun/Kconfig
+++ b/drivers/net/ethernet/sun/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_SUN
 	default y
 	depends on SUN3 || SBUS || PCI || SUN_LDOMS
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say
-	  Y and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/tehuti/Kconfig b/drivers/net/ethernet/tehuti/Kconfig
index 1fc027eda33e..b17f0ca3f395 100644
--- a/drivers/net/ethernet/tehuti/Kconfig
+++ b/drivers/net/ethernet/tehuti/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_TEHUTI
 	default y
 	depends on PCI
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index 631e0afd07d2..e7f0b7d95b65 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_TI
 	default y
 	depends on PCI || EISA || AR7 || ARCH_DAVINCI || ARCH_OMAP2PLUS || ARCH_KEYSTONE
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
@@ -110,9 +108,7 @@ config TLAN
 	depends on (PCI || EISA)
 	---help---
 	  If you have a PCI Ethernet network card based on the ThunderLAN chip
-	  which is supported by this driver, say Y and read the
-	  Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  which is supported by this driver, say Y here.
 
 	  Devices currently supported by this driver are Compaq Netelligent,
 	  Compaq NetFlex and Olicom cards.  Please read the file
diff --git a/drivers/net/ethernet/toshiba/Kconfig b/drivers/net/ethernet/toshiba/Kconfig
index 5d244b6b5e3a..6f1d5b623768 100644
--- a/drivers/net/ethernet/toshiba/Kconfig
+++ b/drivers/net/ethernet/toshiba/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_TOSHIBA
 	default y
 	depends on PCI && (PPC_IBM_CELL_BLADE || MIPS) || PPC_PS3
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/tundra/Kconfig b/drivers/net/ethernet/tundra/Kconfig
index cf7d69b62c42..81d845e4e23b 100644
--- a/drivers/net/ethernet/tundra/Kconfig
+++ b/drivers/net/ethernet/tundra/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_TUNDRA
 	default y
 	depends on TSI108_BRIDGE
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/via/Kconfig b/drivers/net/ethernet/via/Kconfig
index ad7f51218ab5..8b0b1d6aca72 100644
--- a/drivers/net/ethernet/via/Kconfig
+++ b/drivers/net/ethernet/via/Kconfig
@@ -6,9 +6,7 @@ config NET_VENDOR_VIA
 	bool "VIA devices"
 	default y
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/wiznet/Kconfig b/drivers/net/ethernet/wiznet/Kconfig
index b4d281626fb4..f98b91d21f33 100644
--- a/drivers/net/ethernet/wiznet/Kconfig
+++ b/drivers/net/ethernet/wiznet/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_WIZNET
 	depends on HAS_IOMEM
 	default y
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/xilinx/Kconfig b/drivers/net/ethernet/xilinx/Kconfig
index 7b90a5eba099..4f5c024c6192 100644
--- a/drivers/net/ethernet/xilinx/Kconfig
+++ b/drivers/net/ethernet/xilinx/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_XILINX
 	default y
 	depends on PPC || PPC32 || MICROBLAZE || ARCH_ZYNQ
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/xircom/Kconfig b/drivers/net/ethernet/xircom/Kconfig
index 69f56a6de821..d6208a4c9866 100644
--- a/drivers/net/ethernet/xircom/Kconfig
+++ b/drivers/net/ethernet/xircom/Kconfig
@@ -7,9 +7,7 @@ config NET_VENDOR_XIRCOM
 	default y
 	depends on PCMCIA
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
diff --git a/drivers/net/ethernet/xscale/Kconfig b/drivers/net/ethernet/xscale/Kconfig
index b81bc9fca378..af3432fe9a5e 100644
--- a/drivers/net/ethernet/xscale/Kconfig
+++ b/drivers/net/ethernet/xscale/Kconfig
@@ -8,9 +8,7 @@ config NET_VENDOR_XSCALE
 	depends on NET_VENDOR_INTEL && (ARM && ARCH_IXP4XX && \
 		   IXP4XX_NPE && IXP4XX_QMGR)
 	---help---
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  If you have a network (Ethernet) card belonging to this class, say Y.
 
 	  Note that the answer to this question does not directly affect the
 	  kernel: saying N will just cause the configurator to skip all
-- 
2.2.1
