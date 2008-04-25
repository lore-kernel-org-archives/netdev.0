From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Fri, 25 Apr 2008 03:26:21 -0400
Message-ID: <20080425072621.GA21299@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:33520 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753466AbYDYH0W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 03:26:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'upstream-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upst=
ream-davem

to receive the following updates:

 Documentation/networking/phy.txt   |   38 +++-
 drivers/net/arm/at91_ether.c       |    1 +
 drivers/net/arm/ep93xx_eth.c       |    2 +
 drivers/net/atlx/atl1.c            |  138 ++++++++++++
 drivers/net/atlx/atlx.c            |  177 ---------------
 drivers/net/ax88796.c              |    1 +
 drivers/net/bfin_mac.c             |    7 +-
 drivers/net/cpmac.c                |    2 +
 drivers/net/dm9000.c               |    1 +
 drivers/net/e1000e/82571.c         |    6 -
 drivers/net/e1000e/defines.h       |    3 +
 drivers/net/e1000e/e1000.h         |   34 +++-
 drivers/net/e1000e/es2lan.c        |  129 ++++++++---
 drivers/net/e1000e/ethtool.c       |   49 ++++-
 drivers/net/e1000e/hw.h            |   12 +-
 drivers/net/e1000e/netdev.c        |  159 ++++++++-----
 drivers/net/e1000e/phy.c           |   73 ++++---
 drivers/net/ehea/ehea_main.c       |    4 +-
 drivers/net/forcedeth.c            |  432 ++++++++++++++++++++++++++++=
+-------
 drivers/net/gianfar.c              |  104 ++++++---
 drivers/net/ibm_newemac/core.c     |   83 ++++++-
 drivers/net/ibm_newemac/core.h     |   14 +-
 drivers/net/ibm_newemac/mal.c      |   20 ++-
 drivers/net/ibm_newemac/rgmii.c    |    2 +-
 drivers/net/ibm_newemac/tah.c      |    2 +-
 drivers/net/ibm_newemac/zmii.c     |    2 +-
 drivers/net/igb/igb_main.c         |    2 +
 drivers/net/irda/ali-ircc.c        |    2 +
 drivers/net/irda/pxaficp_ir.c      |    2 +
 drivers/net/irda/sa1100_ir.c       |    2 +
 drivers/net/ixgbe/ixgbe_main.c     |    2 +
 drivers/net/jazzsonic.c            |    2 +
 drivers/net/korina.c               |   39 ++--
 drivers/net/macb.c                 |    2 +
 drivers/net/meth.c                 |    2 +
 drivers/net/mv643xx_eth.c          |    5 +-
 drivers/net/netx-eth.c             |    2 +-
 drivers/net/netxen/netxen_nic_hw.c |   15 +-
 drivers/net/phy/mdio_bus.c         |    3 +
 drivers/net/phy/phy.c              |    4 +-
 drivers/net/phy/phy_device.c       |  129 ++++++++++-
 drivers/net/s2io.c                 |  128 +----------
 drivers/net/s2io.h                 |    9 -
 drivers/net/sgiseeq.c              |    4 +-
 drivers/net/smc911x.c              |    8 +-
 drivers/net/smc91x.c               |    2 +
 drivers/net/sni_82596.c            |    2 +
 drivers/net/tehuti.c               |   15 ++
 drivers/net/tsi108_eth.c           |    2 +
 drivers/net/typhoon.c              |    1 -
 drivers/net/ucc_geth.c             |    2 +-
 drivers/net/via-velocity.c         |   46 +++--
 drivers/net/wan/c101.c             |    6 +-
 drivers/net/wan/hdlc_fr.c          |    4 -
 include/linux/phy.h                |   24 ++-
 55 files changed, 1290 insertions(+), 671 deletions(-)

Andrew Morton (1):
      ehea: make things static

Andy Fleming (3):
      ucc_geth: Fix sneaky merge conflict regarding bus_id
      phylib: Add support for board-level PHY fixups
      gianfar: Fix skb allocation strategy

Auke Kok (3):
      e1000e: Add interrupt moderation run-time ethtool interface
      e1000e: lower ring minimum size to 64
      igb: save and restore pcie/msi state to support EEH recovery

Ayaz Abdulla (2):
      forcedeth: new backoff implementation
      forcedeth: realtek phy crossover detection

Benjamin Herrenschmidt (1):
      ibm_newemac: Increase MDIO timeouts

Bruce Allan (1):
      e1000e: cleanup several stats issues

Chris Snook (2):
      atlx: remove flash vendor parameter
      [netdrvr] atlx: code movement: move atl1 parameter parsing

C=E9dric Augonnet (1):
      Removing dead code in drivers/net/wan/hdlc_fr.c

David Graham (1):
      e1000e: Fix HW Error on es2lan, ARP capture issue by BMC

=46rancois Romieu (4):
      tehuti: check register size
      korina: fix misplaced return statement
      korina: misc cleanup
      via-velocity: fix vlan receipt

Grant Grundler (1):
      [netdrvr] typhoon: typhoon_resume - remove call to start_queue

Harvey Harrison (1):
      netxen: reduce stack usage of netxen_nic_flash_print

Jeff Garzik (1):
      [netdrvr] tehuti: move ioctl perm check closer to function start

Jesse Brandeburg (1):
      e1000e: Increment version to 0.2.1

Josh Boyer (2):
      ibm_newemac: Fix section mismatch warnings
      ibm_newemac Use status property for unused/unwired EMACs

Kay Sievers (1):
      net drivers: fix platform driver hotplug/coldplug

Krzysztof Halasa (1):
      WAN: Fix confusing insmod error code for C101 too.

Roel Kluin (1):
      smc911x: test after postfix decrement fails in smc911x_{reset,dro=
p_pkt}

Sreenivasa Honnur (4):
      S2io: Fix memory leak during free_tx_buffers
      S2io: Version update for memory leak fix during free_tx_buffers
      S2io: Removed receive buffer replenishment tasklet
      S2io: Removed rx_lock and put_lock

Stefan Roese (2):
      ibm_newemac: Fix problem with jumbo frame support and EMAC V4.pat=
ch
      ibm_newemac: Add support for 460EX/GT-type MAL rx-channel handlin=
g

Valentine Barshak (2):
      ibm_newemac: PowerPC 440GX EMAC PHY clock workaround
      ibm_newemac: PowerPC 440EP/440GR EMAC PHY clock workaround

Wendy Xiong (2):
      ixgbe: save and restore pcie/msi state to support EEH recovery
      e1000e: save and restore pcie/msi state to support EEH recovery

diff --git a/Documentation/networking/phy.txt b/Documentation/networkin=
g/phy.txt
index 0bc95ea..8df6a7b 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -1,7 +1,7 @@
=20
 -------
 PHY Abstraction Layer
-(Updated 2006-11-30)
+(Updated 2008-04-08)
=20
 Purpose
=20
@@ -291,3 +291,39 @@ Writing a PHY driver
  Feel free to look at the Marvell, Cicada, and Davicom drivers in
  drivers/net/phy/ for examples (the lxt and qsemi drivers have
  not been tested as of this writing)
+
+Board Fixups
+
+ Sometimes the specific interaction between the platform and the PHY r=
equires
+ special handling.  For instance, to change where the PHY's clock inpu=
t is,
+ or to add a delay to account for latency issues in the data path.  In=
 order
+ to support such contingencies, the PHY Layer allows platform code to =
register
+ fixups to be run when the PHY is brought up (or subsequently reset).
+
+ When the PHY Layer brings up a PHY it checks to see if there are any =
fixups
+ registered for it, matching based on UID (contained in the PHY device=
's phy_id
+ field) and the bus identifier (contained in phydev->dev.bus_id).  Bot=
h must
+ match, however two constants, PHY_ANY_ID and PHY_ANY_UID, are provide=
d as
+ wildcards for the bus ID and UID, respectively.
+
+ When a match is found, the PHY layer will invoke the run function ass=
ociated
+ with the fixup.  This function is passed a pointer to the phy_device =
of
+ interest.  It should therefore only operate on that PHY.
+
+ The platform code can either register the fixup using phy_register_fi=
xup():
+
+	int phy_register_fixup(const char *phy_id,
+		u32 phy_uid, u32 phy_uid_mask,
+		int (*run)(struct phy_device *));
+
+ Or using one of the two stubs, phy_register_fixup_for_uid() and
+ phy_register_fixup_for_id():
+
+ int phy_register_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask,
+		int (*run)(struct phy_device *));
+ int phy_register_fixup_for_id(const char *phy_id,
+		int (*run)(struct phy_device *));
+
+ The stubs set one of the two matching criteria, and set the other one=
 to
+ match anything.
+
diff --git a/drivers/net/arm/at91_ether.c b/drivers/net/arm/at91_ether.=
c
index 0ae0d83..770226d 100644
--- a/drivers/net/arm/at91_ether.c
+++ b/drivers/net/arm/at91_ether.c
@@ -1246,3 +1246,4 @@ module_exit(at91ether_exit)
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("AT91RM9200 EMAC Ethernet driver");
 MODULE_AUTHOR("Andrew Victor");
+MODULE_ALIAS("platform:" DRV_NAME);
diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.=
c
index 91a6590..ecd8fc6 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -897,6 +897,7 @@ static struct platform_driver ep93xx_eth_driver =3D=
 {
 	.remove		=3D ep93xx_eth_remove,
 	.driver		=3D {
 		.name	=3D "ep93xx-eth",
+		.owner	=3D THIS_MODULE,
 	},
 };
=20
@@ -914,3 +915,4 @@ static void __exit ep93xx_eth_cleanup_module(void)
 module_init(ep93xx_eth_init_module);
 module_exit(ep93xx_eth_cleanup_module);
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:ep93xx-eth");
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 5586fc6..0afe522 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -91,6 +91,144 @@
 #include "atlx.c"
=20
 /*
+ * This is the only thing that needs to be changed to adjust the
+ * maximum number of ports that the driver can manage.
+ */
+#define ATL1_MAX_NIC 4
+
+#define OPTION_UNSET    -1
+#define OPTION_DISABLED 0
+#define OPTION_ENABLED  1
+
+#define ATL1_PARAM_INIT { [0 ... ATL1_MAX_NIC] =3D OPTION_UNSET }
+
+/*
+ * Interrupt Moderate Timer in units of 2 us
+ *
+ * Valid Range: 10-65535
+ *
+ * Default Value: 100 (200us)
+ */
+static int __devinitdata int_mod_timer[ATL1_MAX_NIC+1] =3D ATL1_PARAM_=
INIT;
+static int num_int_mod_timer;
+module_param_array_named(int_mod_timer, int_mod_timer, int,
+	&num_int_mod_timer, 0);
+MODULE_PARM_DESC(int_mod_timer, "Interrupt moderator timer");
+
+#define DEFAULT_INT_MOD_CNT	100	/* 200us */
+#define MAX_INT_MOD_CNT		65000
+#define MIN_INT_MOD_CNT		50
+
+struct atl1_option {
+	enum { enable_option, range_option, list_option } type;
+	char *name;
+	char *err;
+	int def;
+	union {
+		struct {	/* range_option info */
+			int min;
+			int max;
+		} r;
+		struct {	/* list_option info */
+			int nr;
+			struct atl1_opt_list {
+				int i;
+				char *str;
+			} *p;
+		} l;
+	} arg;
+};
+
+static int __devinit atl1_validate_option(int *value, struct atl1_opti=
on *opt,
+	struct pci_dev *pdev)
+{
+	if (*value =3D=3D OPTION_UNSET) {
+		*value =3D opt->def;
+		return 0;
+	}
+
+	switch (opt->type) {
+	case enable_option:
+		switch (*value) {
+		case OPTION_ENABLED:
+			dev_info(&pdev->dev, "%s enabled\n", opt->name);
+			return 0;
+		case OPTION_DISABLED:
+			dev_info(&pdev->dev, "%s disabled\n", opt->name);
+			return 0;
+		}
+		break;
+	case range_option:
+		if (*value >=3D opt->arg.r.min && *value <=3D opt->arg.r.max) {
+			dev_info(&pdev->dev, "%s set to %i\n", opt->name,
+				*value);
+			return 0;
+		}
+		break;
+	case list_option:{
+			int i;
+			struct atl1_opt_list *ent;
+
+			for (i =3D 0; i < opt->arg.l.nr; i++) {
+				ent =3D &opt->arg.l.p[i];
+				if (*value =3D=3D ent->i) {
+					if (ent->str[0] !=3D '\0')
+						dev_info(&pdev->dev, "%s\n",
+							ent->str);
+					return 0;
+				}
+			}
+		}
+		break;
+
+	default:
+		break;
+	}
+
+	dev_info(&pdev->dev, "invalid %s specified (%i) %s\n",
+		opt->name, *value, opt->err);
+	*value =3D opt->def;
+	return -1;
+}
+
+/*
+ * atl1_check_options - Range Checking for Command Line Parameters
+ * @adapter: board private structure
+ *
+ * This routine checks all command line parameters for valid user
+ * input.  If an invalid value is given, or if no user specified
+ * value exists, a default value is used.  The final value is stored
+ * in a variable in the adapter structure.
+ */
+void __devinit atl1_check_options(struct atl1_adapter *adapter)
+{
+	struct pci_dev *pdev =3D adapter->pdev;
+	int bd =3D adapter->bd_number;
+	if (bd >=3D ATL1_MAX_NIC) {
+		dev_notice(&pdev->dev, "no configuration for board#%i\n", bd);
+		dev_notice(&pdev->dev, "using defaults for all values\n");
+	}
+	{			/* Interrupt Moderate Timer */
+		struct atl1_option opt =3D {
+			.type =3D range_option,
+			.name =3D "Interrupt Moderator Timer",
+			.err =3D "using default of "
+				__MODULE_STRING(DEFAULT_INT_MOD_CNT),
+			.def =3D DEFAULT_INT_MOD_CNT,
+			.arg =3D {.r =3D {.min =3D MIN_INT_MOD_CNT,
+					.max =3D MAX_INT_MOD_CNT} }
+		};
+		int val;
+		if (num_int_mod_timer > bd) {
+			val =3D int_mod_timer[bd];
+			atl1_validate_option(&val, &opt, pdev);
+			adapter->imt =3D (u16) val;
+		} else
+			adapter->imt =3D (u16) (opt.def);
+	}
+}
+
+/*
  * atl1_pci_tbl - PCI Device ID Table
  */
 static const struct pci_device_id atl1_pci_tbl[] =3D {
diff --git a/drivers/net/atlx/atlx.c b/drivers/net/atlx/atlx.c
index 4186326..f06b854 100644
--- a/drivers/net/atlx/atlx.c
+++ b/drivers/net/atlx/atlx.c
@@ -253,181 +253,4 @@ static void atlx_restore_vlan(struct atlx_adapter=
 *adapter)
 	atlx_vlan_rx_register(adapter->netdev, adapter->vlgrp);
 }
=20
-/*
- * This is the only thing that needs to be changed to adjust the
- * maximum number of ports that the driver can manage.
- */
-#define ATL1_MAX_NIC 4
-
-#define OPTION_UNSET    -1
-#define OPTION_DISABLED 0
-#define OPTION_ENABLED  1
-
-#define ATL1_PARAM_INIT { [0 ... ATL1_MAX_NIC] =3D OPTION_UNSET }
-
-/*
- * Interrupt Moderate Timer in units of 2 us
- *
- * Valid Range: 10-65535
- *
- * Default Value: 100 (200us)
- */
-static int __devinitdata int_mod_timer[ATL1_MAX_NIC+1] =3D ATL1_PARAM_=
INIT;
-static int num_int_mod_timer;
-module_param_array_named(int_mod_timer, int_mod_timer, int,
-	&num_int_mod_timer, 0);
-MODULE_PARM_DESC(int_mod_timer, "Interrupt moderator timer");
-
-/*
- * flash_vendor
- *
- * Valid Range: 0-2
- *
- * 0 - Atmel
- * 1 - SST
- * 2 - ST
- *
- * Default Value: 0
- */
-static int __devinitdata flash_vendor[ATL1_MAX_NIC+1] =3D ATL1_PARAM_I=
NIT;
-static int num_flash_vendor;
-module_param_array_named(flash_vendor, flash_vendor, int, &num_flash_v=
endor, 0);
-MODULE_PARM_DESC(flash_vendor, "SPI flash vendor");
-
-#define DEFAULT_INT_MOD_CNT	100	/* 200us */
-#define MAX_INT_MOD_CNT		65000
-#define MIN_INT_MOD_CNT		50
-
-#define FLASH_VENDOR_DEFAULT	0
-#define FLASH_VENDOR_MIN	0
-#define FLASH_VENDOR_MAX	2
-
-struct atl1_option {
-	enum { enable_option, range_option, list_option } type;
-	char *name;
-	char *err;
-	int def;
-	union {
-		struct {	/* range_option info */
-			int min;
-			int max;
-		} r;
-		struct {	/* list_option info */
-			int nr;
-			struct atl1_opt_list {
-				int i;
-				char *str;
-			} *p;
-		} l;
-	} arg;
-};
-
-static int __devinit atl1_validate_option(int *value, struct atl1_opti=
on *opt,
-	struct pci_dev *pdev)
-{
-	if (*value =3D=3D OPTION_UNSET) {
-		*value =3D opt->def;
-		return 0;
-	}
-
-	switch (opt->type) {
-	case enable_option:
-		switch (*value) {
-		case OPTION_ENABLED:
-			dev_info(&pdev->dev, "%s enabled\n", opt->name);
-			return 0;
-		case OPTION_DISABLED:
-			dev_info(&pdev->dev, "%s disabled\n", opt->name);
-			return 0;
-		}
-		break;
-	case range_option:
-		if (*value >=3D opt->arg.r.min && *value <=3D opt->arg.r.max) {
-			dev_info(&pdev->dev, "%s set to %i\n", opt->name,
-				*value);
-			return 0;
-		}
-		break;
-	case list_option:{
-			int i;
-			struct atl1_opt_list *ent;
-
-			for (i =3D 0; i < opt->arg.l.nr; i++) {
-				ent =3D &opt->arg.l.p[i];
-				if (*value =3D=3D ent->i) {
-					if (ent->str[0] !=3D '\0')
-						dev_info(&pdev->dev, "%s\n",
-							ent->str);
-					return 0;
-				}
-			}
-		}
-		break;
-
-	default:
-		break;
-	}
-
-	dev_info(&pdev->dev, "invalid %s specified (%i) %s\n",
-		opt->name, *value, opt->err);
-	*value =3D opt->def;
-	return -1;
-}
-
-/*
- * atl1_check_options - Range Checking for Command Line Parameters
- * @adapter: board private structure
- *
- * This routine checks all command line parameters for valid user
- * input.  If an invalid value is given, or if no user specified
- * value exists, a default value is used.  The final value is stored
- * in a variable in the adapter structure.
- */
-void __devinit atl1_check_options(struct atl1_adapter *adapter)
-{
-	struct pci_dev *pdev =3D adapter->pdev;
-	int bd =3D adapter->bd_number;
-	if (bd >=3D ATL1_MAX_NIC) {
-		dev_notice(&pdev->dev, "no configuration for board#%i\n", bd);
-		dev_notice(&pdev->dev, "using defaults for all values\n");
-	}
-	{			/* Interrupt Moderate Timer */
-		struct atl1_option opt =3D {
-			.type =3D range_option,
-			.name =3D "Interrupt Moderator Timer",
-			.err =3D "using default of "
-				__MODULE_STRING(DEFAULT_INT_MOD_CNT),
-			.def =3D DEFAULT_INT_MOD_CNT,
-			.arg =3D {.r =3D {.min =3D MIN_INT_MOD_CNT,
-					.max =3D MAX_INT_MOD_CNT} }
-		};
-		int val;
-		if (num_int_mod_timer > bd) {
-			val =3D int_mod_timer[bd];
-			atl1_validate_option(&val, &opt, pdev);
-			adapter->imt =3D (u16) val;
-		} else
-			adapter->imt =3D (u16) (opt.def);
-	}
-
-	{			/* Flash Vendor */
-		struct atl1_option opt =3D {
-			.type =3D range_option,
-			.name =3D "SPI Flash Vendor",
-			.err =3D "using default of "
-				__MODULE_STRING(FLASH_VENDOR_DEFAULT),
-			.def =3D DEFAULT_INT_MOD_CNT,
-			.arg =3D {.r =3D {.min =3D FLASH_VENDOR_MIN,
-					.max =3D FLASH_VENDOR_MAX} }
-		};
-		int val;
-		if (num_flash_vendor > bd) {
-			val =3D flash_vendor[bd];
-			atl1_validate_option(&val, &opt, pdev);
-			adapter->hw.flash_vendor =3D (u8) val;
-		} else
-			adapter->hw.flash_vendor =3D (u8) (opt.def);
-	}
-}
-
 #endif /* ATLX_C */
diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index 194949a..0b4adf4 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -1005,3 +1005,4 @@ module_exit(axdrv_exit);
 MODULE_DESCRIPTION("AX88796 10/100 Ethernet platform driver");
 MODULE_AUTHOR("Ben Dooks, <ben@simtec.co.uk>");
 MODULE_LICENSE("GPL v2");
+MODULE_ALIAS("platform:ax88796");
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 717dcc1..4fec858 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -47,6 +47,7 @@
 MODULE_AUTHOR(DRV_AUTHOR);
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION(DRV_DESC);
+MODULE_ALIAS("platform:bfin_mac");
=20
 #if defined(CONFIG_BFIN_MAC_USE_L1)
 # define bfin_mac_alloc(dma_handle, size)  l1_data_sram_zalloc(size)
@@ -1089,8 +1090,9 @@ static struct platform_driver bfin_mac_driver =3D=
 {
 	.resume =3D bfin_mac_resume,
 	.suspend =3D bfin_mac_suspend,
 	.driver =3D {
-		   .name =3D DRV_NAME,
-		   },
+		.name =3D DRV_NAME,
+		.owner	=3D THIS_MODULE,
+	},
 };
=20
 static int __init bfin_mac_init(void)
@@ -1106,3 +1108,4 @@ static void __exit bfin_mac_cleanup(void)
 }
=20
 module_exit(bfin_mac_cleanup);
