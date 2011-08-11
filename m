From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/10] amd: Move AMD (Lance) chipset drivers
Date: Wed, 10 Aug 2011 20:27:51 -0700
Message-ID: <1313033278-7337-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313033278-7337-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@tredhat.com, sassmann@redhat.com,
	Peter Maydell <pmaydell@chiark.greenend.org.uk>,
	Roman Hodek <Roman.Hodek@informatik.uni-erlangen.de>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Donald Becker <becker@scyld.com>,
	Sam Creasey <sammy@users.qual.net>,
	Miguel de Icaza <miguel@nuclecu.unam.mx>,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	Don Fry <pcnet32@frontier.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Russell King <linux@arm.linux.org.uk>,
	David Davies <davies@maniac.ultranet.com>,
	"M.Hipp" <hippm@informatik.uni-tuebingen.de>,
	Pete Popov <ppopov@embeddedalley.com>,
	David Hinds <dahinds@users.sourceforge.net>,
	"Roger C. Pao" <rpao@paonet.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4743 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753987Ab1HKD2F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2011 23:28:05 -0400
In-Reply-To: <1313033278-7337-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves the drivers for the AMD chipsets into drivers/net/ethernet/amd/
and the necessary Kconfig and Makfile changes.

The au1000 (Alchemy) driver was also moved into the same directory
even though it is not a "Lance" driver.

CC: Peter Maydell <pmaydell@chiark.greenend.org.uk>
CC: Roman Hodek <Roman.Hodek@informatik.uni-erlangen.de>
CC: "Maciej W. Rozycki" <macro@linux-mips.org>
CC: Donald Becker <becker@scyld.com>
CC: Sam Creasey <sammy@users.qual.net>
CC: Miguel de Icaza <miguel@nuclecu.unam.mx>
CC: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
CC: Don Fry <pcnet32@frontier.com>
CC: Geert Uytterhoeven <geert@linux-m68k.org>
CC: Russell King <linux@arm.linux.org.uk>
CC: David Davies <davies@maniac.ultranet.com>
CC: "M.Hipp" <hippm@informatik.uni-tuebingen.de>
CC: Pete Popov <ppopov@embeddedalley.com>
CC: David Hinds <dahinds@users.sourceforge.net>
CC: "Roger C. Pao" <rpao@paonet.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                      |    4 +-
 drivers/net/Kconfig                              |  153 -----------------
 drivers/net/Makefile                             |   14 --
 drivers/net/arm/Kconfig                          |    7 -
 drivers/net/arm/Makefile                         |    1 -
 drivers/net/ethernet/Kconfig                     |    1 +
 drivers/net/ethernet/Makefile                    |    1 +
 drivers/net/{ => ethernet/amd}/7990.c            |    0
 drivers/net/{ => ethernet/amd}/7990.h            |    0
 drivers/net/ethernet/amd/Kconfig                 |  192 ++++++++++++++++++++++
 drivers/net/ethernet/amd/Makefile                |   20 +++
 drivers/net/{ => ethernet/amd}/a2065.c           |    0
 drivers/net/{ => ethernet/amd}/a2065.h           |    0
 drivers/net/{arm => ethernet/amd}/am79c961a.c    |    0
 drivers/net/{arm => ethernet/amd}/am79c961a.h    |    0
 drivers/net/{ => ethernet/amd}/amd8111e.c        |    0
 drivers/net/{ => ethernet/amd}/amd8111e.h        |    0
 drivers/net/{ => ethernet/amd}/ariadne.c         |    0
 drivers/net/{ => ethernet/amd}/ariadne.h         |    0
 drivers/net/{ => ethernet/amd}/atarilance.c      |    0
 drivers/net/{ => ethernet/amd}/au1000_eth.c      |    0
 drivers/net/{ => ethernet/amd}/au1000_eth.h      |    0
 drivers/net/{ => ethernet/amd}/declance.c        |    0
 drivers/net/{ => ethernet/amd}/depca.c           |    0
 drivers/net/{ => ethernet/amd}/depca.h           |    0
 drivers/net/{ => ethernet/amd}/hplance.c         |    0
 drivers/net/{ => ethernet/amd}/hplance.h         |    0
 drivers/net/{ => ethernet/amd}/lance.c           |    0
 drivers/net/{ => ethernet/amd}/mvme147.c         |    0
 drivers/net/{ => ethernet/amd}/ni65.c            |    0
 drivers/net/{ => ethernet/amd}/ni65.h            |    0
 drivers/net/{pcmcia => ethernet/amd}/nmclan_cs.c |    0
 drivers/net/{ => ethernet/amd}/pcnet32.c         |    0
 drivers/net/{ => ethernet/amd}/sun3lance.c       |    0
 drivers/net/{ => ethernet/amd}/sunlance.c        |    0
 drivers/net/pcmcia/Kconfig                       |    9 -
 drivers/net/pcmcia/Makefile                      |    1 -
 37 files changed, 216 insertions(+), 187 deletions(-)
 rename drivers/net/{ => ethernet/amd}/7990.c (100%)
 rename drivers/net/{ => ethernet/amd}/7990.h (100%)
 create mode 100644 drivers/net/ethernet/amd/Kconfig
 create mode 100644 drivers/net/ethernet/amd/Makefile
 rename drivers/net/{ => ethernet/amd}/a2065.c (100%)
 rename drivers/net/{ => ethernet/amd}/a2065.h (100%)
 rename drivers/net/{arm => ethernet/amd}/am79c961a.c (100%)
 rename drivers/net/{arm => ethernet/amd}/am79c961a.h (100%)
 rename drivers/net/{ => ethernet/amd}/amd8111e.c (100%)
 rename drivers/net/{ => ethernet/amd}/amd8111e.h (100%)
 rename drivers/net/{ => ethernet/amd}/ariadne.c (100%)
 rename drivers/net/{ => ethernet/amd}/ariadne.h (100%)
 rename drivers/net/{ => ethernet/amd}/atarilance.c (100%)
 rename drivers/net/{ => ethernet/amd}/au1000_eth.c (100%)
 rename drivers/net/{ => ethernet/amd}/au1000_eth.h (100%)
 rename drivers/net/{ => ethernet/amd}/declance.c (100%)
 rename drivers/net/{ => ethernet/amd}/depca.c (100%)
 rename drivers/net/{ => ethernet/amd}/depca.h (100%)
 rename drivers/net/{ => ethernet/amd}/hplance.c (100%)
 rename drivers/net/{ => ethernet/amd}/hplance.h (100%)
 rename drivers/net/{ => ethernet/amd}/lance.c (100%)
 rename drivers/net/{ => ethernet/amd}/mvme147.c (100%)
 rename drivers/net/{ => ethernet/amd}/ni65.c (100%)
 rename drivers/net/{ => ethernet/amd}/ni65.h (100%)
 rename drivers/net/{pcmcia => ethernet/amd}/nmclan_cs.c (100%)
 rename drivers/net/{ => ethernet/amd}/pcnet32.c (100%)
 rename drivers/net/{ => ethernet/amd}/sun3lance.c (100%)
 rename drivers/net/{ => ethernet/amd}/sunlance.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 112e226..6f9dc94 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -746,7 +746,7 @@ L:	linux-arm-kernel@lists.infradead.org (moderated for non-subscribers)
 W:	http://www.arm.linux.org.uk/
 S:	Maintained
 F:	arch/arm/mach-ebsa110/
