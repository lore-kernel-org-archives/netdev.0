From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] get rid of references to modules.txt
Date: Tue, 23 Sep 2003 12:06:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030923120631.1a921506.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

For 2.6.0-test5, cleanup of config help.

Unify all references to building a module, and get rid of references to modules.txt
diff -Nru a/drivers/net/Kconfig b/drivers/net/Kconfig

--- a/drivers/net/Kconfig	Tue Sep 23 12:05:46 2003
+++ b/drivers/net/Kconfig	Tue Sep 23 12:05:46 2003
@@ -53,9 +53,7 @@
 	  Administrator's Guide, available from
 	  <http://www.tldp.org/docs.html#guide>.
 
-	  If you want to compile this as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt>.  The module
+	  To compile this driver as a module, say M here: the module
 	  will be called dummy.  If you want to use more than one dummy
 	  device at a time, you need to compile this driver as a module.
 	  Instead of 'dummy', the devices will then be called 'dummy0',
@@ -78,9 +76,7 @@
 	  This is similar to the EQL driver, but it merges Ethernet segments
 	  instead of serial lines.
 
-	  If you want to compile this as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt>.  The module
+	  To compile this driver as a module, say M here: the module
 	  will be called bonding.
 
 config EQUALIZER
@@ -100,11 +96,8 @@
 	  section 6.2 of the NET-3-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called eql.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt>.  If
-	  unsure, say N.
+	  To compile this driver as a module, say M here: the module
+	  will be called eql.  If unsure, say N.
 
 config TUN
 	tristate "Universal TUN/TAP device driver support"
@@ -124,10 +117,8 @@
 	  Please read <file:Documentation/networking/tuntap.txt> for more
 	  information.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called tun.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt>.
+	  To compile this driver as a module, say M here: the module
+	  will be called tun.
 
 	  If you don't know what to use this for, you don't need it.
 
@@ -149,10 +140,8 @@
 	  Ethernet device. Please read the file
 	  <file:Documentation/networking/ethertap.txt> for more information.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called ethertap. If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt>.
+	  To compile this driver as a module, say M here: the module
+	  will be called ethertap.
 
 	  If you don't know what to use this for, you don't need it.
 
@@ -231,10 +220,8 @@
 	  motherboard will usually use a MACE (Medium Access Control for
 	  Ethernet) interface. Say Y to include support for the MACE chip.
 
-	  This driver is also available as a module called mace ( = code
-	  which can be inserted in and removed from the running kernel
-	  whenever you want). If you want to compile it as a module, say M
-	  here and read <file:Documentation/modules.txt>.
+	  To compile this driver as a module, say M here: the module
+	  will be called mace.
 
 config MACE_AAUI_PORT
 	bool "Use AAUI port instead of TP by default"
@@ -254,10 +241,8 @@
 	  Say Y for support of BMAC Ethernet interfaces. These are used on G3
 	  computers.
 
-	  This driver is also available as a module called bmac ( = code
-	  which can be inserted in and removed from the running kernel
-	  whenever you want). If you want to compile it as a module, say M
-	  here and read <file:Documentation/modules.txt>.
+	  To compile this driver as a module, say M here: the module
+	  will be called bmac.
 
 config OAKNET
 	tristate "National DP83902AV (Oak ethernet) support"
@@ -265,10 +250,8 @@
 	help
 	  Say Y if your machine has this type of Ethernet network card.
 
-	  This driver is also available as a module called oaknet ( = code
-	  which can be inserted in and removed from the running kernel
-	  whenever you want). If you want to compile it as a module, say M
-	  here and read <file:Documentation/modules.txt>.
+	  To compile this driver as a module, say M here: the module
+	  will be called oaknet.	
 
 config ARIADNE
 	tristate "Ariadne support"
@@ -277,10 +260,8 @@
 	  If you have a Village Tronic Ariadne Ethernet adapter, say Y.
 	  Otherwise, say N.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you
-	  want). The module is called ariadne. If you want to compile it as
-	  a module, say M here and read <file:Documentation/modules.txt>.
+	  To compile this driver as a module, say M here: the module
+	  will be called ariadne.
 
 config A2065
 	tristate "A2065 support"
@@ -289,10 +270,8 @@
 	  If you have a Commodore A2065 Ethernet adapter, say Y. Otherwise,
 	  say N.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you
-	  want). The module is called a2065. If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt>.
+	  To compile this driver as a module, say M here: the module
+	  will be called a2065.
 
 config HYDRA
 	tristate "Hydra support"
@@ -300,10 +279,8 @@
 	help
 	  If you have a Hydra Ethernet adapter, say Y. Otherwise, say N.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you
