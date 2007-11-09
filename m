From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] remove references to net-modules.txt
Date: Fri, 9 Nov 2007 07:01:41 +0100
Message-ID: <20071109060141.GM26163@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751348AbXKIGCZ@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When I removed net-modules.txt because it only contained ancient 
information I missed that many Kconfig entries pointed to this ancient 
information.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 Documentation/networking/3c505.txt |    3 
 drivers/net/Kconfig                |  199 ++++++++++-------------------
 drivers/net/arcnet/Kconfig         |   15 --
 drivers/net/tulip/Kconfig          |   21 +--
 4 files changed, 82 insertions(+), 156 deletions(-)

6451db6bafae46e17885b8c7b243095fc257e8ed 
diff --git a/Documentation/networking/3c505.txt b/Documentation/networking/3c505.txt
index b9d5b72..72f38b1 100644
--- a/Documentation/networking/3c505.txt
+++ b/Documentation/networking/3c505.txt
@@ -14,8 +14,7 @@ If no base address is given at boot time, the driver will autoprobe
 ports 0x300, 0x280 and 0x310 (in that order).  If no IRQ is given, the driver
 will try to probe for it.
 
-The driver can be used as a loadable module.  See net-modules.txt for details
-of the parameters it can take.  
+The driver can be used as a loadable module.
 
 Theoretically, one instance of the driver can now run multiple cards,
 in the standard way (when loading a module, say "modprobe 3c505
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 5f800a6..0fdcf72 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -365,8 +365,7 @@ config MAC89x0
 	  read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  This module will
+	  To compile this driver as a module, choose M here. This module will
 	  be called mac89x0.
 
 config MACSONIC
@@ -379,8 +378,7 @@ config MACSONIC
 	  one of these say Y and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  This module will
+	  To compile this driver as a module, choose M here. This module will
 	  be called macsonic.
 
 config MACMACE
@@ -618,8 +616,7 @@ config EL1
 	  have problems.  Some people suggest to ping ("man ping") a nearby
 	  machine every minute ("man cron") when using this card.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called 3c501.
 
 config EL2
@@ -631,8 +628,7 @@ config EL2
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called 3c503.
 
 config ELPLUS
@@ -644,8 +640,7 @@ config ELPLUS
 	  this type, say Y and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called 3c505.
 
 config EL16
@@ -656,8 +651,7 @@ config EL16
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called 3c507.
 
 config EL3
@@ -672,8 +666,7 @@ config EL3
 	  setup disk to disable Plug & Play mode, and to select the default
 	  media type.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called 3c509.
 
 config 3C515
@@ -684,8 +677,7 @@ config 3C515
 	  network card, say Y and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called 3c515.
 
 config ELMC
@@ -696,8 +688,7 @@ config ELMC
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called 3c523.
 
 config ELMC_II
@@ -708,8 +699,7 @@ config ELMC_II
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called 3c527.
 
 config VORTEX
@@ -732,8 +722,7 @@ config VORTEX
 	  <file:Documentation/networking/vortex.txt> and in the comments at
 	  the beginning of <file:drivers/net/3c59x.c>.
 
-	  To compile this support as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.
+	  To compile this support as a module, choose M here.
 
 config TYPHOON
 	tristate "3cr990 series \"Typhoon\" support"
@@ -750,8 +739,7 @@ config TYPHOON
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called typhoon.
 
 config LANCE
@@ -788,8 +776,7 @@ config WD80x3
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called wd.
 
 config ULTRAMCA
@@ -801,8 +788,7 @@ config ULTRAMCA
 	  an MCA based system (PS/2), say Y and read the Ethernet-HOWTO,
 	  available from <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called smc-mca.
 
 config ULTRA
@@ -821,8 +807,7 @@ config ULTRA
 	  this but keep it in mind if you have such a SCSI card and have
 	  problems.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called smc-ultra.
 
 config ULTRA32
@@ -834,8 +819,7 @@ config ULTRA32
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called smc-ultra32.
 
 config BFIN_MAC
@@ -896,8 +880,7 @@ config SMC9194
 	  <file:Documentation/networking/smc9.txt> and the Ethernet-HOWTO,
 	  available from <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called smc9194.
 
 config SMC91X
@@ -915,8 +898,7 @@ config SMC91X
 	  This driver is also available as a module ( = code which can be
 	  inserted in and removed from the running kernel whenever you want).
 	  The module will be called smc91x.  If you want to compile it as a
-	  module, say M here and read <file:Documentation/kbuild/modules.txt>
-	  as well as <file:Documentation/networking/net-modules.txt>.
+	  module, say M here and read <file:Documentation/kbuild/modules.txt>.
 
 config NET_NETX
 	tristate "NetX Ethernet support"
@@ -925,8 +907,7 @@ config NET_NETX
 	help
 	  This is support for the Hilscher netX builtin Ethernet ports
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called netx-eth.
 
 config DM9000
@@ -937,9 +918,8 @@ config DM9000
 	---help---
 	  Support for DM9000 chipset.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
-	  called dm9000.
+	  To compile this driver as a module, choose M here.  The module
+	  will be called dm9000.
 
 config SMC911X
 	tristate "SMSC LAN911[5678] support"
@@ -979,8 +959,7 @@ config NI5010
 	  <http://www.tldp.org/docs.html#howto>. Note that this is still
 	  experimental code.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called ni5010.
 
 config NI52
@@ -991,8 +970,7 @@ config NI52
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called ni52.
 
 config NI65
@@ -1003,8 +981,7 @@ config NI65
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called ni65.
 
 source "drivers/net/tulip/Kconfig"
@@ -1018,8 +995,7 @@ config AT1700
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called at1700.
 
 config DEPCA
@@ -1032,8 +1008,7 @@ config DEPCA
 	  <http://www.tldp.org/docs.html#howto> as well as
 	  <file:drivers/net/depca.c>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called depca.
 
 config HP100
@@ -1044,8 +1019,7 @@ config HP100
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called hp100.
 
 config NET_ISA
@@ -1074,8 +1048,7 @@ config E2100
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called e2100.
 
 config EWRK3
@@ -1089,8 +1062,7 @@ config EWRK3
 	  well as the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called ewrk3.
 
 config EEXPRESS
@@ -1104,8 +1076,7 @@ config EEXPRESS
 	  because the driver was very unreliable. We now have a new driver
 	  that should do better.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called eexpress.
 
 config EEXPRESS_PRO
@@ -1118,8 +1089,7 @@ config EEXPRESS_PRO
 	  driver.  Please read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called eepro.
 
 config HPLAN_PLUS
@@ -1131,8 +1101,7 @@ config HPLAN_PLUS
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called hp-plus.
 
 config HPLAN
@@ -1144,8 +1113,7 @@ config HPLAN
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called hp.
 
 config LP486E
@@ -1164,8 +1132,7 @@ config ETH16I
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called eth16i.
 
 config NE2000
@@ -1185,8 +1152,7 @@ config NE2000
 	  laptops), say N here and Y to "NE/2 (ne2000 MCA version) support",
 	  below.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called ne.
 
 config ZNET