+
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 9da7ff4..2b5740b 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -42,6 +42,7 @@
 MODULE_AUTHOR("Eugene Konev <ejka@imfi.kspu.ru>");
 MODULE_DESCRIPTION("TI AR7 ethernet driver (CPMAC)");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:cpmac");
=20
 static int debug_level =3D 8;
 static int dumb_switch;
@@ -1103,6 +1104,7 @@ static int __devexit cpmac_remove(struct platform=
_device *pdev)
=20
 static struct platform_driver cpmac_driver =3D {
 	.driver.name =3D "cpmac",
+	.driver.owner =3D THIS_MODULE,
 	.probe =3D cpmac_probe,
 	.remove =3D __devexit_p(cpmac_remove),
 };
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index d63cc93..e6fe261 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -1418,3 +1418,4 @@ module_exit(dm9000_cleanup);
 MODULE_AUTHOR("Sascha Hauer, Ben Dooks");
 MODULE_DESCRIPTION("Davicom DM9000 network driver");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:dm9000");
diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 01c8866..462351c 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1326,12 +1326,10 @@ struct e1000_info e1000_82571_info =3D {
 	.mac			=3D e1000_82571,
 	.flags			=3D FLAG_HAS_HW_VLAN_FILTER
 				  | FLAG_HAS_JUMBO_FRAMES
-				  | FLAG_HAS_STATS_PTC_PRC
 				  | FLAG_HAS_WOL
 				  | FLAG_APME_IN_CTRL3
 				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_CTRLEXT_ON_LOAD
-				  | FLAG_HAS_STATS_ICR_ICT
 				  | FLAG_HAS_SMART_POWER_DOWN
 				  | FLAG_RESET_OVERWRITES_LAA /* errata */
 				  | FLAG_TARC_SPEED_MODE_BIT /* errata */
@@ -1347,12 +1345,10 @@ struct e1000_info e1000_82572_info =3D {
 	.mac			=3D e1000_82572,
 	.flags			=3D FLAG_HAS_HW_VLAN_FILTER
 				  | FLAG_HAS_JUMBO_FRAMES
-				  | FLAG_HAS_STATS_PTC_PRC
 				  | FLAG_HAS_WOL
 				  | FLAG_APME_IN_CTRL3
 				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_CTRLEXT_ON_LOAD
-				  | FLAG_HAS_STATS_ICR_ICT
 				  | FLAG_TARC_SPEED_MODE_BIT, /* errata */
 	.pba			=3D 38,
 	.get_variants		=3D e1000_get_variants_82571,
@@ -1365,11 +1361,9 @@ struct e1000_info e1000_82573_info =3D {
 	.mac			=3D e1000_82573,
 	.flags			=3D FLAG_HAS_HW_VLAN_FILTER
 				  | FLAG_HAS_JUMBO_FRAMES
-				  | FLAG_HAS_STATS_PTC_PRC
 				  | FLAG_HAS_WOL
 				  | FLAG_APME_IN_CTRL3
 				  | FLAG_RX_CSUM_ENABLED
-				  | FLAG_HAS_STATS_ICR_ICT
 				  | FLAG_HAS_SMART_POWER_DOWN
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_ERT
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.=
h
index 572cfd4..2a53875 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -184,6 +184,7 @@
 #define E1000_SWFW_EEP_SM   0x1
 #define E1000_SWFW_PHY0_SM  0x2
 #define E1000_SWFW_PHY1_SM  0x4
+#define E1000_SWFW_CSR_SM   0x8
=20
 /* Device Control */
 #define E1000_CTRL_FD       0x00000001  /* Full duplex.0=3Dhalf; 1=3Df=
ull */
@@ -527,8 +528,10 @@
 #define PHY_ID2          0x03 /* Phy Id Reg (word 2) */
 #define PHY_AUTONEG_ADV  0x04 /* Autoneg Advertisement */
 #define PHY_LP_ABILITY   0x05 /* Link Partner Ability (Base Page) */
+#define PHY_AUTONEG_EXP  0x06 /* Autoneg Expansion Reg */
 #define PHY_1000T_CTRL   0x09 /* 1000Base-T Control Reg */
 #define PHY_1000T_STATUS 0x0A /* 1000Base-T Status Reg */
+#define PHY_EXT_STATUS   0x0F /* Extended Status Reg */
=20
 /* NVM Control */
 #define E1000_EECD_SK        0x00000001 /* NVM Clock */
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 5a89dff..38bfd0d 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -64,11 +64,14 @@ struct e1000_info;
 /* Tx/Rx descriptor defines */
 #define E1000_DEFAULT_TXD		256
 #define E1000_MAX_TXD			4096
-#define E1000_MIN_TXD			80
+#define E1000_MIN_TXD			64
=20
 #define E1000_DEFAULT_RXD		256
 #define E1000_MAX_RXD			4096
-#define E1000_MIN_RXD			80
+#define E1000_MIN_RXD			64
+
+#define E1000_MIN_ITR_USECS		10 /* 100000 irq/sec */
+#define E1000_MAX_ITR_USECS		10000 /* 100    irq/sec */
=20
 /* Early Receive defines */
 #define E1000_ERT_2048			0x100
@@ -147,6 +150,18 @@ struct e1000_ring {
 	struct e1000_queue_stats stats;
 };
=20
+/* PHY register snapshot values */
+struct e1000_phy_regs {
+	u16 bmcr;		/* basic mode control register    */
+	u16 bmsr;		/* basic mode status register     */
+	u16 advertise;		/* auto-negotiation advertisement */
+	u16 lpa;		/* link partner ability register  */
+	u16 expansion;		/* auto-negotiation expansion reg */
+	u16 ctrl1000;		/* 1000BASE-T control register    */
+	u16 stat1000;		/* 1000BASE-T status register     */
+	u16 estatus;		/* extended status register       */
+};
+
 /* board specific private data structure */
 struct e1000_adapter {
 	struct timer_list watchdog_timer;
@@ -202,8 +217,8 @@ struct e1000_adapter {
 	/* Tx stats */
 	u64 tpt_old;
 	u64 colc_old;
-	u64 gotcl_old;
-	u32 gotcl;
+	u32 gotc;
+	u64 gotc_old;
 	u32 tx_timeout_count;
 	u32 tx_fifo_head;
 	u32 tx_head_addr;
@@ -227,8 +242,8 @@ struct e1000_adapter {
 	u64 hw_csum_err;
 	u64 hw_csum_good;
 	u64 rx_hdr_split;
-	u64 gorcl_old;
-	u32 gorcl;
+	u32 gorc;
+	u64 gorc_old;
 	u32 alloc_rx_buff_failed;
 	u32 rx_dma_failed;
=20
@@ -250,6 +265,9 @@ struct e1000_adapter {
 	struct e1000_phy_info phy_info;
 	struct e1000_phy_stats phy_stats;
=20
+	/* Snapshot of PHY registers */
+	struct e1000_phy_regs phy_regs;
+
 	struct e1000_ring test_tx_ring;
 	struct e1000_ring test_rx_ring;
 	u32 test_icr;
@@ -286,8 +304,6 @@ struct e1000_info {
 #define FLAG_HAS_CTRLEXT_ON_LOAD          (1 << 5)
 #define FLAG_HAS_SWSM_ON_LOAD             (1 << 6)
 #define FLAG_HAS_JUMBO_FRAMES             (1 << 7)
-#define FLAG_HAS_STATS_ICR_ICT            (1 << 9)
-#define FLAG_HAS_STATS_PTC_PRC            (1 << 10)
 #define FLAG_HAS_SMART_POWER_DOWN         (1 << 11)
 #define FLAG_IS_QUAD_PORT_A               (1 << 12)
 #define FLAG_IS_QUAD_PORT                 (1 << 13)
@@ -433,6 +449,8 @@ extern s32 e1000e_read_kmrn_reg(struct e1000_hw *hw=
, u32 offset, u16 *data);
 extern s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, u32 iterat=
ions,
 			       u32 usec_interval, bool *success);
 extern s32 e1000e_phy_reset_dsp(struct e1000_hw *hw);
+extern s32 e1000e_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u=
16 *data);
+extern s32 e1000e_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, =
u16 data);
 extern s32 e1000e_check_downshift(struct e1000_hw *hw);
=20
 static inline s32 e1000_phy_hw_reset(struct e1000_hw *hw)
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index d59a99a..dc552d7 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -41,6 +41,7 @@
 #define E1000_KMRNCTRLSTA_OFFSET_FIFO_CTRL	 0x00
 #define E1000_KMRNCTRLSTA_OFFSET_INB_CTRL	 0x02
 #define E1000_KMRNCTRLSTA_OFFSET_HD_CTRL	 0x10
+#define E1000_KMRNCTRLSTA_OFFSET_MAC2PHY_OPMODE	 0x1F
=20
 #define E1000_KMRNCTRLSTA_FIFO_CTRL_RX_BYPASS	 0x0008
 #define E1000_KMRNCTRLSTA_FIFO_CTRL_TX_BYPASS	 0x0800
@@ -48,6 +49,7 @@
=20
 #define E1000_KMRNCTRLSTA_HD_CTRL_10_100_DEFAULT 0x0004
 #define E1000_KMRNCTRLSTA_HD_CTRL_1000_DEFAULT	 0x0000
+#define E1000_KMRNCTRLSTA_OPMODE_E_IDLE		 0x2000
=20
 #define E1000_TCTL_EXT_GCEX_MASK 0x000FFC00 /* Gigabit Carry Extend Pa=
dding */
 #define DEFAULT_TCTL_EXT_GCEX_80003ES2LAN	 0x00010000
@@ -85,6 +87,9 @@
 /* Kumeran Mode Control Register (Page 193, Register 16) */
 #define GG82563_KMCR_PASS_FALSE_CARRIER		 0x0800
=20
+/* Max number of times Kumeran read/write should be validated */
+#define GG82563_MAX_KMRN_RETRY  0x5
+
 /* Power Management Control Register (Page 193, Register 20) */
 #define GG82563_PMCR_ENABLE_ELECTRICAL_IDLE	 0x0001
 					   /* 1=3DEnable SERDES Electrical Idle */
@@ -270,6 +275,7 @@ static s32 e1000_acquire_phy_80003es2lan(struct e10=
00_hw *hw)
 	u16 mask;
=20
 	mask =3D hw->bus.func ? E1000_SWFW_PHY1_SM : E1000_SWFW_PHY0_SM;
+	mask |=3D E1000_SWFW_CSR_SM;
=20
 	return e1000_acquire_swfw_sync_80003es2lan(hw, mask);
 }
@@ -286,6 +292,8 @@ static void e1000_release_phy_80003es2lan(struct e1=
000_hw *hw)
 	u16 mask;
=20
 	mask =3D hw->bus.func ? E1000_SWFW_PHY1_SM : E1000_SWFW_PHY0_SM;
+	mask |=3D E1000_SWFW_CSR_SM;
+
 	e1000_release_swfw_sync_80003es2lan(hw, mask);
 }
=20
@@ -410,20 +418,27 @@ static s32 e1000_read_phy_reg_gg82563_80003es2lan=
(struct e1000_hw *hw,
 	u32 page_select;
 	u16 temp;
=20
+	ret_val =3D e1000_acquire_phy_80003es2lan(hw);
+	if (ret_val)
+		return ret_val;
+
 	/* Select Configuration Page */
-	if ((offset & MAX_PHY_REG_ADDRESS) < GG82563_MIN_ALT_REG)
+	if ((offset & MAX_PHY_REG_ADDRESS) < GG82563_MIN_ALT_REG) {
 		page_select =3D GG82563_PHY_PAGE_SELECT;
-	else
+	} else {
 		/*
 		 * Use Alternative Page Select register to access
 		 * registers 30 and 31
 		 */
 		page_select =3D GG82563_PHY_PAGE_SELECT_ALT;
+	}
=20
 	temp =3D (u16)((u16)offset >> GG82563_PAGE_SHIFT);
-	ret_val =3D e1000e_write_phy_reg_m88(hw, page_select, temp);
-	if (ret_val)
+	ret_val =3D e1000e_write_phy_reg_mdic(hw, page_select, temp);
+	if (ret_val) {
+		e1000_release_phy_80003es2lan(hw);
 		return ret_val;
+	}
=20
 	/*
 	 * The "ready" bit in the MDIC register may be incorrectly set
@@ -433,20 +448,21 @@ static s32 e1000_read_phy_reg_gg82563_80003es2lan=
(struct e1000_hw *hw,
 	udelay(200);
=20
 	/* ...and verify the command was successful. */
-	ret_val =3D e1000e_read_phy_reg_m88(hw, page_select, &temp);
+	ret_val =3D e1000e_read_phy_reg_mdic(hw, page_select, &temp);
=20
 	if (((u16)offset >> GG82563_PAGE_SHIFT) !=3D temp) {
 		ret_val =3D -E1000_ERR_PHY;
+		e1000_release_phy_80003es2lan(hw);
 		return ret_val;
 	}
=20
 	udelay(200);
=20
-	ret_val =3D e1000e_read_phy_reg_m88(hw,
-					 MAX_PHY_REG_ADDRESS & offset,
-					 data);
+	ret_val =3D e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset=
,
+					   data);
=20
 	udelay(200);
+	e1000_release_phy_80003es2lan(hw);
=20
 	return ret_val;
 }
@@ -467,20 +483,27 @@ static s32 e1000_write_phy_reg_gg82563_80003es2la=
n(struct e1000_hw *hw,
 	u32 page_select;
 	u16 temp;
=20
+	ret_val =3D e1000_acquire_phy_80003es2lan(hw);
+	if (ret_val)
+		return ret_val;
+
 	/* Select Configuration Page */
-	if ((offset & MAX_PHY_REG_ADDRESS) < GG82563_MIN_ALT_REG)
+	if ((offset & MAX_PHY_REG_ADDRESS) < GG82563_MIN_ALT_REG) {
 		page_select =3D GG82563_PHY_PAGE_SELECT;
-	else
+	} else {
 		/*
 		 * Use Alternative Page Select register to access
 		 * registers 30 and 31
 		 */
 		page_select =3D GG82563_PHY_PAGE_SELECT_ALT;
+	}
=20
 	temp =3D (u16)((u16)offset >> GG82563_PAGE_SHIFT);
-	ret_val =3D e1000e_write_phy_reg_m88(hw, page_select, temp);
-	if (ret_val)
+	ret_val =3D e1000e_write_phy_reg_mdic(hw, page_select, temp);
+	if (ret_val) {
+		e1000_release_phy_80003es2lan(hw);
 		return ret_val;
+	}
=20
=20
 	/*
@@ -491,18 +514,20 @@ static s32 e1000_write_phy_reg_gg82563_80003es2la=
n(struct e1000_hw *hw,
 	udelay(200);
=20
 	/* ...and verify the command was successful. */
-	ret_val =3D e1000e_read_phy_reg_m88(hw, page_select, &temp);
+	ret_val =3D e1000e_read_phy_reg_mdic(hw, page_select, &temp);
=20
-	if (((u16)offset >> GG82563_PAGE_SHIFT) !=3D temp)
+	if (((u16)offset >> GG82563_PAGE_SHIFT) !=3D temp) {
+		e1000_release_phy_80003es2lan(hw);
 		return -E1000_ERR_PHY;
+	}
=20
 	udelay(200);
=20
-	ret_val =3D e1000e_write_phy_reg_m88(hw,
-					  MAX_PHY_REG_ADDRESS & offset,
-					  data);
+	ret_val =3D e1000e_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offse=
t,
+					    data);
=20
 	udelay(200);
+	e1000_release_phy_80003es2lan(hw);
=20
 	return ret_val;
 }
@@ -882,10 +907,10 @@ static s32 e1000_copper_link_setup_gg82563_80003e=
s2lan(struct e1000_hw *hw)
 	struct e1000_phy_info *phy =3D &hw->phy;
 	s32 ret_val;
 	u32 ctrl_ext;
-	u16 data;
+	u32 i =3D 0;
+	u16 data, data2;
=20
-	ret_val =3D e1e_rphy(hw, GG82563_PHY_MAC_SPEC_CTRL,
-				     &data);
+	ret_val =3D e1e_rphy(hw, GG82563_PHY_MAC_SPEC_CTRL, &data);
 	if (ret_val)
 		return ret_val;
=20
@@ -893,8 +918,7 @@ static s32 e1000_copper_link_setup_gg82563_80003es2=
lan(struct e1000_hw *hw)
 	/* Use 25MHz for both link down and 1000Base-T for Tx clock. */
 	data |=3D GG82563_MSCR_TX_CLK_1000MBPS_25;
=20
-	ret_val =3D e1e_wphy(hw, GG82563_PHY_MAC_SPEC_CTRL,
-				      data);
+	ret_val =3D e1e_wphy(hw, GG82563_PHY_MAC_SPEC_CTRL, data);
 	if (ret_val)
 		return ret_val;
=20
@@ -954,6 +978,18 @@ static s32 e1000_copper_link_setup_gg82563_80003es=
2lan(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
=20
+	ret_val =3D e1000e_read_kmrn_reg(hw,
+				       E1000_KMRNCTRLSTA_OFFSET_MAC2PHY_OPMODE,
+				       &data);
+	if (ret_val)
+		return ret_val;
+	data |=3D E1000_KMRNCTRLSTA_OPMODE_E_IDLE;
+	ret_val =3D e1000e_write_kmrn_reg(hw,
+					E1000_KMRNCTRLSTA_OFFSET_MAC2PHY_OPMODE,
+					data);
+	if (ret_val)
+		return ret_val;
+
 	ret_val =3D e1e_rphy(hw, GG82563_PHY_SPEC_CTRL_2, &data);
 	if (ret_val)
 		return ret_val;
@@ -983,9 +1019,18 @@ static s32 e1000_copper_link_setup_gg82563_80003e=
s2lan(struct e1000_hw *hw)
 		if (ret_val)
 			return ret_val;
=20
-		ret_val =3D e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL, &data);
-		if (ret_val)
-			return ret_val;
+		do {
+			ret_val =3D e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL,
+					   &data);
+			if (ret_val)
+				return ret_val;
+
+			ret_val =3D e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL,
+					   &data2);
+			if (ret_val)
+				return ret_val;
+			i++;
+		} while ((data !=3D data2) && (i < GG82563_MAX_KMRN_RETRY));
=20
 		data &=3D ~GG82563_KMCR_PASS_FALSE_CARRIER;
 		ret_val =3D e1e_wphy(hw, GG82563_PHY_KMRN_MODE_CTRL, data);
@@ -1074,7 +1119,8 @@ static s32 e1000_cfg_kmrn_10_100_80003es2lan(stru=
ct e1000_hw *hw, u16 duplex)
 {
 	s32 ret_val;
 	u32 tipg;
-	u16 reg_data;
+	u32 i =3D 0;
+	u16 reg_data, reg_data2;
=20
 	reg_data =3D E1000_KMRNCTRLSTA_HD_CTRL_10_100_DEFAULT;
 	ret_val =3D e1000e_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_OFFSET_HD_CTR=
L,
@@ -1088,9 +1134,16 @@ static s32 e1000_cfg_kmrn_10_100_80003es2lan(str=
uct e1000_hw *hw, u16 duplex)
 	tipg |=3D DEFAULT_TIPG_IPGT_10_100_80003ES2LAN;
 	ew32(TIPG, tipg);
=20
-	ret_val =3D e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL, &reg_data);
-	if (ret_val)
-		return ret_val;
+	do {
+		ret_val =3D e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL, &reg_data);
+		if (ret_val)
+			return ret_val;
+
+		ret_val =3D e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL, &reg_data2);
+		if (ret_val)
+			return ret_val;
+		i++;
+	} while ((reg_data !=3D reg_data2) && (i < GG82563_MAX_KMRN_RETRY));
=20
 	if (duplex =3D=3D HALF_DUPLEX)
 		reg_data |=3D GG82563_KMCR_PASS_FALSE_CARRIER;
@@ -1112,8 +1165,9 @@ static s32 e1000_cfg_kmrn_10_100_80003es2lan(stru=
ct e1000_hw *hw, u16 duplex)
 static s32 e1000_cfg_kmrn_1000_80003es2lan(struct e1000_hw *hw)
 {
 	s32 ret_val;
-	u16 reg_data;
+	u16 reg_data, reg_data2;
 	u32 tipg;
+	u32 i =3D 0;
=20
 	reg_data =3D E1000_KMRNCTRLSTA_HD_CTRL_1000_DEFAULT;
 	ret_val =3D e1000e_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_OFFSET_HD_CTR=
L,
@@ -1127,9 +1181,16 @@ static s32 e1000_cfg_kmrn_1000_80003es2lan(struc=
t e1000_hw *hw)
 	tipg |=3D DEFAULT_TIPG_IPGT_1000_80003ES2LAN;
 	ew32(TIPG, tipg);
=20
-	ret_val =3D e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL, &reg_data);
-	if (ret_val)
-		return ret_val;
+	do {
+		ret_val =3D e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL, &reg_data);
+		if (ret_val)
+			return ret_val;
+
+		ret_val =3D e1e_rphy(hw, GG82563_PHY_KMRN_MODE_CTRL, &reg_data2);
+		if (ret_val)
+			return ret_val;
+		i++;
+	} while ((reg_data !=3D reg_data2) && (i < GG82563_MAX_KMRN_RETRY));
=20
 	reg_data &=3D ~GG82563_KMCR_PASS_FALSE_CARRIER;
 	ret_val =3D e1e_wphy(hw, GG82563_PHY_KMRN_MODE_CTRL, reg_data);