-	  want). The module is called hydra. If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt>.
+	  To compile this driver as a module, say M here: the module
+	  will be called hydra.
 
 config ZORRO8390
 	tristate "Zorro NS8390-based Ethernet support"
@@ -314,10 +291,8 @@
 	  Computers X-Surf Ethernet cards. If you have such a card, say Y.
 	  Otherwise, say N.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module is called zorro8390. If you want to compile it as
-	  a module, say M here and read <file:Documentation/modules.txt>.
+	  To compile this driver as a module, say M here: the module
+	  will be called zorro8390.
 
 config APNE
 	tristate "PCMCIA NE2000 support"
@@ -326,10 +301,8 @@
 	  If you have a PCMCIA NE2000 compatible adapter, say Y.  Otherwise,
 	  say N.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you
-	  want). The module is called apne. If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt>.
+	  To compile this driver as a module, say M here: the module
+	  will be called apne. 
 
 config APOLLO_ELPLUS
 	tristate "Apollo 3c505 support"
@@ -358,11 +331,8 @@
 	  read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  If you want to compile this as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt> as well as
-	  <file:Documentation/networking/net-modules.txt>.  This module will
-	  be called mac89x0.
+	  To compile this driver as a module, say M here: the module
+	  will be called mac89x0.
 
 config MACSONIC
 	tristate "Macintosh SONIC based ethernet (onboard, NuBus, LC, CS)"
@@ -374,11 +344,8 @@
 	  one of these say Y and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  If you want to compile this as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt> as well as
-	  <file:Documentation/networking/net-modules.txt>.  This module will
-	  be called macsonic.
+	  To compile this driver as a module, say M here: the module
+	  will be called macsonic.
 
 config MACMACE
 	bool "Macintosh (AV) onboard MACE ethernet (EXPERIMENTAL)"
@@ -394,27 +361,30 @@
 	depends on NETDEVICES && MVME147
 	help
 	  Support for the on-board Ethernet interface on the Motorola MVME147
-	  single-board computer.  Say Y here to include the
-	  driver for this chip in your kernel.   If you want to compile it as
-	  a module, say M here and read <file:Documentation/modules.txt>.
+	  single-board computer.
+
+  	  To compile this driver as a module, say M here: the module
+	  will be called mvme1747.
 
 config MVME16x_NET
 	tristate "MVME16x Ethernet support"
 	depends on NETDEVICES && MVME16x
 	help
 	  This is the driver for the Ethernet interface on the Motorola
-	  MVME162, 166, 167, 172 and 177 boards.  Say Y here to include the
-	  driver for this chip in your kernel.   If you want to compile it as
-	  a module, say M here and read <file:Documentation/modules.txt>.
+	  MVME162, 166, 167, 172 and 177 boards.  
+
+  	  To compile this driver as a module, say M here: the module
+	  will be called 82596.
 
 config BVME6000_NET
 	tristate "BVME6000 Ethernet support"
 	depends on NETDEVICES && BVME6000
 	help
 	  This is the driver for the Ethernet interface on BVME4000 and
-	  BVME6000 VME boards.  Say Y here to include the driver for this chip
-	  in your kernel.   If you want to compile it as a module, say M here
-	  and read <file:Documentation/modules.txt>.
+	  BVME6000 VME boards.
+
+  	  To compile this driver as a module, say M here: the module
+	  will be called 82596.
 
 config ATARILANCE
 	tristate "Atari Lance support"
@@ -532,10 +502,8 @@
 	  cards are based on the AMD Lance chipset, which is better known
 	  via the NE2100 cards.
 
-	  This support is also available as a module called sunlance ( =
-	  code which can be inserted in and removed from the running kernel
-	  whenever you want). If you want to compile it as a module, say M
-	  here and read <file:Documentation/modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called sunlance.
 
 config HAPPYMEAL
 	tristate "Sun Happy Meal 10/100baseT support"
@@ -546,10 +514,8 @@
 	  both PCI and Sbus devices. This driver also supports the "qfe" quad
 	  100baseT device available in both PCI and Sbus configurations.
 
-	  This support is also available as a module called sunhme ( = code
-	  which can be inserted in and removed from the running kernel
-	  whenever you want). If you want to compile it as a module, say M
-	  here and read <file:Documentation/modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called sunhme.
 
 config SUNBMAC
 	tristate "Sun BigMAC 10/100baseT support (EXPERIMENTAL)"
@@ -558,10 +524,8 @@
 	  This driver supports the "be" interface available as an Sbus option.
 	  This is Sun's older 100baseT Ethernet device.
 
-	  This support is also available as a module called sunbmac ( = code
-	  which can be inserted in and removed from the running kernel
-	  whenever you want). If you want to compile it as a module, say M
-	  here and read <file:Documentation/modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called sunbmac.
 
 config SUNQE
 	tristate "Sun QuadEthernet support"
