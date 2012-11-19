From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 378/493] ethernet: remove use of __devinitconst
Date: Mon, 19 Nov 2012 13:25:27 -0500
Message-ID: <1353349642-3677-378-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	Jes Sorensen <jes@trained-monkey.org>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Daniele Venzano <venza@brownhat.org>,
	Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	linux-acenic@sunsite.dk
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41487 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754218Ab2KSSer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:34:47 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devinitconst is no
longer needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de> 
Cc: Jes Sorensen <jes@trained-monkey.org> 
Cc: Jay Cliburn <jcliburn@gmail.com> 
Cc: Chris Snook <chris.snook@gmail.com> 
Cc: Grant Grundler <grundler@parisc-linux.org> 
Cc: Francois Romieu <romieu@fr.zoreil.com> 
Cc: Daniele Venzano <venza@brownhat.org> 
Cc: Roger Luethi <rl@hellgate.ch> 
Cc: netdev@vger.kernel.org 
Cc: linux-acenic@sunsite.dk 
---
 drivers/net/ethernet/3com/3c59x.c               | 2 +-
 drivers/net/ethernet/8390/ne2k-pci.c            | 2 +-
 drivers/net/ethernet/adaptec/starfire.c         | 4 ++--
 drivers/net/ethernet/alteon/acenic.c            | 2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c | 2 +-
 drivers/net/ethernet/atheros/atlx/atl2.c        | 2 +-
 drivers/net/ethernet/dec/tulip/de4x5.c          | 2 +-
 drivers/net/ethernet/dec/tulip/dmfe.c           | 2 +-
 drivers/net/ethernet/dec/tulip/eeprom.c         | 2 +-
 drivers/net/ethernet/dec/tulip/uli526x.c        | 2 +-
 drivers/net/ethernet/dec/tulip/winbond-840.c    | 2 +-
 drivers/net/ethernet/dlink/sundance.c           | 4 ++--
 drivers/net/ethernet/fealnx.c                   | 4 ++--
 drivers/net/ethernet/natsemi/natsemi.c          | 2 +-
 drivers/net/ethernet/packetengines/hamachi.c    | 2 +-
 drivers/net/ethernet/packetengines/yellowfin.c  | 2 +-
 drivers/net/ethernet/realtek/8139too.c          | 2 +-
 drivers/net/ethernet/sis/sis190.c               | 2 +-
 drivers/net/ethernet/sis/sis900.c               | 2 +-
 drivers/net/ethernet/via/via-rhine.c            | 2 +-
 20 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 56fdc39..3c0f663 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -102,7 +102,7 @@ static int vortex_debug = 1;
 #include <linux/delay.h>
 
 
-static const char version[] __devinitconst =
+static const char version[] =
 	DRV_NAME ": Donald Becker and others.\n";
 
 MODULE_AUTHOR("Donald Becker <becker@scyld.com>");
diff --git a/drivers/net/ethernet/8390/ne2k-pci.c b/drivers/net/ethernet/8390/ne2k-pci.c
index f734d0f..96b31b1 100644
--- a/drivers/net/ethernet/8390/ne2k-pci.c
+++ b/drivers/net/ethernet/8390/ne2k-pci.c
@@ -61,7 +61,7 @@ static int options[MAX_UNITS];
 #include "8390.h"
 
 /* These identify the driver base version and may not be removed. */
-static const char version[] __devinitconst =
+static const char version[] =
 	KERN_INFO DRV_NAME ".c:v" DRV_VERSION " " DRV_RELDATE
 	" D. Becker/P. Gortmaker\n";
 
diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index 7ec9115..7b3d3a2 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -166,7 +166,7 @@ static int rx_copybreak /* = 0 */;
 #define FIRMWARE_TX	"adaptec/starfire_tx.bin"
 
 /* These identify the driver base version and may not be removed. */
-static const char version[] __devinitconst =
+static const char version[] =
 KERN_INFO "starfire.c:v1.03 7/26/2000  Written by Donald Becker <becker@scyld.com>\n"
 " (unofficial 2.2/2.4 kernel port, version " DRV_VERSION ", " DRV_RELDATE ")\n";
 
@@ -295,7 +295,7 @@ MODULE_DEVICE_TABLE(pci, starfire_pci_tbl);
 static const struct chip_info {
 	const char *name;
 	int drv_flags;
-} netdrv_tbl[] __devinitconst = {
+} netdrv_tbl[] = {
 	{ "Adaptec Starfire 6915", CanHaveMII },
 };
 