@@ -1231,12 +1292,10 @@ struct e1000_info e1000_es2_info =3D {
 	.mac			=3D e1000_80003es2lan,
 	.flags			=3D FLAG_HAS_HW_VLAN_FILTER
 				  | FLAG_HAS_JUMBO_FRAMES
-				  | FLAG_HAS_STATS_PTC_PRC
 				  | FLAG_HAS_WOL
 				  | FLAG_APME_IN_CTRL3
 				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_CTRLEXT_ON_LOAD
-				  | FLAG_HAS_STATS_ICR_ICT
 				  | FLAG_RX_NEEDS_RESTART /* errata */
 				  | FLAG_TARC_SET_BIT_ZERO /* errata */
 				  | FLAG_APME_CHECK_PORT_B
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.=
c
index 6d1b257..ce045ac 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -46,8 +46,8 @@ struct e1000_stats {
 static const struct e1000_stats e1000_gstrings_stats[] =3D {
 	{ "rx_packets", E1000_STAT(stats.gprc) },
 	{ "tx_packets", E1000_STAT(stats.gptc) },
-	{ "rx_bytes", E1000_STAT(stats.gorcl) },
-	{ "tx_bytes", E1000_STAT(stats.gotcl) },
+	{ "rx_bytes", E1000_STAT(stats.gorc) },
+	{ "tx_bytes", E1000_STAT(stats.gotc) },
 	{ "rx_broadcast", E1000_STAT(stats.bprc) },
 	{ "tx_broadcast", E1000_STAT(stats.bptc) },
 	{ "rx_multicast", E1000_STAT(stats.mprc) },
@@ -83,7 +83,7 @@ static const struct e1000_stats e1000_gstrings_stats[=
] =3D {
 	{ "rx_flow_control_xoff", E1000_STAT(stats.xoffrxc) },
 	{ "tx_flow_control_xon", E1000_STAT(stats.xontxc) },
 	{ "tx_flow_control_xoff", E1000_STAT(stats.xofftxc) },
-	{ "rx_long_byte_count", E1000_STAT(stats.gorcl) },
+	{ "rx_long_byte_count", E1000_STAT(stats.gorc) },
 	{ "rx_csum_offload_good", E1000_STAT(hw_csum_good) },
 	{ "rx_csum_offload_errors", E1000_STAT(hw_csum_err) },
 	{ "rx_header_split", E1000_STAT(rx_hdr_split) },
@@ -1770,6 +1770,47 @@ static int e1000_phys_id(struct net_device *netd=
ev, u32 data)
 	return 0;
 }
=20
+static int e1000_get_coalesce(struct net_device *netdev,
+			      struct ethtool_coalesce *ec)
+{
+	struct e1000_adapter *adapter =3D netdev_priv(netdev);
+
+	if (adapter->itr_setting <=3D 3)
+		ec->rx_coalesce_usecs =3D adapter->itr_setting;
+	else
+		ec->rx_coalesce_usecs =3D 1000000 / adapter->itr_setting;
+
+	return 0;
+}
+
+static int e1000_set_coalesce(struct net_device *netdev,
+			      struct ethtool_coalesce *ec)
+{
+	struct e1000_adapter *adapter =3D netdev_priv(netdev);
+	struct e1000_hw *hw =3D &adapter->hw;
+
+	if ((ec->rx_coalesce_usecs > E1000_MAX_ITR_USECS) ||
+	    ((ec->rx_coalesce_usecs > 3) &&
+	     (ec->rx_coalesce_usecs < E1000_MIN_ITR_USECS)) ||
+	    (ec->rx_coalesce_usecs =3D=3D 2))
+		return -EINVAL;
+
+	if (ec->rx_coalesce_usecs <=3D 3) {
+		adapter->itr =3D 20000;
+		adapter->itr_setting =3D ec->rx_coalesce_usecs;
+	} else {
+		adapter->itr =3D (1000000 / ec->rx_coalesce_usecs);
+		adapter->itr_setting =3D adapter->itr & ~3;
+	}
+
+	if (adapter->itr_setting !=3D 0)
+		ew32(ITR, 1000000000 / (adapter->itr * 256));
+	else
+		ew32(ITR, 0);
+
+	return 0;
+}
+
 static int e1000_nway_reset(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter =3D netdev_priv(netdev);
@@ -1845,6 +1886,8 @@ static const struct ethtool_ops e1000_ethtool_ops=
 =3D {
 	.phys_id		=3D e1000_phys_id,
 	.get_ethtool_stats	=3D e1000_get_ethtool_stats,
 	.get_sset_count		=3D e1000e_get_sset_count,
+	.get_coalesce		=3D e1000_get_coalesce,
+	.set_coalesce		=3D e1000_set_coalesce,
 };
=20
 void e1000e_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 53f1ac6..a930e6d 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -592,10 +592,8 @@ struct e1000_hw_stats {
 	u64 bprc;
 	u64 mprc;
 	u64 gptc;
-	u64 gorcl;
-	u64 gorch;
-	u64 gotcl;
-	u64 gotch;
+	u64 gorc;
+	u64 gotc;
 	u64 rnbc;
 	u64 ruc;
 	u64 rfc;
@@ -604,10 +602,8 @@ struct e1000_hw_stats {
 	u64 mgprc;
 	u64 mgpdc;
 	u64 mgptc;
-	u64 torl;
-	u64 torh;
-	u64 totl;
-	u64 toth;
+	u64 tor;
+	u64 tot;
 	u64 tpr;
 	u64 tpt;
 	u64 ptc64;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index c8dc47f..8991ab8 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -46,7 +46,7 @@
=20
 #include "e1000.h"
=20
-#define DRV_VERSION "0.2.0"
+#define DRV_VERSION "0.2.1"
 char e1000e_driver_name[] =3D "e1000e";
 const char e1000e_driver_version[] =3D DRV_VERSION;
=20
@@ -466,10 +466,10 @@ next_desc:
 	if (cleaned_count)
 		adapter->alloc_rx_buf(adapter, cleaned_count);
=20
-	adapter->total_rx_packets +=3D total_rx_packets;
 	adapter->total_rx_bytes +=3D total_rx_bytes;
-	adapter->net_stats.rx_packets +=3D total_rx_packets;
+	adapter->total_rx_packets +=3D total_rx_packets;
 	adapter->net_stats.rx_bytes +=3D total_rx_bytes;
+	adapter->net_stats.rx_packets +=3D total_rx_packets;
 	return cleaned;
 }
=20
@@ -606,8 +606,8 @@ static bool e1000_clean_tx_irq(struct e1000_adapter=
 *adapter)
 	}
 	adapter->total_tx_bytes +=3D total_tx_bytes;
 	adapter->total_tx_packets +=3D total_tx_packets;
-	adapter->net_stats.tx_packets +=3D total_tx_packets;
 	adapter->net_stats.tx_bytes +=3D total_tx_bytes;
+	adapter->net_stats.tx_packets +=3D total_tx_packets;
 	return cleaned;
 }
=20
@@ -775,10 +775,10 @@ next_desc:
 	if (cleaned_count)
 		adapter->alloc_rx_buf(adapter, cleaned_count);
=20
-	adapter->total_rx_packets +=3D total_rx_packets;
 	adapter->total_rx_bytes +=3D total_rx_bytes;
-	adapter->net_stats.rx_packets +=3D total_rx_packets;
+	adapter->total_rx_packets +=3D total_rx_packets;
 	adapter->net_stats.rx_bytes +=3D total_rx_bytes;
+	adapter->net_stats.rx_packets +=3D total_rx_packets;
 	return cleaned;
 }
=20
@@ -2506,56 +2506,27 @@ void e1000e_update_stats(struct e1000_adapter *=
adapter)
=20
 	adapter->stats.crcerrs +=3D er32(CRCERRS);
 	adapter->stats.gprc +=3D er32(GPRC);
-	adapter->stats.gorcl +=3D er32(GORCL);
-	adapter->stats.gorch +=3D er32(GORCH);
+	adapter->stats.gorc +=3D er32(GORCL);
+	er32(GORCH); /* Clear gorc */
 	adapter->stats.bprc +=3D er32(BPRC);
 	adapter->stats.mprc +=3D er32(MPRC);
 	adapter->stats.roc +=3D er32(ROC);
=20
-	if (adapter->flags & FLAG_HAS_STATS_PTC_PRC) {
-		adapter->stats.prc64 +=3D er32(PRC64);
-		adapter->stats.prc127 +=3D er32(PRC127);
-		adapter->stats.prc255 +=3D er32(PRC255);
-		adapter->stats.prc511 +=3D er32(PRC511);
-		adapter->stats.prc1023 +=3D er32(PRC1023);
-		adapter->stats.prc1522 +=3D er32(PRC1522);
-		adapter->stats.symerrs +=3D er32(SYMERRS);
-		adapter->stats.sec +=3D er32(SEC);
-	}
-
 	adapter->stats.mpc +=3D er32(MPC);
 	adapter->stats.scc +=3D er32(SCC);
 	adapter->stats.ecol +=3D er32(ECOL);
 	adapter->stats.mcc +=3D er32(MCC);
 	adapter->stats.latecol +=3D er32(LATECOL);
 	adapter->stats.dc +=3D er32(DC);
-	adapter->stats.rlec +=3D er32(RLEC);
 	adapter->stats.xonrxc +=3D er32(XONRXC);
 	adapter->stats.xontxc +=3D er32(XONTXC);
 	adapter->stats.xoffrxc +=3D er32(XOFFRXC);
 	adapter->stats.xofftxc +=3D er32(XOFFTXC);
-	adapter->stats.fcruc +=3D er32(FCRUC);
 	adapter->stats.gptc +=3D er32(GPTC);
-	adapter->stats.gotcl +=3D er32(GOTCL);
-	adapter->stats.gotch +=3D er32(GOTCH);
+	adapter->stats.gotc +=3D er32(GOTCL);
+	er32(GOTCH); /* Clear gotc */
 	adapter->stats.rnbc +=3D er32(RNBC);
 	adapter->stats.ruc +=3D er32(RUC);
-	adapter->stats.rfc +=3D er32(RFC);
-	adapter->stats.rjc +=3D er32(RJC);
-	adapter->stats.torl +=3D er32(TORL);
-	adapter->stats.torh +=3D er32(TORH);
-	adapter->stats.totl +=3D er32(TOTL);
-	adapter->stats.toth +=3D er32(TOTH);
-	adapter->stats.tpr +=3D er32(TPR);
-
-	if (adapter->flags & FLAG_HAS_STATS_PTC_PRC) {
-		adapter->stats.ptc64 +=3D er32(PTC64);
-		adapter->stats.ptc127 +=3D er32(PTC127);
-		adapter->stats.ptc255 +=3D er32(PTC255);
-		adapter->stats.ptc511 +=3D er32(PTC511);
-		adapter->stats.ptc1023 +=3D er32(PTC1023);
-		adapter->stats.ptc1522 +=3D er32(PTC1522);
-	}
=20
 	adapter->stats.mptc +=3D er32(MPTC);
 	adapter->stats.bptc +=3D er32(BPTC);
@@ -2574,19 +2545,6 @@ void e1000e_update_stats(struct e1000_adapter *a=
dapter)
 	adapter->stats.tsctc +=3D er32(TSCTC);
 	adapter->stats.tsctfc +=3D er32(TSCTFC);
=20
-	adapter->stats.iac +=3D er32(IAC);
-
-	if (adapter->flags & FLAG_HAS_STATS_ICR_ICT) {
-		adapter->stats.icrxoc +=3D er32(ICRXOC);
-		adapter->stats.icrxptc +=3D er32(ICRXPTC);
-		adapter->stats.icrxatc +=3D er32(ICRXATC);
-		adapter->stats.ictxptc +=3D er32(ICTXPTC);
-		adapter->stats.ictxatc +=3D er32(ICTXATC);
-		adapter->stats.ictxqec +=3D er32(ICTXQEC);
-		adapter->stats.ictxqmtc +=3D er32(ICTXQMTC);
-		adapter->stats.icrxdmtc +=3D er32(ICRXDMTC);
-	}
-
 	/* Fill out the OS statistics structure */
 	adapter->net_stats.multicast =3D adapter->stats.mprc;
 	adapter->net_stats.collisions =3D adapter->stats.colc;
@@ -2633,6 +2591,54 @@ void e1000e_update_stats(struct e1000_adapter *a=
dapter)
 	spin_unlock_irqrestore(&adapter->stats_lock, irq_flags);
 }
=20
+/**
+ * e1000_phy_read_status - Update the PHY register status snapshot
+ * @adapter: board private structure
+ **/
+static void e1000_phy_read_status(struct e1000_adapter *adapter)
+{
+	struct e1000_hw *hw =3D &adapter->hw;
+	struct e1000_phy_regs *phy =3D &adapter->phy_regs;
+	int ret_val;
+	unsigned long irq_flags;
+
+
+	spin_lock_irqsave(&adapter->stats_lock, irq_flags);
+
+	if ((er32(STATUS) & E1000_STATUS_LU) &&
+	    (adapter->hw.phy.media_type =3D=3D e1000_media_type_copper)) {
+		ret_val  =3D e1e_rphy(hw, PHY_CONTROL, &phy->bmcr);
+		ret_val |=3D e1e_rphy(hw, PHY_STATUS, &phy->bmsr);
+		ret_val |=3D e1e_rphy(hw, PHY_AUTONEG_ADV, &phy->advertise);
+		ret_val |=3D e1e_rphy(hw, PHY_LP_ABILITY, &phy->lpa);
+		ret_val |=3D e1e_rphy(hw, PHY_AUTONEG_EXP, &phy->expansion);
+		ret_val |=3D e1e_rphy(hw, PHY_1000T_CTRL, &phy->ctrl1000);
+		ret_val |=3D e1e_rphy(hw, PHY_1000T_STATUS, &phy->stat1000);
+		ret_val |=3D e1e_rphy(hw, PHY_EXT_STATUS, &phy->estatus);
+		if (ret_val)
+			ndev_warn(adapter->netdev,
+				  "Error reading PHY register\n");
+	} else {
+		/*
+		 * Do not read PHY registers if link is not up
+		 * Set values to typical power-on defaults
+		 */
+		phy->bmcr =3D (BMCR_SPEED1000 | BMCR_ANENABLE | BMCR_FULLDPLX);
+		phy->bmsr =3D (BMSR_100FULL | BMSR_100HALF | BMSR_10FULL |
+			     BMSR_10HALF | BMSR_ESTATEN | BMSR_ANEGCAPABLE |
+			     BMSR_ERCAP);
+		phy->advertise =3D (ADVERTISE_PAUSE_ASYM | ADVERTISE_PAUSE_CAP |
+				  ADVERTISE_ALL | ADVERTISE_CSMA);
+		phy->lpa =3D 0;
+		phy->expansion =3D EXPANSION_ENABLENPAGE;
+		phy->ctrl1000 =3D ADVERTISE_1000FULL;
+		phy->stat1000 =3D 0;
+		phy->estatus =3D (ESTATUS_1000_TFULL | ESTATUS_1000_THALF);
+	}
+
+	spin_unlock_irqrestore(&adapter->stats_lock, irq_flags);
+}
+
 static void e1000_print_link_info(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw =3D &adapter->hw;
@@ -2745,6 +2751,7 @@ static void e1000_watchdog_task(struct work_struc=
t *work)
 		if (!netif_carrier_ok(netdev)) {
 			bool txb2b =3D 1;
 			/* update snapshot of PHY registers on LSC */
+			e1000_phy_read_status(adapter);
 			mac->ops.get_link_up_info(&adapter->hw,
 						   &adapter->link_speed,
 						   &adapter->link_duplex);
@@ -2842,10 +2849,10 @@ link_up:
 	mac->collision_delta =3D adapter->stats.colc - adapter->colc_old;
 	adapter->colc_old =3D adapter->stats.colc;
=20
-	adapter->gorcl =3D adapter->stats.gorcl - adapter->gorcl_old;
-	adapter->gorcl_old =3D adapter->stats.gorcl;
-	adapter->gotcl =3D adapter->stats.gotcl - adapter->gotcl_old;
-	adapter->gotcl_old =3D adapter->stats.gotcl;
+	adapter->gorc =3D adapter->stats.gorc - adapter->gorc_old;
+	adapter->gorc_old =3D adapter->stats.gorc;
+	adapter->gotc =3D adapter->stats.gotc - adapter->gotc_old;
+	adapter->gotc_old =3D adapter->stats.gotc;
=20
 	e1000e_update_adaptive(&adapter->hw);
=20
@@ -3500,7 +3507,6 @@ static int e1000_mii_ioctl(struct net_device *net=
dev, struct ifreq *ifr,
 {
 	struct e1000_adapter *adapter =3D netdev_priv(netdev);
 	struct mii_ioctl_data *data =3D if_mii(ifr);
-	unsigned long irq_flags;
=20
 	if (adapter->hw.phy.media_type !=3D e1000_media_type_copper)
 		return -EOPNOTSUPP;
@@ -3512,13 +3518,40 @@ static int e1000_mii_ioctl(struct net_device *n=
etdev, struct ifreq *ifr,
 	case SIOCGMIIREG:
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
-		spin_lock_irqsave(&adapter->stats_lock, irq_flags);
-		if (e1e_rphy(&adapter->hw, data->reg_num & 0x1F,
-				   &data->val_out)) {
-			spin_unlock_irqrestore(&adapter->stats_lock, irq_flags);
+		switch (data->reg_num & 0x1F) {
+		case MII_BMCR:
+			data->val_out =3D adapter->phy_regs.bmcr;
+			break;
+		case MII_BMSR:
+			data->val_out =3D adapter->phy_regs.bmsr;
+			break;
+		case MII_PHYSID1:
+			data->val_out =3D (adapter->hw.phy.id >> 16);
+			break;
+		case MII_PHYSID2:
+			data->val_out =3D (adapter->hw.phy.id & 0xFFFF);
+			break;
+		case MII_ADVERTISE:
+			data->val_out =3D adapter->phy_regs.advertise;
+			break;
+		case MII_LPA:
+			data->val_out =3D adapter->phy_regs.lpa;
+			break;
+		case MII_EXPANSION:
+			data->val_out =3D adapter->phy_regs.expansion;
+			break;
+		case MII_CTRL1000:
+			data->val_out =3D adapter->phy_regs.ctrl1000;
+			break;
+		case MII_STAT1000:
+			data->val_out =3D adapter->phy_regs.stat1000;
+			break;
+		case MII_ESTATUS:
+			data->val_out =3D adapter->phy_regs.estatus;
+			break;
+		default:
 			return -EIO;
 		}
-		spin_unlock_irqrestore(&adapter->stats_lock, irq_flags);
 		break;
 	case SIOCSMIIREG:
 	default:
@@ -3774,6 +3807,7 @@ static pci_ers_result_t e1000_io_slot_reset(struc=
t pci_dev *pdev)
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 	pci_set_master(pdev);
+	pci_restore_state(pdev);
=20
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);
@@ -3900,6 +3934,7 @@ static int __devinit e1000_probe(struct pci_dev *=
pdev,
 		goto err_pci_reg;
=20
 	pci_set_master(pdev);
+	pci_save_state(pdev);
=20
 	err =3D -ENOMEM;
 	netdev =3D alloc_etherdev(sizeof(struct e1000_adapter));
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 3a4574c..e102332 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -116,7 +116,7 @@ s32 e1000e_phy_reset_dsp(struct e1000_hw *hw)
 }
=20
 /**
- *  e1000_read_phy_reg_mdic - Read MDI control register
+ *  e1000e_read_phy_reg_mdic - Read MDI control register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to be read
  *  @data: pointer to the read data
@@ -124,7 +124,7 @@ s32 e1000e_phy_reset_dsp(struct e1000_hw *hw)
  *  Reads the MDI control register in the PHY at offset and stores the
  *  information read to data.
  **/
-static s32 e1000_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u1=
6 *data)
+s32 e1000e_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *dat=
a)
 {
 	struct e1000_phy_info *phy =3D &hw->phy;
 	u32 i, mdic =3D 0;
@@ -150,7 +150,7 @@ static s32 e1000_read_phy_reg_mdic(struct e1000_hw =
*hw, u32 offset, u16 *data)
 	 * Increasing the time out as testing showed failures with
 	 * the lower time out
 	 */
-	for (i =3D 0; i < 64; i++) {
+	for (i =3D 0; i < (E1000_GEN_POLL_TIMEOUT * 3); i++) {
 		udelay(50);
 		mdic =3D er32(MDIC);
 		if (mdic & E1000_MDIC_READY)
@@ -170,14 +170,14 @@ static s32 e1000_read_phy_reg_mdic(struct e1000_h=
w *hw, u32 offset, u16 *data)
 }
=20
 /**
- *  e1000_write_phy_reg_mdic - Write MDI control register
+ *  e1000e_write_phy_reg_mdic - Write MDI control register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to write to
  *  @data: data to write to register at offset
  *
  *  Writes data to MDI control register in the PHY at offset.
  **/
-static s32 e1000_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u=
16 data)
+s32 e1000e_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 dat=
a)
 {
 	struct e1000_phy_info *phy =3D &hw->phy;
 	u32 i, mdic =3D 0;
@@ -199,9 +199,13 @@ static s32 e1000_write_phy_reg_mdic(struct e1000_h=
w *hw, u32 offset, u16 data)
=20
 	ew32(MDIC, mdic);
=20
-	/* Poll the ready bit to see if the MDI read completed */
-	for (i =3D 0; i < E1000_GEN_POLL_TIMEOUT; i++) {
-		udelay(5);
+	/*
+	 * Poll the ready bit to see if the MDI read completed
+	 * Increasing the time out as testing showed failures with
+	 * the lower time out
+	 */
+	for (i =3D 0; i < (E1000_GEN_POLL_TIMEOUT * 3); i++) {
+		udelay(50);
 		mdic =3D er32(MDIC);
 		if (mdic & E1000_MDIC_READY)
 			break;
@@ -210,6 +214,10 @@ static s32 e1000_write_phy_reg_mdic(struct e1000_h=
w *hw, u32 offset, u16 data)
 		hw_dbg(hw, "MDI Write did not complete\n");
 		return -E1000_ERR_PHY;
 	}
+	if (mdic & E1000_MDIC_ERROR) {
+		hw_dbg(hw, "MDI Error\n");
+		return -E1000_ERR_PHY;
+	}
=20
 	return 0;
 }
@@ -232,9 +240,8 @@ s32 e1000e_read_phy_reg_m88(struct e1000_hw *hw, u3=
2 offset, u16 *data)
 	if (ret_val)
 		return ret_val;
=20
-	ret_val =3D e1000_read_phy_reg_mdic(hw,
-					  MAX_PHY_REG_ADDRESS & offset,
-					  data);
+	ret_val =3D e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset=
,
+					   data);
=20
 	hw->phy.ops.release_phy(hw);
=20
@@ -258,9 +265,8 @@ s32 e1000e_write_phy_reg_m88(struct e1000_hw *hw, u=
32 offset, u16 data)
 	if (ret_val)
 		return ret_val;
=20
-	ret_val =3D e1000_write_phy_reg_mdic(hw,
-					   MAX_PHY_REG_ADDRESS & offset,
-					   data);
+	ret_val =3D e1000e_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offse=
t,
+					    data);
=20
 	hw->phy.ops.release_phy(hw);
=20
@@ -286,18 +292,17 @@ s32 e1000e_read_phy_reg_igp(struct e1000_hw *hw, =
u32 offset, u16 *data)
 		return ret_val;
=20
 	if (offset > MAX_PHY_MULTI_PAGE_REG) {
-		ret_val =3D e1000_write_phy_reg_mdic(hw,
-						   IGP01E1000_PHY_PAGE_SELECT,
-						   (u16)offset);
+		ret_val =3D e1000e_write_phy_reg_mdic(hw,
+						    IGP01E1000_PHY_PAGE_SELECT,
+						    (u16)offset);
 		if (ret_val) {
 			hw->phy.ops.release_phy(hw);
 			return ret_val;
 		}
 	}
=20
-	ret_val =3D e1000_read_phy_reg_mdic(hw,
-					  MAX_PHY_REG_ADDRESS & offset,
-					  data);
+	ret_val =3D e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset=
,
+					   data);
=20
 	hw->phy.ops.release_phy(hw);
=20
@@ -322,18 +327,17 @@ s32 e1000e_write_phy_reg_igp(struct e1000_hw *hw,=
 u32 offset, u16 data)
 		return ret_val;
=20
 	if (offset > MAX_PHY_MULTI_PAGE_REG) {
-		ret_val =3D e1000_write_phy_reg_mdic(hw,
-						   IGP01E1000_PHY_PAGE_SELECT,
-						   (u16)offset);
+		ret_val =3D e1000e_write_phy_reg_mdic(hw,
+						    IGP01E1000_PHY_PAGE_SELECT,
+						    (u16)offset);
 		if (ret_val) {
 			hw->phy.ops.release_phy(hw);
 			return ret_val;
 		}
 	}
=20
-	ret_val =3D e1000_write_phy_reg_mdic(hw,
-					   MAX_PHY_REG_ADDRESS & offset,
-					   data);
+	ret_val =3D e1000e_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offse=
t,
+					    data);
=20
 	hw->phy.ops.release_phy(hw);
=20
@@ -420,7 +424,9 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *h=
w)
 	if (ret_val)
 		return ret_val;