@@ -1207,8 +1173,7 @@ config SEEQ8005
 	  is for you, read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called seeq8005.
 
 config NE2_MCA
@@ -1220,8 +1185,7 @@ config NE2_MCA
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called ne2.
 
 config IBMLANA
@@ -1232,8 +1196,7 @@ config IBMLANA
 	  CONFIG_MCA to use this driver.  It is both available as an in-kernel
 	  driver and as a module.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The only
+	  To compile this driver as a module, choose M here. The only
 	  currently supported card is the IBM LAN Adapter/A for Ethernet.  It
 	  will both support 16K and 32K memory windows, however a 32K window
 	  gives a better security against packet losses.  Usage of multiple
@@ -1247,8 +1210,7 @@ config IBMVETH
 	  This driver supports virtual ethernet adapters on newer IBM iSeries
 	  and pSeries systems.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module will
+	  To compile this driver as a module, choose M here. The module will
 	  be called ibmveth.
 
 source "drivers/net/ibm_emac/Kconfig"
@@ -1278,8 +1240,7 @@ config PCNET32
 	  answer Y here and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called pcnet32.
 
 config PCNET32_NAPI
@@ -1306,8 +1267,7 @@ config AMD8111_ETH
 	  answer Y here and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called amd8111e.
 
 config AMD8111E_NAPI
@@ -1361,8 +1321,7 @@ config AC3200
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called ac3200.
 
 config APRICOT
@@ -1373,9 +1332,8 @@ config APRICOT
 	  read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
-	  called apricot.
+	  To compile this driver as a module, choose M here. The module
+	  will be called apricot.
 
 config B44
 	tristate "Broadcom 440x/47xx ethernet support"
@@ -1387,9 +1345,8 @@ config B44
 	  or M and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