@@ -571,10 +535,8 @@
 	  an Sbus option. Note that this is not the same as Quad FastEthernet
 	  "qfe" which is supported by the Happy Meal driver instead.
 
-	  This support is also available as a module called sunqe ( = code
-	  which can be inserted in and removed from the running kernel
-	  whenever you want). If you want to compile it as a module, say M
-	  here and read <file:Documentation/modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called sunqe.
 
 config SUNGEM
 	tristate "Sun GEM support"
@@ -607,11 +569,8 @@
 	  have problems.  Some people suggest to ping ("man ping") a nearby
 	  machine every minute ("man cron") when using this card.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called 3c501.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called 3c501.
 
 config EL2
 	tristate "3c503 \"EtherLink II\" support"
@@ -621,11 +580,8 @@
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called 3c503.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called 3c503.
 
 config ELPLUS
 	tristate "3c505 \"EtherLink Plus\" support"
@@ -636,11 +592,8 @@
 	  this type, say Y and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  If you want to compile this as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt> as well as
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
-	  called 3c505.
+  	  To compile this driver as a module, say M here: the module
+	  will be called 3c505.
 
 config EL16
 	tristate "3c507 \"EtherLink 16\" support (EXPERIMENTAL)"
@@ -650,11 +603,8 @@
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called 3c507.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called 3c507.
 
 config EL3
 	tristate "3c509/3c529 (MCA)/3c569B (98)/3c579 \"EtherLink III\" support"
@@ -668,11 +618,8 @@
 	  setup disk to disable Plug & Play mode, and to select the default
 	  media type.
 
-	  If you want to compile this as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt> as well as
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
-	  called 3c509.
+  	  To compile this driver as a module, say M here: the module
+	  will be called 3c509.
 
 config 3C515
 	tristate "3c515 ISA \"Fast EtherLink\""
@@ -682,11 +629,8 @@
 	  network card, say Y and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  If you want to compile this as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt> as well as
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
-	  called 3c515.
+  	  To compile this driver as a module, say M here: the module
+	  will be called 3c515.
 
 config ELMC
 	tristate "3c523 \"EtherLink/MC\" support"
@@ -696,11 +640,8 @@
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called 3c523.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called 3c523.
 
 config ELMC_II
 	tristate "3c527 \"EtherLink/MC 32\" support (EXPERIMENTAL)"
@@ -710,11 +651,8 @@
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called 3c527.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called 3c527.
 
 config VORTEX
 	tristate "3c590/3c900 series (592/595/597) \"Vortex/Boomerang\" support"
@@ -735,10 +673,8 @@
 	  <file:Documentation/networking/vortex.txt> and in the comments at
 	  the beginning of <file:drivers/net/3c59x.c>.
 
-	  If you want to compile this as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt> as well as
-	  <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called 3c59x.
 
 config TYPHOON
 	tristate "3cr990 series \"Typhoon\" support"
@@ -754,11 +690,8 @@
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called typhoon.o.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called typhoon.
 
 config LANCE
 	tristate "AMD LANCE and PCnet (AT1500 and NE2100) support"
@@ -769,10 +702,8 @@
 	  <http://www.tldp.org/docs.html#howto>. Some LinkSys cards are
 	  of this type.
 
-	  If you want to compile this driver as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt>.  This is
-	  recommended.  The module will be called lance.
+  	  To compile this driver as a module, say M here: the module
+	  will be called lance.
 
 config NET_VENDOR_SMC
 	bool "Western Digital/SMC cards"
@@ -795,11 +726,8 @@
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called wd.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called wd.
 
 config ULTRAMCA
 	tristate "SMC Ultra MCA support"
@@ -809,11 +737,8 @@
 	  an MCA based system (PS/2), say Y and read the Ethernet-HOWTO,
 	  available from <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called smc-mca.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called smc-mca.
 
 config ULTRA
 	tristate "SMC Ultra support"
@@ -830,11 +755,8 @@
 	  this but keep it in mind if you have such a SCSI card and have
 	  problems.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called smc-ultra.  If you want to compile it as
-	  a module, say M here and read <file:Documentation/modules.txt> as
-	  well as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called smc-ultra.
 
 config ULTRA32
 	tristate "SMC Ultra32 EISA support"
@@ -844,11 +766,8 @@
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called smc-ultra32.  If you want to compile it
-	  as a module, say M here and read <file:Documentation/modules.txt> as
-	  well as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called smc-ultra32.
 
 config SMC9194
 	tristate "SMC 9194 support"
@@ -861,11 +780,8 @@
 	  <file:Documentation/networking/smc9.txt> and the Ethernet-HOWTO,
 	  available from <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called smc9194.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called smc9194.
 
 config NET_VENDOR_RACAL
 	bool "Racal-Interlan (Micom) NI cards"