-F:	drivers/net/arm/am79c961a.*
+F:	drivers/net/ethernet/amd/am79c961a.*
 
 ARM/EZX SMARTPHONES (A780, A910, A1200, E680, ROKR E2 and ROKR E6)
 M:	Daniel Ribeiro <drwyrm@gmail.com>
@@ -4941,7 +4941,7 @@ PCNET32 NETWORK DRIVER
 M:	Don Fry <pcnet32@frontier.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/pcnet32.c
+F:	drivers/net/ethernet/amd/pcnet32.c
 
 PCRYPT PARALLEL CRYPTO ENGINE
 M:	Steffen Klassert <steffen.klassert@secunet.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0b3ea21..b686dab 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -287,27 +287,6 @@ config BMAC
 	  To compile this driver as a module, choose M here: the module
 	  will be called bmac.
 
-config ARIADNE
-	tristate "Ariadne support"
-	depends on ZORRO
-	help
-	  If you have a Village Tronic Ariadne Ethernet adapter, say Y.
-	  Otherwise, say N.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called ariadne.
-
-config A2065
-	tristate "A2065 support"
-	depends on ZORRO
-	select CRC32
-	help
-	  If you have a Commodore A2065 Ethernet adapter, say Y. Otherwise,
-	  say N.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called a2065.
-
 config HYDRA
 	tristate "Hydra support"
 	depends on ZORRO
@@ -387,16 +366,6 @@ config MACMACE
 	  say Y and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-config MVME147_NET