-	  called b44.
+	  To compile this driver as a module, choose M here. The module
+	  will be called b44.
 
 # Auto-select SSB PCI-HOST support, if possible
 config B44_PCI_AUTOSELECT
@@ -1418,9 +1375,8 @@ config FORCEDETH
 	  read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
-	  called forcedeth.
+	  To compile this driver as a module, choose M here. The module
+	  will be called forcedeth.
 
 config FORCEDETH_NAPI
 	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
@@ -1446,9 +1402,8 @@ config CS89x0
 	  <http://www.tldp.org/docs.html#howto> as well as
 	  <file:Documentation/networking/cs89x0.txt>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
-	  called cs89x0.
+	  To compile this driver as a module, choose M here. The module
+	  will be called cs89x0.
 
 config TC35815
 	tristate "TOSHIBA TC35815 Ethernet support"
@@ -1464,8 +1419,7 @@ config EEPRO100
 	  card, say Y and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called eepro100.
 
 
@@ -1492,8 +1446,7 @@ config E100
 	  More specific information on configuring the driver is in 
 	  <file:Documentation/networking/e100.txt>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called e100.
 
 config LNE390
@@ -1505,8 +1458,7 @@ config LNE390
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called lne390.
 
 config FEALNX
@@ -1546,8 +1498,7 @@ config NE2K_PCI
 	  NetVin NV5000SC   Via 86C926      SureCom NE34   Winbond
 	  Holtek HT80232    Holtek HT80229
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called ne2k-pci.
 
 config NE3210
@@ -1560,8 +1511,7 @@ config NE3210
 	  <http://www.tldp.org/docs.html#howto>.  Note that this driver
 	  will NOT WORK for NE3200 cards as they are completely different.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called ne3210.
 
 config ES3210
@@ -1573,8 +1523,7 @@ config ES3210
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called es3210.
 
 config 8139CP
@@ -1704,8 +1653,7 @@ config TLAN
 	  Compaq NetFlex and Olicom cards.  Please read the file
 	  <file:Documentation/networking/tlan.txt> for more details.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called tlan.
 
 	  Please email feedback to <torben.mathiasen@compaq.com>.
@@ -1995,8 +1943,7 @@ config E1000
 	  More specific information on configuring the driver is in 
 	  <file:Documentation/networking/e1000.txt>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called e1000.
 
 config E1000_NAPI
@@ -2041,8 +1988,7 @@ config E1000E
 	  More specific information on configuring the driver is in
 	  <file:Documentation/networking/e1000e.txt>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called e1000e.
 
 source "drivers/net/ixp2000/Kconfig"
@@ -2075,8 +2021,7 @@ config HAMACHI
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
+	  To compile this driver as a module, choose M here. The module will be
 	  called hamachi.
 
 config YELLOWFIN
@@ -2525,8 +2470,7 @@ config IXGBE
 	  More specific information on configuring the driver is in
 	  <file:Documentation/networking/ixgbe.txt>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called ixgbe.
 
 config IXGB
@@ -2548,8 +2492,7 @@ config IXGB
 	  More specific information on configuring the driver is in 
 	  <file:Documentation/networking/ixgb.txt>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called ixgb.
 
 config IXGB_NAPI
@@ -2602,8 +2545,7 @@ config MYRI10GE
 
 	  <http://www.myri.com/scs/download-Myri10GE.html>
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module
+	  To compile this driver as a module, choose M here. The module
 	  will be called myri10ge.
 
 config NETXEN_NIC
@@ -2827,10 +2769,9 @@ config PLIP
 	  with the PLIP support in Linux versions 1.0.x.  This option enlarges
 	  your kernel by about 8 KB.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
-	  called plip.  If unsure, say Y or M, in case you buy a laptop
-	  later.
+	  To compile this driver as a module, choose M here. The module
+	  will be called plip. If unsure, say Y or M, in case you buy
+	  a laptop later.
 
 config PPP
 	tristate "PPP (point-to-point protocol) support"
@@ -2860,8 +2801,7 @@ config PPP
 	  If you said Y to "Version information on all symbols" above, then
 	  you cannot compile the PPP driver into the kernel; you can then only
 	  compile it as a module. To compile this driver as a module, choose M
-	  here and read <file:Documentation/networking/net-modules.txt>.
-	  The module will be called ppp_generic.
+	  here. The module will be called ppp_generic.
 
 config PPP_MULTILINK
 	bool "PPP multilink support (EXPERIMENTAL)"