@@ -889,11 +805,8 @@
 	  <http://www.tldp.org/docs.html#howto>. Note that this is still
 	  experimental code.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called ni5010.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called ni5010.
 
 config NI52
 	tristate "NI5210 support"
@@ -903,11 +816,8 @@
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called ni52.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called ni52.
 
 config NI65
 	tristate "NI6510 support"
@@ -917,11 +827,8 @@
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called ni65.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called ni65.
 
 source "drivers/net/tulip/Kconfig"
 
@@ -933,12 +840,8 @@
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  If you want to compile it as a module, say M here and read
-	  <file:Documentation/modules.txt> as well as
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
-	  called at1700.
+  	  To compile this driver as a module, say M here: the module
+	  will be called at1700.
 
 config DEPCA
 	tristate "DEPCA, DE10x, DE200, DE201, DE202, DE422 support"
@@ -949,12 +852,8 @@
 	  <http://www.tldp.org/docs.html#howto> as well as
 	  <file:drivers/net/depca.c>.
 
-	  If you want to compile this as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt> as well as
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
-	  called
-	  depca.
+  	  To compile this driver as a module, say M here: the module
+	  will be called depca.
 
 config HP100
 	tristate "HP 10/100VG PCLAN (ISA, EISA, PCI) support"
@@ -964,11 +863,8 @@
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  If you want to compile this as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt> as well as
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
-	  called hp100.
+  	  To compile this driver as a module, say M here: the module
+	  will be called hp100.
 
 config NET_ISA
 	bool "Other ISA cards"
@@ -995,11 +891,8 @@
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called e2100.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called e2100.
 
 config EWRK3
 	tristate "EtherWORKS 3 (DE203, DE204, DE205) support"
@@ -1011,11 +904,8 @@
 	  well as the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  If you want to compile this as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt> as well as
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
-	  called ewrk3.
+  	  To compile this driver as a module, say M here: the module
+	  will be called ewrk3.
 
 config EEXPRESS
 	tristate "EtherExpress 16 support"
@@ -1028,11 +918,8 @@
 	  because the driver was very unreliable. We now have a new driver
 	  that should do better.
 
-	  If you want to compile this driver as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt> as well as
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
-	  called eexpress.
+  	  To compile this driver as a module, say M here: the module
+	  will be called eexpress.
 
 config EEXPRESS_PRO
 	tristate "EtherExpressPro support/EtherExpress 10 (i82595) support"
@@ -1044,11 +931,8 @@
 	  driver.  Please read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called eepro.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called eepro.
 
 config FMV18X
 	tristate "FMV-181/182/183/184 support (OBSOLETE)"
@@ -1061,11 +945,8 @@
 	  If you use an FMV-183 or FMV-184 and it is not working, you may need
 	  to disable Plug & Play mode of the card.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called fmv18x.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called fmv18x.
 
 config HPLAN_PLUS
 	tristate "HP PCLAN+ (27247B and 27252A) support"
@@ -1075,11 +956,8 @@
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called hp-plus.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called hp-plus.
 
 config HPLAN
 	tristate "HP PCLAN (27245 and other 27xxx series) support"
@@ -1089,11 +967,8 @@
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called hp.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called hp.
 
 config LP486E
 	tristate "LP486E on board Ethernet"
@@ -1111,11 +986,8 @@
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called eth16i.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called eth16i.
 
 config NE2000
 	tristate "NE2000/NE1000 support"
@@ -1132,11 +1004,8 @@
 	  laptops), say N here and Y to "NE/2 (ne2000 MCA version) support",
 	  below.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called ne.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called ne.
 
 config ZNET
 	tristate "Zenith Z-Note support (EXPERIMENTAL)"
@@ -1156,11 +1025,8 @@
 	  is for you, read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  If you want to compile this as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt> as well as
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
-	  called seeq8005.
+  	  To compile this driver as a module, say M here: the module
+	  will be called seeq8005.
 
 config SK_G16
 	tristate "SK_G16 support (OBSOLETE)"
@@ -1230,11 +1096,8 @@
 	  of different type hasn't been tested with this driver.  Say Y if you
 	  have one of these Ethernet adapters.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module is called sk_mca.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called sk_mca.
 
 config NE2_MCA
 	tristate "NE/2 (ne2000 MCA version) support"
@@ -1244,11 +1107,8 @@
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called ne2.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called ne2.
 
 config IBMLANA
 	tristate "IBM LAN Adapter/A support"
