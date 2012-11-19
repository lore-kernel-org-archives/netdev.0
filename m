From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 331/493] ethernet: remove use of __devinitdata
Date: Mon, 19 Nov 2012 13:24:40 -0500
Message-ID: <1353349642-3677-331-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	David Dillow <dave@thedillows.org>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	Russell King <linux@arm.linux.org.uk>,
	Florian Fainelli <florian@openwrt.org>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	e1000-devel@lists.sourceforge.net
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41468 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754077Ab2KSSeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:34:31 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devinitdata is no
longer needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de> 
Cc: David Dillow <dave@thedillows.org> 
Cc: Jay Cliburn <jcliburn@gmail.com> 
Cc: Chris Snook <chris.snook@gmail.com> 
Cc: Grant Grundler <grundler@parisc-linux.org> 
Cc: Russell King <linux@arm.linux.org.uk> 
Cc: Florian Fainelli <florian@openwrt.org> 
Cc: Anirudha Sarangi <anirudh@xilinx.com> 
Cc: John Linn <John.Linn@xilinx.com> 
Cc: netdev@vger.kernel.org 
Cc: linux-arm-kernel@lists.infradead.org 
Cc: e1000-devel@lists.sourceforge.net 
---
 drivers/net/ethernet/3com/3c509.c                 | 2 +-
 drivers/net/ethernet/3com/3c59x.c                 | 2 +-
 drivers/net/ethernet/3com/typhoon.c               | 2 +-
 drivers/net/ethernet/8390/hydra.c                 | 2 +-
 drivers/net/ethernet/8390/ne2k-pci.c              | 2 +-
 drivers/net/ethernet/8390/zorro8390.c             | 4 ++--
 drivers/net/ethernet/amd/a2065.c                  | 2 +-
 drivers/net/ethernet/amd/ariadne.c                | 2 +-
 drivers/net/ethernet/amd/declance.c               | 2 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_param.c  | 2 +-
 drivers/net/ethernet/atheros/atlx/atl1.c          | 2 +-
 drivers/net/ethernet/atheros/atlx/atl2.c          | 2 +-
 drivers/net/ethernet/broadcom/bnx2.c              | 4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  | 4 ++--
 drivers/net/ethernet/broadcom/cnic.c              | 2 +-
 drivers/net/ethernet/broadcom/tg3.c               | 4 ++--
 drivers/net/ethernet/dec/tulip/dmfe.c             | 2 +-
 drivers/net/ethernet/dec/tulip/eeprom.c           | 2 +-
 drivers/net/ethernet/dec/tulip/tulip_core.c       | 2 +-
 drivers/net/ethernet/dec/tulip/uli526x.c          | 2 +-
 drivers/net/ethernet/dlink/dl2k.c                 | 2 +-
 drivers/net/ethernet/i825xx/ether1.c              | 2 +-
 drivers/net/ethernet/ibm/emac/core.c              | 2 +-
 drivers/net/ethernet/ibm/ibmveth.c                | 2 +-
 drivers/net/ethernet/intel/e1000/e1000_param.c    | 2 +-
 drivers/net/ethernet/intel/e1000e/param.c         | 2 +-
 drivers/net/ethernet/intel/ixgb/ixgb_param.c      | 2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c         | 2 +-
 drivers/net/ethernet/micrel/ksz884x.c             | 2 +-
 drivers/net/ethernet/natsemi/ibmlana.c            | 2 +-
 drivers/net/ethernet/natsemi/natsemi.c            | 2 +-
 drivers/net/ethernet/rdc/r6040.c                  | 2 +-
 drivers/net/ethernet/seeq/ether3.c                | 2 +-
 drivers/net/ethernet/smsc/epic100.c               | 4 ++--
 drivers/net/ethernet/sun/cassini.c                | 4 ++--
 drivers/net/ethernet/sun/niu.c                    | 2 +-
 drivers/net/ethernet/sun/sungem.c                 | 2 +-
 drivers/net/ethernet/sun/sunvnet.c                | 2 +-
 drivers/net/ethernet/toshiba/tc35815.c            | 2 +-
 drivers/net/ethernet/xilinx/ll_temac_main.c       | 2 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 2 +-
 drivers/net/ethernet/xilinx/xilinx_emaclite.c     | 2 +-
 42 files changed, 48 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index 7e6466c..f85e082 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -92,7 +92,7 @@
 #include <asm/io.h>
 #include <asm/irq.h>
 