-	tristate "MVME147 (Lance) Ethernet support"
-	depends on MVME147
-	select CRC32
-	help
-	  Support for the on-board Ethernet interface on the Motorola MVME147
-	  single-board computer.  Say Y here to include the
-	  driver for this chip in your kernel.
-	  To compile this driver as a module, choose M here.
-
 config MVME16x_NET
 	tristate "MVME16x Ethernet support"
 	depends on MVME16x
@@ -415,27 +384,6 @@ config BVME6000_NET
 	  in your kernel.
 	  To compile this driver as a module, choose M here.
 
-config ATARILANCE
-	tristate "Atari Lance support"
-	depends on ATARI
-	help
-	  Say Y to include support for several Atari Ethernet adapters based
-	  on the AMD Lance chipset: RieblCard (with or without battery), or
-	  PAMCard VME (also the version by Rhotron, with different addresses).
-
-config SUN3LANCE
-	tristate "Sun3/Sun3x on-board LANCE support"
-	depends on SUN3 || SUN3X
-	help
-	  Most Sun3 and Sun3x motherboards (including the 3/50, 3/60 and 3/80)
-	  featured an AMD Lance 10Mbit Ethernet controller on board; say Y
-	  here to compile in the Linux driver for this and enable Ethernet.
-	  General Linux information on the Sun 3 and 3x series (now
-	  discontinued) is at
-	  <http://www.angelfire.com/ca2/tech68k/sun3.html>.
-
-	  If you're not building a kernel for a Sun 3, say N.
-
 config SUN3_82586
 	bool "Sun3 on-board Intel 82586 support"
 	depends on SUN3
@@ -445,14 +393,6 @@ config SUN3_82586
 	  that this driver does not support 82586-based adapters on additional
 	  VME boards.
 
-config HPLANCE
-	bool "HP on-board LANCE support"
-	depends on DIO
-	select CRC32
-	help
-	  If you want to use the builtin "LANCE" Ethernet controller on an
-	  HP300 machine, say Y here.
-
 config LASI_82596
 	tristate "Lasi ethernet"
 	depends on GSC
@@ -487,15 +427,6 @@ config XTENSA_XT2000_SONIC
 	help
 	  This is the driver for the onboard card of the Xtensa XT2000 board.
 
-config MIPS_AU1X00_ENET
-	tristate "MIPS AU1000 Ethernet support"
-	depends on MIPS_ALCHEMY
-	select PHYLIB
-	select CRC32
-	help
-	  If you have an Alchemy Semi AU1X00 based system
-	  say Y.  Otherwise, say N.
-
 config SGI_IOC3_ETH
 	bool "SGI IOC3 Ethernet"
 	depends on PCI && SGI_IP27
@@ -545,19 +476,6 @@ config SH_ETH
 	  This driver supporting CPUs are:
 		- SH7710, SH7712, SH7763, SH7619, SH7724, and SH7757.
 
-config SUNLANCE
-	tristate "Sun LANCE support"
-	depends on SBUS
-	select CRC32
-	help
-	  This driver supports the "le" interface present on all 32-bit Sparc
-	  systems, on some older Ultra systems and as an Sbus option.  These
-	  cards are based on the AMD Lance chipset, which is better known
-	  via the NE2100 cards.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called sunlance.
-
 config HAPPYMEAL
 	tristate "Sun Happy Meal 10/100baseT support"
 	depends on SBUS || PCI
@@ -673,18 +591,6 @@ config ELMC_II
 	  To compile this driver as a module, choose M here. The module
 	  will be called 3c527.
 
-config LANCE
-	tristate "AMD LANCE and PCnet (AT1500 and NE2100) support"
-	depends on ISA && ISA_DMA_API
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>. Some LinkSys cards are
-	  of this type.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called lance.  This is recommended.
-
 config NET_VENDOR_SMC
 	bool "Western Digital/SMC cards"
 	depends on ISA || MCA || EISA || MAC
@@ -1020,17 +926,6 @@ config NI52
 	  To compile this driver as a module, choose M here. The module
 	  will be called ni52.
 
-config NI65
-	tristate "NI6510 support"
-	depends on NET_VENDOR_RACAL && ISA && ISA_DMA_API
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ni65.
-
 config DNET
 	tristate "Dave ethernet support (DNET)"
 	depends on NET_ETHERNET && HAS_IOMEM
@@ -1056,19 +951,6 @@ config AT1700
 	  To compile this driver as a module, choose M here. The module
 	  will be called at1700.
 