@@ -1257,14 +1117,17 @@
 	  This is a Micro Channel Ethernet adapter.  You need to set
 	  CONFIG_MCA to use this driver.  It is both available as an in-kernel
 	  driver and as a module ( = code which can be inserted in and removed
-	  from the running kernel whenever you want).  If you want to compile
-	  it as a module, say M here and read <file:Documentation/modules.txt>
-	  as well as <file:Documentation/networking/net-modules.txt>. The only
-	  currently supported card is the IBM LAN Adapter/A for Ethernet.  It
-	  will both support 16K and 32K memory windows, however a 32K window
-	  gives a better security against packet losses.  Usage of multiple
-	  boards with this driver should be possible, but has not been tested
-	  up to now due to lack of hardware.
+	  from the running kernel whenever you want). 
+
+  	  To compile this driver as a module, say M here: the module
+	  will be called ibmlana.
+
+	  The only currently supported card is the IBM LAN Adapter/A
+	  for Ethernet.  It will both support 16K and 32K memory
+	  windows, however a 32K window gives a better security
+	  against packet losses.  Usage of multiple boards with this
+	  driver should be possible, but has not been tested up to now
+	  due to lack of hardware.
 
 config NET_PCI
 	bool "EISA, VLB, PCI and on board controllers"
@@ -1288,11 +1151,8 @@
 	  answer Y here and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called pcnet32.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called pcnet32.
 
 config AMD8111_ETH
 	tristate "AMD 8111 (new PCI lance) support"
@@ -1302,11 +1162,8 @@
 	  answer Y here and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called amd8111e.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called amd8111e.
 
 config ADAPTEC_STARFIRE
 	tristate "Adaptec Starfire/DuraLAN support"
@@ -1317,10 +1174,8 @@
 	  Adaptec e.g. the ANA-6922A. The older 32 bit boards use the tulip
 	  driver.
 
-	  If you want to compile this driver as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt>.  This is
-	  recommended.  The module will be called starfire.
+  	  To compile this driver as a module, say M here: the module
+	  will be called starfire.
 
 config ADAPTEC_STARFIRE_NAPI
 	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
@@ -1342,11 +1197,8 @@
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called ac3200.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called ac3200.
 
 config APRICOT
 	tristate "Apricot Xen-II on board Ethernet"
@@ -1356,11 +1208,8 @@
 	  read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  If you want to compile this as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt> as well as
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
-	  called apricot.
+  	  To compile this driver as a module, say M here: the module
+	  will be called apricot.
 
 config B44
 	tristate "Broadcom 4400 ethernet support (EXPERIMENTAL)"
@@ -1370,11 +1219,8 @@
 	  read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  If you want to compile this as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt> as well as
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
-	  called b44.
+  	  To compile this driver as a module, say M here: the module
+	  will be called b44.
 
 config CS89x0
 	tristate "CS89x0 support"
@@ -1386,11 +1232,8 @@
 	  <http://www.tldp.org/docs.html#howto> as well as
 	  <file:Documentation/networking/cs89x0.txt>.
 
-	  If you want to compile this as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt> as well as
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
-	  called cs89x.
+  	  To compile this driver as a module, say M here: the module
+	  will be called cs89x.
 
 config TC35815
 	tristate "TOSHIBA TC35815 Ethernet support"
@@ -1407,11 +1250,8 @@
 	  <http://www.tldp.org/docs.html#howto>.  More specific
 	  information is contained in <file:Documentation/networking/dgrs.txt>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called dgrs.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called dgrs.
 
 config EEPRO100
 	tristate "EtherExpressPro/100 support (eepro100, original Becker driver)"
@@ -1421,11 +1261,8 @@
 	  card, say Y and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called eepro100.  If you want to compile it as
-	  a module, say M here and read <file:Documentation/modules.txt> as
-	  well as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called eepro100.
 
 
 config EEPRO100_PIO
@@ -1509,11 +1346,8 @@
 	  More specific information on configuring the driver is in 
 	  <file:Documentation/networking/e100.txt>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called e100.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called e100.
 
 config LNE390
 	tristate "Mylex EISA LNE390A/B support (EXPERIMENTAL)"
@@ -1523,11 +1357,8 @@
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called lne390.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called lne390.
 
 config FEALNX
 	tristate "Myson MTD-8xx PCI Ethernet support"
@@ -1562,11 +1393,8 @@
 	  NetVin NV5000SC   Via 86C926      SureCom NE34   Winbond
 	  Holtek HT80232    Holtek HT80229
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called ne2k-pci.  If you want to compile it as
-	  a module, say M here and read <file:Documentation/modules.txt> as
-	  well as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called ne2k-pci.
 
 config NE3210
 	tristate "Novell/Eagle/Microdyne NE3210 EISA support (EXPERIMENTAL)"
