From: akpm@osdl.org
Subject: [patch 05/13] M68k Ethernet drivers depend on NET_ETHERNET
Date: Sun, 21 Nov 2004 22:43:52 -0800
Message-ID: <200411220644.iAM6i4900638@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, geert@linux-m68k.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Geert Uytterhoeven <geert@linux-m68k.org>

M68k Ethernet drivers depend on NET_ETHERNET instead of NETDEVICES

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/Kconfig |   30 +++++++++++++++---------------
 1 files changed, 15 insertions(+), 15 deletions(-)

diff -puN drivers/net/Kconfig~m68k-ethernet-drivers-depend-on-net_ethernet drivers/net/Kconfig
--- 25/drivers/net/Kconfig~m68k-ethernet-drivers-depend-on-net_ethernet	2004-11-21 22:42:52.923636624 -0800
+++ 25-akpm/drivers/net/Kconfig	2004-11-21 22:43:02.797135624 -0800
@@ -288,7 +288,7 @@ config ZORRO8390
 
 config APNE
 	tristate "PCMCIA NE2000 support"
-	depends on NETDEVICES && AMIGA_PCMCIA
+	depends on NET_ETHERNET && AMIGA_PCMCIA
 	select CRC32
 	help
 	  If you have a PCMCIA NE2000 compatible adapter, say Y.  Otherwise,
@@ -299,7 +299,7 @@ config APNE
 
 config APOLLO_ELPLUS
 	tristate "Apollo 3c505 support"
-	depends on NETDEVICES && APOLLO
+	depends on NET_ETHERNET && APOLLO
 	help
 	  Say Y or M here if your Apollo has a 3Com 3c505 ISA Ethernet card.
 	  If you don't have one made for Apollos, you can use one from a PC,
@@ -308,7 +308,7 @@ config APOLLO_ELPLUS
 
 config MAC8390
 	bool "Macintosh NS 8390 based ethernet cards"
-	depends on NETDEVICES && MAC
+	depends on NET_ETHERNET && MAC
 	select CRC32
 	help
 	  If you want to include a driver to support Nubus or LC-PDS
@@ -318,7 +318,7 @@ config MAC8390
 
 config MAC89x0
 	tristate "Macintosh CS89x0 based ethernet cards"
-	depends on NETDEVICES && MAC && BROKEN
+	depends on NET_ETHERNET && MAC && BROKEN
 	---help---
 	  Support for CS89x0 chipset based Ethernet cards.  If you have a
 	  Nubus or LC-PDS network (Ethernet) card of this type, say Y and
@@ -331,7 +331,7 @@ config MAC89x0
 
 config MACSONIC
 	tristate "Macintosh SONIC based ethernet (onboard, NuBus, LC, CS)"
-	depends on NETDEVICES && MAC
+	depends on NET_ETHERNET && MAC
 	---help---
 	  Support for NatSemi SONIC based Ethernet devices.  This includes
 	  the onboard Ethernet in many Quadras as well as some LC-PDS,
@@ -345,7 +345,7 @@ config MACSONIC
 
 config MACMACE
 	bool "Macintosh (AV) onboard MACE ethernet (EXPERIMENTAL)"
-	depends on NETDEVICES && MAC && EXPERIMENTAL
+	depends on NET_ETHERNET && MAC && EXPERIMENTAL
 	select CRC32
 	help
 	  Support for the onboard AMD 79C940 MACE Ethernet controller used in
@@ -355,7 +355,7 @@ config MACMACE
 
 config MVME147_NET
 	tristate "MVME147 (Lance) Ethernet support"
-	depends on NETDEVICES && MVME147
+	depends on NET_ETHERNET && MVME147
 	select CRC32
 	help
 	  Support for the on-board Ethernet interface on the Motorola MVME147
@@ -365,7 +365,7 @@ config MVME147_NET
 
 config MVME16x_NET
 	tristate "MVME16x Ethernet support"
-	depends on NETDEVICES && MVME16x
+	depends on NET_ETHERNET && MVME16x
 	help
 	  This is the driver for the Ethernet interface on the Motorola
 	  MVME162, 166, 167, 172 and 177 boards.  Say Y here to include the
@@ -374,7 +374,7 @@ config MVME16x_NET
 
 config BVME6000_NET
 	tristate "BVME6000 Ethernet support"
-	depends on NETDEVICES && BVME6000
+	depends on NET_ETHERNET && BVME6000
 	help
 	  This is the driver for the Ethernet interface on BVME4000 and
 	  BVME6000 VME boards.  Say Y here to include the driver for this chip
@@ -383,7 +383,7 @@ config BVME6000_NET
 
 config ATARILANCE
 	tristate "Atari Lance support"
-	depends on NETDEVICES && ATARI
+	depends on NET_ETHERNET && ATARI
 	help
 	  Say Y to include support for several Atari Ethernet adapters based
 	  on the AMD Lance chipset: RieblCard (with or without battery), or
@@ -391,7 +391,7 @@ config ATARILANCE
 
 config ATARI_BIONET
 	tristate "BioNet-100 support"
-	depends on NETDEVICES && ATARI && ATARI_ACSI && BROKEN
+	depends on NET_ETHERNET && ATARI && ATARI_ACSI && BROKEN
 	help
 	  Say Y to include support for BioData's BioNet-100 Ethernet adapter
 	  for the ACSI port. The driver works (has to work...) with a polled
@@ -399,7 +399,7 @@ config ATARI_BIONET
 
 config ATARI_PAMSNET
 	tristate "PAMsNet support"
-	depends on NETDEVICES && ATARI && ATARI_ACSI && BROKEN
+	depends on NET_ETHERNET && ATARI && ATARI_ACSI && BROKEN
 	help
 	  Say Y to include support for the PAMsNet Ethernet adapter for the
 	  ACSI port ("ACSI node"). The driver works (has to work...) with a
@@ -407,7 +407,7 @@ config ATARI_PAMSNET
 
 config SUN3LANCE
 	tristate "Sun3/Sun3x on-board LANCE support"
-	depends on NETDEVICES && (SUN3 || SUN3X)
+	depends on NET_ETHERNET && (SUN3 || SUN3X)
 	help
 	  Most Sun3 and Sun3x motherboards (including the 3/50, 3/60 and 3/80)
 	  featured an AMD Lance 10Mbit Ethernet controller on board; say Y
@@ -420,7 +420,7 @@ config SUN3LANCE
 
 config SUN3_82586
 	tristate "Sun3 on-board Intel 82586 support"
-	depends on NETDEVICES && SUN3
+	depends on NET_ETHERNET && SUN3
 	help
 	  This driver enables support for the on-board Intel 82586 based
 	  Ethernet adapter found on Sun 3/1xx and 3/2xx motherboards.  Note
@@ -429,7 +429,7 @@ config SUN3_82586
 
 config HPLANCE
 	bool "HP on-board LANCE support"
-	depends on NETDEVICES && HP300
+	depends on NET_ETHERNET && HP300
 	select CRC32
 	help
 	  If you want to use the builtin "LANCE" Ethernet controller on an
_