-config DEPCA
-	tristate "DEPCA, DE10x, DE200, DE201, DE202, DE422 support"
-	depends on ISA || EISA || MCA
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto> as well as
-	  <file:drivers/net/depca.c>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called depca.
-
 config HP100
 	tristate "HP 10/100VG PCLAN (ISA, EISA, PCI) support"
 	depends on ISA || EISA || PCI
@@ -1287,32 +1169,6 @@ config NET_PCI
 	  will be asked for your specific card in the following questions. If
 	  you are unsure, say Y.
 
-config PCNET32
-	tristate "AMD PCnet32 PCI support"
-	depends on NET_PCI && PCI
-	select CRC32
-	select MII
-	help
-	  If you have a PCnet32 or PCnetPCI based network (Ethernet) card,
-	  answer Y here and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called pcnet32.
-
-config AMD8111_ETH
-	tristate "AMD 8111 (new PCI lance) support"
-	depends on NET_PCI && PCI
-	select CRC32
-	select MII
-	help
-	  If you have an AMD 8111-based PCI lance ethernet card,
-	  answer Y here and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called amd8111e.
-
 config ADAPTEC_STARFIRE
 	tristate "Adaptec Starfire/DuraLAN support"
 	depends on NET_PCI && PCI
@@ -1834,15 +1690,6 @@ config SGISEEQ
 	  Say Y here if you have an Seeq based Ethernet network card. This is
 	  used in many Silicon Graphics machines.
 
-config DECLANCE
-	tristate "DEC LANCE ethernet controller support"
-	depends on MACH_DECSTATION
-	select CRC32
-	help
-	  This driver is for the series of Ethernet controllers produced by
-	  DEC (now Compaq) based on the AMD Lance chipset, including the
-	  DEPCA series.  (This chipset is better known via the NE2100 cards.)
-
 config FEC
 	bool "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
 	depends on M523x || M527x || M5272 || M528x || M520x || M532x || \
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index d4d6744..59b6cc9 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -56,7 +56,6 @@ obj-$(CONFIG_PLIP) += plip.o
 obj-$(CONFIG_ROADRUNNER) += rrunner.o
 
 obj-$(CONFIG_HAPPYMEAL) += sunhme.o
-obj-$(CONFIG_SUNLANCE) += sunlance.o
 obj-$(CONFIG_SUNQE) += sunqe.o
 obj-$(CONFIG_SUNBMAC) += sunbmac.o
 obj-$(CONFIG_SUNGEM) += sungem.o sungem_phy.o
@@ -67,7 +66,6 @@ obj-$(CONFIG_MACE) += mace.o
 obj-$(CONFIG_BMAC) += bmac.o
 
 obj-$(CONFIG_NE2K_PCI) += ne2k-pci.o 8390.o
-obj-$(CONFIG_PCNET32) += pcnet32.o
 obj-$(CONFIG_E100) += e100.o
 obj-$(CONFIG_TLAN) += tlan.o
 obj-$(CONFIG_EPIC100) += epic100.o
@@ -177,9 +175,7 @@ obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
 obj-$(CONFIG_DE600) += de600.o
 obj-$(CONFIG_DE620) += de620.o
-obj-$(CONFIG_LANCE) += lance.o
 obj-$(CONFIG_SUN3_82586) += sun3_82586.o
-obj-$(CONFIG_SUN3LANCE) += sun3lance.o
 obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_SGISEEQ) += sgiseeq.o
 obj-$(CONFIG_SGI_O2MACE_ETH) += meth.o
@@ -194,12 +190,10 @@ obj-$(CONFIG_8139CP) += 8139cp.o
 obj-$(CONFIG_8139TOO) += 8139too.o
 obj-$(CONFIG_ZNET) += znet.o
 obj-$(CONFIG_CPMAC) += cpmac.o
-obj-$(CONFIG_DEPCA) += depca.o
 obj-$(CONFIG_EWRK3) += ewrk3.o
 obj-$(CONFIG_ATP) += atp.o
 obj-$(CONFIG_NI5010) += ni5010.o
 obj-$(CONFIG_NI52) += ni52.o
-obj-$(CONFIG_NI65) += ni65.o
 obj-$(CONFIG_ELPLUS) += 3c505.o
 obj-$(CONFIG_AC3200) += ac3200.o 8390.o
 obj-$(CONFIG_APRICOT) += 82596.o
@@ -214,19 +208,12 @@ obj-$(CONFIG_LP486E) += lp486e.o
 
 obj-$(CONFIG_ETH16I) += eth16i.o
 obj-$(CONFIG_ZORRO8390) += zorro8390.o