@@ -3022,9 +2962,8 @@ config SLIP
 	  <http://www.bart.nl/~patrickr/term-howto/Term-HOWTO.html>). SLIP
 	  support will enlarge your kernel by about 4 KB. If unsure, say N.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module will be
-	  called slip.
+	  To compile this driver as a module, choose M here. The module
+	  will be called slip.
 
 config SLIP_COMPRESSED
 	bool "CSLIP compressed headers"
diff --git a/drivers/net/arcnet/Kconfig b/drivers/net/arcnet/Kconfig
index 4030274..3b2f7f1 100644
--- a/drivers/net/arcnet/Kconfig
+++ b/drivers/net/arcnet/Kconfig
@@ -19,8 +19,7 @@ menuconfig ARCNET
 	  from <http://www.tldp.org/docs.html#howto>(even though ARCnet
 	  is not really Ethernet).
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module will
+	  To compile this driver as a module, choose M here. The module will
 	  be called arcnet.
 
 if ARCNET
@@ -81,8 +80,7 @@ config ARCNET_COM90xx
 	  have always used the old ARCnet driver without knowing what type of
 	  card you had, this is probably the one for you.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module will
+	  To compile this driver as a module, choose M here. The module will
 	  be called com90xx.
 
 config ARCNET_COM90xxIO
@@ -93,8 +91,7 @@ config ARCNET_COM90xxIO
 	  the normal driver. Only use it if your card doesn't support shared
 	  memory.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module will
+	  To compile this driver as a module, choose M here. The module will
 	  be called com90io.
 
 config ARCNET_RIM_I
@@ -105,8 +102,7 @@ config ARCNET_RIM_I
 	  driver is completely untested, so if you have one of these cards,
 	  please mail <dwmw2@infradead.org>, especially if it works!
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module will
+	  To compile this driver as a module, choose M here. The module will
 	  be called arc-rimi.
 
 config ARCNET_COM20020
@@ -116,8 +112,7 @@ config ARCNET_COM20020
 	  things as promiscuous mode, so packet sniffing is possible, and
 	  extra diagnostic information.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module will
+	  To compile this driver as a module, choose M here. The module will
 	  be called com20020.
 
 config ARCNET_COM20020_ISA
diff --git a/drivers/net/tulip/Kconfig b/drivers/net/tulip/Kconfig
index 49d7a29..20ac150 100644
--- a/drivers/net/tulip/Kconfig
+++ b/drivers/net/tulip/Kconfig
@@ -24,8 +24,7 @@ config DE2104X
 	  will say Y here.) Do read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module will
+	  To compile this driver as a module, choose M here. The module will
 	  be called de2104x.
 
 config TULIP
@@ -42,8 +41,7 @@ config TULIP
 	  will say Y here.) Do read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module will
+	  To compile this driver as a module, choose M here. The module will
 	  be called tulip.
 
 config TULIP_MWI
@@ -104,8 +102,7 @@ config DE4X5
 	  information is contained in
 	  <file:Documentation/networking/de4x5.txt>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module will
+	  To compile this driver as a module, choose M here. The module will
 	  be called de4x5.
 
 config WINBOND_840
@@ -129,8 +126,7 @@ config DM9102
 	  (Ethernet) card, say Y.  Some information is contained in the file
 	  <file:Documentation/networking/dmfe.txt>.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module will
+	  To compile this driver as a module, choose M here. The module will
 	  be called dmfe.
 
 config ULI526X
@@ -141,8 +137,7 @@ config ULI526X
 	  This driver is for ULi M5261/M5263 10/100M Ethernet Controller
 	  (<http://www.uli.com.tw/>).
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module will
+	  To compile this driver as a module, choose M here. The module will
 	  be called uli526x.
 	  
 config PCMCIA_XIRCOM
@@ -154,8 +149,7 @@ config PCMCIA_XIRCOM
 	  as with work-alike chips from Lite-On (PNIC) and Macronix (MXIC) and
 	  ASIX.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module will
+	  To compile this driver as a module, choose M here. The module will
 	  be called xircom_cb.  If unsure, say N.
 
 config PCMCIA_XIRTULIP
@@ -168,8 +162,7 @@ config PCMCIA_XIRTULIP
 	  as with work-alike chips from Lite-On (PNIC) and Macronix (MXIC) and
 	  ASIX.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module will
+	  To compile this driver as a module, choose M here. The module will
 	  be called xircom_tulip_cb.  If unsure, say N.
 
 endif # NET_TULIP