@@ -1577,11 +1405,8 @@
 	  <http://www.tldp.org/docs.html#howto>.  Note that this driver
 	  will NOT WORK for NE3200 cards as they are completely different.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called ne3210.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called ne3210.
 
 config ES3210
 	tristate "Racal-Interlan EISA ES3210 support (EXPERIMENTAL)"
@@ -1591,11 +1416,8 @@
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called es3210.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called es3210.
 
 config 8139CP
 	tristate "RealTek RTL-8139 C+ PCI Fast Ethernet Adapter support (EXPERIMENTAL)"
@@ -1606,10 +1428,8 @@
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  If you want to compile this driver as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read Documentation/modules.txt. This is recommended.
-	  The module will be called 8139cp.
+  	  To compile this driver as a module, say M here: the module
+	  will be called 8139cp.
 
 config 8139TOO
 	tristate "RealTek RTL-8139 PCI Fast Ethernet Adapter support"
@@ -1621,10 +1441,8 @@
 	  Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  If you want to compile this driver as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt>.  This is
-	  recommended.  The module will be called 8139too.
+  	  To compile this driver as a module, say M here: the module
+	  will be called 8139too.
 
 config 8139TOO_PIO
 	bool "Use PIO instead of MMIO"
@@ -1680,10 +1498,8 @@
 	  This driver also supports AMD 79C901 HomePNA so that you can use
 	  your phone line as a network cable.
 
-	  If you want to compile this driver as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt>.  This is
-	  recommended.  The module will be called sis900.
+  	  To compile this driver as a module, say M here: the module
+	  will be called sis900.
 
 config EPIC100
 	tristate "SMC EtherPower II"
@@ -1725,11 +1541,8 @@
 	  Compaq NetFlex and Olicom cards.  Please read the file
 	  <file:Documentation/networking/tlan.txt> for more details.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called tlan.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called tlan.
 
 	  Please email feedback to  torben.mathiasen@compaq.com.
 
@@ -1740,11 +1553,8 @@
 	  If you have a VIA "rhine" based network card (Rhine-I (3043) or
 	  Rhine-2 (VT86c100A)), say Y here.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called via-rhine.  If you want to compile it as
-	  a module, say M here and read <file:Documentation/modules.txt> as
-	  well as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called via-rhine.
 
 config VIA_RHINE_MMIO
 	bool "Use MMIO instead of PIO (EXPERIMENTAL)"
@@ -1802,10 +1612,8 @@
 	  said N to the "Parallel printer support", because the two drivers
 	  don't like each other.
 
-	  If you want to compile this driver as a module however ( = code
-	  which can be inserted in and removed from the running kernel
-	  whenever you want), say M here and read
-	  <file:Documentation/modules.txt>.  The module will be called atp.
+  	  To compile this driver as a module, say M here: the module
+	  will be called atp.
 
 config DE600
 	tristate "D-Link DE600 pocket adapter support"
@@ -1819,11 +1627,8 @@
 	  port and it is safe to compile the corresponding drivers into the
 	  kernel.
 
-	  If you want to compile this driver as a module however ( = code
-	  which can be inserted in and removed from the running kernel
-	  whenever you want), say M here and read
-	  <file:Documentation/modules.txt>.
-	  The module will be called de600.
+  	  To compile this driver as a module, say M here: the module
+	  will be called de600.
 
 config DE620
 	tristate "D-Link DE620 pocket adapter support"
@@ -1837,11 +1642,8 @@
 	  port and it is safe to compile the corresponding drivers into the
 	  kernel.
 
-	  If you want to compile this driver as a module however ( = code
-	  which can be inserted in and removed from the running kernel
-	  whenever you want), say M here and read
-	  <file:Documentation/modules.txt>.
-	  The module will be called de620.
+  	  To compile this driver as a module, say M here: the module
+	  will be called de620.
 
 config SGISEEQ
 	tristate "SGI Seeq ethernet controller support"