-obj-$(CONFIG_HPLANCE) += hplance.o 7990.o
-obj-$(CONFIG_MVME147_NET) += mvme147.o 7990.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_KORINA) += korina.o
 obj-$(CONFIG_MIPS_JAZZ_SONIC) += jazzsonic.o
-obj-$(CONFIG_MIPS_AU1X00_ENET) += au1000_eth.o
 obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
 obj-$(CONFIG_SGI_IOC3_ETH) += ioc3-eth.o
-obj-$(CONFIG_DECLANCE) += declance.o
-obj-$(CONFIG_ATARILANCE) += atarilance.o
-obj-$(CONFIG_A2065) += a2065.o
 obj-$(CONFIG_HYDRA) += hydra.o
-obj-$(CONFIG_ARIADNE) += ariadne.o
 obj-$(CONFIG_CS89x0) += cs89x0.o
 obj-$(CONFIG_MACSONIC) += macsonic.o
 obj-$(CONFIG_MACMACE) += macmace.o
@@ -236,7 +223,6 @@ obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
 obj-$(CONFIG_DL2K) += dl2k.o
 obj-$(CONFIG_R8169) += r8169.o
-obj-$(CONFIG_AMD8111_ETH) += amd8111e.o
 obj-$(CONFIG_IBMVETH) += ibmveth.o
 obj-$(CONFIG_S2IO) += s2io.o
 obj-$(CONFIG_VXGE) += vxge/
diff --git a/drivers/net/arm/Kconfig b/drivers/net/arm/Kconfig
index 39e1c0d..d0c8cf2 100644
--- a/drivers/net/arm/Kconfig
+++ b/drivers/net/arm/Kconfig
@@ -2,13 +2,6 @@
 # Acorn Network device configuration
 #  These are for Acorn's Expansion card network interfaces
 #
-config ARM_AM79C961A
-	bool "ARM EBSA110 AM79C961A support"
-	depends on ARM && ARCH_EBSA110
-	select CRC32
-	help
-	  If you wish to compile a kernel for the EBSA-110, then you should
-	  always answer Y to this.
 
 config ARM_ETHER1
 	tristate "Acorn Ether1 support"
diff --git a/drivers/net/arm/Makefile b/drivers/net/arm/Makefile
index 303171f..63c57be 100644
--- a/drivers/net/arm/Makefile
+++ b/drivers/net/arm/Makefile
@@ -3,7 +3,6 @@
 # Makefile for the ARM network device drivers
 #
 
-obj-$(CONFIG_ARM_AM79C961A)	+= am79c961a.o
 obj-$(CONFIG_ARM_ETHERH)	+= etherh.o
 obj-$(CONFIG_ARM_ETHER3)	+= ether3.o
 obj-$(CONFIG_ARM_ETHER1)	+= ether1.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 18193ec..5e62efd 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -12,5 +12,6 @@ menuconfig ETHERNET
 if ETHERNET
 
 source "drivers/net/ethernet/3com/Kconfig"
+source "drivers/net/ethernet/amd/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 07766ba..1bc2ac2 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -3,3 +3,4 @@
 #
 
 obj-$(CONFIG_NET_VENDOR_3COM) += 3com/