=20
-	phy_data |=3D M88E1000_PSCR_ASSERT_CRS_ON_TX;
+	/* For newer PHYs this bit is downshift enable */
+	if (phy->type =3D=3D e1000_phy_m88)
+		phy_data |=3D M88E1000_PSCR_ASSERT_CRS_ON_TX;
=20
 	/*
 	 * Options:
@@ -463,7 +469,7 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *h=
w)
 	if (ret_val)
 		return ret_val;
=20
-	if (phy->revision < 4) {
+	if ((phy->type =3D=3D e1000_phy_m88) && (phy->revision < 4)) {
 		/*
 		 * Force TX_CLK in the Extended PHY Specific Control Register
 		 * to 25MHz clock.
@@ -518,8 +524,11 @@ s32 e1000e_copper_link_setup_igp(struct e1000_hw *=
hw)
 		return ret_val;
 	}
=20
-	/* Wait 15ms for MAC to configure PHY from NVM settings. */
-	msleep(15);
+	/*
+	 * Wait 100ms for MAC to configure PHY from NVM settings, to avoid
+	 * timeout issues when LFS is enabled.
+	 */
+	msleep(100);
=20
 	/* disable lplu d0 during driver init */
 	ret_val =3D e1000_set_d0_lplu_state(hw, 0);
@@ -1152,9 +1161,7 @@ s32 e1000e_set_d3_lplu_state(struct e1000_hw *hw,=
 bool active)
=20
 	if (!active) {
 		data &=3D ~IGP02E1000_PM_D3_LPLU;
-		ret_val =3D e1e_wphy(hw,
-					     IGP02E1000_PHY_POWER_MGMT,
-					     data);
+		ret_val =3D e1e_wphy(hw, IGP02E1000_PHY_POWER_MGMT, data);
 		if (ret_val)
 			return ret_val;
 		/*
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.=
c
index 9ff7538..f9bc21c 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -2611,7 +2611,7 @@ static int ehea_stop(struct net_device *dev)
 	return ret;
 }
=20
-void ehea_purge_sq(struct ehea_qp *orig_qp)
+static void ehea_purge_sq(struct ehea_qp *orig_qp)
 {
 	struct ehea_qp qp =3D *orig_qp;
 	struct ehea_qp_init_attr *init_attr =3D &qp.init_attr;
@@ -2625,7 +2625,7 @@ void ehea_purge_sq(struct ehea_qp *orig_qp)
 	}
 }
=20
-void ehea_flush_sq(struct ehea_port *port)
+static void ehea_flush_sq(struct ehea_port *port)
 {
 	int i;
=20
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 8c4214b..35f66d4 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -96,6 +96,7 @@
 #define DEV_HAS_PAUSEFRAME_TX_V2   0x10000  /* device supports tx paus=
e frames version 2 */
 #define DEV_HAS_PAUSEFRAME_TX_V3   0x20000  /* device supports tx paus=
e frames version 3 */
 #define DEV_NEED_TX_LIMIT          0x40000  /* device needs to limit t=
x */
+#define DEV_HAS_GEAR_MODE          0x80000  /* device supports gear mo=
de */
=20
 enum {
 	NvRegIrqStatus =3D 0x000,
@@ -174,11 +175,13 @@ enum {
 	NvRegReceiverStatus =3D 0x98,
 #define NVREG_RCVSTAT_BUSY	0x01
=20
-	NvRegRandomSeed =3D 0x9c,
-#define NVREG_RNDSEED_MASK	0x00ff
-#define NVREG_RNDSEED_FORCE	0x7f00
-#define NVREG_RNDSEED_FORCE2	0x2d00
-#define NVREG_RNDSEED_FORCE3	0x7400
+	NvRegSlotTime =3D 0x9c,
+#define NVREG_SLOTTIME_LEGBF_ENABLED	0x80000000
+#define NVREG_SLOTTIME_10_100_FULL	0x00007f00
+#define NVREG_SLOTTIME_1000_FULL 	0x0003ff00
+#define NVREG_SLOTTIME_HALF		0x0000ff00
+#define NVREG_SLOTTIME_DEFAULT	 	0x00007f00
+#define NVREG_SLOTTIME_MASK		0x000000ff
=20
 	NvRegTxDeferral =3D 0xA0,
 #define NVREG_TX_DEFERRAL_DEFAULT		0x15050f
@@ -201,6 +204,11 @@ enum {
=20
 	NvRegPhyInterface =3D 0xC0,
 #define PHY_RGMII		0x10000000
+	NvRegBackOffControl =3D 0xC4,
+#define NVREG_BKOFFCTRL_DEFAULT			0x70000000
+#define NVREG_BKOFFCTRL_SEED_MASK		0x000003ff
+#define NVREG_BKOFFCTRL_SELECT			24
+#define NVREG_BKOFFCTRL_GEAR			12
=20
 	NvRegTxRingPhysAddr =3D 0x100,
 	NvRegRxRingPhysAddr =3D 0x104,
@@ -352,6 +360,7 @@ union ring_type {
=20
 #define NV_TX_LASTPACKET	(1<<16)
 #define NV_TX_RETRYERROR	(1<<19)
+#define NV_TX_RETRYCOUNT_MASK	(0xF<<20)
 #define NV_TX_FORCED_INTERRUPT	(1<<24)
 #define NV_TX_DEFERRED		(1<<26)
 #define NV_TX_CARRIERLOST	(1<<27)
@@ -362,6 +371,7 @@ union ring_type {
=20
 #define NV_TX2_LASTPACKET	(1<<29)
 #define NV_TX2_RETRYERROR	(1<<18)
+#define NV_TX2_RETRYCOUNT_MASK	(0xF<<19)
 #define NV_TX2_FORCED_INTERRUPT	(1<<30)
 #define NV_TX2_DEFERRED		(1<<25)
 #define NV_TX2_CARRIERLOST	(1<<26)
@@ -473,16 +483,22 @@ union ring_type {
 #define DESC_VER_3	3
=20
 /* PHY defines */
-#define PHY_OUI_MARVELL	0x5043
-#define PHY_OUI_CICADA	0x03f1
-#define PHY_OUI_VITESSE	0x01c1
-#define PHY_OUI_REALTEK	0x0732
+#define PHY_OUI_MARVELL		0x5043
+#define PHY_OUI_CICADA		0x03f1
+#define PHY_OUI_VITESSE		0x01c1
+#define PHY_OUI_REALTEK		0x0732
+#define PHY_OUI_REALTEK2	0x0020
 #define PHYID1_OUI_MASK	0x03ff
 #define PHYID1_OUI_SHFT	6
 #define PHYID2_OUI_MASK	0xfc00
 #define PHYID2_OUI_SHFT	10
 #define PHYID2_MODEL_MASK		0x03f0
-#define PHY_MODEL_MARVELL_E3016		0x220
+#define PHY_MODEL_REALTEK_8211		0x0110
+#define PHY_REV_MASK			0x0001
+#define PHY_REV_REALTEK_8211B		0x0000
+#define PHY_REV_REALTEK_8211C		0x0001
+#define PHY_MODEL_REALTEK_8201		0x0200
+#define PHY_MODEL_MARVELL_E3016		0x0220
 #define PHY_MARVELL_E3016_INITMASK	0x0300
 #define PHY_CICADA_INIT1	0x0f000
 #define PHY_CICADA_INIT2	0x0e00
@@ -509,10 +525,18 @@ union ring_type {
 #define PHY_REALTEK_INIT_REG1	0x1f
 #define PHY_REALTEK_INIT_REG2	0x19
 #define PHY_REALTEK_INIT_REG3	0x13
+#define PHY_REALTEK_INIT_REG4	0x14
+#define PHY_REALTEK_INIT_REG5	0x18
+#define PHY_REALTEK_INIT_REG6	0x11
 #define PHY_REALTEK_INIT1	0x0000
 #define PHY_REALTEK_INIT2	0x8e00
 #define PHY_REALTEK_INIT3	0x0001
 #define PHY_REALTEK_INIT4	0xad17
+#define PHY_REALTEK_INIT5	0xfb54
+#define PHY_REALTEK_INIT6	0xf5c7
+#define PHY_REALTEK_INIT7	0x1000
+#define PHY_REALTEK_INIT8	0x0003
+#define PHY_REALTEK_INIT_MSK1	0x0003
=20
 #define PHY_GIGABIT	0x0100
=20
@@ -691,6 +715,7 @@ struct fe_priv {
 	int wolenabled;
 	unsigned int phy_oui;
 	unsigned int phy_model;
+	unsigned int phy_rev;
 	u16 gigabit;
 	int intr_test;
 	int recover_error;
@@ -704,6 +729,7 @@ struct fe_priv {
 	u32 txrxctl_bits;
 	u32 vlanctl_bits;
 	u32 driver_data;
+	u32 device_id;
 	u32 register_size;
 	int rx_csum;
 	u32 mac_in_use;
@@ -814,6 +840,16 @@ enum {
 };
 static int dma_64bit =3D NV_DMA_64BIT_ENABLED;
=20
+/*
+ * Crossover Detection
+ * Realtek 8201 phy + some OEM boards do not work properly.
+ */
+enum {
+	NV_CROSSOVER_DETECTION_DISABLED,
+	NV_CROSSOVER_DETECTION_ENABLED
+};
+static int phy_cross =3D NV_CROSSOVER_DETECTION_DISABLED;
+
 static inline struct fe_priv *get_nvpriv(struct net_device *dev)
 {
 	return netdev_priv(dev);
@@ -1078,25 +1114,53 @@ static int phy_init(struct net_device *dev)
 		}
 	}
 	if (np->phy_oui =3D=3D PHY_OUI_REALTEK) {
-		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT=
1)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, PHY_REALTEK_INIT=
2)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT=
3)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG3, PHY_REALTEK_INIT=
4)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
-			return PHY_ERROR;
+		if (np->phy_model =3D=3D PHY_MODEL_REALTEK_8211 &&
+		    np->phy_rev =3D=3D PHY_REV_REALTEK_8211B) {
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INI=
T1)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, PHY_REALTEK_INI=
T2)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INI=
T3)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG3, PHY_REALTEK_INI=
T4)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG4, PHY_REALTEK_INI=
T5)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG5, PHY_REALTEK_INI=
T6)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INI=
T1)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
 		}
-		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT=
1)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
-			return PHY_ERROR;
+		if (np->phy_model =3D=3D PHY_MODEL_REALTEK_8201) {
+			if (np->device_id =3D=3D PCI_DEVICE_ID_NVIDIA_NVENET_32 ||
+			    np->device_id =3D=3D PCI_DEVICE_ID_NVIDIA_NVENET_33 ||
+			    np->device_id =3D=3D PCI_DEVICE_ID_NVIDIA_NVENET_34 ||
+			    np->device_id =3D=3D PCI_DEVICE_ID_NVIDIA_NVENET_35 ||
+			    np->device_id =3D=3D PCI_DEVICE_ID_NVIDIA_NVENET_36 ||
+			    np->device_id =3D=3D PCI_DEVICE_ID_NVIDIA_NVENET_37 ||
+			    np->device_id =3D=3D PCI_DEVICE_ID_NVIDIA_NVENET_38 ||
+			    np->device_id =3D=3D PCI_DEVICE_ID_NVIDIA_NVENET_39) {
+				phy_reserved =3D mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, M=
II_READ);
+				phy_reserved |=3D PHY_REALTEK_INIT7;
+				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, phy_reserved))=
 {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev))=
;
+					return PHY_ERROR;
+				}
+			}
 		}
 	}
=20
@@ -1236,26 +1300,71 @@ static int phy_init(struct net_device *dev)
 		}
 	}
 	if (np->phy_oui =3D=3D PHY_OUI_REALTEK) {
-		/* reset could have cleared these out, set them back */
-		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT=
1)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, PHY_REALTEK_INIT=
2)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT=
3)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
-			return PHY_ERROR;
-		}
-		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG3, PHY_REALTEK_INIT=
4)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
-			return PHY_ERROR;
+		if (np->phy_model =3D=3D PHY_MODEL_REALTEK_8211 &&
+		    np->phy_rev =3D=3D PHY_REV_REALTEK_8211B) {
+			/* reset could have cleared these out, set them back */
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INI=
T1)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, PHY_REALTEK_INI=
T2)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INI=
T3)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG3, PHY_REALTEK_INI=
T4)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG4, PHY_REALTEK_INI=
T5)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG5, PHY_REALTEK_INI=
T6)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INI=
T1)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
 		}
-		if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT=
1)) {
-			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
-			return PHY_ERROR;
+		if (np->phy_model =3D=3D PHY_MODEL_REALTEK_8201) {
+			if (np->device_id =3D=3D PCI_DEVICE_ID_NVIDIA_NVENET_32 ||
+			    np->device_id =3D=3D PCI_DEVICE_ID_NVIDIA_NVENET_33 ||
+			    np->device_id =3D=3D PCI_DEVICE_ID_NVIDIA_NVENET_34 ||
+			    np->device_id =3D=3D PCI_DEVICE_ID_NVIDIA_NVENET_35 ||
+			    np->device_id =3D=3D PCI_DEVICE_ID_NVIDIA_NVENET_36 ||
+			    np->device_id =3D=3D PCI_DEVICE_ID_NVIDIA_NVENET_37 ||
+			    np->device_id =3D=3D PCI_DEVICE_ID_NVIDIA_NVENET_38 ||
+			    np->device_id =3D=3D PCI_DEVICE_ID_NVIDIA_NVENET_39) {
+				phy_reserved =3D mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, M=
II_READ);
+				phy_reserved |=3D PHY_REALTEK_INIT7;
+				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, phy_reserved))=
 {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev))=
;
+					return PHY_ERROR;
+				}
+			}
+			if (phy_cross =3D=3D NV_CROSSOVER_DETECTION_DISABLED) {
+				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_IN=
IT3)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev))=
;
+					return PHY_ERROR;
+				}
+				phy_reserved =3D mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, M=
II_READ);
+				phy_reserved &=3D ~PHY_REALTEK_INIT_MSK1;
+				phy_reserved |=3D PHY_REALTEK_INIT3;
+				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, phy_reserved))=
 {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev))=
;
+					return PHY_ERROR;
+				}
+				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_IN=
IT1)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev))=
;
+					return PHY_ERROR;
+				}
+			}
 		}
 	}
=20
@@ -1769,6 +1878,115 @@ static inline u32 nv_get_empty_tx_slots(struct =
fe_priv *np)
 	return (u32)(np->tx_ring_size - ((np->tx_ring_size + (np->put_tx_ctx =
- np->get_tx_ctx)) % np->tx_ring_size));
 }
=20
+static void nv_legacybackoff_reseed(struct net_device *dev)
+{
+	u8 __iomem *base =3D get_hwbase(dev);
+	u32 reg;
+	u32 low;
+	int tx_status =3D 0;
+
+	reg =3D readl(base + NvRegSlotTime) & ~NVREG_SLOTTIME_MASK;
+	get_random_bytes(&low, sizeof(low));
+	reg |=3D low & NVREG_SLOTTIME_MASK;
+
+	/* Need to stop tx before change takes effect.
+	 * Caller has already gained np->lock.
+	 */
+	tx_status =3D readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_S=
TART;
+	if (tx_status)
+		nv_stop_tx(dev);
+	nv_stop_rx(dev);
+	writel(reg, base + NvRegSlotTime);
+	if (tx_status)
+		nv_start_tx(dev);
+	nv_start_rx(dev);
+}
+
+/* Gear Backoff Seeds */
+#define BACKOFF_SEEDSET_ROWS	8
+#define BACKOFF_SEEDSET_LFSRS	15
+
+/* Known Good seed sets */
+static const u32 main_seedset[BACKOFF_SEEDSET_ROWS][BACKOFF_SEEDSET_LF=
SRS] =3D {
+    {145, 155, 165, 175, 185, 196, 235, 245, 255, 265, 275, 285, 660, =
690, 874},
+    {245, 255, 265, 575, 385, 298, 335, 345, 355, 366, 375, 385, 761, =
790, 974},
+    {145, 155, 165, 175, 185, 196, 235, 245, 255, 265, 275, 285, 660, =
690, 874},
+    {245, 255, 265, 575, 385, 298, 335, 345, 355, 366, 375, 386, 761, =
790, 974},
+    {266, 265, 276, 585, 397, 208, 345, 355, 365, 376, 385, 396, 771, =
700, 984},
+    {266, 265, 276, 586, 397, 208, 346, 355, 365, 376, 285, 396, 771, =
700, 984},
+    {366, 365, 376, 686, 497, 308, 447, 455, 466, 476, 485, 496, 871, =
800,  84},
+    {466, 465, 476, 786, 597, 408, 547, 555, 566, 576, 585, 597, 971, =
900, 184}};
+
+static const u32 gear_seedset[BACKOFF_SEEDSET_ROWS][BACKOFF_SEEDSET_LF=
SRS] =3D {
+    {251, 262, 273, 324, 319, 508, 375, 364, 341, 371, 398, 193, 375, =
 30, 295},
+    {351, 375, 373, 469, 551, 639, 477, 464, 441, 472, 498, 293, 476, =
130, 395},
+    {351, 375, 373, 469, 551, 639, 477, 464, 441, 472, 498, 293, 476, =
130, 397},
+    {251, 262, 273, 324, 319, 508, 375, 364, 341, 371, 398, 193, 375, =
 30, 295},
+    {251, 262, 273, 324, 319, 508, 375, 364, 341, 371, 398, 193, 375, =
 30, 295},
+    {351, 375, 373, 469, 551, 639, 477, 464, 441, 472, 498, 293, 476, =
130, 395},
+    {351, 375, 373, 469, 551, 639, 477, 464, 441, 472, 498, 293, 476, =
130, 395},
+    {351, 375, 373, 469, 551, 639, 477, 464, 441, 472, 498, 293, 476, =
130, 395}};
+
+static void nv_gear_backoff_reseed(struct net_device *dev)
+{
+	u8 __iomem *base =3D get_hwbase(dev);
+	u32 miniseed1, miniseed2, miniseed2_reversed, miniseed3, miniseed3_re=
versed;
+	u32 temp, seedset, combinedSeed;
+	int i;
+
+	/* Setup seed for free running LFSR */
+	/* We are going to read the time stamp counter 3 times
+	   and swizzle bits around to increase randomness */
+	get_random_bytes(&miniseed1, sizeof(miniseed1));
+	miniseed1 &=3D 0x0fff;
+	if (miniseed1 =3D=3D 0)
+		miniseed1 =3D 0xabc;
+
+	get_random_bytes(&miniseed2, sizeof(miniseed2));
+	miniseed2 &=3D 0x0fff;
+	if (miniseed2 =3D=3D 0)
+		miniseed2 =3D 0xabc;
+	miniseed2_reversed =3D
+		((miniseed2 & 0xF00) >> 8) |
+		 (miniseed2 & 0x0F0) |
+		 ((miniseed2 & 0x00F) << 8);
+
+	get_random_bytes(&miniseed3, sizeof(miniseed3));
+	miniseed3 &=3D 0x0fff;
+	if (miniseed3 =3D=3D 0)
+		miniseed3 =3D 0xabc;
+	miniseed3_reversed =3D
+		((miniseed3 & 0xF00) >> 8) |
+		 (miniseed3 & 0x0F0) |
+		 ((miniseed3 & 0x00F) << 8);
+
+	combinedSeed =3D ((miniseed1 ^ miniseed2_reversed) << 12) |
+		       (miniseed2 ^ miniseed3_reversed);
+
+	/* Seeds can not be zero */
+	if ((combinedSeed & NVREG_BKOFFCTRL_SEED_MASK) =3D=3D 0)
+		combinedSeed |=3D 0x08;
+	if ((combinedSeed & (NVREG_BKOFFCTRL_SEED_MASK << NVREG_BKOFFCTRL_GEA=
R)) =3D=3D 0)
+		combinedSeed |=3D 0x8000;
+
+	/* No need to disable tx here */
+	temp =3D NVREG_BKOFFCTRL_DEFAULT | (0 << NVREG_BKOFFCTRL_SELECT);
+	temp |=3D combinedSeed & NVREG_BKOFFCTRL_SEED_MASK;
+	temp |=3D combinedSeed >> NVREG_BKOFFCTRL_GEAR;
+	writel(temp,base + NvRegBackOffControl);
+
+    	/* Setup seeds for all gear LFSRs. */
+	get_random_bytes(&seedset, sizeof(seedset));
+	seedset =3D seedset % BACKOFF_SEEDSET_ROWS;
+	for (i =3D 1; i <=3D BACKOFF_SEEDSET_LFSRS; i++)
+	{
+		temp =3D NVREG_BKOFFCTRL_DEFAULT | (i << NVREG_BKOFFCTRL_SELECT);
+		temp |=3D main_seedset[seedset][i-1] & 0x3ff;
+		temp |=3D ((gear_seedset[seedset][i-1] & 0x3ff) << NVREG_BKOFFCTRL_G=
EAR);
+		writel(temp, base + NvRegBackOffControl);
+	}
+}
+
 /*
  * nv_start_xmit: dev->hard_start_xmit function
  * Called with netif_tx_lock held.
@@ -2088,6 +2306,8 @@ static void nv_tx_done(struct net_device *dev)
 						dev->stats.tx_fifo_errors++;
 					if (flags & NV_TX_CARRIERLOST)
 						dev->stats.tx_carrier_errors++;
+					if ((flags & NV_TX_RETRYERROR) && !(flags & NV_TX_RETRYCOUNT_MASK=
))
+						nv_legacybackoff_reseed(dev);
 					dev->stats.tx_errors++;
 				} else {
 					dev->stats.tx_packets++;
@@ -2103,6 +2323,8 @@ static void nv_tx_done(struct net_device *dev)
 						dev->stats.tx_fifo_errors++;
 					if (flags & NV_TX2_CARRIERLOST)
 						dev->stats.tx_carrier_errors++;
+					if ((flags & NV_TX2_RETRYERROR) && !(flags & NV_TX2_RETRYCOUNT_MA=
SK))
+						nv_legacybackoff_reseed(dev);
 					dev->stats.tx_errors++;
 				} else {
 					dev->stats.tx_packets++;
@@ -2144,6 +2366,15 @@ static void nv_tx_done_optimized(struct net_devi=
ce *dev, int limit)
 		if (flags & NV_TX2_LASTPACKET) {
 			if (!(flags & NV_TX2_ERROR))
 				dev->stats.tx_packets++;
+			else {
+				if ((flags & NV_TX2_RETRYERROR) && !(flags & NV_TX2_RETRYCOUNT_MAS=
K)) {
+					if (np->driver_data & DEV_HAS_GEAR_MODE)
+						nv_gear_backoff_reseed(dev);
+					else
+						nv_legacybackoff_reseed(dev);
+				}
+			}
+
 			dev_kfree_skb_any(np->get_tx_ctx->skb);
 			np->get_tx_ctx->skb =3D NULL;
=20
@@ -2905,15 +3136,14 @@ set_speed:
 	}
=20
 	if (np->gigabit =3D=3D PHY_GIGABIT) {
-		phyreg =3D readl(base + NvRegRandomSeed);
+		phyreg =3D readl(base + NvRegSlotTime);
 		phyreg &=3D ~(0x3FF00);
-		if ((np->linkspeed & 0xFFF) =3D=3D NVREG_LINKSPEED_10)
-			phyreg |=3D NVREG_RNDSEED_FORCE3;
-		else if ((np->linkspeed & 0xFFF) =3D=3D NVREG_LINKSPEED_100)
-			phyreg |=3D NVREG_RNDSEED_FORCE2;
+		if (((np->linkspeed & 0xFFF) =3D=3D NVREG_LINKSPEED_10) ||
+		    ((np->linkspeed & 0xFFF) =3D=3D NVREG_LINKSPEED_100))
+			phyreg |=3D NVREG_SLOTTIME_10_100_FULL;
 		else if ((np->linkspeed & 0xFFF) =3D=3D NVREG_LINKSPEED_1000)
-			phyreg |=3D NVREG_RNDSEED_FORCE;
-		writel(phyreg, base + NvRegRandomSeed);
+			phyreg |=3D NVREG_SLOTTIME_1000_FULL;
+		writel(phyreg, base + NvRegSlotTime);
 	}
=20
 	phyreg =3D readl(base + NvRegPhyInterface);
@@ -4843,6 +5073,7 @@ static int nv_open(struct net_device *dev)
 	u8 __iomem *base =3D get_hwbase(dev);
 	int ret =3D 1;
 	int oom, i;
+	u32 low;
=20
 	dprintk(KERN_DEBUG "nv_open: begin\n");
=20
@@ -4902,8 +5133,20 @@ static int nv_open(struct net_device *dev)
 	writel(np->rx_buf_sz, base + NvRegOffloadConfig);
=20
 	writel(readl(base + NvRegReceiverStatus), base + NvRegReceiverStatus)=
;
-	get_random_bytes(&i, sizeof(i));
-	writel(NVREG_RNDSEED_FORCE | (i&NVREG_RNDSEED_MASK), base + NvRegRand=
omSeed);
+
+	get_random_bytes(&low, sizeof(low));
+	low &=3D NVREG_SLOTTIME_MASK;
+	if (np->desc_ver =3D=3D DESC_VER_1) {
+		writel(low|NVREG_SLOTTIME_DEFAULT, base + NvRegSlotTime);
+	} else {
+		if (!(np->driver_data & DEV_HAS_GEAR_MODE)) {
+			/* setup legacy backoff */
+			writel(NVREG_SLOTTIME_LEGBF_ENABLED|NVREG_SLOTTIME_10_100_FULL|low,=
 base + NvRegSlotTime);