@@ -1900,10 +1702,8 @@
 	  as well. To enable Jumbo Frames, add `mtu 9000' to your ifconfig
 	  line.
 
-	  If you want to compile this driver as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt>.  This is
-	  recommended.  The module will be called acenic.
+  	  To compile this driver as a module, say M here: the module
+	  will be called acenic.
 
 config ACENIC_OMIT_TIGON_I
 	bool "Omit support for old Tigon I based AceNICs"
@@ -1927,10 +1727,8 @@
 	  D-Link DGE-550T Gigabit Ethernet Adapter.
 	  D-Link DL2000-based Gigabit Ethernet Adapter.
 
-	  If you want to compile this driver as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt>.  This is
-	  recommended.  The module will be called dl2k.
+  	  To compile this driver as a module, say M here: the module
+	  will be called dl2k.
 
 config E1000
 	tristate "Intel(R) PRO/1000 Gigabit Ethernet support"
@@ -1971,11 +1769,8 @@
 	  More specific information on configuring the driver is in 
 	  <file:Documentation/networking/e1000.txt>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called e1000.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called e1000.
 
 config E1000_NAPI
 	bool "Use Rx Polling (NAPI)"
@@ -1987,10 +1782,8 @@
 	help
 	  This driver supports MyriCOM Sbus gigabit Ethernet cards.
 
-	  If you want to compile this driver as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt>.  This is
-	  recommended.  The module will be called myri_sbus.
+  	  To compile this driver as a module, say M here: the module
+	  will be called myri_sbus.
 
 config NS83820
 	tristate "National Semiconduct DP83820 support"
@@ -2010,11 +1803,8 @@
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  If you want to compile this as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt> as well as
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
-	  called hamachi.
+  	  To compile this driver as a module, say M here: the module
+	  will be called hamachi.
 
 config YELLOWFIN
 	tristate "Packet Engines Yellowfin Gigabit-NIC support (EXPERIMENTAL)"
@@ -2026,10 +1816,8 @@
 	  <http://cesdis.gsfc.nasa.gov/linux/drivers/yellowfin.html> for more
 	  information about this driver in particular and Beowulf in general.
 
-	  If you want to compile this driver as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt>.  This is
-	  recommended.  The module will be called yellowfin.
+  	  To compile this driver as a module, say M here: the module
+	  will be called yellowfin.
 
 config R8169
 	tristate "Realtek 8169 gigabit ethernet support"
@@ -2037,10 +1825,8 @@
 	---help---
 	  Say Y here if you have a Realtek 8169 PCI Gigabit Ethernet adapter.
 
-	  If you want to compile this driver as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt>.  This is
-	  recommended.  The module will be called r8169.
+  	  To compile this driver as a module, say M here: the module
+	  will be called r8169.
 
 config SIS190
 	tristate "SiS190 gigabit ethernet support (EXPERIMENTAL)"
@@ -2048,10 +1834,8 @@
 	---help---
 	  Say Y here if you have a SiS 190 PCI Gigabit Ethernet adapter.
 
-	  If you want to compile this driver as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt>.  This is
-	  recommended.  The module will be called sis190.
+  	  To compile this driver as a module, say M here: the module
+	  will be called sis190.
 
 config SK98LIN
 	tristate "Marvell Yukon Chipset / SysKonnect SK-98xx Support"
@@ -2113,10 +1897,8 @@
 	  Questions concerning this driver may be addressed to:
 	      linux@syskonnect.de
 	  
-	  If you want to compile this driver as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read Documentation/modules.txt. This is recommended.
-	  The module will be called sk98lin.o.
+	  To compile this driver as a module, say M here: the module
+	  will be called sk98lin.
 	  
 config CONFIG_SK98LIN_T1
 	bool "3Com 3C940/3C941 Gigabit Ethernet Adapter"
@@ -2259,10 +2041,8 @@
 	help
 	  This driver supports Broadcom Tigon3 based gigabit Ethernet cards.
 
-	  If you want to compile this driver as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt>.  This is
-	  recommended.  The module will be called tg3.
+  	  To compile this driver as a module, say M here: the module
+	  will be called tg3.
 
 endmenu
 
@@ -2297,11 +2077,8 @@
 	  More specific information on configuring the driver is in 
 	  <file:Documentation/networking/ixgb.txt>.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called ixgb.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt> as well
-	  as <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called ixgb.
 
 config IXGB_NAPI
 	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
@@ -2360,10 +2137,8 @@
 	  Questions concerning this driver can be addressed to:
 	  linux@syskonnect.de
 
-	  If you want to compile this driver as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt>.  This is
-	  recommended.  The module will be called skfp.
+  	  To compile this driver as a module, say M here: the module
+	  will be called skfp.
 
 config HIPPI
 	bool "HIPPI driver support (EXPERIMENTAL)"
@@ -2384,11 +2159,8 @@
 	help
 	  Say Y here if this is your PCI HIPPI network card.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called rrunner. If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt>.  If
-	  unsure, say N.
+  	  To compile this driver as a module, say M here: the module
+	  will be called rrunner.
 
 config ROADRUNNER_LARGE_RINGS
 	bool "Use large TX/RX rings (EXPERIMENTAL)"
@@ -2431,11 +2203,8 @@
 	  with the PLIP support in Linux versions 1.0.x.  This option enlarges
 	  your kernel by about 8 KB.
 
-	  If you want to compile this as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt> as well as
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
-	  called plip.  If unsure, say Y or M, in case you buy a laptop
+  	  To compile this driver as a module, say M here: the module
+	  will be called plip.  If unsure, say Y or M, in case you buy a laptop
 	  later.
 
 config PPP
@@ -2463,14 +2232,8 @@
 	  synchronous lines, you should say Y (or M) here and to "Support
 	  synchronous PPP", below.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  If you said Y to "Version information on all symbols" above, then
-	  you cannot compile the PPP driver into the kernel; you can then only
-	  compile it as a module.  The module will be called ppp_generic.
-	  If you want to compile it as a module, say M here and read
-	  <file:Documentation/modules.txt> as well as
-	  <file:Documentation/networking/net-modules.txt>.
+  	  To compile this driver as a module, say M here: the module
+	  will be called ppp_generic.
 
 config PPP_MULTILINK
 	bool "PPP multilink support (EXPERIMENTAL)"
@@ -2507,9 +2270,8 @@
 	  a modem (not a synchronous or ISDN modem) to contact your ISP, you
 	  need this option.
 
-	  This code is also available as a module (code which can be inserted
-	  into and removed from the running kernel).  If you want to compile
-	  it as a module, say M here and read <file:Documentation/modules.txt>.
+	  To compile this driver as a module, say M here: the module
+	  will be called ppp_async.
 
 	  If unsure, say Y.
 
@@ -2521,10 +2283,8 @@
 	  (HDLC) tty devices, such as the SyncLink adapter. These devices
 	  are often used for high-speed leased lines like T1/E1.
 
-	  This code is also available as a module (code which can be inserted
-	  into and removed from the running kernel).  If you want to compile
-	  it as a module, say M here and read
-	  <file:Documentation/modules.txt>.
+	  To compile this driver as a module, say M here: the module
+	  will be called ppp_sync_tty.
 
 config PPP_DEFLATE
 	tristate "PPP Deflate compression"
@@ -2537,10 +2297,8 @@
 	  Deflate compression method as well for this to be useful.  Even if
 	  they don't support it, it is safe to say Y here.
 
-	  This code is also available as a module (code which can be inserted
-	  into and removed from the running kernel).  If you want to compile
-	  it as a module, say M here and read
-	  <file:Documentation/modules.txt>.
+	  To compile this driver as a module, say M here: the module
+	  will be called ppp_deflate.
 
 config PPP_BSDCOMP
 	tristate "PPP BSD-Compress compression"
@@ -2557,9 +2315,8 @@
 	  above) is preferable to BSD-Compress, because it compresses better
 	  and is patent-free.
 
-	  Note that the BSD compression code will always be compiled as a
-	  module; it is called bsd_comp and will show up in the directory
-	  modules once you have said "make modules". If unsure, say N.
+	  To compile this driver as a module, say M here: the module
+	  will be calledbsd_comp.
 
 config PPPOE
 	tristate "PPP over Ethernet (EXPERIMENTAL)"
@@ -2610,11 +2367,8 @@
 	  <http://www.bart.nl/~patrickr/term-howto/Term-HOWTO.html>). SLIP
 	  support will enlarge your kernel by about 4 KB. If unsure, say N.
 
-	  If you want to compile this as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want),
-	  say M here and read <file:Documentation/modules.txt> as well as
-	  <file:Documentation/networking/net-modules.txt>. The module will be
-	  called slip.
+	  To compile this driver as a module, say M here: the module
+	  will be called slip.
 
 config SLIP_COMPRESSED
 	bool "CSLIP compressed headers"
@@ -2674,10 +2428,8 @@
 	help
 	  Say Y here if you have a Fibre Channel adaptor of this kind.
 
-	  The driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called iph5526. For general information about
-	  modules read <file:Documentation/modules.txt>.
+	  To compile this driver as a module, say M here: the module
+	  will be called iph5526.
 
 config RCPCI
 	tristate "Red Creek Hardware VPN (EXPERIMENTAL)"
@@ -2686,10 +2438,8 @@
 	  This is a driver for hardware which provides a Virtual Private
 	  Network (VPN). Say Y if you have it.
 
-	  This code is also available as a module called rcpci ( = code
-	  which can be inserted in and removed from the running kernel
-	  whenever you want). If you want to compile it as a module, say M
-	  here and read <file:Documentation/modules.txt>.
+	  To compile this driver as a module, say M here: the module
+	  will be called rcpci.
 
 config SHAPER
 	tristate "Traffic Shaper (EXPERIMENTAL)"
@@ -2709,11 +2459,8 @@
 	  program, available from <ftp://shadow.cabi.net/pub/Linux/> in the
 	  shaper package.
 
-	  This driver is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module will be called shaper.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/modules.txt>.  If
-	  unsure, say N.
+	  To compile this driver as a module, say M here: the module
+	  will be called shaper.  If unsure, say N.
 
 source "drivers/net/wan/Kconfig"
 