-static char version[] __devinitdata = DRV_NAME ".c:" DRV_VERSION " " DRV_RELDATE " becker@scyld.com\n";
+static char version[] = DRV_NAME ".c:" DRV_VERSION " " DRV_RELDATE " becker@scyld.com\n";
 
 #ifdef EL3_DEBUG
 static int el3_debug = EL3_DEBUG;
diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 7e421f3..56fdc39 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -277,7 +277,7 @@ static struct vortex_chip_info {
 	int flags;
 	int drv_flags;
 	int io_size;
-} vortex_info_tbl[] __devinitdata = {
+} vortex_info_tbl[] = {
 	{"3c590 Vortex 10Mbps",
 	 PCI_USES_MASTER, IS_VORTEX, 32, },
 	{"3c592 EISA 10Mbps Demon/Vortex",					/* AKPM: from Don's 3c59x_cb.c 0.49H */
diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 6d2efdd..4077af1 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -168,7 +168,7 @@ enum typhoon_cards {
 };
 
 /* directly indexed by enum typhoon_cards, above */
-static struct typhoon_card_info typhoon_card_info[] __devinitdata = {
+static struct typhoon_card_info typhoon_card_info[] = {
 	{ "3Com Typhoon (3C990-TX)",
 		TYPHOON_CRYPTO_NONE},
 	{ "3Com Typhoon (3CR990-TX-95)",
diff --git a/drivers/net/ethernet/8390/hydra.c b/drivers/net/ethernet/8390/hydra.c
index cf638ba..2743bb9 100644
--- a/drivers/net/ethernet/8390/hydra.c
+++ b/drivers/net/ethernet/8390/hydra.c
@@ -67,7 +67,7 @@ static void hydra_block_output(struct net_device *dev, int count,
 			       const unsigned char *buf, int start_page);
 static void __devexit hydra_remove_one(struct zorro_dev *z);
 
-static struct zorro_device_id hydra_zorro_tbl[] __devinitdata = {
+static struct zorro_device_id hydra_zorro_tbl[] = {
     { ZORRO_PROD_HYDRA_SYSTEMS_AMIGANET },
     { 0 }
 };
diff --git a/drivers/net/ethernet/8390/ne2k-pci.c b/drivers/net/ethernet/8390/ne2k-pci.c
index cdea7e1..f734d0f 100644
--- a/drivers/net/ethernet/8390/ne2k-pci.c
+++ b/drivers/net/ethernet/8390/ne2k-pci.c
@@ -119,7 +119,7 @@ enum ne2k_pci_chipsets {
 static struct {
 	char *name;
 	int flags;
-} pci_clone_list[] __devinitdata = {
+} pci_clone_list[] = {
 	{"RealTek RTL-8029", REALTEK_FDX},
 	{"Winbond 89C940", 0},
 	{"Compex RL2000", 0},
diff --git a/drivers/net/ethernet/8390/zorro8390.c b/drivers/net/ethernet/8390/zorro8390.c
index 3328eff..674efc5 100644
--- a/drivers/net/ethernet/8390/zorro8390.c
+++ b/drivers/net/ethernet/8390/zorro8390.c
@@ -75,7 +75,7 @@ static struct card_info {
 	zorro_id id;
 	const char *name;
 	unsigned int offset;
-} cards[] __devinitdata = {
+} cards[] = {
 	{ ZORRO_PROD_VILLAGE_TRONIC_ARIADNE2, "Ariadne II", 0x0600 },
 	{ ZORRO_PROD_INDIVIDUAL_COMPUTERS_X_SURF, "X-Surf", 0x8600 },
 };
@@ -264,7 +264,7 @@ static void __devexit zorro8390_remove_one(struct zorro_dev *z)
 	free_netdev(dev);
 }
 
-static struct zorro_device_id zorro8390_zorro_tbl[] __devinitdata = {
+static struct zorro_device_id zorro8390_zorro_tbl[] = {
 	{ ZORRO_PROD_VILLAGE_TRONIC_ARIADNE2, },
 	{ ZORRO_PROD_INDIVIDUAL_COMPUTERS_X_SURF, },
 	{ 0 }
diff --git a/drivers/net/ethernet/amd/a2065.c b/drivers/net/ethernet/amd/a2065.c
index 51d917f..2784c2d 100644
--- a/drivers/net/ethernet/amd/a2065.c
+++ b/drivers/net/ethernet/amd/a2065.c
@@ -644,7 +644,7 @@ static int a2065_init_one(struct zorro_dev *z,
 static void __devexit a2065_remove_one(struct zorro_dev *z);
 
 
-static struct zorro_device_id a2065_zorro_tbl[] __devinitdata = {
+static struct zorro_device_id a2065_zorro_tbl[] = {
 	{ ZORRO_PROD_CBM_A2065_1 },
 	{ ZORRO_PROD_CBM_A2065_2 },
 	{ ZORRO_PROD_AMERISTAR_A2065 },
diff --git a/drivers/net/ethernet/amd/ariadne.c b/drivers/net/ethernet/amd/ariadne.c
index f9c43f4..08147ae 100644
--- a/drivers/net/ethernet/amd/ariadne.c
+++ b/drivers/net/ethernet/amd/ariadne.c
@@ -692,7 +692,7 @@ static void __devexit ariadne_remove_one(struct zorro_dev *z)
 	free_netdev(dev);
 }
 
-static struct zorro_device_id ariadne_zorro_tbl[] __devinitdata = {
+static struct zorro_device_id ariadne_zorro_tbl[] = {
 	{ ZORRO_PROD_VILLAGE_TRONIC_ARIADNE },
 	{ 0 }
 };
diff --git a/drivers/net/ethernet/amd/declance.c b/drivers/net/ethernet/amd/declance.c
index a9380b9..baca0bd 100644
--- a/drivers/net/ethernet/amd/declance.c
+++ b/drivers/net/ethernet/amd/declance.c
@@ -72,7 +72,7 @@
 #include <asm/dec/machtype.h>
 #include <asm/dec/system.h>
 
-static char version[] __devinitdata =
+static char version[] =
 "declance.c: v0.011 by Linux MIPS DECstation task force\n";
 
 MODULE_AUTHOR("Linux MIPS DECstation task force");
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_param.c b/drivers/net/ethernet/atheros/atl1e/atl1e_param.c
index b2d740a..ea54cce 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_param.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_param.c
@@ -40,7 +40,7 @@
 #define ATL1E_PARAM_INIT { [0 ... ATL1E_MAX_NIC] = OPTION_UNSET }
 
 #define ATL1E_PARAM(x, desc) \
-	static int __devinitdata x[ATL1E_MAX_NIC + 1] = ATL1E_PARAM_INIT; \
+	static int x[ATL1E_MAX_NIC + 1] = ATL1E_PARAM_INIT; \
 	static unsigned int num_##x; \
 	module_param_array_named(x, x, int, &num_##x, 0); \
 	MODULE_PARM_DESC(x, desc);
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 736c022..714552d 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -113,7 +113,7 @@ static const struct ethtool_ops atl1_ethtool_ops;
  *
  * Default Value: 100 (200us)
  */
-static int __devinitdata int_mod_timer[ATL1_MAX_NIC+1] = ATL1_PARAM_INIT;
+static int int_mod_timer[ATL1_MAX_NIC+1] = ATL1_PARAM_INIT;
 static unsigned int num_int_mod_timer;
 module_param_array_named(int_mod_timer, int_mod_timer, int,
 	&num_int_mod_timer, 0);
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 2a5f117..9068312 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -2850,7 +2850,7 @@ static void atl2_force_ps(struct atl2_hw *hw)
     MODULE_PARM_DESC(X, desc);
 #else
 #define ATL2_PARAM(X, desc) \
-    static int __devinitdata X[ATL2_MAX_NIC+1] = ATL2_PARAM_INIT; \
+    static int X[ATL2_MAX_NIC+1] = ATL2_PARAM_INIT; \
     static unsigned int num_##X; \
     module_param_array_named(X, X, int, &num_##X, 0); \
     MODULE_PARM_DESC(X, desc);
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index d9388a0..30a3c0d 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -71,7 +71,7 @@
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT  (5*HZ)
 
-static char version[] __devinitdata =
+static char version[] =
 	"Broadcom NetXtreme II Gigabit Ethernet Driver " DRV_MODULE_NAME " v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
 MODULE_AUTHOR("Michael Chan <mchan@broadcom.com>");
@@ -106,7 +106,7 @@ typedef enum {
 /* indexed by board_t, above */
 static struct {
 	char *name;
-} board_info[] __devinitdata = {
+} board_info[] = {
 	{ "Broadcom NetXtreme II BCM5706 1000Base-T" },
 	{ "HP NC370T Multifunction Gigabit Server Adapter" },
 	{ "HP NC370i Multifunction Gigabit Server Adapter" },
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 0719c20..cf165d3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -79,7 +79,7 @@
 /* Time in jiffies before concluding the transmitter is hung */
 #define TX_TIMEOUT		(5*HZ)
 
-static char version[] __devinitdata =
+static char version[] =
 	"Broadcom NetXtreme II 5771x/578xx 10/20-Gigabit Ethernet Driver "
 	DRV_MODULE_NAME " " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
@@ -149,7 +149,7 @@ enum bnx2x_board_type {
 /* indexed by board_type, above */
 static struct {
 	char *name;
-} board_info[] __devinitdata = {
+} board_info[] = {
 	{ "Broadcom NetXtreme II BCM57710 10 Gigabit PCIe [Everest]" },
 	{ "Broadcom NetXtreme II BCM57711 10 Gigabit PCIe" },
 	{ "Broadcom NetXtreme II BCM57711E 10 Gigabit PCIe" },
diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index cc8434f..3b825f4 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -53,7 +53,7 @@
 
 #define DRV_MODULE_NAME		"cnic"
 
-static char version[] __devinitdata =
+static char version[] =
 	"Broadcom NetXtreme II CNIC Driver " DRV_MODULE_NAME " v" CNIC_MODULE_VERSION " (" CNIC_MODULE_RELDATE ")\n";
 
 MODULE_AUTHOR("Michael Chan <mchan@broadcom.com> and John(Zongxi) "
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 875887e..ec08654 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -211,7 +211,7 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 #define FIRMWARE_TG3TSO		"tigon/tg3_tso.bin"
 #define FIRMWARE_TG3TSO5	"tigon/tg3_tso5.bin"
 
-static char version[] __devinitdata =
+static char version[] =
 	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")";
 
 MODULE_AUTHOR("David S. Miller (davem@redhat.com) and Jeff Garzik (jgarzik@pobox.com)");
@@ -13474,7 +13474,7 @@ struct subsys_tbl_ent {
 	u32 phy_id;
 };
 
-static struct subsys_tbl_ent subsys_id_to_phy_id[] __devinitdata = {
+static struct subsys_tbl_ent subsys_id_to_phy_id[] = {
 	/* Broadcom boards. */
 	{ TG3PCI_SUBVENDOR_ID_BROADCOM,
 	  TG3PCI_SUBDEVICE_ID_BROADCOM_95700A6, TG3_PHY_ID_BCM5401 },
diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index 204da23..f5b0abf 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -291,7 +291,7 @@ enum dmfe_CR6_bits {
 };
 
 /* Global variable declaration ----------------------------- */
-static int __devinitdata printed_version;
+static int printed_version;
 static const char version[] __devinitconst =
 	"Davicom DM9xxx net driver, version " DRV_VERSION " (" DRV_RELDATE ")";
 
diff --git a/drivers/net/ethernet/dec/tulip/eeprom.c b/drivers/net/ethernet/dec/tulip/eeprom.c
index 8692a72..4f92567 100644
--- a/drivers/net/ethernet/dec/tulip/eeprom.c
+++ b/drivers/net/ethernet/dec/tulip/eeprom.c
@@ -26,7 +26,7 @@
    */
 
 /* Known cards that have old-style EEPROMs. */
-static struct eeprom_fixup eeprom_fixups[] __devinitdata = {
+static struct eeprom_fixup eeprom_fixups[] = {
   {"Asante", 0, 0, 0x94, {0x1e00, 0x0000, 0x0800, 0x0100, 0x018c,
 			  0x0000, 0x0000, 0xe078, 0x0001, 0x0050, 0x0018 }},
   {"SMC9332DST", 0, 0, 0xC0, { 0x1e00, 0x0000, 0x0800, 0x041f,
diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index 4eb705f..fa15d34 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -37,7 +37,7 @@
 #include <asm/prom.h>
 #endif
 
-static char version[] __devinitdata =
+static char version[] =
 	"Linux Tulip driver version " DRV_VERSION " (" DRV_RELDATE ")\n";
 
 /* A few user-configurable values. */
diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index b1aa454..2034f3a 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -204,7 +204,7 @@ enum uli526x_CR6_bits {
 };
 
 /* Global variable declaration ----------------------------- */
-static int __devinitdata printed_version;
+static int printed_version;
 static const char version[] __devinitconst =
 	"ULi M5261/M5263 net driver, version " DRV_VERSION " (" DRV_RELDATE ")";
 
diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index eba0822..398d730 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -23,7 +23,7 @@
 #define dr16(reg)	ioread16(ioaddr + (reg))
 #define dr8(reg)	ioread8(ioaddr + (reg))
 
-static char version[] __devinitdata =
+static char version[] =
       KERN_INFO DRV_NAME " " DRV_VERSION " " DRV_RELDATE "\n";
 #define MAX_UNITS 8
 static int mtu[MAX_UNITS];
diff --git a/drivers/net/ethernet/i825xx/ether1.c b/drivers/net/ethernet/i825xx/ether1.c
index d65dd24..44ca732 100644
--- a/drivers/net/ethernet/i825xx/ether1.c
+++ b/drivers/net/ethernet/i825xx/ether1.c
@@ -72,7 +72,7 @@ static void ether1_timeout(struct net_device *dev);
 
 /* ------------------------------------------------------------------------- */
 
-static char version[] __devinitdata = "ether1 ethernet driver (c) 2000 Russell King v1.07\n";
+static char version[] = "ether1 ethernet driver (c) 2000 Russell King v1.07\n";
 
 #define BUS_16 16
 #define BUS_8  8
diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 914413f..5b87af7 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -2323,7 +2323,7 @@ static int emac_of_bus_notify(struct notifier_block *nb,
 	return 0;
 }
 
-static struct notifier_block emac_of_bus_notifier __devinitdata = {
+static struct notifier_block emac_of_bus_notifier = {
 	.notifier_call = emac_of_bus_notify
 };
 
diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index f9fa90b..2b4daf7 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1593,7 +1593,7 @@ static int ibmveth_resume(struct device *dev)
 	return 0;
 }
 
-static struct vio_device_id ibmveth_device_table[] __devinitdata = {
+static struct vio_device_id ibmveth_device_table[] = {
 	{ "network", "IBM,l-lan"},
 	{ "", "" }
 };
diff --git a/drivers/net/ethernet/intel/e1000/e1000_param.c b/drivers/net/ethernet/intel/e1000/e1000_param.c
index 605a0f0..4e19aa0 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_param.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_param.c
@@ -45,7 +45,7 @@
 
 #define E1000_PARAM_INIT { [0 ... E1000_MAX_NIC] = OPTION_UNSET }
 #define E1000_PARAM(X, desc) \
-	static int __devinitdata X[E1000_MAX_NIC+1] = E1000_PARAM_INIT; \
+	static int X[E1000_MAX_NIC+1] = E1000_PARAM_INIT; \
 	static unsigned int num_##X; \
 	module_param_array_named(X, X, int, &num_##X, 0); \
 	MODULE_PARM_DESC(X, desc);
diff --git a/drivers/net/ethernet/intel/e1000e/param.c b/drivers/net/ethernet/intel/e1000e/param.c
index 62bf36c..7e0c260 100644
--- a/drivers/net/ethernet/intel/e1000e/param.c
+++ b/drivers/net/ethernet/intel/e1000e/param.c
@@ -57,7 +57,7 @@ MODULE_PARM_DESC(copybreak,
 
 #define E1000_PARAM_INIT { [0 ... E1000_MAX_NIC] = OPTION_UNSET }
 #define E1000_PARAM(X, desc)					\
-	static int __devinitdata X[E1000_MAX_NIC+1]		\
+	static int X[E1000_MAX_NIC+1]		\
 		= E1000_PARAM_INIT;				\
 	static unsigned int num_##X;				\
 	module_param_array_named(X, X, int, &num_##X, 0);	\
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_param.c b/drivers/net/ethernet/intel/ixgb/ixgb_param.c
index 4f3a9aa..04a6064 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_param.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_param.c
@@ -47,7 +47,7 @@
 
 #define IXGB_PARAM_INIT { [0 ... IXGB_MAX_NIC] = OPTION_UNSET }
 #define IXGB_PARAM(X, desc)					\
-	static int __devinitdata X[IXGB_MAX_NIC+1]		\
+	static int X[IXGB_MAX_NIC+1]		\
 		= IXGB_PARAM_INIT;				\
 	static unsigned int num_##X = 0;			\
 	module_param_array_named(X, X, int, &num_##X, 0);	\
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 8f744f0..340551e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -98,7 +98,7 @@ MODULE_PARM_DESC(log_num_mgm_entry_size, "log mgm size, that defines the num"
 #define HCA_GLOBAL_CAP_MASK            0
 #define PF_CONTEXT_BEHAVIOUR_MASK      0
 
-static char mlx4_version[] __devinitdata =
+static char mlx4_version[] =
 	DRV_NAME ": Mellanox ConnectX core driver v"
 	DRV_VERSION " (" DRV_RELDATE ")\n";
 
diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index 2f4d051..97082e1 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -1487,7 +1487,7 @@ struct dev_priv {
 #define DRV_VERSION		"1.0.0"
 #define DRV_RELDATE		"Feb 8, 2010"
 
-static char version[] __devinitdata =
+static char version[] =
 	"Micrel " DEVICE_NAME " " DRV_VERSION " (" DRV_RELDATE ")";
 
 static u8 DEFAULT_MAC_ADDRESS[] = { 0x00, 0x10, 0xA1, 0x88, 0x42, 0x01 };
diff --git a/drivers/net/ethernet/natsemi/ibmlana.c b/drivers/net/ethernet/natsemi/ibmlana.c
index 076bc45..923e640 100644
--- a/drivers/net/ethernet/natsemi/ibmlana.c
+++ b/drivers/net/ethernet/natsemi/ibmlana.c
@@ -900,7 +900,7 @@ static short ibmlana_adapter_ids[] __initdata = {
 	0x0000
 };
 
-static char *ibmlana_adapter_names[] __devinitdata = {
+static char *ibmlana_adapter_names[] = {
 	"IBM LAN Adapter/A",
 	NULL
 };
diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index 63b94c3..bb2d723 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -242,7 +242,7 @@ static struct {
 	const char *name;
 	unsigned long flags;
 	unsigned int eeprom_size;
-} natsemi_pci_info[] __devinitdata = {
+} natsemi_pci_info[] = {
 	{ "Aculab E1/T1 PMXc cPCI carrier card", NATSEMI_FLAG_IGNORE_PHY, 128 },
 	{ "NatSemi DP8381[56]", 0, 24 },
 };
diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index f0bba8c..6d09efe 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -206,7 +206,7 @@ struct r6040_private {
 	int old_duplex;
 };
 
-static char version[] __devinitdata = DRV_NAME
+static char version[] = DRV_NAME
 	": RDC R6040 NAPI net driver,"
 	"version "DRV_VERSION " (" DRV_RELDATE ")";
 
diff --git a/drivers/net/ethernet/seeq/ether3.c b/drivers/net/ethernet/seeq/ether3.c
index d968f7b..9693b9b 100644
--- a/drivers/net/ethernet/seeq/ether3.c
+++ b/drivers/net/ethernet/seeq/ether3.c
@@ -67,7 +67,7 @@
 #include <asm/ecard.h>
 #include <asm/io.h>
 
-static char version[] __devinitdata = "ether3 ethernet driver (c) 1995-2000 R.M.King v1.17\n";
+static char version[] = "ether3 ethernet driver (c) 1995-2000 R.M.King v1.17\n";
 
 #include "ether3.h"
 
diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index d5ef36f..9ca0308 100644
--- a/drivers/net/ethernet/smsc/epic100.c
+++ b/drivers/net/ethernet/smsc/epic100.c
@@ -90,9 +90,9 @@ static int rx_copybreak;
 #include <asm/byteorder.h>
 
 /* These identify the driver base version and may not be removed. */
-static char version[] __devinitdata =
+static char version[] =
 DRV_NAME ".c:v1.11 1/7/2001 Written by Donald Becker <becker@scyld.com>\n";
-static char version2[] __devinitdata =
+static char version2[] =
 "  (unofficial 2.4.x kernel port, version " DRV_VERSION ", " DRV_RELDATE ")\n";
 
 MODULE_AUTHOR("Donald Becker <becker@scyld.com>");
diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index 9c7f797..ef2f21a 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -185,7 +185,7 @@
 #define CAS_RESET_SPARE                 3
 #endif
 
-static char version[] __devinitdata =
+static char version[] =
 	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
 static int cassini_debug = -1;	/* -1 == use CAS_DEF_MSG_ENABLE as value */
@@ -222,7 +222,7 @@ static int link_transition_timeout;
 
 
 
-static u16 link_modes[] __devinitdata = {
+static u16 link_modes[] = {
 	BMCR_ANENABLE,			 /* 0 : autoneg */
 	0,				 /* 1 : 10bt half duplex */
 	BMCR_SPEED100,			 /* 2 : 100bt half duplex */
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 926ed9f..7c604a6 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -38,7 +38,7 @@
 #define DRV_MODULE_VERSION	"1.1"
 #define DRV_MODULE_RELDATE	"Apr 22, 2010"
 
-static char version[] __devinitdata =
+static char version[] =
 	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
 MODULE_AUTHOR("David S. Miller (davem@davemloft.net)");
diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index fd0e61d..c7bc056 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -77,7 +77,7 @@
 #define DRV_VERSION	"1.0"
 #define DRV_AUTHOR	"David S. Miller <davem@redhat.com>"
 
-static char version[] __devinitdata =
+static char version[] =
         DRV_NAME ".c:v" DRV_VERSION " " DRV_AUTHOR "\n";
 
 MODULE_AUTHOR(DRV_AUTHOR);
diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index d94563b..2852b70 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -25,7 +25,7 @@
 #define DRV_MODULE_VERSION	"1.0"
 #define DRV_MODULE_RELDATE	"June 25, 2007"
 
-static char version[] __devinitdata =
+static char version[] =
 	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 MODULE_AUTHOR("David S. Miller (davem@davemloft.net)");
 MODULE_DESCRIPTION("Sun LDOM virtual network driver");
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 0dafa25..6fc4f95 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -60,7 +60,7 @@ enum tc35815_chiptype {
 /* indexed by tc35815_chiptype, above */
 static const struct {
 	const char *name;
-} chip_info[] __devinitdata = {
+} chip_info[] = {
 	{ "TOSHIBA TC35815CF 10/100BaseTX" },
 	{ "TOSHIBA TC35815 with Wake on LAN" },
 	{ "TOSHIBA TC35815/TX4939" },
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index c7375a8..6039f15 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -1163,7 +1163,7 @@ static int __devexit temac_of_remove(struct platform_device *op)
 	return 0;
 }
 
-static struct of_device_id temac_of_match[] __devinitdata = {
+static struct of_device_id temac_of_match[] = {
 	{ .compatible = "xlnx,xps-ll-temac-1.01.b", },
 	{ .compatible = "xlnx,xps-ll-temac-2.00.a", },
 	{ .compatible = "xlnx,xps-ll-temac-2.02.a", },
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index b8c9a33..4fb86d4 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -48,7 +48,7 @@
 #define AXIENET_REGS_N		32
 
 /* Match table for of_platform binding */
-static struct of_device_id axienet_of_match[] __devinitdata = {
+static struct of_device_id axienet_of_match[] = {
 	{ .compatible = "xlnx,axi-ethernet-1.00.a", },
 	{ .compatible = "xlnx,axi-ethernet-1.01.a", },
 	{ .compatible = "xlnx,axi-ethernet-2.01.a", },
diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 8d4f32d..f67922d 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -1280,7 +1280,7 @@ static struct net_device_ops xemaclite_netdev_ops = {
 };
 
 /* Match table for OF platform binding */
-static struct of_device_id xemaclite_of_match[] __devinitdata = {
+static struct of_device_id xemaclite_of_match[] = {
 	{ .compatible = "xlnx,opb-ethernetlite-1.01.a", },
 	{ .compatible = "xlnx,opb-ethernetlite-1.01.b", },
 	{ .compatible = "xlnx,xps-ethernetlite-1.00.a", },
-- 
1.8.0