+obj-$(CONFIG_NET_VENDOR_AMD) += amd/
diff --git a/drivers/net/7990.c b/drivers/net/ethernet/amd/7990.c
similarity index 100%
rename from drivers/net/7990.c
rename to drivers/net/ethernet/amd/7990.c
diff --git a/drivers/net/7990.h b/drivers/net/ethernet/amd/7990.h
similarity index 100%
rename from drivers/net/7990.h
rename to drivers/net/ethernet/amd/7990.h
diff --git a/drivers/net/ethernet/amd/Kconfig b/drivers/net/ethernet/amd/Kconfig
new file mode 100644
index 0000000..0513940
--- /dev/null
+++ b/drivers/net/ethernet/amd/Kconfig
@@ -0,0 +1,192 @@
+#
+# AMD network device configuration
+#
+
+config NET_VENDOR_AMD
+	bool "AMD devices"
+	depends on DIO || MACH_DECSTATION || MVME147 || ATARI || SUN3 || \
+		   SUN3X || SBUS || PCI || ZORRO || (ISA && ISA_DMA_API) || \
+		   (ARM && ARCH_EBSA110) || ISA || EISA || MCA || PCMCIA
+	---help---
+	  If you have a network (Ethernet) chipset belonging to this class,
+	  say Y.
+
+	  Note that the answer to this question does not directly affect
+	  the kernel: saying N will just case the configurator to skip all
+	  the questions regarding AMD chipsets. If you say Y, you will be asked
+	  for your specific chipset/driver in the following questions.
+
+if NET_VENDOR_AMD
+
+config A2065
+	tristate "A2065 support"
+	depends on ZORRO
+	select CRC32
+	---help---
+	  If you have a Commodore A2065 Ethernet adapter, say Y. Otherwise,
+	  say N.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called a2065.
+
+config AMD8111_ETH
+	tristate "AMD 8111 (new PCI LANCE) support"
+	depends on PCI
+	select CRC32
+	select MII
+	---help---
+	  If you have an AMD 8111-based PCI LANCE ethernet card,
+	  answer Y here and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called amd8111e.
+
+config LANCE
+	tristate "AMD LANCE and PCnet (AT1500 and NE2100) support"
+	depends on ISA && ISA_DMA_API
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>. Some LinkSys cards are
+	  of this type.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called lance.  This is recommended.
+
+config PCNET32
+	tristate "AMD PCnet32 PCI support"
+	depends on PCI
+	select CRC32
+	select MII
+	---help---
+	  If you have a PCnet32 or PCnetPCI based network (Ethernet) card,
+	  answer Y here and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called pcnet32.
+
+config ARIADNE
+	tristate "Ariadne support"
+	depends on ZORRO
+	---help---
+	  If you have a Village Tronic Ariadne Ethernet adapter, say Y.
+	  Otherwise, say N.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called ariadne.
+
+config ARM_AM79C961A
+	bool "ARM EBSA110 AM79C961A support"
+	depends on ARM && ARCH_EBSA110
+	select CRC32
+	---help---
+	  If you wish to compile a kernel for the EBSA-110, then you should
+	  always answer Y to this.
+
+config ATARILANCE
+	tristate "Atari LANCE support"
+	depends on ATARI
+	---help---
+	  Say Y to include support for several Atari Ethernet adapters based
+	  on the AMD LANCE chipset: RieblCard (with or without battery), or
+	  PAMCard VME (also the version by Rhotron, with different addresses).
+
+config DECLANCE
+	tristate "DEC LANCE ethernet controller support"
+	depends on MACH_DECSTATION
+	select CRC32
+	---help---
+	  This driver is for the series of Ethernet controllers produced by
+	  DEC (now Compaq) based on the AMD LANCE chipset, including the
+	  DEPCA series.  (This chipset is better known via the NE2100 cards.)
+
+config DEPCA
+	tristate "DEPCA, DE10x, DE200, DE201, DE202, DE422 support"
+	depends on (ISA || EISA || MCA)
+	select CRC32
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto> as well as
+	  <file:drivers/net/depca.c>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called depca.
+
+config HPLANCE
+	bool "HP on-board LANCE support"
+	depends on DIO
+	select CRC32
+	---help---
+	  If you want to use the builtin "LANCE" Ethernet controller on an
+	  HP300 machine, say Y here.
+
+config MIPS_AU1X00_ENET
+	tristate "MIPS AU1000 Ethernet support"
+	depends on MIPS_ALCHEMY
+	select PHYLIB
+	select CRC32
+	---help---
+	  If you have an Alchemy Semi AU1X00 based system
+	  say Y.  Otherwise, say N.
+
+config MVME147_NET
+	tristate "MVME147 (LANCE) Ethernet support"
+	depends on MVME147
+	select CRC32
+	---help---
+	  Support for the on-board Ethernet interface on the Motorola MVME147
+	  single-board computer.  Say Y here to include the
+	  driver for this chip in your kernel.
+	  To compile this driver as a module, choose M here.
+
+config PCMCIA_NMCLAN
+	tristate "New Media PCMCIA support"
+	depends on PCMCIA
+	help
+	  Say Y here if you intend to attach a New Media Ethernet or LiveWire
+	  PCMCIA (PC-card) Ethernet card to your computer.
+
+	  To compile this driver as a module, choose M here: the module will be
+	  called nmclan_cs.  If unsure, say N.
+
+config NI65
+	tristate "NI6510 support"
+	depends on ISA && ISA_DMA_API
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ni65.
+
+config SUN3LANCE
+	tristate "Sun3/Sun3x on-board LANCE support"
+	depends on (SUN3 || SUN3X)
+	---help---
+	  Most Sun3 and Sun3x motherboards (including the 3/50, 3/60 and 3/80)
+	  featured an AMD LANCE 10Mbit Ethernet controller on board; say Y
+	  here to compile in the Linux driver for this and enable Ethernet.
+	  General Linux information on the Sun 3 and 3x series (now
+	  discontinued) is at
+	  <http://www.angelfire.com/ca2/tech68k/sun3.html>.
+
+	  If you're not building a kernel for a Sun 3, say N.
+
+config SUNLANCE
+	tristate "Sun LANCE support"
+	depends on SBUS
+	select CRC32
+	---help---
+	  This driver supports the "le" interface present on all 32-bit Sparc
+	  systems, on some older Ultra systems and as an Sbus option.  These
+	  cards are based on the AMD LANCE chipset, which is better known
+	  via the NE2100 cards.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called sunlance.
+
+endif # NET_VENDOR_AMD
diff --git a/drivers/net/ethernet/amd/Makefile b/drivers/net/ethernet/amd/Makefile
new file mode 100644
index 0000000..175caa5
--- /dev/null
+++ b/drivers/net/ethernet/amd/Makefile
@@ -0,0 +1,20 @@
+#
+# Makefile for the AMD network device drivers.
+#
+
+obj-$(CONFIG_A2065) += a2065.o
+obj-$(CONFIG_AMD8111_ETH) += amd8111e.o
+obj-$(CONFIG_ARM_AM79C961A) += am79c961a.o
+obj-$(CONFIG_ARIADNE) += ariadne.o
+obj-$(CONFIG_ATARILANCE) += atarilance.o
+obj-$(CONFIG_DECLANCE) += declance.o
+obj-$(CONFIG_DEPCA) += depca.o
+obj-$(CONFIG_HPLANCE) += hplance.o 7990.o
+obj-$(CONFIG_LANCE) += lance.o
+obj-$(CONFIG_MIPS_AU1X00_ENET) += au1000_eth.o
+obj-$(CONFIG_MVME147_NET) += mvme147.o 7990.o
+obj-$(CONFIG_PCMCIA_NMCLAN) += nmclan_cs.o
+obj-$(CONFIG_NI65) += ni65.o
+obj-$(CONFIG_PCNET32) += pcnet32.o
+obj-$(CONFIG_SUN3LANCE) += sun3lance.o
+obj-$(CONFIG_SUNLANCE) += sunlance.o
diff --git a/drivers/net/a2065.c b/drivers/net/ethernet/amd/a2065.c
similarity index 100%
rename from drivers/net/a2065.c
rename to drivers/net/ethernet/amd/a2065.c
diff --git a/drivers/net/a2065.h b/drivers/net/ethernet/amd/a2065.h
similarity index 100%
rename from drivers/net/a2065.h
rename to drivers/net/ethernet/amd/a2065.h
diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/ethernet/amd/am79c961a.c
similarity index 100%
rename from drivers/net/arm/am79c961a.c
rename to drivers/net/ethernet/amd/am79c961a.c
diff --git a/drivers/net/arm/am79c961a.h b/drivers/net/ethernet/amd/am79c961a.h
similarity index 100%
rename from drivers/net/arm/am79c961a.h
rename to drivers/net/ethernet/amd/am79c961a.h
diff --git a/drivers/net/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
similarity index 100%
rename from drivers/net/amd8111e.c
rename to drivers/net/ethernet/amd/amd8111e.c
diff --git a/drivers/net/amd8111e.h b/drivers/net/ethernet/amd/amd8111e.h
similarity index 100%
rename from drivers/net/amd8111e.h
rename to drivers/net/ethernet/amd/amd8111e.h
diff --git a/drivers/net/ariadne.c b/drivers/net/ethernet/amd/ariadne.c
similarity index 100%
rename from drivers/net/ariadne.c
rename to drivers/net/ethernet/amd/ariadne.c
diff --git a/drivers/net/ariadne.h b/drivers/net/ethernet/amd/ariadne.h
similarity index 100%
rename from drivers/net/ariadne.h
rename to drivers/net/ethernet/amd/ariadne.h
diff --git a/drivers/net/atarilance.c b/drivers/net/ethernet/amd/atarilance.c
similarity index 100%
rename from drivers/net/atarilance.c
rename to drivers/net/ethernet/amd/atarilance.c
diff --git a/drivers/net/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
similarity index 100%
rename from drivers/net/au1000_eth.c
rename to drivers/net/ethernet/amd/au1000_eth.c
diff --git a/drivers/net/au1000_eth.h b/drivers/net/ethernet/amd/au1000_eth.h
similarity index 100%
rename from drivers/net/au1000_eth.h
rename to drivers/net/ethernet/amd/au1000_eth.h
diff --git a/drivers/net/declance.c b/drivers/net/ethernet/amd/declance.c
similarity index 100%
rename from drivers/net/declance.c
rename to drivers/net/ethernet/amd/declance.c
diff --git a/drivers/net/depca.c b/drivers/net/ethernet/amd/depca.c
similarity index 100%
rename from drivers/net/depca.c
rename to drivers/net/ethernet/amd/depca.c
diff --git a/drivers/net/depca.h b/drivers/net/ethernet/amd/depca.h
similarity index 100%
rename from drivers/net/depca.h
rename to drivers/net/ethernet/amd/depca.h
diff --git a/drivers/net/hplance.c b/drivers/net/ethernet/amd/hplance.c
similarity index 100%
rename from drivers/net/hplance.c
rename to drivers/net/ethernet/amd/hplance.c
diff --git a/drivers/net/hplance.h b/drivers/net/ethernet/amd/hplance.h
similarity index 100%
rename from drivers/net/hplance.h
rename to drivers/net/ethernet/amd/hplance.h
diff --git a/drivers/net/lance.c b/drivers/net/ethernet/amd/lance.c
similarity index 100%
rename from drivers/net/lance.c
rename to drivers/net/ethernet/amd/lance.c
diff --git a/drivers/net/mvme147.c b/drivers/net/ethernet/amd/mvme147.c
similarity index 100%
rename from drivers/net/mvme147.c
rename to drivers/net/ethernet/amd/mvme147.c
diff --git a/drivers/net/ni65.c b/drivers/net/ethernet/amd/ni65.c
similarity index 100%
rename from drivers/net/ni65.c
rename to drivers/net/ethernet/amd/ni65.c
diff --git a/drivers/net/ni65.h b/drivers/net/ethernet/amd/ni65.h
similarity index 100%
rename from drivers/net/ni65.h
rename to drivers/net/ethernet/amd/ni65.h
diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/ethernet/amd/nmclan_cs.c
similarity index 100%
rename from drivers/net/pcmcia/nmclan_cs.c
rename to drivers/net/ethernet/amd/nmclan_cs.c
diff --git a/drivers/net/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
similarity index 100%
rename from drivers/net/pcnet32.c
rename to drivers/net/ethernet/amd/pcnet32.c
diff --git a/drivers/net/sun3lance.c b/drivers/net/ethernet/amd/sun3lance.c
similarity index 100%
rename from drivers/net/sun3lance.c
rename to drivers/net/ethernet/amd/sun3lance.c
diff --git a/drivers/net/sunlance.c b/drivers/net/ethernet/amd/sunlance.c
similarity index 100%
rename from drivers/net/sunlance.c
rename to drivers/net/ethernet/amd/sunlance.c
diff --git a/drivers/net/pcmcia/Kconfig b/drivers/net/pcmcia/Kconfig
index b67c5ed..e17ad95 100644
--- a/drivers/net/pcmcia/Kconfig
+++ b/drivers/net/pcmcia/Kconfig
@@ -41,15 +41,6 @@ config PCMCIA_PCNET
 	  To compile this driver as a module, choose M here: the module will be
 	  called pcnet_cs.  If unsure, say N.
 