diff --git a/drivers/net/ethernet/alteon/acenic.c b/drivers/net/ethernet/alteon/acenic.c
index dba93e3..4cf8e78 100644
--- a/drivers/net/ethernet/alteon/acenic.c
+++ b/drivers/net/ethernet/alteon/acenic.c
@@ -426,7 +426,7 @@ MODULE_PARM_DESC(max_rx_desc, "AceNIC/3C985/GA620 max number of receive descript
 MODULE_PARM_DESC(tx_ratio, "AceNIC/3C985/GA620 ratio of NIC memory used for TX/RX descriptors (range 0-63)");
 
 
-static const char version[] __devinitconst =
+static const char version[] =
   "acenic.c: v0.92 08/05/2002  Jes Sorensen, linux-acenic@SunSITE.dk\n"
   "                            http://home.cern.ch/~jes/gige/acenic.html\n";
 
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 576fd4b..88a4b72 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -702,7 +702,7 @@ struct atl1c_platform_patch {
 	u32 patch_flag;
 #define ATL1C_LINK_PATCH	0x1
 };
-static const struct atl1c_platform_patch plats[] __devinitconst = {
+static const struct atl1c_platform_patch plats[] = {
 {0x2060, 0xC1, 0x1019, 0x8152, 0x1},
 {0x2060, 0xC1, 0x1019, 0x2060, 0x1},
 {0x2060, 0xC1, 0x1019, 0xE000, 0x1},
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 9068312..4c0867f 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -2845,7 +2845,7 @@ static void atl2_force_ps(struct atl2_hw *hw)
  */
 
 #define ATL2_PARAM(X, desc) \
-    static const int __devinitconst X[ATL2_MAX_NIC + 1] = ATL2_PARAM_INIT; \
+    static const int X[ATL2_MAX_NIC + 1] = ATL2_PARAM_INIT; \
     MODULE_PARM(X, "1-" __MODULE_STRING(ATL2_MAX_NIC) "i"); \
     MODULE_PARM_DESC(X, desc);
 #else
diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index f809302..af41e86 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -479,7 +479,7 @@
 
 #include "de4x5.h"
 
-static const char version[] __devinitconst =
+static const char version[] =
 	KERN_INFO "de4x5.c:V0.546 2001/02/22 davies@maniac.ultranet.com\n";
 
 #define c_char const char
diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index f5b0abf..6166571 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -292,7 +292,7 @@ enum dmfe_CR6_bits {
 
 /* Global variable declaration ----------------------------- */
 static int printed_version;
-static const char version[] __devinitconst =
+static const char version[] =
 	"Davicom DM9xxx net driver, version " DRV_VERSION " (" DRV_RELDATE ")";
 
 static int dmfe_debug;
diff --git a/drivers/net/ethernet/dec/tulip/eeprom.c b/drivers/net/ethernet/dec/tulip/eeprom.c
index 4f92567..df5a892 100644
--- a/drivers/net/ethernet/dec/tulip/eeprom.c
+++ b/drivers/net/ethernet/dec/tulip/eeprom.c
@@ -79,7 +79,7 @@ static struct eeprom_fixup eeprom_fixups[] = {
   {NULL}};
 
 
-static const char *const block_name[] __devinitconst = {
+static const char *const block_name[] = {
 	"21140 non-MII",
 	"21140 MII PHY",
 	"21142 Serial PHY",
diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index 2034f3a..fc36d7b 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -205,7 +205,7 @@ enum uli526x_CR6_bits {
 
 /* Global variable declaration ----------------------------- */
 static int printed_version;
-static const char version[] __devinitconst =
+static const char version[] =
 	"ULi M5261/M5263 net driver, version " DRV_VERSION " (" DRV_RELDATE ")";
 
 static int uli526x_debug;
diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
index a5865dd..d146d50 100644
--- a/drivers/net/ethernet/dec/tulip/winbond-840.c
+++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
@@ -236,7 +236,7 @@ struct pci_id_info {
         int drv_flags;		/* Driver use, intended as capability flags. */
 };
 
-static const struct pci_id_info pci_id_tbl[] __devinitconst = {
+static const struct pci_id_info pci_id_tbl[] = {
 	{ 				/* Sometime a Level-One switch card. */
 	  "Winbond W89c840",	CanHaveMII | HasBrokenTx | FDXOnNoMII},
 	{ "Winbond W89c840",	CanHaveMII | HasBrokenTx},
diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethernet/dlink/sundance.c
index 618a314..40ebb13 100644
--- a/drivers/net/ethernet/dlink/sundance.c
+++ b/drivers/net/ethernet/dlink/sundance.c
@@ -102,7 +102,7 @@ static char *media[MAX_UNITS];
 #include <linux/mii.h>
 
 /* These identify the driver base version and may not be removed. */
-static const char version[] __devinitconst =
+static const char version[] =
 	KERN_INFO DRV_NAME ".c:v" DRV_VERSION " " DRV_RELDATE
 	" Written by Donald Becker\n";
 
@@ -218,7 +218,7 @@ enum {
 struct pci_id_info {
         const char *name;
 };
-static const struct pci_id_info pci_id_tbl[] __devinitconst = {
+static const struct pci_id_info pci_id_tbl[] = {
 	{"D-Link DFE-550TX FAST Ethernet Adapter"},
 	{"D-Link DFE-550FX 100Mbps Fiber-optics Adapter"},
 	{"D-Link DFE-580TX 4 port Server Adapter"},
diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
index b1dcd1c..d8a345c 100644
--- a/drivers/net/ethernet/fealnx.c
+++ b/drivers/net/ethernet/fealnx.c
@@ -92,7 +92,7 @@ static int full_duplex[MAX_UNITS] = { -1, -1, -1, -1, -1, -1, -1, -1 };
 #include <asm/byteorder.h>
 
 /* These identify the driver base version and may not be removed. */
-static const char version[] __devinitconst =
+static const char version[] =
 	KERN_INFO DRV_NAME ".c:v" DRV_VERSION " " DRV_RELDATE "\n";
 
 
@@ -150,7 +150,7 @@ struct chip_info {
 	int flags;
 };
 
-static const struct chip_info skel_netdrv_tbl[] __devinitconst = {
+static const struct chip_info skel_netdrv_tbl[] = {
  	{ "100/10M Ethernet PCI Adapter",	HAS_MII_XCVR },
 	{ "100/10M Ethernet PCI Adapter",	HAS_CHIP_XCVR },
 	{ "1000/100/10M Ethernet PCI Adapter",	HAS_MII_XCVR },
diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index bb2d723..eceebd1 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -127,7 +127,7 @@ static int full_duplex[MAX_UNITS];
 #define NATSEMI_RX_LIMIT	2046	/* maximum supported by hardware */
 
 /* These identify the driver base version and may not be removed. */
-static const char version[] __devinitconst =
+static const char version[] =
   KERN_INFO DRV_NAME " dp8381x driver, version "
       DRV_VERSION ", " DRV_RELDATE "\n"
   "  originally by Donald Becker <becker@scyld.com>\n"
diff --git a/drivers/net/ethernet/packetengines/hamachi.c b/drivers/net/ethernet/packetengines/hamachi.c
index 628de39..16bd6b4 100644
--- a/drivers/net/ethernet/packetengines/hamachi.c
+++ b/drivers/net/ethernet/packetengines/hamachi.c
@@ -166,7 +166,7 @@ static int tx_params[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
 #include <asm/unaligned.h>
 #include <asm/cache.h>
 
-static const char version[] __devinitconst =
+static const char version[] =
 KERN_INFO DRV_NAME ".c:v" DRV_VERSION " " DRV_RELDATE "  Written by Donald Becker\n"
 "   Some modifications by Eric kasten <kasten@nscl.msu.edu>\n"
 "   Further modifications by Keith Underwood <keithu@parl.clemson.edu>\n";
diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
index 3037a60..0abe8f5 100644
--- a/drivers/net/ethernet/packetengines/yellowfin.c
+++ b/drivers/net/ethernet/packetengines/yellowfin.c
@@ -106,7 +106,7 @@ static int gx_fix;
 #include <asm/io.h>
 
 /* These identify the driver base version and may not be removed. */
-static const char version[] __devinitconst =
+static const char version[] =
   KERN_INFO DRV_NAME ".c:v1.05  1/09/2001  Written by Donald Becker <becker@scyld.com>\n"
   "  (unofficial 2.4.x port, " DRV_VERSION ", " DRV_RELDATE ")\n";
 
diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index ccae0d7..90858ef 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -228,7 +228,7 @@ typedef enum {
 static const struct {
 	const char *name;
 	u32 hw_flags;
-} board_info[] __devinitconst = {
+} board_info[] = {
 	{ "RealTek RTL8139", RTL8139_CAPS },
 	{ "RealTek RTL8129", RTL8129_CAPS },
 };
diff --git a/drivers/net/ethernet/sis/sis190.c b/drivers/net/ethernet/sis/sis190.c
index 7e81755..0c64837 100644
--- a/drivers/net/ethernet/sis/sis190.c
+++ b/drivers/net/ethernet/sis/sis190.c
@@ -1618,7 +1618,7 @@ static int sis190_get_mac_addr_from_eeprom(struct pci_dev *pdev,
 static int sis190_get_mac_addr_from_apc(struct pci_dev *pdev,
 						  struct net_device *dev)
 {
-	static const u16 __devinitconst ids[] = { 0x0965, 0x0966, 0x0968 };
+	static const u16 ids[] = { 0x0965, 0x0966, 0x0968 };
 	struct sis190_private *tp = netdev_priv(dev);
 	struct pci_dev *isa_bridge;
 	u8 reg, tmp8;
diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index 5a799c9..09cd377 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -81,7 +81,7 @@
 #define SIS900_MODULE_NAME "sis900"
 #define SIS900_DRV_VERSION "v1.08.10 Apr. 2 2006"
 
-static const char version[] __devinitconst =
+static const char version[] =
 	KERN_INFO "sis900.c: " SIS900_DRV_VERSION "\n";
 
 static int max_interrupt_work = 40;
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index f745825..d8d3050 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -113,7 +113,7 @@ static const int multicast_filter_limit = 32;
 #include <linux/dmi.h>
 
 /* These identify the driver base version and may not be removed. */
-static const char version[] __devinitconst =
+static const char version[] =
 	"v1.10-LK" DRV_VERSION " " DRV_RELDATE " Written by Donald Becker";
 
 /* This driver was written to use PCI memory space. Some early versions
-- 
1.8.0
