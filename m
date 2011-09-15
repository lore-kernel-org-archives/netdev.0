From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 19/27] Initconst section fixes for drivers/net
Date: Thu, 15 Sep 2011 13:09:46 -0700
Message-ID: <1316117394-21666-20-git-send-email-andi@firstfloor.org>
References: <1316117394-21666-1-git-send-email-andi@firstfloor.org>
Cc: Andi Kleen <ak@linux.intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1316117394-21666-1-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@linux.intel.com>

Cc: davem@davemloft.net
Cc: netdev@vger.kernel.org
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 drivers/net/8139too.c           |    2 +-
 drivers/net/atlx/atl2.c         |    2 +-
 drivers/net/can/slcan.c         |    2 +-
 drivers/net/can/vcan.c          |    2 +-
 drivers/net/fealnx.c            |    2 +-
 drivers/net/hamradio/6pack.c    |    6 +++---
 drivers/net/hamradio/bpqether.c |    2 +-
 drivers/net/hamradio/mkiss.c    |    6 +++---
 drivers/net/hamradio/scc.c      |    2 +-
 drivers/net/hamradio/yam.c      |    2 +-
 drivers/net/ne3210.c            |    2 +-
 drivers/net/qlcnic/qlcnic_hw.c  |    2 +-
 drivers/net/sis190.c            |    2 +-
 drivers/net/starfire.c          |    2 +-
 drivers/net/sundance.c          |    2 +-
 drivers/net/tokenring/smctr.c   |    2 +-
 drivers/net/tulip/eeprom.c      |    2 +-
 drivers/net/tulip/winbond-840.c |    2 +-
 drivers/net/wan/z85230.c        |    2 +-
 19 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index c2672c6..f6e9974 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -228,7 +228,7 @@ typedef enum {
 static const struct {
 	const char *name;
 	u32 hw_flags;
-} board_info[] __devinitdata = {
+} board_info[] __devinitconst = {
 	{ "RealTek RTL8139", RTL8139_CAPS },
 	{ "RealTek RTL8129", RTL8129_CAPS },
 };
diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index d4f7dda..d627d46 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -2857,7 +2857,7 @@ static void atl2_force_ps(struct atl2_hw *hw)
  */
 
 #define ATL2_PARAM(X, desc) \
-    static const int __devinitdata X[ATL2_MAX_NIC + 1] = ATL2_PARAM_INIT; \
+    static const int __devinitconst X[ATL2_MAX_NIC + 1] = ATL2_PARAM_INIT; \
     MODULE_PARM(X, "1-" __MODULE_STRING(ATL2_MAX_NIC) "i"); \
     MODULE_PARM_DESC(X, desc);
 #else
diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index 4b70b7e..775c0fd 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -59,7 +59,7 @@
 #include <linux/kernel.h>
 #include <linux/can.h>
 
-static __initdata const char banner[] =
+static __initconst const char banner[] =
 	KERN_INFO "slcan: serial line CAN interface driver\n";
 
 MODULE_ALIAS_LDISC(N_SLCAN);
diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index a30b8f4..b477728 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -51,7 +51,7 @@
 #include <linux/slab.h>
 #include <net/rtnetlink.h>
 
-static __initdata const char banner[] =
+static __initconst const char banner[] =
 	KERN_INFO "vcan: Virtual CAN interface driver\n";
 
 MODULE_DESCRIPTION("virtual CAN interface");
diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index fa8677c..196356f 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -150,7 +150,7 @@ struct chip_info {
 	int flags;
 };
 
-static const struct chip_info skel_netdrv_tbl[] __devinitdata = {
+static const struct chip_info skel_netdrv_tbl[] __devinitconst = {
  	{ "100/10M Ethernet PCI Adapter",	HAS_MII_XCVR },
 	{ "100/10M Ethernet PCI Adapter",	HAS_CHIP_XCVR },
 	{ "1000/100/10M Ethernet PCI Adapter",	HAS_MII_XCVR },
diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 2a5a34d..c0e4ac6 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -812,9 +812,9 @@ static struct tty_ldisc_ops sp_ldisc = {
 
 /* Initialize 6pack control device -- register 6pack line discipline */
 
-static const char msg_banner[]  __initdata = KERN_INFO \
+static const char msg_banner[]  __initconst = KERN_INFO \
 	"AX.25: 6pack driver, " SIXPACK_VERSION "\n";
-static const char msg_regfail[] __initdata = KERN_ERR  \
+static const char msg_regfail[] __initconst = KERN_ERR  \
 	"6pack: can't register line discipline (err = %d)\n";
 
 static int __init sixpack_init_driver(void)
@@ -830,7 +830,7 @@ static int __init sixpack_init_driver(void)
 	return status;
 }
 
-static const char msg_unregfail[] __exitdata = KERN_ERR \
+static char msg_unregfail[] __exitdata = KERN_ERR \
 	"6pack: can't unregister line discipline (err = %d)\n";
 
 static void __exit sixpack_exit_driver(void)
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index 18d8aff..ddb8d52 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -88,7 +88,7 @@
 
 #include <linux/bpqether.h>
 
-static const char banner[] __initdata = KERN_INFO \
+static const char banner[] __initconst = KERN_INFO \
 	"AX.25: bpqether driver version 004\n";
 
 static char bcast_addr[6]={0xFF,0xFF,0xFF,0xFF,0xFF,0xFF};
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index bc02968..f94ed24 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -998,9 +998,9 @@ static struct tty_ldisc_ops ax_ldisc = {
 	.write_wakeup	= mkiss_write_wakeup
 };
 
-static const char banner[] __initdata = KERN_INFO \
+static const char banner[] __initconst = KERN_INFO \
 	"mkiss: AX.25 Multikiss, Hans Albas PE1AYX\n";
-static const char msg_regfail[] __initdata = KERN_ERR \
+static const char msg_regfail[] __initconst = KERN_ERR \
 	"mkiss: can't register line discipline (err = %d)\n";
 
 static int __init mkiss_init_driver(void)
@@ -1016,7 +1016,7 @@ static int __init mkiss_init_driver(void)
 	return status;
 }
 
-static const char msg_unregfail[] __exitdata = KERN_ERR \
+static char msg_unregfail[] __exitdata = KERN_ERR \
 	"mkiss: can't unregister line discipline (err = %d)\n";
 
 static void __exit mkiss_exit_driver(void)
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index 3365581..bdda73e 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -183,7 +183,7 @@
 
 #include "z8530.h"
 
-static const char banner[] __initdata = KERN_INFO \
+static const char banner[] __initconst = KERN_INFO \
 	"AX.25: Z8530 SCC driver version "VERSION".dl1bke\n";
 
 static void t_dwait(unsigned long);
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 96a98d2..856ce96 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -77,7 +77,7 @@
 /* --------------------------------------------------------------------- */
 
 static const char yam_drvname[] = "yam";
-static const char yam_drvinfo[] __initdata = KERN_INFO \
+static const char yam_drvinfo[] __initconst = KERN_INFO \
 	"YAM driver version 0.8 by F1OAT/F6FBB\n";
 
 /* --------------------------------------------------------------------- */
diff --git a/drivers/net/ne3210.c b/drivers/net/ne3210.c
index 243ed2a..34a89dd 100644
--- a/drivers/net/ne3210.c
+++ b/drivers/net/ne3210.c
@@ -82,7 +82,7 @@ static void ne3210_block_output(struct net_device *dev, int count, const unsigne
 
 static unsigned char irq_map[] __initdata = {15, 12, 11, 10, 9, 7, 5, 3};
 static unsigned int shmem_map[] __initdata = {0xff0, 0xfe0, 0xfff0, 0xd8, 0xffe0, 0xffc0, 0xd0, 0x0};
-static const char *ifmap[] __initdata = {"UTP", "?", "BNC", "AUI"};
+static const char * const ifmap[] __initconst = {"UTP", "?", "BNC", "AUI"};
 static int ifmap_val[] __initdata = {
 		IF_PORT_10BASET,
 		IF_PORT_UNKNOWN,
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 4055c21..c12edb9 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -38,7 +38,7 @@ static inline void writeq(u64 val, void __iomem *addr)
 }
 #endif
 
-static const struct crb_128M_2M_block_map
+static struct crb_128M_2M_block_map
 crb_128M_2M_map[64] __cacheline_aligned_in_smp = {
     {{{0, 0,         0,         0} } },		/* 0: PCI */
     {{{1, 0x0100000, 0x0102000, 0x120000},	/* 1: PCIE */
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 3c0f131..17f8b02 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1624,7 +1624,7 @@ static int __devinit sis190_get_mac_addr_from_eeprom(struct pci_dev *pdev,
 static int __devinit sis190_get_mac_addr_from_apc(struct pci_dev *pdev,
 						  struct net_device *dev)
 {
-	static const u16 __devinitdata ids[] = { 0x0965, 0x0966, 0x0968 };
+	static const u16 __devinitconst ids[] = { 0x0965, 0x0966, 0x0968 };
 	struct sis190_private *tp = netdev_priv(dev);
 	struct pci_dev *isa_bridge;
 	u8 reg, tmp8;
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 7ae1f99..e77819d 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -308,7 +308,7 @@ MODULE_DEVICE_TABLE(pci, starfire_pci_tbl);
 static const struct chip_info {
 	const char *name;
 	int drv_flags;
-} netdrv_tbl[] __devinitdata = {
+} netdrv_tbl[] __devinitconst = {
 	{ "Adaptec Starfire 6915", CanHaveMII },
 };
 
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 4793df8..44c9849 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -218,7 +218,7 @@ enum {
 struct pci_id_info {
         const char *name;
 };
-static const struct pci_id_info pci_id_tbl[] __devinitdata = {
+static const struct pci_id_info pci_id_tbl[] __devinitconst = {
 	{"D-Link DFE-550TX FAST Ethernet Adapter"},
 	{"D-Link DFE-550FX 100Mbps Fiber-optics Adapter"},
 	{"D-Link DFE-580TX 4 port Server Adapter"},
diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
index d9044ab..d83ee07 100644
--- a/drivers/net/tokenring/smctr.c
+++ b/drivers/net/tokenring/smctr.c
@@ -60,7 +60,7 @@
 
 #include "smctr.h"               /* Our Stuff */
 
-static const char version[] __initdata =
+static const char version[] __initconst =
 	KERN_INFO "smctr.c: v1.4 7/12/00 by jschlst@samba.org\n";
 static const char cardname[] = "smctr";
 
diff --git a/drivers/net/tulip/eeprom.c b/drivers/net/tulip/eeprom.c
index fa5eee9..1f222f4 100644
--- a/drivers/net/tulip/eeprom.c
+++ b/drivers/net/tulip/eeprom.c
@@ -81,7 +81,7 @@ static struct eeprom_fixup eeprom_fixups[] __devinitdata = {
   {NULL}};
 
 
-static const char *block_name[] __devinitdata = {
+static const char *const block_name[] __devinitconst = {
 	"21140 non-MII",
 	"21140 MII PHY",
 	"21142 Serial PHY",
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 862eadf..3eee1e6 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -236,7 +236,7 @@ struct pci_id_info {
         int drv_flags;		/* Driver use, intended as capability flags. */
 };
 
-static const struct pci_id_info pci_id_tbl[] __devinitdata = {
+static const struct pci_id_info pci_id_tbl[] __devinitconst = {
 	{ 				/* Sometime a Level-One switch card. */
 	  "Winbond W89c840",	CanHaveMII | HasBrokenTx | FDXOnNoMII},
 	{ "Winbond W89c840",	CanHaveMII | HasBrokenTx},
diff --git a/drivers/net/wan/z85230.c b/drivers/net/wan/z85230.c
index 0e57690..feacc3b 100644
--- a/drivers/net/wan/z85230.c
+++ b/drivers/net/wan/z85230.c
@@ -1775,7 +1775,7 @@ EXPORT_SYMBOL(z8530_queue_xmit);
 /*
  *	Module support
  */
-static const char banner[] __initdata =
+static const char banner[] __initconst =
 	KERN_INFO "Generic Z85C30/Z85230 interface driver v0.02\n";
 
 static int __init z85230_init_driver(void)
-- 
1.7.4.4