+		} else {
+			writel(NVREG_SLOTTIME_10_100_FULL, base + NvRegSlotTime);
+			nv_gear_backoff_reseed(dev);
+		}
+	}
 	writel(NVREG_TX_DEFERRAL_DEFAULT, base + NvRegTxDeferral);
 	writel(NVREG_RX_DEFERRAL_DEFAULT, base + NvRegRxDeferral);
 	if (poll_interval =3D=3D -1) {
@@ -5110,6 +5353,8 @@ static int __devinit nv_probe(struct pci_dev *pci=
_dev, const struct pci_device_i
=20
 	/* copy of driver data */
 	np->driver_data =3D id->driver_data;
+	/* copy of device id */
+	np->device_id =3D id->device;
=20
 	/* handle different descriptor versions */
 	if (id->driver_data & DEV_HAS_HIGH_DMA) {
@@ -5399,6 +5644,14 @@ static int __devinit nv_probe(struct pci_dev *pc=
i_dev, const struct pci_device_i
 			pci_name(pci_dev), id1, id2, phyaddr);
 		np->phyaddr =3D phyaddr;
 		np->phy_oui =3D id1 | id2;
+
+		/* Realtek hardcoded phy id1 to all zero's on certain phys */
+		if (np->phy_oui =3D=3D PHY_OUI_REALTEK2)
+			np->phy_oui =3D PHY_OUI_REALTEK;
+		/* Setup phy revision for Realtek */
+		if (np->phy_oui =3D=3D PHY_OUI_REALTEK && np->phy_model =3D=3D PHY_M=
ODEL_REALTEK_8211)
+			np->phy_rev =3D mii_rw(dev, phyaddr, MII_RESV1, MII_READ) & PHY_REV=
_MASK;
+
 		break;
 	}
 	if (i =3D=3D 33) {
@@ -5477,6 +5730,28 @@ out:
 	return err;
 }
=20
+static void nv_restore_phy(struct net_device *dev)
+{
+	struct fe_priv *np =3D netdev_priv(dev);
+	u16 phy_reserved, mii_control;
+
+	if (np->phy_oui =3D=3D PHY_OUI_REALTEK &&
+	    np->phy_model =3D=3D PHY_MODEL_REALTEK_8201 &&
+	    phy_cross =3D=3D NV_CROSSOVER_DETECTION_DISABLED) {
+		mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT3);
+		phy_reserved =3D mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, MII=
_READ);
+		phy_reserved &=3D ~PHY_REALTEK_INIT_MSK1;
+		phy_reserved |=3D PHY_REALTEK_INIT8;
+		mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG2, phy_reserved);
+		mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1);
+
+		/* restart auto negotiation */
+		mii_control =3D mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
+		mii_control |=3D (BMCR_ANRESTART | BMCR_ANENABLE);
+		mii_rw(dev, np->phyaddr, MII_BMCR, mii_control);
+	}
+}
+
 static void __devexit nv_remove(struct pci_dev *pci_dev)
 {
 	struct net_device *dev =3D pci_get_drvdata(pci_dev);
@@ -5493,6 +5768,9 @@ static void __devexit nv_remove(struct pci_dev *p=
ci_dev)
 	writel(readl(base + NvRegTransmitPoll) & ~NVREG_TRANSMITPOLL_MAC_ADDR=
_REV,
 	       base + NvRegTransmitPoll);
=20
+	/* restore any phy related changes */
+	nv_restore_phy(dev);
+
 	/* free all structures */
 	free_rings(dev);
 	iounmap(get_hwbase(dev));
@@ -5632,83 +5910,83 @@ static struct pci_device_id pci_tbl[] =3D {
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_20),
-		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGED=
ESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME=
_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DE=
V_HAS_CORRECT_MACADDR|DEV_NEED_TX_LIMIT|DEV_NEED_TX_LIMIT,
+		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGED=
ESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME=
_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DE=
V_HAS_CORRECT_MACADDR|DEV_NEED_TX_LIMIT|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_=
MODE,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_21),
-		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGED=
ESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME=
_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DE=
V_HAS_CORRECT_MACADDR|DEV_NEED_TX_LIMIT,
+		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGED=
ESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME=
_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DE=
V_HAS_CORRECT_MACADDR|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_22),
-		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGED=
ESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME=
_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DE=
V_HAS_CORRECT_MACADDR|DEV_NEED_TX_LIMIT,
+		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGED=
ESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME=
_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DE=
V_HAS_CORRECT_MACADDR|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
 	},
 	{	/* MCP65 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_23),
-		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGED=
ESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME=
_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DE=
V_HAS_CORRECT_MACADDR|DEV_NEED_TX_LIMIT,
+		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGED=
ESC|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME=
_TX_V1|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DE=
V_HAS_CORRECT_MACADDR|DEV_NEED_TX_LIMIT|DEV_HAS_GEAR_MODE,
 	},
 	{	/* MCP67 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_24),
-		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_D=
MA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STA=
TISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACA=
DDR,
+		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_D=
MA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STA=
TISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACA=
DDR|DEV_HAS_GEAR_MODE,
 	},
 	{	/* MCP67 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_25),
-		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_D=
MA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STA=
TISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACA=
DDR,
+		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_D=
MA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STA=
TISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACA=
DDR|DEV_HAS_GEAR_MODE,
 	},
 	{	/* MCP67 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_26),
-		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_D=
MA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STA=
TISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACA=
DDR,
+		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_D=
MA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STA=
TISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACA=
DDR|DEV_HAS_GEAR_MODE,
 	},
 	{	/* MCP67 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_27),
-		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_D=
MA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STA=
TISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACA=
DDR,
+		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_D=
MA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STA=
TISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACA=
DDR|DEV_HAS_GEAR_MODE,
 	},
 	{	/* MCP73 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_28),
-		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_D=
MA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STA=
TISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACA=
DDR|DEV_HAS_COLLISION_FIX,
+		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_D=
MA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STA=
TISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACA=
DDR|DEV_HAS_COLLISION_FIX|DEV_HAS_GEAR_MODE,
 	},
 	{	/* MCP73 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_29),
-		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_D=
MA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STA=
TISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACA=
DDR|DEV_HAS_COLLISION_FIX,
+		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_D=
MA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STA=
TISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACA=
DDR|DEV_HAS_COLLISION_FIX|DEV_HAS_GEAR_MODE,
 	},
 	{	/* MCP73 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_30),
-		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_D=
MA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STA=
TISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACA=
DDR|DEV_HAS_COLLISION_FIX,
+		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_D=
MA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STA=
TISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACA=
DDR|DEV_HAS_COLLISION_FIX|DEV_HAS_GEAR_MODE,
 	},
 	{	/* MCP73 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_31),
-		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_D=
MA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STA=
TISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACA=
DDR|DEV_HAS_COLLISION_FIX,
+		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_D=
MA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX_V1|DEV_HAS_STA=
TISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACA=
DDR|DEV_HAS_COLLISION_FIX|DEV_HAS_GEAR_MODE,
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_32),
-		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKS=
UM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_=
TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV=
_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
+		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKS=
UM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_=
TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV=
_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GE=
AR_MODE,
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_33),
-		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKS=
UM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_=
TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV=
_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
+		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKS=
UM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_=
TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV=
_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GE=
AR_MODE,
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_34),
-		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKS=
UM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_=
TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV=
_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
+		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKS=
UM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_=
TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV=
_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GE=
AR_MODE,
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_35),
-		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKS=
UM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_=
TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV=
_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
+		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKS=
UM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_=
TX_V2|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV=
_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GE=
AR_MODE,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_36),
-		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKS=
UM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_=
TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV=
_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
+		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKS=
UM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_=
TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV=
_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GE=
AR_MODE,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_37),
-		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKS=
UM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_=
TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV=
_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
+		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKS=
UM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_=
TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV=
_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GE=
AR_MODE,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_38),
-		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKS=
UM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_=
TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV=
_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
+		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKS=
UM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_=
TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV=
_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GE=
AR_MODE,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_39),
-		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKS=
UM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_=
TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV=
_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT,
+		.driver_data =3D DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKS=
UM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_=
TX_V3|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV=
_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT|DEV_HAS_GE=
AR_MODE,
 	},
 	{0,},
 };
@@ -5744,6 +6022,8 @@ module_param(msix, int, 0);
 MODULE_PARM_DESC(msix, "MSIX interrupts are enabled by setting to 1 an=
d disabled by setting to 0.");
 module_param(dma_64bit, int, 0);
 MODULE_PARM_DESC(dma_64bit, "High DMA is enabled by setting to 1 and d=
isabled by setting to 0.");
+module_param(phy_cross, int, 0);
+MODULE_PARM_DESC(phy_cross, "Phy crossover detection for Realtek 8201 =
phy is enabled by setting to 1 and disabled by setting to 0.");
=20
 MODULE_AUTHOR("Manfred Spraul <manfred@colorfullife.com>");
 MODULE_DESCRIPTION("Reverse Engineered nForce ethernet driver");
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index c8c3df7..99a4b99 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -98,7 +98,6 @@
 #include "gianfar_mii.h"
=20
 #define TX_TIMEOUT      (1*HZ)
-#define SKB_ALLOC_TIMEOUT 1000000
 #undef BRIEF_GFAR_ERRORS
 #undef VERBOSE_GFAR_ERRORS
=20
@@ -115,7 +114,9 @@ static int gfar_enet_open(struct net_device *dev);
 static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev=
);
 static void gfar_timeout(struct net_device *dev);
 static int gfar_close(struct net_device *dev);
-struct sk_buff *gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp=
);
+struct sk_buff *gfar_new_skb(struct net_device *dev);
+static void gfar_new_rxbdp(struct net_device *dev, struct rxbd8 *bdp,
+		struct sk_buff *skb);
 static int gfar_set_mac_address(struct net_device *dev);
 static int gfar_change_mtu(struct net_device *dev, int new_mtu);
 static irqreturn_t gfar_error(int irq, void *dev_id);
@@ -783,14 +784,21 @@ int startup_gfar(struct net_device *dev)
=20
 	rxbdp =3D priv->rx_bd_base;
 	for (i =3D 0; i < priv->rx_ring_size; i++) {
-		struct sk_buff *skb =3D NULL;
+		struct sk_buff *skb;
=20
-		rxbdp->status =3D 0;
+		skb =3D gfar_new_skb(dev);
=20
-		skb =3D gfar_new_skb(dev, rxbdp);
+		if (!skb) {
+			printk(KERN_ERR "%s: Can't allocate RX buffers\n",
+					dev->name);
+
+			goto err_rxalloc_fail;
+		}
=20
 		priv->rx_skbuff[i] =3D skb;
=20
+		gfar_new_rxbdp(dev, rxbdp, skb);
+
 		rxbdp++;
 	}
=20
@@ -916,6 +924,7 @@ rx_irq_fail:
 tx_irq_fail:
 	free_irq(priv->interruptError, dev);
 err_irq_fail:
+err_rxalloc_fail:=09
 rx_skb_fail:
 	free_skb_resources(priv);
 tx_skb_fail:
@@ -1328,18 +1337,37 @@ static irqreturn_t gfar_transmit(int irq, void =
*dev_id)
 	return IRQ_HANDLED;
 }
=20
-struct sk_buff * gfar_new_skb(struct net_device *dev, struct rxbd8 *bd=
p)
+static void gfar_new_rxbdp(struct net_device *dev, struct rxbd8 *bdp,
+		struct sk_buff *skb)
+{
+	struct gfar_private *priv =3D netdev_priv(dev);
+	u32 * status_len =3D (u32 *)bdp;
+	u16 flags;
+
+	bdp->bufPtr =3D dma_map_single(&dev->dev, skb->data,
+			priv->rx_buffer_size, DMA_FROM_DEVICE);
+
+	flags =3D RXBD_EMPTY | RXBD_INTERRUPT;
+
+	if (bdp =3D=3D priv->rx_bd_base + priv->rx_ring_size - 1)
+		flags |=3D RXBD_WRAP;
+
+	eieio();
+
+	*status_len =3D (u32)flags << 16;
+}
+
+
+struct sk_buff * gfar_new_skb(struct net_device *dev)
 {
 	unsigned int alignamount;
 	struct gfar_private *priv =3D netdev_priv(dev);
 	struct sk_buff *skb =3D NULL;
-	unsigned int timeout =3D SKB_ALLOC_TIMEOUT;
=20
 	/* We have to allocate the skb, so keep trying till we succeed */
-	while ((!skb) && timeout--)
-		skb =3D dev_alloc_skb(priv->rx_buffer_size + RXBUF_ALIGNMENT);
+	skb =3D netdev_alloc_skb(dev, priv->rx_buffer_size + RXBUF_ALIGNMENT)=
;
=20
-	if (NULL =3D=3D skb)
+	if (!skb)
 		return NULL;
=20
 	alignamount =3D RXBUF_ALIGNMENT -
@@ -1350,15 +1378,6 @@ struct sk_buff * gfar_new_skb(struct net_device =
*dev, struct rxbd8 *bdp)
 	 */
 	skb_reserve(skb, alignamount);
=20
-	bdp->bufPtr =3D dma_map_single(&dev->dev, skb->data,
-			priv->rx_buffer_size, DMA_FROM_DEVICE);
-
-	bdp->length =3D 0;
-
-	/* Mark the buffer empty */
-	eieio();
-	bdp->status |=3D (RXBD_EMPTY | RXBD_INTERRUPT);
-
 	return skb;
 }
=20
@@ -1544,10 +1563,31 @@ int gfar_clean_rx_ring(struct net_device *dev, =
int rx_work_limit)
 	bdp =3D priv->cur_rx;
=20
 	while (!((bdp->status & RXBD_EMPTY) || (--rx_work_limit < 0))) {
+		struct sk_buff *newskb;
 		rmb();
+
+		/* Add another skb for the future */
+		newskb =3D gfar_new_skb(dev);
+
 		skb =3D priv->rx_skbuff[priv->skb_currx];
=20
-		if ((bdp->status & RXBD_LAST) && !(bdp->status & RXBD_ERR)) {
+		/* We drop the frame if we failed to allocate a new buffer */
+		if (unlikely(!newskb || !(bdp->status & RXBD_LAST) ||
+				 bdp->status & RXBD_ERR)) {
+			count_errors(bdp->status, dev);
+
+			if (unlikely(!newskb))
+				newskb =3D skb;
+
+			if (skb) {
+				dma_unmap_single(&priv->dev->dev,
+						bdp->bufPtr,
+						priv->rx_buffer_size,
+						DMA_FROM_DEVICE);
+
+				dev_kfree_skb_any(skb);
+			}
+		} else {
 			/* Increment the number of packets */
 			dev->stats.rx_packets++;
 			howmany++;
@@ -1558,23 +1598,14 @@ int gfar_clean_rx_ring(struct net_device *dev, =
int rx_work_limit)
 			gfar_process_frame(dev, skb, pkt_len);
=20
 			dev->stats.rx_bytes +=3D pkt_len;
-		} else {
-			count_errors(bdp->status, dev);
-
-			if (skb)
-				dev_kfree_skb_any(skb);
-
-			priv->rx_skbuff[priv->skb_currx] =3D NULL;
 		}
=20
 		dev->last_rx =3D jiffies;
=20
-		/* Clear the status flags for this buffer */
-		bdp->status &=3D ~RXBD_STATS;
+		priv->rx_skbuff[priv->skb_currx] =3D newskb;
=20
-		/* Add another skb for the future */
-		skb =3D gfar_new_skb(dev, bdp);
-		priv->rx_skbuff[priv->skb_currx] =3D skb;
+		/* Setup the new bdp */
+		gfar_new_rxbdp(dev, bdp, newskb);
=20
 		/* Update to the next pointer */
 		if (bdp->status & RXBD_WRAP)
@@ -1584,9 +1615,8 @@ int gfar_clean_rx_ring(struct net_device *dev, in=
t rx_work_limit)
=20
 		/* update to point at the next skb */
 		priv->skb_currx =3D
-		    (priv->skb_currx +
-		     1) & RX_RING_MOD_MASK(priv->rx_ring_size);
-
+		    (priv->skb_currx + 1) &
+		    RX_RING_MOD_MASK(priv->rx_ring_size);
 	}
=20
 	/* Update the current rxbd pointer to be the next one */
@@ -2001,12 +2031,16 @@ static irqreturn_t gfar_error(int irq, void *de=
v_id)
 	return IRQ_HANDLED;
 }
=20
+/* work with hotplug and coldplug */
+MODULE_ALIAS("platform:fsl-gianfar");
+
 /* Structure for a device driver */
 static struct platform_driver gfar_driver =3D {
 	.probe =3D gfar_probe,
 	.remove =3D gfar_remove,
 	.driver	=3D {
 		.name =3D "fsl-gianfar",
+		.owner =3D THIS_MODULE,
 	},
 };