-config PCMCIA_NMCLAN
-	tristate "New Media PCMCIA support"
-	help
-	  Say Y here if you intend to attach a New Media Ethernet or LiveWire
-	  PCMCIA (PC-card) Ethernet card to your computer.
-
-	  To compile this driver as a module, choose M here: the module will be
-	  called nmclan_cs.  If unsure, say N.
-
 config PCMCIA_SMC91C92
 	tristate "SMC 91Cxx PCMCIA support"
 	select CRC32
diff --git a/drivers/net/pcmcia/Makefile b/drivers/net/pcmcia/Makefile
index 2f2ab3b..985f0ae 100644
--- a/drivers/net/pcmcia/Makefile
+++ b/drivers/net/pcmcia/Makefile
@@ -4,7 +4,6 @@
 
 # 16-bit client drivers
 obj-$(CONFIG_PCMCIA_FMVJ18X)	+= fmvj18x_cs.o
-obj-$(CONFIG_PCMCIA_NMCLAN)	+= nmclan_cs.o
 obj-$(CONFIG_PCMCIA_PCNET)	+= pcnet_cs.o
 obj-$(CONFIG_PCMCIA_SMC91C92)	+= smc91c92_cs.o
 obj-$(CONFIG_PCMCIA_XIRC2PS)	+= xirc2ps_cs.o
-- 
1.7.6