=20
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/c=
ore.c
index 378a239..5d2108c 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -43,6 +43,8 @@
 #include <asm/io.h>
 #include <asm/dma.h>
 #include <asm/uaccess.h>
+#include <asm/dcr.h>
+#include <asm/dcr-regs.h>
=20
 #include "core.h"
=20
@@ -127,10 +129,35 @@ static struct device_node *emac_boot_list[EMAC_BO=
OT_LIST_SIZE];
 static inline void emac_report_timeout_error(struct emac_instance *dev=
,
 					     const char *error)
 {
-	if (net_ratelimit())
+	if (emac_has_feature(dev, EMAC_FTR_440GX_PHY_CLK_FIX |
+				  EMAC_FTR_440EP_PHY_CLK_FIX))
+		DBG(dev, "%s" NL, error);
+	else if (net_ratelimit())
 		printk(KERN_ERR "%s: %s\n", dev->ndev->name, error);
 }
=20
+/* EMAC PHY clock workaround:
+ * 440EP/440GR has more sane SDR0_MFR register implementation than 440=
GX,
+ * which allows controlling each EMAC clock
+ */
+static inline void emac_rx_clk_tx(struct emac_instance *dev)
+{
+#ifdef CONFIG_PPC_DCR_NATIVE
+	if (emac_has_feature(dev, EMAC_FTR_440EP_PHY_CLK_FIX))
+		dcri_clrset(SDR0, SDR0_MFR,
+			    0, SDR0_MFR_ECS >> dev->cell_index);
+#endif
+}
+
+static inline void emac_rx_clk_default(struct emac_instance *dev)
+{
+#ifdef CONFIG_PPC_DCR_NATIVE
+	if (emac_has_feature(dev, EMAC_FTR_440EP_PHY_CLK_FIX))
+		dcri_clrset(SDR0, SDR0_MFR,
+			    SDR0_MFR_ECS >> dev->cell_index, 0);
+#endif
+}
+
 /* PHY polling intervals */
 #define PHY_POLL_LINK_ON	HZ
 #define PHY_POLL_LINK_OFF	(HZ / 5)
@@ -524,7 +551,10 @@ static int emac_configure(struct emac_instance *de=
v)
 		rx_size =3D dev->rx_fifo_size_gige;
=20
 		if (dev->ndev->mtu > ETH_DATA_LEN) {
-			mr1 |=3D EMAC_MR1_JPSM;
+			if (emac_has_feature(dev, EMAC_FTR_EMAC4))
+				mr1 |=3D EMAC4_MR1_JPSM;
+			else
+				mr1 |=3D EMAC_MR1_JPSM;
 			dev->stop_timeout =3D STOP_TIMEOUT_1000_JUMBO;
 		} else
 			dev->stop_timeout =3D STOP_TIMEOUT_1000;
@@ -708,7 +738,7 @@ static int __emac_mdio_read(struct emac_instance *d=
ev, u8 id, u8 reg)
 		rgmii_get_mdio(dev->rgmii_dev, dev->rgmii_port);
=20
 	/* Wait for management interface to become idle */
-	n =3D 10;
+	n =3D 20;
 	while (!emac_phy_done(dev, in_be32(&p->stacr))) {
 		udelay(1);
 		if (!--n) {
@@ -733,7 +763,7 @@ static int __emac_mdio_read(struct emac_instance *d=
ev, u8 id, u8 reg)
 	out_be32(&p->stacr, r);
=20
 	/* Wait for read to complete */
-	n =3D 100;
+	n =3D 200;
 	while (!emac_phy_done(dev, (r =3D in_be32(&p->stacr)))) {
 		udelay(1);
 		if (!--n) {
@@ -780,7 +810,7 @@ static void __emac_mdio_write(struct emac_instance =
*dev, u8 id, u8 reg,
 		rgmii_get_mdio(dev->rgmii_dev, dev->rgmii_port);
=20
 	/* Wait for management interface to be idle */
-	n =3D 10;
+	n =3D 20;
 	while (!emac_phy_done(dev, in_be32(&p->stacr))) {
 		udelay(1);
 		if (!--n) {
@@ -806,7 +836,7 @@ static void __emac_mdio_write(struct emac_instance =
*dev, u8 id, u8 reg,
 	out_be32(&p->stacr, r);
=20
 	/* Wait for write to complete */
-	n =3D 100;
+	n =3D 200;
 	while (!emac_phy_done(dev, in_be32(&p->stacr))) {
 		udelay(1);
 		if (!--n) {
@@ -1094,9 +1124,11 @@ static int emac_open(struct net_device *ndev)
 		int link_poll_interval;
 		if (dev->phy.def->ops->poll_link(&dev->phy)) {
 			dev->phy.def->ops->read_link(&dev->phy);
+			emac_rx_clk_default(dev);
 			netif_carrier_on(dev->ndev);
 			link_poll_interval =3D PHY_POLL_LINK_ON;
 		} else {
+			emac_rx_clk_tx(dev);
 			netif_carrier_off(dev->ndev);
 			link_poll_interval =3D PHY_POLL_LINK_OFF;
 		}
@@ -1174,6 +1206,7 @@ static void emac_link_timer(struct work_struct *w=
ork)
=20
 	if (dev->phy.def->ops->poll_link(&dev->phy)) {
 		if (!netif_carrier_ok(dev->ndev)) {
+			emac_rx_clk_default(dev);
 			/* Get new link parameters */
 			dev->phy.def->ops->read_link(&dev->phy);
=20
@@ -1186,6 +1219,7 @@ static void emac_link_timer(struct work_struct *w=
ork)
 		link_poll_interval =3D PHY_POLL_LINK_ON;
 	} else {
 		if (netif_carrier_ok(dev->ndev)) {
+			emac_rx_clk_tx(dev);
 			netif_carrier_off(dev->ndev);
 			netif_tx_disable(dev->ndev);
 			emac_reinitialize(dev);
@@ -2237,7 +2271,7 @@ static int __devinit emac_of_bus_notify(struct no=
tifier_block *nb,
 	return 0;
 }
=20
-static struct notifier_block emac_of_bus_notifier =3D {
+static struct notifier_block emac_of_bus_notifier __devinitdata =3D {
 	.notifier_call =3D emac_of_bus_notify
 };
=20
@@ -2330,6 +2364,19 @@ static int __devinit emac_init_phy(struct emac_i=
nstance *dev)
 	dev->phy.mdio_read =3D emac_mdio_read;
 	dev->phy.mdio_write =3D emac_mdio_write;
=20
+	/* Enable internal clock source */
+#ifdef CONFIG_PPC_DCR_NATIVE
+	if (emac_has_feature(dev, EMAC_FTR_440GX_PHY_CLK_FIX))
+		dcri_clrset(SDR0, SDR0_MFR, 0, SDR0_MFR_ECS);
+#endif
+	/* PHY clock workaround */
+	emac_rx_clk_tx(dev);
+
+	/* Enable internal clock source on 440GX*/
+#ifdef CONFIG_PPC_DCR_NATIVE
+	if (emac_has_feature(dev, EMAC_FTR_440GX_PHY_CLK_FIX))
+		dcri_clrset(SDR0, SDR0_MFR, 0, SDR0_MFR_ECS);
+#endif
 	/* Configure EMAC with defaults so we can at least use MDIO
 	 * This is needed mostly for 440GX
 	 */
@@ -2362,6 +2409,12 @@ static int __devinit emac_init_phy(struct emac_i=
nstance *dev)
 			if (!emac_mii_phy_probe(&dev->phy, i))
 				break;
 		}
+
+	/* Enable external clock source */
+#ifdef CONFIG_PPC_DCR_NATIVE
+	if (emac_has_feature(dev, EMAC_FTR_440GX_PHY_CLK_FIX))
+		dcri_clrset(SDR0, SDR0_MFR, SDR0_MFR_ECS, 0);
+#endif
 	mutex_unlock(&emac_phy_map_lock);
 	if (i =3D=3D 0x20) {
 		printk(KERN_WARNING "%s: can't find PHY!\n", np->full_name);
@@ -2487,8 +2540,15 @@ static int __devinit emac_init_config(struct ema=
c_instance *dev)
 	}
=20
 	/* Check EMAC version */
-	if (of_device_is_compatible(np, "ibm,emac4"))
+	if (of_device_is_compatible(np, "ibm,emac4")) {
 		dev->features |=3D EMAC_FTR_EMAC4;
+		if (of_device_is_compatible(np, "ibm,emac-440gx"))
+			dev->features |=3D EMAC_FTR_440GX_PHY_CLK_FIX;
+	} else {
+		if (of_device_is_compatible(np, "ibm,emac-440ep") ||
+		    of_device_is_compatible(np, "ibm,emac-440gr"))
+			dev->features |=3D EMAC_FTR_440EP_PHY_CLK_FIX;
+	}
=20
 	/* Fixup some feature bits based on the device tree */
 	if (of_get_property(np, "has-inverted-stacr-oc", NULL))
@@ -2559,8 +2619,11 @@ static int __devinit emac_probe(struct of_device=
 *ofdev,
 	struct device_node **blist =3D NULL;
 	int err, i;
=20
-	/* Skip unused/unwired EMACS */
-	if (of_get_property(np, "unused", NULL))
+	/* Skip unused/unwired EMACS.  We leave the check for an unused
+	 * property here for now, but new flat device trees should set a
+	 * status property to "disabled" instead.
+	 */
+	if (of_get_property(np, "unused", NULL) || !of_device_is_available(np=
))
 		return -ENODEV;
=20
 	/* Find ourselves in the bootlist if we are there */
diff --git a/drivers/net/ibm_newemac/core.h b/drivers/net/ibm_newemac/c=
ore.h
index 4e74d82..1683db9 100644
--- a/drivers/net/ibm_newemac/core.h
+++ b/drivers/net/ibm_newemac/core.h
@@ -301,6 +301,14 @@ struct emac_instance {
  * Set if we have new type STACR with STAOPC
  */
 #define EMAC_FTR_HAS_NEW_STACR		0x00000040
+/*
+ * Set if we need phy clock workaround for 440gx
+ */
+#define EMAC_FTR_440GX_PHY_CLK_FIX	0x00000080
+/*
+ * Set if we need phy clock workaround for 440ep or 440gr
+ */
+#define EMAC_FTR_440EP_PHY_CLK_FIX	0x00000100
=20
=20
 /* Right now, we don't quite handle the always/possible masks on the
@@ -312,8 +320,8 @@ enum {
=20
 	EMAC_FTRS_POSSIBLE	=3D
 #ifdef CONFIG_IBM_NEW_EMAC_EMAC4
-	    EMAC_FTR_EMAC4	| EMAC_FTR_HAS_NEW_STACR	|
-	    EMAC_FTR_STACR_OC_INVERT	|
+	    EMAC_FTR_EMAC4 | EMAC_FTR_HAS_NEW_STACR |
+	    EMAC_FTR_STACR_OC_INVERT | EMAC_FTR_440GX_PHY_CLK_FIX |
 #endif
 #ifdef CONFIG_IBM_NEW_EMAC_TAH
 	    EMAC_FTR_HAS_TAH	|
@@ -324,7 +332,7 @@ enum {
 #ifdef CONFIG_IBM_NEW_EMAC_RGMII
 	    EMAC_FTR_HAS_RGMII	|
 #endif
-	    0,
+	EMAC_FTR_440EP_PHY_CLK_FIX,
 };
=20
 static inline int emac_has_feature(struct emac_instance *dev,
diff --git a/drivers/net/ibm_newemac/mal.c b/drivers/net/ibm_newemac/ma=
l.c
index 6869f08..10c267b 100644
--- a/drivers/net/ibm_newemac/mal.c
+++ b/drivers/net/ibm_newemac/mal.c
@@ -61,8 +61,8 @@ int __devinit mal_register_commac(struct mal_instance=
	*mal,
 	return 0;
 }
=20
-void __devexit mal_unregister_commac(struct mal_instance	*mal,
-				     struct mal_commac		*commac)
+void mal_unregister_commac(struct mal_instance	*mal,
+		struct mal_commac *commac)
 {
 	unsigned long flags;
=20
@@ -136,6 +136,14 @@ void mal_enable_rx_channel(struct mal_instance *ma=
l, int channel)
 {
 	unsigned long flags;
=20
+	/*
+	 * On some 4xx PPC's (e.g. 460EX/GT), the rx channel is a multiple
+	 * of 8, but enabling in MAL_RXCASR needs the divided by 8 value
+	 * for the bitmask
+	 */
+	if (!(channel % 8))
+		channel >>=3D 3;
+
 	spin_lock_irqsave(&mal->lock, flags);
=20
 	MAL_DBG(mal, "enable_rx(%d)" NL, channel);
@@ -148,6 +156,14 @@ void mal_enable_rx_channel(struct mal_instance *ma=
l, int channel)
=20
 void mal_disable_rx_channel(struct mal_instance *mal, int channel)
 {
+	/*
+	 * On some 4xx PPC's (e.g. 460EX/GT), the rx channel is a multiple
+	 * of 8, but enabling in MAL_RXCASR needs the divided by 8 value
+	 * for the bitmask
+	 */
+	if (!(channel % 8))
+		channel >>=3D 3;
+
 	set_mal_dcrn(mal, MAL_RXCARR, MAL_CHAN_MASK(channel));
=20
 	MAL_DBG(mal, "disable_rx(%d)" NL, channel);
diff --git a/drivers/net/ibm_newemac/rgmii.c b/drivers/net/ibm_newemac/=
rgmii.c
index 5757788..e32da3d 100644
--- a/drivers/net/ibm_newemac/rgmii.c
+++ b/drivers/net/ibm_newemac/rgmii.c
@@ -179,7 +179,7 @@ void rgmii_put_mdio(struct of_device *ofdev, int in=
put)
 	mutex_unlock(&dev->lock);
 }
=20
-void __devexit rgmii_detach(struct of_device *ofdev, int input)
+void rgmii_detach(struct of_device *ofdev, int input)
 {
 	struct rgmii_instance *dev =3D dev_get_drvdata(&ofdev->dev);
 	struct rgmii_regs __iomem *p =3D dev->base;
diff --git a/drivers/net/ibm_newemac/tah.c b/drivers/net/ibm_newemac/ta=
h.c
index b023d10..30173a9 100644
--- a/drivers/net/ibm_newemac/tah.c
+++ b/drivers/net/ibm_newemac/tah.c
@@ -35,7 +35,7 @@ int __devinit tah_attach(struct of_device *ofdev, int=
 channel)
 	return 0;
 }
=20
-void __devexit tah_detach(struct of_device *ofdev, int channel)
+void tah_detach(struct of_device *ofdev, int channel)
 {
 	struct tah_instance *dev =3D dev_get_drvdata(&ofdev->dev);
=20
diff --git a/drivers/net/ibm_newemac/zmii.c b/drivers/net/ibm_newemac/z=
mii.c
index 2ea472a..17b1541 100644
--- a/drivers/net/ibm_newemac/zmii.c
+++ b/drivers/net/ibm_newemac/zmii.c
@@ -189,7 +189,7 @@ void zmii_set_speed(struct of_device *ofdev, int in=
put, int speed)
 	mutex_unlock(&dev->lock);
 }
=20
-void __devexit zmii_detach(struct of_device *ofdev, int input)
+void zmii_detach(struct of_device *ofdev, int input)
 {
 	struct zmii_instance *dev =3D dev_get_drvdata(&ofdev->dev);
=20
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index aaee02e..ae398f0 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -871,6 +871,7 @@ static int __devinit igb_probe(struct pci_dev *pdev=
,
 		goto err_pci_reg;
=20
 	pci_set_master(pdev);
+	pci_save_state(pdev);
=20
 	err =3D -ENOMEM;
 	netdev =3D alloc_etherdev(sizeof(struct igb_adapter));
@@ -4079,6 +4080,7 @@ static pci_ers_result_t igb_io_slot_reset(struct =
pci_dev *pdev)
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 	pci_set_master(pdev);
+	pci_restore_state(pdev);
=20
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 9f58452..083b0dd 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -60,6 +60,7 @@ static struct platform_driver ali_ircc_driver =3D {
 	.resume		=3D ali_ircc_resume,
 	.driver		=3D {
 		.name	=3D ALI_IRCC_DRIVER_NAME,
+		.owner	=3D THIS_MODULE,
 	},
 };
=20
@@ -2256,6 +2257,7 @@ static void FIR2SIR(int iobase)
 MODULE_AUTHOR("Benjamin Kong <benjamin_kong@ali.com.tw>");
 MODULE_DESCRIPTION("ALi FIR Controller Driver");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:" ALI_IRCC_DRIVER_NAME);
=20
=20
 module_param_array(io, int, NULL, 0);
diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_i=
r.c
index 8c09344..60b94bb 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -897,6 +897,7 @@ static int pxa_irda_remove(struct platform_device *=
_dev)
 static struct platform_driver pxa_ir_driver =3D {
 	.driver         =3D {
 		.name   =3D "pxa2xx-ir",
+		.owner	=3D THIS_MODULE,
 	},
 	.probe		=3D pxa_irda_probe,
 	.remove		=3D pxa_irda_remove,
@@ -918,3 +919,4 @@ module_init(pxa_irda_init);
 module_exit(pxa_irda_exit);
=20
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:pxa2xx-ir");
diff --git a/drivers/net/irda/sa1100_ir.c b/drivers/net/irda/sa1100_ir.=
c
index 056639f..1bc8518 100644
--- a/drivers/net/irda/sa1100_ir.c
+++ b/drivers/net/irda/sa1100_ir.c
@@ -1008,6 +1008,7 @@ static struct platform_driver sa1100ir_driver =3D=
 {
 	.resume		=3D sa1100_irda_resume,
 	.driver		=3D {
 		.name	=3D "sa11x0-ir",
+		.owner	=3D THIS_MODULE,
 	},
 };
=20
@@ -1041,3 +1042,4 @@ MODULE_LICENSE("GPL");
 MODULE_PARM_DESC(power_level, "IrDA power level, 1 (low) to 3 (high)")=
;
 MODULE_PARM_DESC(tx_lpm, "Enable transmitter low power (1.6us) mode");
 MODULE_PARM_DESC(max_rate, "Maximum baud rate (4000000, 115200, 57600,=
 38400, 19200, 9600)");
+MODULE_ALIAS("platform:sa11x0-ir");
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_m=
ain.c
index cb371a8..7b85922 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3431,6 +3431,7 @@ static int __devinit ixgbe_probe(struct pci_dev *=
pdev,
 	}
=20
 	pci_set_master(pdev);
+	pci_save_state(pdev);
=20
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	netdev =3D alloc_etherdev_mq(sizeof(struct ixgbe_adapter), MAX_TX_QUE=
UES);
@@ -3721,6 +3722,7 @@ static pci_ers_result_t ixgbe_io_slot_reset(struc=
t pci_dev *pdev)
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 	pci_set_master(pdev);
+	pci_restore_state(pdev);
=20
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);
diff --git a/drivers/net/jazzsonic.c b/drivers/net/jazzsonic.c
index 5c154fe..0794482 100644
--- a/drivers/net/jazzsonic.c
+++ b/drivers/net/jazzsonic.c
@@ -249,6 +249,7 @@ out:
 MODULE_DESCRIPTION("Jazz SONIC ethernet driver");
 module_param(sonic_debug, int, 0);
 MODULE_PARM_DESC(sonic_debug, "jazzsonic debug level (1-4)");
+MODULE_ALIAS("platform:jazzsonic");
=20
 #include "sonic.c"
=20
@@ -271,6 +272,7 @@ static struct platform_driver jazz_sonic_driver =3D=
 {
 	.remove	=3D __devexit_p(jazz_sonic_device_remove),
 	.driver	=3D {
 		.name	=3D jazz_sonic_string,
+		.owner	=3D THIS_MODULE,
 	},
 };
=20
diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index 1d24a73..e185763 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -883,7 +883,7 @@ static int korina_init(struct net_device *dev)
 static int korina_restart(struct net_device *dev)
 {
 	struct korina_private *lp =3D netdev_priv(dev);
-	int ret =3D 0;
+	int ret;
=20
 	/*
 	 * Disable interrupts
@@ -987,7 +987,7 @@ static void korina_poll_controller(struct net_devic=
e *dev)
 static int korina_open(struct net_device *dev)
 {
 	struct korina_private *lp =3D netdev_priv(dev);
-	int ret =3D 0;
+	int ret;
=20
 	/* Initialize */
 	ret =3D korina_init(dev);
@@ -1031,6 +1031,8 @@ static int korina_open(struct net_device *dev)
 		    dev->name, lp->und_irq);
 		goto err_free_ovr_irq;
 	}
+out:
+	return ret;
=20
 err_free_ovr_irq:
 	free_irq(lp->ovr_irq, dev);
@@ -1041,8 +1043,6 @@ err_free_rx_irq:
 err_release:
 	korina_free_ring(dev);
 	goto out;
-out:
-	return ret;
 }
=20
 static int korina_close(struct net_device *dev)
@@ -1082,7 +1082,7 @@ static int korina_probe(struct platform_device *p=
dev)
 	struct korina_private *lp;
 	struct net_device *dev;
 	struct resource *r;
-	int retval, err;
+	int rc;
=20
 	dev =3D alloc_etherdev(sizeof(struct korina_private));
 	if (!dev) {
@@ -1106,7 +1106,7 @@ static int korina_probe(struct platform_device *p=
dev)
 	lp->eth_regs =3D ioremap_nocache(r->start, r->end - r->start);
 	if (!lp->eth_regs) {
 		printk(KERN_ERR DRV_NAME "cannot remap registers\n");
-		retval =3D -ENXIO;
+		rc =3D -ENXIO;
 		goto probe_err_out;
 	}
=20
@@ -1114,7 +1114,7 @@ static int korina_probe(struct platform_device *p=
dev)
 	lp->rx_dma_regs =3D ioremap_nocache(r->start, r->end - r->start);
 	if (!lp->rx_dma_regs) {
 		printk(KERN_ERR DRV_NAME "cannot remap Rx DMA registers\n");
-		retval =3D -ENXIO;
+		rc =3D -ENXIO;
 		goto probe_err_dma_rx;
 	}
=20
@@ -1122,14 +1122,14 @@ static int korina_probe(struct platform_device =
*pdev)
 	lp->tx_dma_regs =3D ioremap_nocache(r->start, r->end - r->start);
 	if (!lp->tx_dma_regs) {
 		printk(KERN_ERR DRV_NAME "cannot remap Tx DMA registers\n");
-		retval =3D -ENXIO;
+		rc =3D -ENXIO;
 		goto probe_err_dma_tx;
 	}
=20
 	lp->td_ring =3D kmalloc(TD_RING_SIZE + RD_RING_SIZE, GFP_KERNEL);
 	if (!lp->td_ring) {
 		printk(KERN_ERR DRV_NAME "cannot allocate descriptors\n");
-		retval =3D -ENOMEM;
+		rc =3D -ENXIO;
 		goto probe_err_td_ring;
 	}
=20
@@ -1166,14 +1166,14 @@ static int korina_probe(struct platform_device =
*pdev)
 	lp->mii_if.phy_id_mask =3D 0x1f;
 	lp->mii_if.reg_num_mask =3D 0x1f;
=20
-	err =3D register_netdev(dev);
-	if (err) {
+	rc =3D register_netdev(dev);
+	if (rc < 0) {
 		printk(KERN_ERR DRV_NAME
-			": cannot register net device %d\n", err);
-		retval =3D -EINVAL;
+			": cannot register net device %d\n", rc);
 		goto probe_err_register;
 	}
-	return 0;
+out:
+	return rc;
=20
 probe_err_register:
 	kfree(lp->td_ring);
@@ -1185,7 +1185,7 @@ probe_err_dma_rx:
 	iounmap(lp->eth_regs);
 probe_err_out:
 	free_netdev(dev);
-	return retval;
+	goto out;
 }
=20
 static int korina_remove(struct platform_device *pdev)
@@ -1193,12 +1193,9 @@ static int korina_remove(struct platform_device =
*pdev)
 	struct korina_device *bif =3D platform_get_drvdata(pdev);
 	struct korina_private *lp =3D netdev_priv(bif->dev);
=20
-	if (lp->eth_regs)
-		iounmap(lp->eth_regs);
-	if (lp->rx_dma_regs)
-		iounmap(lp->rx_dma_regs);
-	if (lp->tx_dma_regs)
-		iounmap(lp->tx_dma_regs);
+	iounmap(lp->eth_regs);
+	iounmap(lp->rx_dma_regs);
+	iounmap(lp->tx_dma_regs);
=20
 	platform_set_drvdata(pdev, NULL);
 	unregister_netdev(bif->dev);
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index d513bb8..92dccd4 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -1281,6 +1281,7 @@ static struct platform_driver macb_driver =3D {
 	.remove		=3D __exit_p(macb_remove),
 	.driver		=3D {
 		.name		=3D "macb",
+		.owner	=3D THIS_MODULE,
 	},
 };
=20
@@ -1300,3 +1301,4 @@ module_exit(macb_exit);
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Atmel MACB Ethernet driver");
 MODULE_AUTHOR("Haavard Skinnemoen <hskinnemoen@atmel.com>");
+MODULE_ALIAS("platform:macb");
diff --git a/drivers/net/meth.c b/drivers/net/meth.c
index cdaa8fc..0b32648 100644
--- a/drivers/net/meth.c
+++ b/drivers/net/meth.c
@@ -830,6 +830,7 @@ static struct platform_driver meth_driver =3D {
 	.remove	=3D __devexit_p(meth_remove),
 	.driver =3D {
 		.name	=3D "meth",
+		.owner	=3D THIS_MODULE,
 	}
 };
=20
@@ -855,3 +856,4 @@ module_exit(meth_exit_module);
 MODULE_AUTHOR("Ilya Volynets <ilya@theIlya.com>");
 MODULE_DESCRIPTION("SGI O2 Builtin Fast Ethernet driver");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:meth");
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 601ffd6..381b36e 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2030,6 +2030,7 @@ static struct platform_driver mv643xx_eth_driver =
=3D {
 	.shutdown =3D mv643xx_eth_shutdown,
 	.driver =3D {
 		.name =3D MV643XX_ETH_NAME,
+		.owner	=3D THIS_MODULE,
 	},
 };
=20
@@ -2038,6 +2039,7 @@ static struct platform_driver mv643xx_eth_shared_=
driver =3D {
 	.remove =3D mv643xx_eth_shared_remove,
 	.driver =3D {
 		.name =3D MV643XX_ETH_SHARED_NAME,
+		.owner	=3D THIS_MODULE,
 	},
 };
=20
@@ -2085,7 +2087,8 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR(	"Rabeeh Khoury, Assaf Hoffman, Matthew Dharm, Manish La=
chwani"
 		" and Dale Farnsworth");
 MODULE_DESCRIPTION("Ethernet driver for Marvell MV643XX");
-MODULE_ALIAS("platform:mv643xx_eth");
+MODULE_ALIAS("platform:" MV643XX_ETH_NAME);
+MODULE_ALIAS("platform:" MV643XX_ETH_SHARED_NAME);
=20
 /*
  * The second part is the low level driver of the gigE ethernet ports.
diff --git a/drivers/net/netx-eth.c b/drivers/net/netx-eth.c
index 78d34af..dc442e3 100644
--- a/drivers/net/netx-eth.c
+++ b/drivers/net/netx-eth.c
@@ -502,4 +502,4 @@ module_exit(netx_eth_cleanup);
=20
 MODULE_AUTHOR("Sascha Hauer, Pengutronix");
 MODULE_LICENSE("GPL");
-
+MODULE_ALIAS("platform:" CARDNAME);
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/ne=
txen_nic_hw.c
index 05748ca..af73564 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1132,8 +1132,8 @@ void netxen_nic_flash_print(struct netxen_adapter=
 *adapter)
 	u32 fw_minor =3D 0;
 	u32 fw_build =3D 0;
 	char brd_name[NETXEN_MAX_SHORT_NAME];
-	struct netxen_new_user_info user_info;
-	int i, addr =3D NETXEN_USER_START;
+	char serial_num[32];
+	int i, addr;
 	__le32 *ptr32;
=20
 	struct netxen_board_info *board_info =3D &(adapter->ahw.boardcfg);
@@ -1150,10 +1150,10 @@ void netxen_nic_flash_print(struct netxen_adapt=
er *adapter)
 		valid =3D 0;
 	}
 	if (valid) {
-		ptr32 =3D (u32 *) & user_info;
-		for (i =3D 0;
-		     i < sizeof(struct netxen_new_user_info) / sizeof(u32);
-		     i++) {
+		ptr32 =3D (u32 *)&serial_num;
+		addr =3D NETXEN_USER_START +
+		       offsetof(struct netxen_new_user_info, serial_num);
+		for (i =3D 0; i < 8; i++) {
 			if (netxen_rom_fast_read(adapter, addr, ptr32) =3D=3D -1) {
 				printk("%s: ERROR reading %s board userarea.\n",
 				       netxen_nic_driver_name,
@@ -1163,10 +1163,11 @@ void netxen_nic_flash_print(struct netxen_adapt=
er *adapter)
 			ptr32++;
 			addr +=3D sizeof(u32);
 		}
+
 		get_brd_name_by_type(board_info->board_type, brd_name);
=20
 		printk("NetXen %s Board S/N %s  Chip id 0x%x\n",
-		       brd_name, user_info.serial_num, board_info->chip_id);
+		       brd_name, serial_num, board_info->chip_id);
=20
 		printk("NetXen %s Board #%d, Chip id 0x%x\n",
 		       board_info->board_type =3D=3D 0x0b ? "XGB" : "GBE",
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 963630c..94e0b7e 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -89,6 +89,9 @@ int mdiobus_register(struct mii_bus *bus)
=20
 			phydev->bus =3D bus;
=20
+			/* Run all of the fixups for this PHY */
+			phy_scan_fixups(phydev);
+
 			err =3D device_register(&phydev->dev);
=20
 			if (err) {
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 12fccb1..3c18bb5 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -406,8 +406,10 @@ int phy_mii_ioctl(struct phy_device *phydev,
 	=09
 		if (mii_data->reg_num =3D=3D MII_BMCR=20
 				&& val & BMCR_RESET
-				&& phydev->drv->config_init)
+				&& phydev->drv->config_init) {
+			phy_scan_fixups(phydev);
 			phydev->drv->config_init(phydev);
+		}
 		break;
=20
 	default:
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.=
c
index 8b1121b..ddf8d51 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -53,6 +53,96 @@ static void phy_device_release(struct device *dev)
 	phy_device_free(to_phy_device(dev));
 }
=20
+static LIST_HEAD(phy_fixup_list);
+static DEFINE_MUTEX(phy_fixup_lock);
+
+/*
+ * Creates a new phy_fixup and adds it to the list
+ * @bus_id: A string which matches phydev->dev.bus_id (or PHY_ANY_ID)
+ * @phy_uid: Used to match against phydev->phy_id (the UID of the PHY)
+ * 	It can also be PHY_ANY_UID
+ * @phy_uid_mask: Applied to phydev->phy_id and fixup->phy_uid before
+ * 	comparison
+ * @run: The actual code to be run when a matching PHY is found
+ */
+int phy_register_fixup(const char *bus_id, u32 phy_uid, u32 phy_uid_ma=
sk,
+		int (*run)(struct phy_device *))
+{
+	struct phy_fixup *fixup;
+
+	fixup =3D kzalloc(sizeof(struct phy_fixup), GFP_KERNEL);
+	if (!fixup)
+		return -ENOMEM;
+
+	strncpy(fixup->bus_id, bus_id, BUS_ID_SIZE);
+	fixup->phy_uid =3D phy_uid;
+	fixup->phy_uid_mask =3D phy_uid_mask;
+	fixup->run =3D run;
+
+	mutex_lock(&phy_fixup_lock);
+	list_add_tail(&fixup->list, &phy_fixup_list);
+	mutex_unlock(&phy_fixup_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(phy_register_fixup);
+
+/* Registers a fixup to be run on any PHY with the UID in phy_uid */
+int phy_register_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask,
+		int (*run)(struct phy_device *))
+{
+	return phy_register_fixup(PHY_ANY_ID, phy_uid, phy_uid_mask, run);
+}
+EXPORT_SYMBOL(phy_register_fixup_for_uid);
+
+/* Registers a fixup to be run on the PHY with id string bus_id */
+int phy_register_fixup_for_id(const char *bus_id,
+		int (*run)(struct phy_device *))
+{
+	return phy_register_fixup(bus_id, PHY_ANY_UID, 0xffffffff, run);
+}
+EXPORT_SYMBOL(phy_register_fixup_for_id);
+
+/*
+ * Returns 1 if fixup matches phydev in bus_id and phy_uid.
+ * Fixups can be set to match any in one or more fields.
+ */
+static int phy_needs_fixup(struct phy_device *phydev, struct phy_fixup=
 *fixup)
+{
+	if (strcmp(fixup->bus_id, phydev->dev.bus_id) !=3D 0)
+		if (strcmp(fixup->bus_id, PHY_ANY_ID) !=3D 0)
+			return 0;
+
+	if ((fixup->phy_uid & fixup->phy_uid_mask) !=3D
+			(phydev->phy_id & fixup->phy_uid_mask))
+		if (fixup->phy_uid !=3D PHY_ANY_UID)
+			return 0;
+
+	return 1;
+}
+
+/* Runs any matching fixups for this phydev */
+int phy_scan_fixups(struct phy_device *phydev)
+{
+	struct phy_fixup *fixup;
+
+	mutex_lock(&phy_fixup_lock);
+	list_for_each_entry(fixup, &phy_fixup_list, list) {
+		if (phy_needs_fixup(phydev, fixup)) {
+			int err;
+
+			err =3D fixup->run(phydev);
+
+			if (err < 0)
+				return err;
+		}
+	}
+	mutex_unlock(&phy_fixup_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(phy_scan_fixups);
+
 struct phy_device* phy_device_create(struct mii_bus *bus, int addr, in=
t phy_id)
 {
 	struct phy_device *dev;
@@ -179,13 +269,13 @@ void phy_prepare_link(struct phy_device *phydev,
  *   choose to call only the subset of functions which provide
  *   the desired functionality.
  */
-struct phy_device * phy_connect(struct net_device *dev, const char *ph=
y_id,
+struct phy_device * phy_connect(struct net_device *dev, const char *bu=
s_id,
 		void (*handler)(struct net_device *), u32 flags,
 		phy_interface_t interface)
 {
 	struct phy_device *phydev;
=20
-	phydev =3D phy_attach(dev, phy_id, flags, interface);
+	phydev =3D phy_attach(dev, bus_id, flags, interface);
=20
 	if (IS_ERR(phydev))
 		return phydev;
@@ -226,7 +316,7 @@ static int phy_compare_id(struct device *dev, void =
*data)
 /**
  * phy_attach - attach a network device to a particular PHY device
  * @dev: network device to attach
- * @phy_id: PHY device to attach
+ * @bus_id: PHY device to attach
  * @flags: PHY device's dev_flags
  * @interface: PHY device's interface
  *
@@ -238,7 +328,7 @@ static int phy_compare_id(struct device *dev, void =
*data)
  *     change.  The phy_device is returned to the attaching driver.
  */
 struct phy_device *phy_attach(struct net_device *dev,
-		const char *phy_id, u32 flags, phy_interface_t interface)
+		const char *bus_id, u32 flags, phy_interface_t interface)
 {
 	struct bus_type *bus =3D &mdio_bus_type;
 	struct phy_device *phydev;
@@ -246,12 +336,12 @@ struct phy_device *phy_attach(struct net_device *=
dev,
=20
 	/* Search the list of PHY devices on the mdio bus for the
 	 * PHY with the requested name */
-	d =3D bus_find_device(bus, NULL, (void *)phy_id, phy_compare_id);
+	d =3D bus_find_device(bus, NULL, (void *)bus_id, phy_compare_id);
=20
 	if (d) {
 		phydev =3D to_phy_device(d);
 	} else {
-		printk(KERN_ERR "%s not found\n", phy_id);
+		printk(KERN_ERR "%s not found\n", bus_id);
 		return ERR_PTR(-ENODEV);
 	}
=20
@@ -271,7 +361,7 @@ struct phy_device *phy_attach(struct net_device *de=
v,
=20
 	if (phydev->attached_dev) {
 		printk(KERN_ERR "%s: %s already attached\n",
-				dev->name, phy_id);
+				dev->name, bus_id);
 		return ERR_PTR(-EBUSY);
 	}
=20
@@ -287,6 +377,11 @@ struct phy_device *phy_attach(struct net_device *d=
ev,
 	if (phydev->drv->config_init) {
 		int err;
=20
+		err =3D phy_scan_fixups(phydev);
+
+		if (err < 0)
+			return ERR_PTR(err);
+
 		err =3D phydev->drv->config_init(phydev);
=20
 		if (err < 0)
@@ -395,6 +490,7 @@ EXPORT_SYMBOL(genphy_config_advert);
  */
 int genphy_setup_forced(struct phy_device *phydev)
 {
+	int err;
 	int ctl =3D 0;
=20
 	phydev->pause =3D phydev->asym_pause =3D 0;
@@ -407,17 +503,26 @@ int genphy_setup_forced(struct phy_device *phydev=
)
 	if (DUPLEX_FULL =3D=3D phydev->duplex)
 		ctl |=3D BMCR_FULLDPLX;
 =09
-	ctl =3D phy_write(phydev, MII_BMCR, ctl);
+	err =3D phy_write(phydev, MII_BMCR, ctl);
=20
-	if (ctl < 0)
-		return ctl;
+	if (err < 0)
+		return err;
+
+	/*
+	 * Run the fixups on this PHY, just in case the
+	 * board code needs to change something after a reset
+	 */
+	err =3D phy_scan_fixups(phydev);
+
+	if (err < 0)
+		return err;
=20
 	/* We just reset the device, so we'd better configure any
 	 * settings the PHY requires to operate */
 	if (phydev->drv->config_init)
-		ctl =3D phydev->drv->config_init(phydev);
+		err =3D phydev->drv->config_init(phydev);
=20
-	return ctl;
+	return err;
 }
=20
=20
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index dcbe01b..157fd93 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -86,7 +86,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
=20
-#define DRV_VERSION "2.0.26.20"
+#define DRV_VERSION "2.0.26.22"
=20
 /* S2io Driver name & version. */
 static char s2io_driver_name[] =3D "Neterion";
@@ -117,20 +117,6 @@ static inline int RXD_IS_UP2DT(struct RxD_t *rxdp)
=20
 #define LINK_IS_UP(val64) (!(val64 & (ADAPTER_STATUS_RMAC_REMOTE_FAULT=
 | \
 				      ADAPTER_STATUS_RMAC_LOCAL_FAULT)))
-#define TASKLET_IN_USE test_and_set_bit(0, (&sp->tasklet_status))
-#define PANIC	1
-#define LOW	2
-static inline int rx_buffer_level(struct s2io_nic * sp, int rxb_size, =
int ring)
-{
-	struct mac_info *mac_control;
-
-	mac_control =3D &sp->mac_control;
-	if (rxb_size <=3D rxd_count[sp->rxd_mode])
-		return PANIC;
-	else if ((mac_control->rings[ring].pkt_cnt - rxb_size) > 16)
-		return  LOW;
-	return 0;
-}
=20
 static inline int is_s2io_card_up(const struct s2io_nic * sp)
 {
@@ -2458,7 +2444,7 @@ static void free_tx_buffers(struct s2io_nic *nic)
 	for (i =3D 0; i < config->tx_fifo_num; i++) {
 		unsigned long flags;
 		spin_lock_irqsave(&mac_control->fifos[i].tx_lock, flags);
-		for (j =3D 0; j < config->tx_cfg[i].fifo_len - 1; j++) {
+		for (j =3D 0; j < config->tx_cfg[i].fifo_len; j++) {
 			txdp =3D (struct TxD *) \
 			mac_control->fifos[i].list_info[j].list_virt_addr;
 			skb =3D s2io_txdl_getskb(&mac_control->fifos[i], txdp, j);
@@ -2544,7 +2530,6 @@ static int fill_rx_buffers(struct s2io_nic *nic, =
int ring_no)
 	struct config_param *config;
 	u64 tmp;
 	struct buffAdd *ba;
-	unsigned long flags;
 	struct RxD_t *first_rxdp =3D NULL;
 	u64 Buffer0_ptr =3D 0, Buffer1_ptr =3D 0;
 	struct RxD1 *rxdp1;
@@ -2592,15 +2577,7 @@ static int fill_rx_buffers(struct s2io_nic *nic,=
 int ring_no)
 			DBG_PRINT(INTR_DBG, "%s: Next block at: %p\n",
 				  dev->name, rxdp);
 		}
-		if(!napi) {
-			spin_lock_irqsave(&nic->put_lock, flags);
-			mac_control->rings[ring_no].put_pos =3D
-			(block_no * (rxd_count[nic->rxd_mode] + 1)) + off;
-			spin_unlock_irqrestore(&nic->put_lock, flags);
-		} else {
-			mac_control->rings[ring_no].put_pos =3D
-			(block_no * (rxd_count[nic->rxd_mode] + 1)) + off;
-		}
+
 		if ((rxdp->Control_1 & RXD_OWN_XENA) &&
 			((nic->rxd_mode =3D=3D RXD_MODE_3B) &&
 				(rxdp->Control_2 & s2BIT(0)))) {
@@ -2978,7 +2955,7 @@ static void rx_intr_handler(struct ring_info *rin=
g_data)
 {
 	struct s2io_nic *nic =3D ring_data->nic;
 	struct net_device *dev =3D (struct net_device *) nic->dev;
-	int get_block, put_block, put_offset;
+	int get_block, put_block;
 	struct rx_curr_get_info get_info, put_info;
 	struct RxD_t *rxdp;
 	struct sk_buff *skb;
@@ -2987,19 +2964,11 @@ static void rx_intr_handler(struct ring_info *r=
ing_data)
 	struct RxD1* rxdp1;
 	struct RxD3* rxdp3;
=20
-	spin_lock(&nic->rx_lock);
-
 	get_info =3D ring_data->rx_curr_get_info;
 	get_block =3D get_info.block_index;
 	memcpy(&put_info, &ring_data->rx_curr_put_info, sizeof(put_info));
 	put_block =3D put_info.block_index;
 	rxdp =3D ring_data->rx_blocks[get_block].rxds[get_info.offset].virt_a=
ddr;
-	if (!napi) {
-		spin_lock(&nic->put_lock);
-		put_offset =3D ring_data->put_pos;
-		spin_unlock(&nic->put_lock);
-	} else
-		put_offset =3D ring_data->put_pos;
=20
 	while (RXD_IS_UP2DT(rxdp)) {
 		/*
@@ -3016,7 +2985,6 @@ static void rx_intr_handler(struct ring_info *rin=
g_data)
 			DBG_PRINT(ERR_DBG, "%s: The skb is ",
 				  dev->name);
 			DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");
-			spin_unlock(&nic->rx_lock);
 			return;
 		}
 		if (nic->rxd_mode =3D=3D RXD_MODE_1) {
@@ -3072,8 +3040,6 @@ static void rx_intr_handler(struct ring_info *rin=
g_data)
 			}
 		}
 	}
-
-	spin_unlock(&nic->rx_lock);
 }
=20
 /**
@@ -4105,7 +4071,6 @@ static int s2io_close(struct net_device *dev)
 			do_s2io_delete_unicast_mc(sp, tmp64);
 	}
=20
-	/* Reset card, kill tasklet and free Tx and Rx buffers. */
 	s2io_card_down(sp);
=20
 	return 0;
@@ -4370,29 +4335,9 @@ s2io_alarm_handle(unsigned long data)
=20
 static int s2io_chk_rx_buffers(struct s2io_nic *sp, int rng_n)
 {
-	int rxb_size, level;
-
-	if (!sp->lro) {
-		rxb_size =3D atomic_read(&sp->rx_bufs_left[rng_n]);
-		level =3D rx_buffer_level(sp, rxb_size, rng_n);
-
-		if ((level =3D=3D PANIC) && (!TASKLET_IN_USE)) {
-			int ret;
-			DBG_PRINT(INTR_DBG, "%s: Rx BD hit ", __FUNCTION__);
-			DBG_PRINT(INTR_DBG, "PANIC levels\n");
-			if ((ret =3D fill_rx_buffers(sp, rng_n)) =3D=3D -ENOMEM) {
-				DBG_PRINT(INFO_DBG, "Out of memory in %s",
-					  __FUNCTION__);
-				clear_bit(0, (&sp->tasklet_status));
-				return -1;
-			}
-			clear_bit(0, (&sp->tasklet_status));
-		} else if (level =3D=3D LOW)
-			tasklet_schedule(&sp->task);
-
-	} else if (fill_rx_buffers(sp, rng_n) =3D=3D -ENOMEM) {
-			DBG_PRINT(INFO_DBG, "%s:Out of memory", sp->dev->name);
-			DBG_PRINT(INFO_DBG, " in Rx Intr!!\n");
+	if (fill_rx_buffers(sp, rng_n) =3D=3D -ENOMEM) {
+		DBG_PRINT(INFO_DBG, "%s:Out of memory", sp->dev->name);
+		DBG_PRINT(INFO_DBG, " in Rx Intr!!\n");
 	}
 	return 0;
 }
@@ -6770,49 +6715,6 @@ static int s2io_change_mtu(struct net_device *de=
v, int new_mtu)
 }
=20
 /**
- *  s2io_tasklet - Bottom half of the ISR.
- *  @dev_adr : address of the device structure in dma_addr_t format.
- *  Description:
- *  This is the tasklet or the bottom half of the ISR. This is
- *  an extension of the ISR which is scheduled by the scheduler to be =
run
- *  when the load on the CPU is low. All low priority tasks of the ISR=
 can
- *  be pushed into the tasklet. For now the tasklet is used only to
- *  replenish the Rx buffers in the Rx buffer descriptors.
- *  Return value:
- *  void.
- */
-
-static void s2io_tasklet(unsigned long dev_addr)
-{
-	struct net_device *dev =3D (struct net_device *) dev_addr;
-	struct s2io_nic *sp =3D dev->priv;
-	int i, ret;
-	struct mac_info *mac_control;
-	struct config_param *config;
-
-	mac_control =3D &sp->mac_control;
-	config =3D &sp->config;
-
-	if (!TASKLET_IN_USE) {
-		for (i =3D 0; i < config->rx_ring_num; i++) {
-			ret =3D fill_rx_buffers(sp, i);
-			if (ret =3D=3D -ENOMEM) {
-				DBG_PRINT(INFO_DBG, "%s: Out of ",
-					  dev->name);
-				DBG_PRINT(INFO_DBG, "memory in tasklet\n");
-				break;
-			} else if (ret =3D=3D -EFILL) {
-				DBG_PRINT(INFO_DBG,
-					  "%s: Rx Ring %d is full\n",
-					  dev->name, i);
-				break;
-			}
-		}
-		clear_bit(0, (&sp->tasklet_status));
-	}
-}
-
-/**
  * s2io_set_link - Set the LInk status
  * @data: long pointer to device private structue
  * Description: Sets the link status for the adapter
@@ -7161,7 +7063,6 @@ static void do_s2io_card_down(struct s2io_nic * s=
p, int do_io)
 {
 	int cnt =3D 0;
 	struct XENA_dev_config __iomem *bar0 =3D sp->bar0;
-	unsigned long flags;
 	register u64 val64 =3D 0;
 	struct config_param *config;
 	config =3D &sp->config;
@@ -7186,9 +7087,6 @@ static void do_s2io_card_down(struct s2io_nic * s=
p, int do_io)
=20
 	s2io_rem_isr(sp);
=20
-	/* Kill tasklet. */
-	tasklet_kill(&sp->task);
-
 	/* Check if the device is Quiescent and then Reset the NIC */
 	while(do_io) {
 		/* As per the HW requirement we need to replenish the
@@ -7223,9 +7121,7 @@ static void do_s2io_card_down(struct s2io_nic * s=
p, int do_io)
 	free_tx_buffers(sp);
=20
 	/* Free all Rx buffers */
-	spin_lock_irqsave(&sp->rx_lock, flags);
 	free_rx_buffers(sp);
-	spin_unlock_irqrestore(&sp->rx_lock, flags);
=20
 	clear_bit(__S2IO_STATE_LINK_TASK, &(sp->state));
 }
@@ -7314,9 +7210,6 @@ static int s2io_card_up(struct s2io_nic * sp)
=20
 	S2IO_TIMER_CONF(sp->alarm_timer, s2io_alarm_handle, sp, (HZ/2));
=20
-	/* Enable tasklet for the device */
-	tasklet_init(&sp->task, s2io_tasklet, (unsigned long) dev);
-
 	/*  Enable select interrupts */
 	en_dis_err_alarms(sp, ENA_ALL_INTRS, ENABLE_INTRS);
 	if (sp->config.intr_type !=3D INTA)
@@ -8119,20 +8012,15 @@ s2io_init_nic(struct pci_dev *pdev, const struc=
t pci_device_id *pre)
 	s2io_reset(sp);
=20
 	/*
-	 * Initialize the tasklet status and link state flags
+	 * Initialize link state flags
 	 * and the card state parameter
 	 */
-	sp->tasklet_status =3D 0;
 	sp->state =3D 0;
=20
 	/* Initialize spinlocks */
 	for (i =3D 0; i < sp->config.tx_fifo_num; i++)
 		spin_lock_init(&mac_control->fifos[i].tx_lock);
=20
-	if (!napi)
-		spin_lock_init(&sp->put_lock);
-	spin_lock_init(&sp->rx_lock);
-
 	/*
 	 * SXE-002: Configure link and activity LED to init state
 	 * on driver load.
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index e68fdf7..ce53a02 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -703,9 +703,6 @@ struct ring_info {
 	 */
 	struct rx_curr_get_info rx_curr_get_info;
=20
-	/* Index to the absolute position of the put pointer of Rx ring */
-	int put_pos;
-
 	/* Buffer Address store. */
 	struct buffAdd **ba;
 	struct s2io_nic *nic;
@@ -868,8 +865,6 @@ struct s2io_nic {
 	int device_enabled_once;
=20
 	char name[60];
-	struct tasklet_struct task;
-	volatile unsigned long tasklet_status;
=20
 	/* Timer that handles I/O errors/exceptions */
 	struct timer_list alarm_timer;
@@ -879,8 +874,6 @@ struct s2io_nic {
=20
 	atomic_t rx_bufs_left[MAX_RX_RINGS];
=20
-	spinlock_t put_lock;
-
 #define PROMISC     1
 #define ALL_MULTI   2
=20
@@ -964,7 +957,6 @@ struct s2io_nic {
 	u8		lro;
 	u16		lro_max_aggr_per_sess;
 	volatile unsigned long state;
-	spinlock_t	rx_lock;
 	u64		general_int_mask;
 #define VPD_STRING_LEN 80
 	u8  product_name[VPD_STRING_LEN];
@@ -1094,7 +1086,6 @@ static void s2io_handle_errors(void * dev_id);
 static int s2io_starter(void);
 static void s2io_closer(void);
 static void s2io_tx_watchdog(struct net_device *dev);
-static void s2io_tasklet(unsigned long dev_addr);
 static void s2io_set_multicast(struct net_device *dev);
 static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * =
rxdp);
 static void s2io_link(struct s2io_nic * sp, int link);
diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index 78994ed..6261201 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -825,7 +825,8 @@ static struct platform_driver sgiseeq_driver =3D {
 	.probe	=3D sgiseeq_probe,
 	.remove	=3D __devexit_p(sgiseeq_remove),
 	.driver =3D {
-		.name	=3D "sgiseeq"
+		.name	=3D "sgiseeq",
+		.owner	=3D THIS_MODULE,
 	}
 };
=20
@@ -850,3 +851,4 @@ module_exit(sgiseeq_module_exit);
 MODULE_DESCRIPTION("SGI Seeq 8003 driver");
 MODULE_AUTHOR("Linux/MIPS Mailing List <linux-mips@linux-mips.org>");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:sgiseeq");
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 76cc1d3..4e28002 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -92,6 +92,7 @@ module_param(tx_fifo_kb, int, 0400);
 MODULE_PARM_DESC(tx_fifo_kb,"transmit FIFO size in KB (1<x<15)(default=
=3D8)");
=20
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:smc911x");
=20
 /*
  * The internal workings of the driver.  If you are changing anything
@@ -243,7 +244,7 @@ static void smc911x_reset(struct net_device *dev)
 		do {
 			udelay(10);
 			reg =3D SMC_GET_PMT_CTRL() & PMT_CTRL_READY_;
-		} while ( timeout-- && !reg);
+		} while (--timeout && !reg);
 		if (timeout =3D=3D 0) {
 			PRINTK("%s: smc911x_reset timeout waiting for PM restore\n", dev->n=
ame);
 			return;
@@ -267,7 +268,7 @@ static void smc911x_reset(struct net_device *dev)
 				resets++;
 				break;
 			}
-		} while ( timeout-- && (reg & HW_CFG_SRST_));
+		} while (--timeout && (reg & HW_CFG_SRST_));
 	}
 	if (timeout =3D=3D 0) {
 		PRINTK("%s: smc911x_reset timeout waiting for reset\n", dev->name);
@@ -413,7 +414,7 @@ static inline void smc911x_drop_pkt(struct net_devi=
ce *dev)
 		do {
 			udelay(10);
 			reg =3D SMC_GET_RX_DP_CTRL() & RX_DP_CTRL_FFWD_BUSY_;
-		} while ( timeout-- && reg);
+		} while (--timeout && reg);
 		if (timeout =3D=3D 0) {
 			PRINTK("%s: timeout waiting for RX fast forward\n", dev->name);
 		}
@@ -2262,6 +2263,7 @@ static struct platform_driver smc911x_driver =3D =
{
 	.resume	 =3D smc911x_drv_resume,
 	.driver	 =3D {
 		.name	 =3D CARDNAME,
+		.owner	=3D THIS_MODULE,
 	},
 };
=20
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 600b92a..a188e33 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -132,6 +132,7 @@ module_param(watchdog, int, 0400);
 MODULE_PARM_DESC(watchdog, "transmit timeout in milliseconds");
=20
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:smc91x");
=20
 /*
  * The internal workings of the driver.  If you are changing anything
@@ -2308,6 +2309,7 @@ static struct platform_driver smc_driver =3D {
 	.resume		=3D smc_drv_resume,
 	.driver		=3D {
 		.name	=3D CARDNAME,
+		.owner	=3D THIS_MODULE,
 	},
 };
=20
diff --git a/drivers/net/sni_82596.c b/drivers/net/sni_82596.c
index 2cf6794..854ccf2 100644
--- a/drivers/net/sni_82596.c
+++ b/drivers/net/sni_82596.c
@@ -44,6 +44,7 @@ static const char sni_82596_string[] =3D "snirm_82596=
";
 MODULE_AUTHOR("Thomas Bogendoerfer");
 MODULE_DESCRIPTION("i82596 driver");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:snirm_82596");
 module_param(i596_debug, int, 0);
 MODULE_PARM_DESC(i596_debug, "82596 debug mask");
=20
@@ -166,6 +167,7 @@ static struct platform_driver sni_82596_driver =3D =
{
 	.remove	=3D __devexit_p(sni_82596_driver_remove),
 	.driver	=3D {
 		.name	=3D sni_82596_string,
+		.owner	=3D THIS_MODULE,
 	},
 };
=20
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 17585e5..e83b166 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -625,6 +625,12 @@ static void __init bdx_firmware_endianess(void)
 		s_firmLoad[i] =3D CPU_CHIP_SWAP32(s_firmLoad[i]);
 }
=20
+static int bdx_range_check(struct bdx_priv *priv, u32 offset)
+{
+	return (offset > (u32) (BDX_REGS_SIZE / priv->nic->port_num)) ?
+		-EINVAL : 0;
+}
+
 static int bdx_ioctl_priv(struct net_device *ndev, struct ifreq *ifr, =
int cmd)
 {
 	struct bdx_priv *priv =3D ndev->priv;
@@ -643,9 +649,15 @@ static int bdx_ioctl_priv(struct net_device *ndev,=
 struct ifreq *ifr, int cmd)
 		DBG("%d 0x%x 0x%x\n", data[0], data[1], data[2]);
 	}
=20
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	switch (data[0]) {
=20
 	case BDX_OP_READ:
+		error =3D bdx_range_check(priv, data[1]);
+		if (error < 0)
+			return error;
 		data[2] =3D READ_REG(priv, data[1]);
 		DBG("read_reg(0x%x)=3D0x%x (dec %d)\n", data[1], data[2],
 		    data[2]);
@@ -655,6 +667,9 @@ static int bdx_ioctl_priv(struct net_device *ndev, =
struct ifreq *ifr, int cmd)
 		break;
=20
 	case BDX_OP_WRITE:
+		error =3D bdx_range_check(priv, data[1]);
+		if (error < 0)
+			return error;
 		WRITE_REG(priv, data[1], data[2]);
 		DBG("write_reg(0x%x, 0x%x)\n", data[1], data[2]);
 		break;
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index 6f33f84..6017d52 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -162,6 +162,7 @@ static struct platform_driver tsi_eth_driver =3D {
 	.remove =3D tsi108_ether_remove,
 	.driver	=3D {
 		.name =3D "tsi-ethernet",
+		.owner =3D THIS_MODULE,
 	},
 };
=20
@@ -1729,3 +1730,4 @@ module_exit(tsi108_ether_exit);
 MODULE_AUTHOR("Tundra Semiconductor Corporation");
 MODULE_DESCRIPTION("Tsi108 Gigabit Ethernet driver");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:tsi-ethernet");
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 333961b..c0dd25b 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -2183,7 +2183,6 @@ typhoon_resume(struct pci_dev *pdev)
 	}
=20
 	netif_device_attach(dev);
-	netif_start_queue(dev);
 	return 0;
=20
 reset:
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 29a4d65..0aac91c 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3926,7 +3926,7 @@ static int ucc_geth_probe(struct of_device* ofdev=
, const struct of_device_id *ma
 	ug_info->uf_info.irq =3D irq_of_parse_and_map(np, 0);
 	fixed_link =3D of_get_property(np, "fixed-link", NULL);
 	if (fixed_link) {
-		ug_info->mdio_bus =3D 0;
+		snprintf(ug_info->mdio_bus, MII_BUS_ID_SIZE, "0");
 		ug_info->phy_address =3D fixed_link[0];
 		phy =3D NULL;
 	} else {
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index ed1afaf..6b8d882 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -605,7 +605,6 @@ static void __devinit velocity_get_options(struct v=
elocity_opt *opts, int index,
 static void velocity_init_cam_filter(struct velocity_info *vptr)
 {
 	struct mac_regs __iomem * regs =3D vptr->mac_regs;
-	unsigned short vid;
=20
 	/* Turn on MCFG_PQEN, turn off MCFG_RTGOPT */
 	WORD_REG_BITS_SET(MCFG_PQEN, MCFG_RTGOPT, &regs->MCFG);
@@ -617,29 +616,33 @@ static void velocity_init_cam_filter(struct veloc=
ity_info *vptr)
 	mac_set_vlan_cam_mask(regs, vptr->vCAMmask);
 	mac_set_cam_mask(regs, vptr->mCAMmask);
=20
-	/* Enable first VCAM */
+	/* Enable VCAMs */
 	if (vptr->vlgrp) {
-		for (vid =3D 0; vid < VLAN_VID_MASK; vid++) {
-			if (vlan_group_get_device(vptr->vlgrp, vid)) {
-				/* If Tagging option is enabled and
-				   VLAN ID is not zero, then
-				   turn on MCFG_RTGOPT also */
-				if (vid !=3D 0)
-					WORD_REG_BITS_ON(MCFG_RTGOPT, &regs->MCFG);
+		unsigned int vid, i =3D 0;
+
+		if (!vlan_group_get_device(vptr->vlgrp, 0))
+			WORD_REG_BITS_ON(MCFG_RTGOPT, &regs->MCFG);
=20
-				mac_set_vlan_cam(regs, 0, (u8 *) &vid);
+		for (vid =3D 1; (vid < VLAN_VID_MASK); vid++) {
+			if (vlan_group_get_device(vptr->vlgrp, vid)) {
+				mac_set_vlan_cam(regs, i, (u8 *) &vid);
+				vptr->vCAMmask[i / 8] |=3D 0x1 << (i % 8);
+				if (++i >=3D VCAM_SIZE)
+					break;
 			}
 		}
-		vptr->vCAMmask[0] |=3D 1;
 		mac_set_vlan_cam_mask(regs, vptr->vCAMmask);
-	} else {
-		u16 temp =3D 0;
-		mac_set_vlan_cam(regs, 0, (u8 *) &temp);
-		temp =3D 1;
-		mac_set_vlan_cam_mask(regs, (u8 *) &temp);
 	}
 }
=20
+static void velocity_vlan_rx_register(struct net_device *dev,
+				      struct vlan_group *grp)
+{
+	struct velocity_info *vptr =3D netdev_priv(dev);
+
+	vptr->vlgrp =3D grp;
+}
+
 static void velocity_vlan_rx_add_vid(struct net_device *dev, unsigned =
short vid)
 {
 	struct velocity_info *vptr =3D netdev_priv(dev);
@@ -959,11 +962,13 @@ static int __devinit velocity_found1(struct pci_d=
ev *pdev, const struct pci_devi
=20
 	dev->vlan_rx_add_vid =3D velocity_vlan_rx_add_vid;
 	dev->vlan_rx_kill_vid =3D velocity_vlan_rx_kill_vid;
+	dev->vlan_rx_register =3D velocity_vlan_rx_register;
=20
 #ifdef  VELOCITY_ZERO_COPY_SUPPORT
 	dev->features |=3D NETIF_F_SG;
 #endif
-	dev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER;
+	dev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER |
+		NETIF_F_HW_VLAN_RX;
=20
 	if (vptr->flags & VELOCITY_FLAGS_TX_CSUM)
 		dev->features |=3D NETIF_F_IP_CSUM;
@@ -1597,8 +1602,13 @@ static int velocity_receive_frame(struct velocit=
y_info *vptr, int idx)
 	skb_put(skb, pkt_len - 4);
 	skb->protocol =3D eth_type_trans(skb, vptr->dev);
=20
+	if (vptr->vlgrp && (rd->rdesc0.RSR & RSR_DETAG)) {
+		vlan_hwaccel_rx(skb, vptr->vlgrp,
+				swab16(le16_to_cpu(rd->rdesc1.PQTAG)));
+	} else
+		netif_rx(skb);
+
 	stats->rx_bytes +=3D pkt_len;
-	netif_rx(skb);
=20
 	return 0;
 }
diff --git a/drivers/net/wan/c101.c b/drivers/net/wan/c101.c
index c4c8eab..c2cc42f 100644
--- a/drivers/net/wan/c101.c
+++ b/drivers/net/wan/c101.c
@@ -402,7 +402,7 @@ static int __init c101_init(void)
 #ifdef MODULE
 		printk(KERN_INFO "c101: no card initialized\n");
 #endif
-		return -ENOSYS;	/* no parameters specified, abort */
+		return -EINVAL;	/* no parameters specified, abort */
 	}
=20
 	printk(KERN_INFO "%s\n", version);
@@ -420,11 +420,11 @@ static int __init c101_init(void)
 			c101_run(irq, ram);
=20
 		if (*hw =3D=3D '\x0')
-			return first_card ? 0 : -ENOSYS;
+			return first_card ? 0 : -EINVAL;
 	}while(*hw++ =3D=3D ':');
=20
 	printk(KERN_ERR "c101: invalid hardware parameters\n");
-	return first_card ? 0 : -ENOSYS;
+	return first_card ? 0 : -EINVAL;
 }
=20
=20
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index c4ab032..520bb0b 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -1090,10 +1090,6 @@ static int fr_add_pvc(struct net_device *frad, u=
nsigned int dlci, int type)
 	pvc_device *pvc =3D NULL;
 	struct net_device *dev;
 	int result, used;
-	char * prefix =3D "pvc%d";
-
-	if (type =3D=3D ARPHRD_ETHER)
-		prefix =3D "pvceth%d";
=20
 	if ((pvc =3D add_pvc(frad, dlci)) =3D=3D NULL) {
 		printk(KERN_WARNING "%s: Memory squeeze on fr_add_pvc()\n",
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 779cbcd..02df20f 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -379,6 +379,18 @@ struct phy_driver {
 };
 #define to_phy_driver(d) container_of(d, struct phy_driver, driver)
=20
+#define PHY_ANY_ID "MATCH ANY PHY"
+#define PHY_ANY_UID 0xffffffff
+
+/* A Structure for boards to register fixups with the PHY Lib */
+struct phy_fixup {
+	struct list_head list;
+	char bus_id[BUS_ID_SIZE];
+	u32 phy_uid;
+	u32 phy_uid_mask;
+	int (*run)(struct phy_device *phydev);
+};
+
 int phy_read(struct phy_device *phydev, u16 regnum);
 int phy_write(struct phy_device *phydev, u16 regnum, u16 val);
 int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id);
@@ -386,8 +398,8 @@ struct phy_device* get_phy_device(struct mii_bus *b=
us, int addr);
 int phy_clear_interrupt(struct phy_device *phydev);
 int phy_config_interrupt(struct phy_device *phydev, u32 interrupts);
 struct phy_device * phy_attach(struct net_device *dev,
-		const char *phy_id, u32 flags, phy_interface_t interface);
-struct phy_device * phy_connect(struct net_device *dev, const char *ph=
y_id,
+		const char *bus_id, u32 flags, phy_interface_t interface);
+struct phy_device * phy_connect(struct net_device *dev, const char *bu=
s_id,
 		void (*handler)(struct net_device *), u32 flags,
 		phy_interface_t interface);
 void phy_disconnect(struct phy_device *phydev);
@@ -427,5 +439,13 @@ void phy_print_status(struct phy_device *phydev);
 struct phy_device* phy_device_create(struct mii_bus *bus, int addr, in=
t phy_id);
 void phy_device_free(struct phy_device *phydev);
=20
+int phy_register_fixup(const char *bus_id, u32 phy_uid, u32 phy_uid_ma=
sk,
+		int (*run)(struct phy_device *));
+int phy_register_fixup_for_id(const char *bus_id,
+		int (*run)(struct phy_device *));
+int phy_register_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask,
+		int (*run)(struct phy_device *));
+int phy_scan_fixups(struct phy_device *phydev);
+
 extern struct bus_type mdio_bus_type;
 #endif /* __PHY_H */
