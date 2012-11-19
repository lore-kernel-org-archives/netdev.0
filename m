From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 470/493] ethernet: remove use of __devexit
Date: Mon, 19 Nov 2012 13:26:59 -0500
Message-ID: <1353349642-3677-470-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
        David Dillow <dave@thedillows.org>,
        Russell King <linux@arm.linux.org.uk>,
        Kristoffer Glembo <kristoffer@gaisler.com>,
        Jes Sorensen <jes@trained-monkey.org>,
        Don Fry <pcnet32@frontier.com>,
        Jay Cliburn <jcliburn@gmail.com>,
        Chris Snook <chris.snook@gmail.com>,
        Grant Grundler <grundler@parisc-linux.org>,
        Jaroslav Kysela <perex@perex.cz>,
        Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
        Francois Romieu <romieu@fr.zoreil.com>,
        Sorbica Shieh <sorbica@icplus.com.tw>,
        Guo-Fu Tseng <cooldavid@cooldavid.org>,
        Mirko Lindner <mlindner@marvell.com>,
        Stephen Hemminger <shemminger@vyatta.com>,
        Wan ZongShun <mcuos.com@gmail.com>,
        Olof Johansson <olof@lixom.net>,
        Florian Fainelli <florian@op
To: gregkh@linuxfoundation.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

CONFIG_HOTPLUG is going away as an option so __devexit is no
longer needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de> 
Cc: David Dillow <dave@thedillows.org> 
Cc: Russell King <linux@arm.linux.org.uk> 
Cc: Kristoffer Glembo <kristoffer@gaisler.com> 
Cc: Jes Sorensen <jes@trained-monkey.org> 
Cc: Don Fry <pcnet32@frontier.com> 
Cc: Jay Cliburn <jcliburn@gmail.com> 
Cc: Chris Snook <chris.snook@gmail.com> 
Cc: Grant Grundler <grundler@parisc-linux.org> 
Cc: Jaroslav Kysela <perex@perex.cz> 
Cc: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com> 
Cc: Francois Romieu <romieu@fr.zoreil.com> 
Cc: Sorbica Shieh <sorbica@icplus.com.tw> 
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org> 
Cc: Mirko Lindner <mlindner@marvell.com> 
Cc: Stephen Hemminger <shemminger@vyatta.com> 
Cc: Wan ZongShun <mcuos.com@gmail.com> 
Cc: Olof Johansson <olof@lixom.net> 
Cc: Florian Fainelli <florian@openwrt.org> 
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com> 
Cc: Ralf Baechle <ralf@linux-mips.org> 
Cc: Daniele Venzano <venza@brownhat.org> 
Cc: Steve Glendinning <steve.glendinning@shawell.net> 
Cc: Samuel Chessman <chessman@tux.org> 
Cc: Roger Luethi <rl@hellgate.ch> 
Cc: Anirudha Sarangi <anirudh@xilinx.com> 
Cc: John Linn <John.Linn@xilinx.com> 
Cc: Krzysztof Halasa <khc@pm.waw.pl> 
Cc: netdev@vger.kernel.org 
Cc: linux-arm-kernel@lists.infradead.org 
Cc: uclinux-dist-devel@blackfin.uclinux.org 
Cc: linux-acenic@sunsite.dk 
Cc: e1000-devel@lists.sourceforge.net 
Cc: linux-mips@linux-mips.org 
---
 drivers/net/ethernet/3com/3c509.c                    | 6 +++---
 drivers/net/ethernet/3com/3c59x.c                    | 4 ++--
 drivers/net/ethernet/3com/typhoon.c                  | 2 +-
 drivers/net/ethernet/8390/etherh.c                   | 2 +-
 drivers/net/ethernet/8390/hydra.c                    | 4 ++--
 drivers/net/ethernet/8390/ne2k-pci.c                 | 2 +-
 drivers/net/ethernet/8390/ne3210.c                   | 2 +-
 drivers/net/ethernet/8390/zorro8390.c                | 2 +-
 drivers/net/ethernet/adaptec/starfire.c              | 2 +-
 drivers/net/ethernet/adi/bfin_mac.c                  | 4 ++--
 drivers/net/ethernet/aeroflex/greth.c                | 2 +-
 drivers/net/ethernet/alteon/acenic.c                 | 2 +-
 drivers/net/ethernet/amd/a2065.c                     | 4 ++--
 drivers/net/ethernet/amd/amd8111e.c                  | 2 +-
 drivers/net/ethernet/amd/ariadne.c                   | 2 +-
 drivers/net/ethernet/amd/au1000_eth.c                | 2 +-
 drivers/net/ethernet/amd/depca.c                     | 4 ++--
 drivers/net/ethernet/amd/hplance.c                   | 4 ++--
 drivers/net/ethernet/amd/pcnet32.c                   | 2 +-
 drivers/net/ethernet/amd/sunlance.c                  | 2 +-
 drivers/net/ethernet/apple/bmac.c                    | 2 +-
 drivers/net/ethernet/apple/mace.c                    | 2 +-
 drivers/net/ethernet/apple/macmace.c                 | 2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c      | 2 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c      | 2 +-
 drivers/net/ethernet/atheros/atlx/atl1.c             | 2 +-
 drivers/net/ethernet/atheros/atlx/atl2.c             | 2 +-
 drivers/net/ethernet/broadcom/b44.c                  | 2 +-
 drivers/net/ethernet/broadcom/bcm63xx_enet.c         | 4 ++--
 drivers/net/ethernet/broadcom/bnx2.c                 | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c     | 2 +-
 drivers/net/ethernet/broadcom/tg3.c                  | 2 +-
 drivers/net/ethernet/brocade/bna/bnad.c              | 2 +-
 drivers/net/ethernet/cadence/at91_ether.c            | 2 +-
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c            | 2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c      | 2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c   | 2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c      | 2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c  | 4 ++--
 drivers/net/ethernet/cisco/enic/enic_main.c          | 2 +-
 drivers/net/ethernet/davicom/dm9000.c                | 2 +-
 drivers/net/ethernet/dec/tulip/de2104x.c             | 2 +-
 drivers/net/ethernet/dec/tulip/de4x5.c               | 4 ++--
 drivers/net/ethernet/dec/tulip/dmfe.c                | 2 +-
 drivers/net/ethernet/dec/tulip/tulip_core.c          | 2 +-
 drivers/net/ethernet/dec/tulip/uli526x.c             | 2 +-
 drivers/net/ethernet/dec/tulip/winbond-840.c         | 2 +-
 drivers/net/ethernet/dec/tulip/xircom_cb.c           | 2 +-
 drivers/net/ethernet/dlink/dl2k.c                    | 2 +-
 drivers/net/ethernet/dlink/sundance.c                | 2 +-
 drivers/net/ethernet/dnet.c                          | 2 +-
 drivers/net/ethernet/emulex/benet/be_main.c          | 2 +-
 drivers/net/ethernet/ethoc.c                         | 2 +-
 drivers/net/ethernet/fealnx.c                        | 2 +-
 drivers/net/ethernet/freescale/fec.c                 | 2 +-
 drivers/net/ethernet/freescale/xgmac_mdio.c          | 2 +-
 drivers/net/ethernet/hp/hp100.c                      | 4 ++--
 drivers/net/ethernet/i825xx/ether1.c                 | 2 +-
 drivers/net/ethernet/i825xx/lasi_82596.c             | 2 +-
 drivers/net/ethernet/i825xx/sni_82596.c              | 2 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c            | 4 ++--
 drivers/net/ethernet/ibm/emac/core.c                 | 2 +-
 drivers/net/ethernet/ibm/emac/mal.c                  | 2 +-
 drivers/net/ethernet/ibm/emac/rgmii.c                | 2 +-
 drivers/net/ethernet/ibm/emac/tah.c                  | 2 +-
 drivers/net/ethernet/ibm/emac/zmii.c                 | 2 +-
 drivers/net/ethernet/ibm/ibmveth.c                   | 2 +-
 drivers/net/ethernet/icplus/ipg.c                    | 2 +-
 drivers/net/ethernet/intel/e100.c                    | 2 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c        | 4 ++--
 drivers/net/ethernet/intel/e1000e/netdev.c           | 2 +-
 drivers/net/ethernet/intel/igb/igb_main.c            | 4 ++--
 drivers/net/ethernet/intel/igbvf/netdev.c            | 2 +-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c          | 4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c        | 2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c    | 2 +-
 drivers/net/ethernet/jme.c                           | 2 +-
 drivers/net/ethernet/lantiq_etop.c                   | 2 +-
 drivers/net/ethernet/marvell/skge.c                  | 2 +-
 drivers/net/ethernet/marvell/sky2.c                  | 2 +-
 drivers/net/ethernet/micrel/ks8695net.c              | 2 +-
 drivers/net/ethernet/micrel/ks8842.c                 | 2 +-
 drivers/net/ethernet/micrel/ks8851.c                 | 2 +-
 drivers/net/ethernet/micrel/ks8851_mll.c             | 2 +-
 drivers/net/ethernet/microchip/enc28j60.c            | 2 +-
 drivers/net/ethernet/natsemi/jazzsonic.c             | 2 +-
 drivers/net/ethernet/natsemi/macsonic.c              | 2 +-
 drivers/net/ethernet/natsemi/natsemi.c               | 2 +-
 drivers/net/ethernet/natsemi/ns83820.c               | 2 +-
 drivers/net/ethernet/natsemi/xtsonic.c               | 2 +-
 drivers/net/ethernet/neterion/s2io.c                 | 2 +-
 drivers/net/ethernet/neterion/s2io.h                 | 2 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c       | 2 +-
 drivers/net/ethernet/nuvoton/w90p910_ether.c         | 2 +-
 drivers/net/ethernet/nvidia/forcedeth.c              | 2 +-
 drivers/net/ethernet/octeon/octeon_mgmt.c            | 2 +-
 drivers/net/ethernet/packetengines/hamachi.c         | 2 +-
 drivers/net/ethernet/packetengines/yellowfin.c       | 2 +-
 drivers/net/ethernet/pasemi/pasemi_mac.c             | 2 +-
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c | 4 ++--
 drivers/net/ethernet/qlogic/qla3xxx.c                | 2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c     | 4 ++--
 drivers/net/ethernet/qlogic/qlge/qlge_main.c         | 2 +-
 drivers/net/ethernet/rdc/r6040.c                     | 2 +-
 drivers/net/ethernet/realtek/8139too.c               | 2 +-
 drivers/net/ethernet/realtek/r8169.c                 | 2 +-
 drivers/net/ethernet/s6gmac.c                        | 2 +-
 drivers/net/ethernet/seeq/ether3.c                   | 2 +-
 drivers/net/ethernet/sgi/ioc3-eth.c                  | 2 +-
 drivers/net/ethernet/silan/sc92031.c                 | 2 +-
 drivers/net/ethernet/sis/sis190.c                    | 2 +-
 drivers/net/ethernet/sis/sis900.c                    | 2 +-
 drivers/net/ethernet/smsc/epic100.c                  | 2 +-
 drivers/net/ethernet/smsc/smc911x.c                  | 2 +-
 drivers/net/ethernet/smsc/smc91x.c                   | 2 +-
 drivers/net/ethernet/smsc/smsc911x.c                 | 2 +-
 drivers/net/ethernet/smsc/smsc9420.c                 | 2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c     | 2 +-
 drivers/net/ethernet/sun/cassini.c                   | 2 +-
 drivers/net/ethernet/sun/niu.c                       | 6 +++---
 drivers/net/ethernet/sun/sunbmac.c                   | 2 +-
 drivers/net/ethernet/sun/sunhme.c                    | 4 ++--
 drivers/net/ethernet/sun/sunqe.c                     | 2 +-
 drivers/net/ethernet/tehuti/tehuti.c                 | 2 +-
 drivers/net/ethernet/ti/cpmac.c                      | 4 ++--
 drivers/net/ethernet/ti/cpsw.c                       | 2 +-
 drivers/net/ethernet/ti/davinci_emac.c               | 2 +-
 drivers/net/ethernet/ti/davinci_mdio.c               | 2 +-
 drivers/net/ethernet/ti/tlan.c                       | 2 +-
 drivers/net/ethernet/toshiba/spider_net.c            | 2 +-
 drivers/net/ethernet/toshiba/tc35815.c               | 2 +-
 drivers/net/ethernet/via/via-rhine.c                 | 2 +-
 drivers/net/ethernet/via/via-velocity.c              | 2 +-
 drivers/net/ethernet/wiznet/w5100.c                  | 2 +-
 drivers/net/ethernet/wiznet/w5300.c                  | 2 +-
 drivers/net/ethernet/xilinx/ll_temac_main.c          | 2 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c    | 2 +-
 drivers/net/ethernet/xilinx/xilinx_emaclite.c        | 2 +-
 drivers/net/ethernet/xscale/ixp4xx_eth.c             | 2 +-
 139 files changed, 161 insertions(+), 161 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index f85e082..a364ccc 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -341,7 +341,7 @@ static int el3_isa_match(struct device *pdev,
 	return 1;
 }
 
-static int __devexit el3_isa_remove(struct device *pdev,
+static int el3_isa_remove(struct device *pdev,
 				    unsigned int ndev)
 {
 	el3_device_remove(pdev);
@@ -445,7 +445,7 @@ static int el3_pnp_probe(struct pnp_dev *pdev,
 	return 0;
 }
 
-static void __devexit el3_pnp_remove(struct pnp_dev *pdev)
+static void el3_pnp_remove(struct pnp_dev *pdev)
 {
 	el3_common_remove(pnp_get_drvdata(pdev));
 	pnp_set_drvdata(pdev, NULL);
@@ -618,7 +618,7 @@ static int __init el3_eisa_probe (struct device *device)
 /* This remove works for all device types.
  *
  * The net dev must be stored in the driver data field */
-static int __devexit el3_device_remove (struct device *device)
+static int el3_device_remove (struct device *device)
 {
 	struct net_device *dev;
 
diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 3c0f663..658e224 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -931,7 +931,7 @@ static int __init vortex_eisa_probe(struct device *device)
 	return 0;
 }
 
-static int __devexit vortex_eisa_remove(struct device *device)
+static int vortex_eisa_remove(struct device *device)
 {
 	struct eisa_device *edev;
 	struct net_device *dev;
@@ -3222,7 +3222,7 @@ static void acpi_set_WOL(struct net_device *dev)
 }
 
 
-static void __devexit vortex_remove_one(struct pci_dev *pdev)
+static void vortex_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct vortex_private *vp;
diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 4077af1..27aaaf9 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -2509,7 +2509,7 @@ error_out:
 	return err;
 }
 
-static void __devexit
+static void
 typhoon_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
diff --git a/drivers/net/ethernet/8390/etherh.c b/drivers/net/ethernet/8390/etherh.c
index 38fc4fb..0edbadd 100644
--- a/drivers/net/ethernet/8390/etherh.c
+++ b/drivers/net/ethernet/8390/etherh.c
@@ -775,7 +775,7 @@ etherh_probe(struct expansion_card *ec, const struct ecard_id *id)
 	return ret;
 }
 
-static void __devexit etherh_remove(struct expansion_card *ec)
+static void etherh_remove(struct expansion_card *ec)
 {
 	struct net_device *dev = ecard_get_drvdata(ec);
 
diff --git a/drivers/net/ethernet/8390/hydra.c b/drivers/net/ethernet/8390/hydra.c
index 2743bb9..0ecaff9 100644
--- a/drivers/net/ethernet/8390/hydra.c
+++ b/drivers/net/ethernet/8390/hydra.c
@@ -65,7 +65,7 @@ static void hydra_block_input(struct net_device *dev, int count,
 			      struct sk_buff *skb, int ring_offset);
 static void hydra_block_output(struct net_device *dev, int count,
 			       const unsigned char *buf, int start_page);
-static void __devexit hydra_remove_one(struct zorro_dev *z);
+static void hydra_remove_one(struct zorro_dev *z);
 
 static struct zorro_device_id hydra_zorro_tbl[] = {
     { ZORRO_PROD_HYDRA_SYSTEMS_AMIGANET },
@@ -247,7 +247,7 @@ static void hydra_block_output(struct net_device *dev, int count,
     z_memcpy_toio(mem_base+((start_page - NESM_START_PG)<<8), buf, count);
 }
 
-static void __devexit hydra_remove_one(struct zorro_dev *z)
+static void hydra_remove_one(struct zorro_dev *z)
 {
     struct net_device *dev = zorro_get_drvdata(z);
 
diff --git a/drivers/net/ethernet/8390/ne2k-pci.c b/drivers/net/ethernet/8390/ne2k-pci.c
index 96b31b1..99f7e02 100644
--- a/drivers/net/ethernet/8390/ne2k-pci.c
+++ b/drivers/net/ethernet/8390/ne2k-pci.c
@@ -647,7 +647,7 @@ static const struct ethtool_ops ne2k_pci_ethtool_ops = {
 	.get_drvinfo		= ne2k_pci_get_drvinfo,
 };
 
-static void __devexit ne2k_pci_remove_one (struct pci_dev *pdev)
+static void ne2k_pci_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 
diff --git a/drivers/net/ethernet/8390/ne3210.c b/drivers/net/ethernet/8390/ne3210.c
index 8579e2f..586c37b 100644
--- a/drivers/net/ethernet/8390/ne3210.c
+++ b/drivers/net/ethernet/8390/ne3210.c
@@ -222,7 +222,7 @@ static int __init ne3210_eisa_probe (struct device *device)
 	return retval;
 }
 
-static int __devexit ne3210_eisa_remove (struct device *device)
+static int ne3210_eisa_remove (struct device *device)
 {
 	struct net_device  *dev    = dev_get_drvdata(device);
 	unsigned long       ioaddr = to_eisa_device (device)->base_addr;
diff --git a/drivers/net/ethernet/8390/zorro8390.c b/drivers/net/ethernet/8390/zorro8390.c
index 674efc5..ceb89d9 100644
--- a/drivers/net/ethernet/8390/zorro8390.c
+++ b/drivers/net/ethernet/8390/zorro8390.c
@@ -254,7 +254,7 @@ static int zorro8390_close(struct net_device *dev)
 	return 0;
 }
 
-static void __devexit zorro8390_remove_one(struct zorro_dev *z)
+static void zorro8390_remove_one(struct zorro_dev *z)
 {
 	struct net_device *dev = zorro_get_drvdata(z);
 
diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index 7b3d3a2..365ea4f 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -1990,7 +1990,7 @@ static int starfire_resume(struct pci_dev *pdev)
 #endif /* CONFIG_PM */
 
 
-static void __devexit starfire_remove_one (struct pci_dev *pdev)
+static void starfire_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct netdev_private *np = netdev_priv(dev);
diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 83a8e69..c1fdb8b 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1727,7 +1727,7 @@ out_err_probe_mac:
 	return rc;
 }
 
-static int __devexit bfin_mac_remove(struct platform_device *pdev)
+static int bfin_mac_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct bfin_mac_local *lp = netdev_priv(ndev);
@@ -1864,7 +1864,7 @@ out_err_alloc:
 	return rc;
 }
 
-static int __devexit bfin_mii_bus_remove(struct platform_device *pdev)
+static int bfin_mii_bus_remove(struct platform_device *pdev)
 {
 	struct mii_bus *miibus = platform_get_drvdata(pdev);
 	struct bfin_mii_bus_platform_data *mii_bus_pd =
diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index 6d99ebb..aa53115 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1576,7 +1576,7 @@ error1:
 	return err;
 }
 
-static int __devexit greth_of_remove(struct platform_device *of_dev)
+static int greth_of_remove(struct platform_device *of_dev)
 {
 	struct net_device *ndev = dev_get_drvdata(&of_dev->dev);
 	struct greth_private *greth = netdev_priv(ndev);
diff --git a/drivers/net/ethernet/alteon/acenic.c b/drivers/net/ethernet/alteon/acenic.c
index 4cf8e78..dfddce6 100644
--- a/drivers/net/ethernet/alteon/acenic.c
+++ b/drivers/net/ethernet/alteon/acenic.c
@@ -603,7 +603,7 @@ static int acenic_probe_one(struct pci_dev *pdev,
 	return -ENODEV;
 }
 
-static void __devexit acenic_remove_one(struct pci_dev *pdev)
+static void acenic_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct ace_private *ap = netdev_priv(dev);
diff --git a/drivers/net/ethernet/amd/a2065.c b/drivers/net/ethernet/amd/a2065.c
index 2784c2d..818f6d6 100644
--- a/drivers/net/ethernet/amd/a2065.c
+++ b/drivers/net/ethernet/amd/a2065.c
@@ -641,7 +641,7 @@ static void lance_set_multicast(struct net_device *dev)
 
 static int a2065_init_one(struct zorro_dev *z,
 				    const struct zorro_device_id *ent);
-static void __devexit a2065_remove_one(struct zorro_dev *z);
+static void a2065_remove_one(struct zorro_dev *z);
 
 
 static struct zorro_device_id a2065_zorro_tbl[] = {
@@ -754,7 +754,7 @@ static int a2065_init_one(struct zorro_dev *z,
 }
 
 
-static void __devexit a2065_remove_one(struct zorro_dev *z)
+static void a2065_remove_one(struct zorro_dev *z)
 {
 	struct net_device *dev = zorro_get_drvdata(z);
 
diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index c66ae87..e21f7b8 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -1702,7 +1702,7 @@ static int amd8111e_resume(struct pci_dev *pci_dev)
 }
 
 
-static void __devexit amd8111e_remove_one(struct pci_dev *pdev)
+static void amd8111e_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	if (dev) {
diff --git a/drivers/net/ethernet/amd/ariadne.c b/drivers/net/ethernet/amd/ariadne.c
index 08147ae..2ea7a23 100644
--- a/drivers/net/ethernet/amd/ariadne.c
+++ b/drivers/net/ethernet/amd/ariadne.c
@@ -682,7 +682,7 @@ static void set_multicast_list(struct net_device *dev)
 }
 
 
-static void __devexit ariadne_remove_one(struct zorro_dev *z)
+static void ariadne_remove_one(struct zorro_dev *z)
 {
 	struct net_device *dev = zorro_get_drvdata(z);
 
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index 884ef9c..2ea221e 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -1295,7 +1295,7 @@ out:
 	return err;
 }
 
-static int __devexit au1000_remove(struct platform_device *pdev)
+static int au1000_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct au1000_private *aup = netdev_priv(dev);
diff --git a/drivers/net/ethernet/amd/depca.c b/drivers/net/ethernet/amd/depca.c
index 34b6bf7..f327174 100644
--- a/drivers/net/ethernet/amd/depca.c
+++ b/drivers/net/ethernet/amd/depca.c
@@ -345,7 +345,7 @@ static struct eisa_driver depca_eisa_driver = {
 
 static int depca_isa_probe (struct platform_device *);
 
-static int __devexit depca_isa_remove(struct platform_device *pdev)
+static int depca_isa_remove(struct platform_device *pdev)
 {
 	return depca_device_remove(&pdev->dev);
 }
@@ -1412,7 +1412,7 @@ static int __init depca_eisa_probe (struct device *device)
 }
 #endif
 
-static int __devexit depca_device_remove (struct device *device)
+static int depca_device_remove (struct device *device)
 {
 	struct net_device *dev;
 	struct depca_private *lp;
diff --git a/drivers/net/ethernet/amd/hplance.c b/drivers/net/ethernet/amd/hplance.c
index d90aa7b38..705333e 100644
--- a/drivers/net/ethernet/amd/hplance.c
+++ b/drivers/net/ethernet/amd/hplance.c
@@ -50,7 +50,7 @@ static int hplance_init_one(struct dio_dev *d,
 				const struct dio_device_id *ent);
 static void hplance_init(struct net_device *dev,
 				struct dio_dev *d);
-static void __devexit hplance_remove_one(struct dio_dev *d);
+static void hplance_remove_one(struct dio_dev *d);
 static void hplance_writerap(void *priv, unsigned short value);
 static void hplance_writerdp(void *priv, unsigned short value);
 static unsigned short hplance_readrdp(void *priv);
@@ -118,7 +118,7 @@ static int hplance_init_one(struct dio_dev *d,
 	return err;
 }
 
-static void __devexit hplance_remove_one(struct dio_dev *d)
+static void hplance_remove_one(struct dio_dev *d)
 {
 	struct net_device *dev = dio_get_drvdata(d);
 
diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 9771928..a227ccd 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -2823,7 +2823,7 @@ static int pcnet32_pm_resume(struct pci_dev *pdev)
 	return 0;
 }
 
-static void __devexit pcnet32_remove_one(struct pci_dev *pdev)
+static void pcnet32_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 
diff --git a/drivers/net/ethernet/amd/sunlance.c b/drivers/net/ethernet/amd/sunlance.c
index 3c5bf2b..64dbffa 100644
--- a/drivers/net/ethernet/amd/sunlance.c
+++ b/drivers/net/ethernet/amd/sunlance.c
@@ -1504,7 +1504,7 @@ static int sunlance_sbus_probe(struct platform_device *op)
 	return err;
 }
 
-static int __devexit sunlance_sbus_remove(struct platform_device *op)
+static int sunlance_sbus_remove(struct platform_device *op)
 {
 	struct lance_private *lp = dev_get_drvdata(&op->dev);
 	struct net_device *net_dev = lp->dev;
diff --git a/drivers/net/ethernet/apple/bmac.c b/drivers/net/ethernet/apple/bmac.c
index 420a06e..f36bbd6 100644
--- a/drivers/net/ethernet/apple/bmac.c
+++ b/drivers/net/ethernet/apple/bmac.c
@@ -1602,7 +1602,7 @@ bmac_proc_info(char *buffer, char **start, off_t offset, int length)
 }
 #endif
 
-static int __devexit bmac_remove(struct macio_dev *mdev)
+static int bmac_remove(struct macio_dev *mdev)
 {
 	struct net_device *dev = macio_get_drvdata(mdev);
 	struct bmac_data *bp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/apple/mace.c b/drivers/net/ethernet/apple/mace.c
index 21cf031..842fe76 100644
--- a/drivers/net/ethernet/apple/mace.c
+++ b/drivers/net/ethernet/apple/mace.c
@@ -271,7 +271,7 @@ static int mace_probe(struct macio_dev *mdev, const struct of_device_id *match)
 	return rc;
 }
 
-static int __devexit mace_remove(struct macio_dev *mdev)
+static int mace_remove(struct macio_dev *mdev)
 {
 	struct net_device *dev = macio_get_drvdata(mdev);
 	struct mace_data *mp;
diff --git a/drivers/net/ethernet/apple/macmace.c b/drivers/net/ethernet/apple/macmace.c
index 7decd85..090ca12 100644
--- a/drivers/net/ethernet/apple/macmace.c
+++ b/drivers/net/ethernet/apple/macmace.c
@@ -746,7 +746,7 @@ MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Macintosh MACE ethernet driver");
 MODULE_ALIAS("platform:macmace");
 
-static int __devexit mac_mace_device_remove (struct platform_device *pdev)
+static int mac_mace_device_remove (struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct mace_data *mp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 88a4b72..44bee4a 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -2587,7 +2587,7 @@ err_dma:
  * Hot-Plug event, or because the driver is going to be removed from
  * memory.
  */
-static void __devexit atl1c_remove(struct pci_dev *pdev)
+static void atl1c_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index 9fff8b9..dec5d2c 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -2387,7 +2387,7 @@ err_dma:
  * Hot-Plug event, or because the driver is going to be removed from
  * memory.
  */
-static void __devexit atl1e_remove(struct pci_dev *pdev)
+static void atl1e_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct atl1e_adapter *adapter = netdev_priv(netdev);
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 714552d..3e7327e 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -3113,7 +3113,7 @@ err_request_regions:
  * Hot-Plug event, or because the driver is going to be removed from
  * memory.
  */
-static void __devexit atl1_remove(struct pci_dev *pdev)
+static void atl1_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct atl1_adapter *adapter;
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 4c0867f..7dc9766 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -1498,7 +1498,7 @@ err_dma:
  */
 /* FIXME: write the original MAC address back in case it was changed from a
  * BIOS-set value, as in atl1 -- CHS */
-static void __devexit atl2_remove(struct pci_dev *pdev)
+static void atl2_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct atl2_adapter *adapter = netdev_priv(netdev);
diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 7fda109..c64351f 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -2249,7 +2249,7 @@ out:
 	return err;
 }
 
-static void __devexit b44_remove_one(struct ssb_device *sdev)
+static void b44_remove_one(struct ssb_device *sdev)
 {
 	struct net_device *dev = ssb_get_drvdata(sdev);
 
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 1bdff26..39387d6 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1830,7 +1830,7 @@ out:
 /*
  * exit func, stops hardware and unregisters netdevice
  */
-static int __devexit bcm_enet_remove(struct platform_device *pdev)
+static int bcm_enet_remove(struct platform_device *pdev)
 {
 	struct bcm_enet_priv *priv;
 	struct net_device *dev;
@@ -1908,7 +1908,7 @@ static int bcm_enet_shared_probe(struct platform_device *pdev)
 	return 0;
 }
 
-static int __devexit bcm_enet_shared_remove(struct platform_device *pdev)
+static int bcm_enet_shared_remove(struct platform_device *pdev)
 {
 	struct resource *res;
 
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 30a3c0d..a1564df 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -8572,7 +8572,7 @@ err_free:
 	return rc;
 }
 
-static void __devexit
+static void
 bnx2_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index cf165d3..47df8d9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12134,7 +12134,7 @@ init_one_exit:
 	return rc;
 }
 
-static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
+static void bnx2x_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct bnx2x *bp;
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index ec08654..f1fc66e 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -16298,7 +16298,7 @@ err_out_disable_pdev:
 	return err;
 }
 
-static void __devexit tg3_remove_one(struct pci_dev *pdev)
+static void tg3_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 45ec1c4..76b2af6 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3426,7 +3426,7 @@ unlock_mutex:
 	return err;
 }
 
-static void __devexit
+static void
 bnad_pci_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index fdf7985..b0cdc04 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -459,7 +459,7 @@ err_free_dev:
 	return res;
 }
 
-static int __devexit at91ether_remove(struct platform_device *pdev)
+static int at91ether_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct macb *lp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
index e5053ad..5f60623 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
+++ b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
@@ -1332,7 +1332,7 @@ static inline void t1_sw_reset(struct pci_dev *pdev)
 	pci_write_config_dword(pdev, A_PCICFG_PM_CSR, 0);
 }
 
-static void __devexit remove_one(struct pci_dev *pdev)
+static void remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct adapter *adapter = dev->ml_priv;
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 9d09fcd..4aa3b21 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -3381,7 +3381,7 @@ out:
 	return err;
 }
 
-static void __devexit remove_one(struct pci_dev *pdev)
+static void remove_one(struct pci_dev *pdev)
 {
 	struct adapter *adapter = pci_get_drvdata(pdev);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
index 67986cc..942dace 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
@@ -1396,7 +1396,7 @@ void cxgb3_adapter_ofld(struct adapter *adapter)
 	register_tdev(tdev);
 }
 
-void __devexit cxgb3_adapter_unofld(struct adapter *adapter)
+void cxgb3_adapter_unofld(struct adapter *adapter)
 {
 	struct t3cdev *tdev = &adapter->tdev;
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 3321e1b..bef893d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4640,7 +4640,7 @@ sriov:
 	return err;
 }
 
-static void __devexit remove_one(struct pci_dev *pdev)
+static void remove_one(struct pci_dev *pdev)
 {
 	struct adapter *adapter = pci_get_drvdata(pdev);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 5ffc34e..f866eb5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2769,7 +2769,7 @@ err_disable_device:
  * "probe" routine and quiesce the device (disable interrupts, etc.).  (Note
  * that this is called "remove_one" in the PF Driver.)
  */
-static void __devexit cxgb4vf_pci_remove(struct pci_dev *pdev)
+static void cxgb4vf_pci_remove(struct pci_dev *pdev)
 {
 	struct adapter *adapter = pci_get_drvdata(pdev);
 
@@ -2835,7 +2835,7 @@ static void __devexit cxgb4vf_pci_remove(struct pci_dev *pdev)
  * "Shutdown" quiesce the device, stopping Ingress Packet and Interrupt
  * delivery.
  */
-static void __devexit cxgb4vf_pci_shutdown(struct pci_dev *pdev)
+static void cxgb4vf_pci_shutdown(struct pci_dev *pdev)
 {
 	struct adapter *adapter;
 	int pidx;
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 44525d2..930f03b 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2552,7 +2552,7 @@ err_out_free_netdev:
 	return err;
 }
 
-static void __devexit enic_remove(struct pci_dev *pdev)
+static void enic_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 
diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index d176ec5..c716e95 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1661,7 +1661,7 @@ static const struct dev_pm_ops dm9000_drv_pm_ops = {
 	.resume		= dm9000_drv_resume,
 };
 
-static int __devexit
+static int
 dm9000_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/ethernet/dec/tulip/de2104x.c
index ae4d5f5..69cc2fd 100644
--- a/drivers/net/ethernet/dec/tulip/de2104x.c
+++ b/drivers/net/ethernet/dec/tulip/de2104x.c
@@ -2099,7 +2099,7 @@ err_out_free:
 	return rc;
 }
 
-static void __devexit de_remove_one (struct pci_dev *pdev)
+static void de_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct de_private *de = netdev_priv(dev);
diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index af41e86..9b68e99 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -2077,7 +2077,7 @@ static int __init de4x5_eisa_probe (struct device *gendev)
 	return status;
 }
 
-static int __devexit de4x5_eisa_remove (struct device *device)
+static int de4x5_eisa_remove (struct device *device)
 {
 	struct net_device *dev;
 	u_long iobase;
@@ -2314,7 +2314,7 @@ static int de4x5_pci_probe (struct pci_dev *pdev,
 	return error;
 }
 
-static void __devexit de4x5_pci_remove (struct pci_dev *pdev)
+static void de4x5_pci_remove (struct pci_dev *pdev)
 {
 	struct net_device *dev;
 	u_long iobase;
diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index 6166571..ad4b005 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -531,7 +531,7 @@ err_out_free:
 }
 
 
-static void __devexit dmfe_remove_one (struct pci_dev *pdev)
+static void dmfe_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct dmfe_board_info *db = netdev_priv(dev);
diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index fa15d34..53cee77 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -1927,7 +1927,7 @@ static int tulip_resume(struct pci_dev *pdev)
 #endif /* CONFIG_PM */
 
 
-static void __devexit tulip_remove_one (struct pci_dev *pdev)
+static void tulip_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
 	struct tulip_private *tp;
diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index fc36d7b..b5e10ef 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -436,7 +436,7 @@ err_out_free:
 }
 
 
-static void __devexit uli526x_remove_one (struct pci_dev *pdev)
+static void uli526x_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct uli526x_board_info *db = netdev_priv(dev);
diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
index d146d50..90ee75a 100644
--- a/drivers/net/ethernet/dec/tulip/winbond-840.c
+++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
@@ -1532,7 +1532,7 @@ static int netdev_close(struct net_device *dev)
 	return 0;
 }
 
-static void __devexit w840_remove1 (struct pci_dev *pdev)
+static void w840_remove1 (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 
diff --git a/drivers/net/ethernet/dec/tulip/xircom_cb.c b/drivers/net/ethernet/dec/tulip/xircom_cb.c
index 8e1f8f6..88feced 100644
--- a/drivers/net/ethernet/dec/tulip/xircom_cb.c
+++ b/drivers/net/ethernet/dec/tulip/xircom_cb.c
@@ -312,7 +312,7 @@ err_disable:
  Interrupts and such are already stopped in the "ifconfig ethX down"
  code.
  */
-static void __devexit xircom_remove(struct pci_dev *pdev)
+static void xircom_remove(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct xircom_private *card = netdev_priv(dev);
diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index 398d730..1d342d3 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -1727,7 +1727,7 @@ rio_close (struct net_device *dev)
 	return 0;
 }
 
-static void __devexit
+static void
 rio_remove1 (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethernet/dlink/sundance.c
index 40ebb13..658098a 100644
--- a/drivers/net/ethernet/dlink/sundance.c
+++ b/drivers/net/ethernet/dlink/sundance.c
@@ -1844,7 +1844,7 @@ static int netdev_close(struct net_device *dev)
 	return 0;
 }
 
-static void __devexit sundance_remove1 (struct pci_dev *pdev)
+static void sundance_remove1 (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index e409525..0f1b993 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -945,7 +945,7 @@ err_out:
 	return err;
 }
 
-static int __devexit dnet_remove(struct platform_device *pdev)
+static int dnet_remove(struct platform_device *pdev)
 {
 
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 92c2f5d..20aebc6 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3766,7 +3766,7 @@ static int be_stats_init(struct be_adapter *adapter)
 	return 0;
 }
 
-static void __devexit be_remove(struct pci_dev *pdev)
+static void be_remove(struct pci_dev *pdev)
 {
 	struct be_adapter *adapter = pci_get_drvdata(pdev);
 
diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 78764bb..8db1c06 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -1143,7 +1143,7 @@ out:
  * ethoc_remove - shutdown OpenCores ethernet MAC
  * @pdev:	platform device
  */
-static int __devexit ethoc_remove(struct platform_device *pdev)
+static int ethoc_remove(struct platform_device *pdev)
 {
 	struct net_device *netdev = platform_get_drvdata(pdev);
 	struct ethoc *priv = netdev_priv(netdev);
diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
index d8a345c..519c289 100644
--- a/drivers/net/ethernet/fealnx.c
+++ b/drivers/net/ethernet/fealnx.c
@@ -684,7 +684,7 @@ err_out_res:
 }
 
 
-static void __devexit fealnx_remove_one(struct pci_dev *pdev)
+static void fealnx_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index ae7ebd7..0704bca 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1701,7 +1701,7 @@ failed_alloc_etherdev:
 	return ret;
 }
 
-static int __devexit
+static int
 fec_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
index ac8378b..418068b 100644
--- a/drivers/net/ethernet/freescale/xgmac_mdio.c
+++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
@@ -240,7 +240,7 @@ err_ioremap:
 	return ret;
 }
 
-static int __devexit xgmac_mdio_remove(struct platform_device *pdev)
+static int xgmac_mdio_remove(struct platform_device *pdev)
 {
 	struct mii_bus *bus = dev_get_drvdata(&pdev->dev);
 
diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index af986d6..c1b997e 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -2866,7 +2866,7 @@ static int __init hp100_eisa_probe (struct device *gendev)
 	return err;
 }
 
-static int __devexit hp100_eisa_remove (struct device *gendev)
+static int hp100_eisa_remove (struct device *gendev)
 {
 	struct net_device *dev = dev_get_drvdata(gendev);
 	cleanup_dev(dev);
@@ -2937,7 +2937,7 @@ static int hp100_pci_probe (struct pci_dev *pdev,
 	return err;
 }
 
-static void __devexit hp100_pci_remove (struct pci_dev *pdev)
+static void hp100_pci_remove (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 
diff --git a/drivers/net/ethernet/i825xx/ether1.c b/drivers/net/ethernet/i825xx/ether1.c
index 44ca732..ba2b749 100644
--- a/drivers/net/ethernet/i825xx/ether1.c
+++ b/drivers/net/ethernet/i825xx/ether1.c
@@ -1052,7 +1052,7 @@ ether1_probe(struct expansion_card *ec, const struct ecard_id *id)
 	return ret;
 }
 
-static void __devexit ether1_remove(struct expansion_card *ec)
+static void ether1_remove(struct expansion_card *ec)
 {
 	struct net_device *dev = ecard_get_drvdata(ec);
 
diff --git a/drivers/net/ethernet/i825xx/lasi_82596.c b/drivers/net/ethernet/i825xx/lasi_82596.c
index 6bd7941..9f1a7ec 100644
--- a/drivers/net/ethernet/i825xx/lasi_82596.c
+++ b/drivers/net/ethernet/i825xx/lasi_82596.c
@@ -195,7 +195,7 @@ lan_init_chip(struct parisc_device *dev)
 	return retval;
 }
 
-static int __devexit lan_remove_chip (struct parisc_device *pdev)
+static int lan_remove_chip (struct parisc_device *pdev)
 {
 	struct net_device *dev = parisc_get_drvdata(pdev);
 	struct i596_private *lp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/i825xx/sni_82596.c b/drivers/net/ethernet/i825xx/sni_82596.c
index 349b5f9..4ceae9a 100644
--- a/drivers/net/ethernet/i825xx/sni_82596.c
+++ b/drivers/net/ethernet/i825xx/sni_82596.c
@@ -147,7 +147,7 @@ probe_failed_free_mpu:
 	return retval;
 }
 
-static int __devexit sni_82596_driver_remove(struct platform_device *pdev)
+static int sni_82596_driver_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct i596_private *lp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 9fc453d..651ca1c 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -101,7 +101,7 @@ static struct ehea_bcmc_reg_array ehea_bcmc_regs;
 static int ehea_probe_adapter(struct platform_device *dev,
 					const struct of_device_id *id);
 
-static int __devexit ehea_remove(struct platform_device *dev);
+static int ehea_remove(struct platform_device *dev);
 
 static struct of_device_id ehea_device_table[] = {
 	{
@@ -3364,7 +3364,7 @@ out:
 	return ret;
 }
 
-static int __devexit ehea_remove(struct platform_device *dev)
+static int ehea_remove(struct platform_device *dev)
 {
 	struct ehea_adapter *adapter = dev_get_drvdata(&dev->dev);
 	int i;
diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 5b87af7..c791ad3 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -2930,7 +2930,7 @@ static int emac_probe(struct platform_device *ofdev)
 	return err;
 }
 
-static int __devexit emac_remove(struct platform_device *ofdev)
+static int emac_remove(struct platform_device *ofdev)
 {
 	struct emac_instance *dev = dev_get_drvdata(&ofdev->dev);
 
diff --git a/drivers/net/ethernet/ibm/emac/mal.c b/drivers/net/ethernet/ibm/emac/mal.c
index a8fded5..8becaaf 100644
--- a/drivers/net/ethernet/ibm/emac/mal.c
+++ b/drivers/net/ethernet/ibm/emac/mal.c
@@ -729,7 +729,7 @@ static int mal_probe(struct platform_device *ofdev)
 	return err;
 }
 
-static int __devexit mal_remove(struct platform_device *ofdev)
+static int mal_remove(struct platform_device *ofdev)
 {
 	struct mal_instance *mal = dev_get_drvdata(&ofdev->dev);
 
diff --git a/drivers/net/ethernet/ibm/emac/rgmii.c b/drivers/net/ethernet/ibm/emac/rgmii.c
index 8b1f02f..3925176 100644
--- a/drivers/net/ethernet/ibm/emac/rgmii.c
+++ b/drivers/net/ethernet/ibm/emac/rgmii.c
@@ -289,7 +289,7 @@ static int rgmii_probe(struct platform_device *ofdev)
 	return rc;
 }
 
-static int __devexit rgmii_remove(struct platform_device *ofdev)
+static int rgmii_remove(struct platform_device *ofdev)
 {
 	struct rgmii_instance *dev = dev_get_drvdata(&ofdev->dev);
 
diff --git a/drivers/net/ethernet/ibm/emac/tah.c b/drivers/net/ethernet/ibm/emac/tah.c
index a6d3144..795f139 100644
--- a/drivers/net/ethernet/ibm/emac/tah.c
+++ b/drivers/net/ethernet/ibm/emac/tah.c
@@ -135,7 +135,7 @@ static int tah_probe(struct platform_device *ofdev)
 	return rc;
 }
 
-static int __devexit tah_remove(struct platform_device *ofdev)
+static int tah_remove(struct platform_device *ofdev)
 {
 	struct tah_instance *dev = dev_get_drvdata(&ofdev->dev);
 
diff --git a/drivers/net/ethernet/ibm/emac/zmii.c b/drivers/net/ethernet/ibm/emac/zmii.c
index f958310..f91202f 100644
--- a/drivers/net/ethernet/ibm/emac/zmii.c
+++ b/drivers/net/ethernet/ibm/emac/zmii.c
@@ -282,7 +282,7 @@ static int zmii_probe(struct platform_device *ofdev)
 	return rc;
 }
 
-static int __devexit zmii_remove(struct platform_device *ofdev)
+static int zmii_remove(struct platform_device *ofdev)
 {
 	struct zmii_instance *dev = dev_get_drvdata(&ofdev->dev);
 
diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 2b4daf7..35485f2 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1426,7 +1426,7 @@ static int ibmveth_probe(struct vio_dev *dev,
 	return 0;
 }
 
-static int __devexit ibmveth_remove(struct vio_dev *dev)
+static int ibmveth_remove(struct vio_dev *dev)
 {
 	struct net_device *netdev = dev_get_drvdata(&dev->dev);
 	struct ibmveth_adapter *adapter = netdev_priv(netdev);
diff --git a/drivers/net/ethernet/icplus/ipg.c b/drivers/net/ethernet/icplus/ipg.c
index 4558459..f80ae74 100644
--- a/drivers/net/ethernet/icplus/ipg.c
+++ b/drivers/net/ethernet/icplus/ipg.c
@@ -2167,7 +2167,7 @@ static const struct ethtool_ops ipg_ethtool_ops = {
 	.nway_reset   = ipg_nway_reset,
 };
 
-static void __devexit ipg_remove(struct pci_dev *pdev)
+static void ipg_remove(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct ipg_nic_private *sp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index d0a4e2f..50c2050 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2981,7 +2981,7 @@ err_out_free_dev:
 	return err;
 }
 
-static void __devexit e100_remove(struct pci_dev *pdev)
+static void e100_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 77d8c0d..840fb0d 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -111,7 +111,7 @@ void e1000_update_stats(struct e1000_adapter *adapter);
 static int e1000_init_module(void);
 static void e1000_exit_module(void);
 static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent);
-static void __devexit e1000_remove(struct pci_dev *pdev);
+static void e1000_remove(struct pci_dev *pdev);
 static int e1000_alloc_queues(struct e1000_adapter *adapter);
 static int e1000_sw_init(struct e1000_adapter *adapter);
 static int e1000_open(struct net_device *netdev);
@@ -1273,7 +1273,7 @@ err_pci_reg:
  * memory.
  **/
 
-static void __devexit e1000_remove(struct pci_dev *pdev)
+static void e1000_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 5dc54df..e59f013 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6436,7 +6436,7 @@ err_dma:
  * Hot-Plug event, or because the driver is going to be removed from
  * memory.
  **/
-static void __devexit e1000_remove(struct pci_dev *pdev)
+static void e1000_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index b5557cb..d82869c 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -118,7 +118,7 @@ static void igb_free_all_tx_resources(struct igb_adapter *);
 static void igb_free_all_rx_resources(struct igb_adapter *);
 static void igb_setup_mrqc(struct igb_adapter *);
 static int igb_probe(struct pci_dev *, const struct pci_device_id *);
-static void __devexit igb_remove(struct pci_dev *pdev);
+static void igb_remove(struct pci_dev *pdev);
 static int igb_sw_init(struct igb_adapter *);
 static int igb_open(struct net_device *);
 static int igb_close(struct net_device *);
@@ -2186,7 +2186,7 @@ err_dma:
  * Hot-Plug event, or because the driver is going to be removed from
  * memory.
  **/
-static void __devexit igb_remove(struct pci_dev *pdev)
+static void igb_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct igb_adapter *adapter = netdev_priv(netdev);
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 6124032..1d71bdd 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -2807,7 +2807,7 @@ err_dma:
  * Hot-Plug event, or because the driver is going to be removed from
  * memory.
  **/
-static void __devexit igbvf_remove(struct pci_dev *pdev)
+static void igbvf_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct igbvf_adapter *adapter = netdev_priv(netdev);
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 407e226..ae96c10 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -73,7 +73,7 @@ MODULE_DEVICE_TABLE(pci, ixgb_pci_tbl);
 static int ixgb_init_module(void);
 static void ixgb_exit_module(void);
 static int ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent);
-static void __devexit ixgb_remove(struct pci_dev *pdev);
+static void ixgb_remove(struct pci_dev *pdev);
 static int ixgb_sw_init(struct ixgb_adapter *adapter);
 static int ixgb_open(struct net_device *netdev);
 static int ixgb_close(struct net_device *netdev);
@@ -558,7 +558,7 @@ err_dma_mask:
  * memory.
  **/
 
-static void __devexit
+static void
 ixgb_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0125ffa..cc1b949 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7578,7 +7578,7 @@ err_dma:
  * Hot-Plug event, or because the driver is going to be removed from
  * memory.
  **/
-static void __devexit ixgbe_remove(struct pci_dev *pdev)
+static void ixgbe_remove(struct pci_dev *pdev)
 {
 	struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
 	struct net_device *netdev = adapter->netdev;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index b8fbdab..1244f5b 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3443,7 +3443,7 @@ err_dma:
  * Hot-Plug event, or because the driver is going to be removed from
  * memory.
  **/
-static void __devexit ixgbevf_remove(struct pci_dev *pdev)
+static void ixgbevf_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 768023c..2f279c4 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -3215,7 +3215,7 @@ err_out:
 	return rc;
 }
 
-static void __devexit
+static void
 jme_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 44d4d61..c124e67 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -774,7 +774,7 @@ err_out:
 	return err;
 }
 
-static int __devexit
+static int
 ltq_etop_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 79b7bbd..3d66e95 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -4012,7 +4012,7 @@ err_out:
 	return err;
 }
 
-static void __devexit skge_remove(struct pci_dev *pdev)
+static void skge_remove(struct pci_dev *pdev)
 {
 	struct skge_hw *hw  = pci_get_drvdata(pdev);
 	struct net_device *dev0, *dev1;
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 07d195f..bd77cb9 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -5086,7 +5086,7 @@ err_out:
 	return err;
 }
 
-static void __devexit sky2_remove(struct pci_dev *pdev)
+static void sky2_remove(struct pci_dev *pdev)
 {
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
 	int i;
diff --git a/drivers/net/ethernet/micrel/ks8695net.c b/drivers/net/ethernet/micrel/ks8695net.c
index 7ac240d..69c3e5c6 100644
--- a/drivers/net/ethernet/micrel/ks8695net.c
+++ b/drivers/net/ethernet/micrel/ks8695net.c
@@ -1597,7 +1597,7 @@ ks8695_drv_resume(struct platform_device *pdev)
  *
  *	This unregisters and releases a KS8695 ethernet device.
  */
-static int __devexit
+static int
 ks8695_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
diff --git a/drivers/net/ethernet/micrel/ks8842.c b/drivers/net/ethernet/micrel/ks8842.c
index a23b534..b71eb39 100644
--- a/drivers/net/ethernet/micrel/ks8842.c
+++ b/drivers/net/ethernet/micrel/ks8842.c
@@ -1240,7 +1240,7 @@ err_mem_region:
 	return err;
 }
 
-static int __devexit ks8842_remove(struct platform_device *pdev)
+static int ks8842_remove(struct platform_device *pdev)
 {
 	struct net_device *netdev = platform_get_drvdata(pdev);
 	struct ks8842_adapter *adapter = netdev_priv(netdev);
diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index dbd2ece..286816a 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1534,7 +1534,7 @@ err_irq:
 	return ret;
 }
 
-static int __devexit ks8851_remove(struct spi_device *spi)
+static int ks8851_remove(struct spi_device *spi)
 {
 	struct ks8851_net *priv = dev_get_drvdata(&spi->dev);
 
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index 2070af2..ef8f9f9 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -1641,7 +1641,7 @@ err_mem_region:
 	return err;
 }
 
-static int __devexit ks8851_remove(struct platform_device *pdev)
+static int ks8851_remove(struct platform_device *pdev)
 {
 	struct net_device *netdev = platform_get_drvdata(pdev);
 	struct ks_net *ks = netdev_priv(netdev);
diff --git a/drivers/net/ethernet/microchip/enc28j60.c b/drivers/net/ethernet/microchip/enc28j60.c
index 2851829..a99456c 100644
--- a/drivers/net/ethernet/microchip/enc28j60.c
+++ b/drivers/net/ethernet/microchip/enc28j60.c
@@ -1617,7 +1617,7 @@ error_alloc:
 	return ret;
 }
 
-static int __devexit enc28j60_remove(struct spi_device *spi)
+static int enc28j60_remove(struct spi_device *spi)
 {
 	struct enc28j60_net *priv = dev_get_drvdata(&spi->dev);
 
diff --git a/drivers/net/ethernet/natsemi/jazzsonic.c b/drivers/net/ethernet/natsemi/jazzsonic.c
index 90c6670..5789a2a 100644
--- a/drivers/net/ethernet/natsemi/jazzsonic.c
+++ b/drivers/net/ethernet/natsemi/jazzsonic.c
@@ -270,7 +270,7 @@ MODULE_ALIAS("platform:jazzsonic");
 
 #include "sonic.c"
 
-static int __devexit jazz_sonic_device_remove (struct platform_device *pdev)
+static int jazz_sonic_device_remove (struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct sonic_local* lp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/natsemi/macsonic.c b/drivers/net/ethernet/natsemi/macsonic.c
index a7d07c4..6364db6 100644
--- a/drivers/net/ethernet/natsemi/macsonic.c
+++ b/drivers/net/ethernet/natsemi/macsonic.c
@@ -619,7 +619,7 @@ MODULE_ALIAS("platform:macsonic");
 
 #include "sonic.c"
 
-static int __devexit mac_sonic_device_remove (struct platform_device *pdev)
+static int mac_sonic_device_remove (struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct sonic_local* lp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index eceebd1..7b2d04a 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -3214,7 +3214,7 @@ static int netdev_close(struct net_device *dev)
 }
 
 
-static void __devexit natsemi_remove1 (struct pci_dev *pdev)
+static void natsemi_remove1 (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	void __iomem * ioaddr = ns_ioaddr(dev);
diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index 0131b18..0281755 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -2241,7 +2241,7 @@ out:
 	return err;
 }
 
-static void __devexit ns83820_remove_one(struct pci_dev *pci_dev)
+static void ns83820_remove_one(struct pci_dev *pci_dev)
 {
 	struct net_device *ndev = pci_get_drvdata(pci_dev);
 	struct ns83820 *dev = PRIV(ndev); /* ok even if NULL */
diff --git a/drivers/net/ethernet/natsemi/xtsonic.c b/drivers/net/ethernet/natsemi/xtsonic.c
index c265a5e..0744b55 100644
--- a/drivers/net/ethernet/natsemi/xtsonic.c
+++ b/drivers/net/ethernet/natsemi/xtsonic.c
@@ -297,7 +297,7 @@ MODULE_PARM_DESC(sonic_debug, "xtsonic debug level (1-4)");
 
 #include "sonic.c"
 
-static int __devexit xtsonic_device_remove (struct platform_device *pdev)
+static int xtsonic_device_remove (struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct sonic_local *lp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 1b70a92..3a010e3 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -8200,7 +8200,7 @@ mem_alloc_failed:
  * from memory.
  */
 
-static void __devexit s2io_rem_nic(struct pci_dev *pdev)
+static void s2io_rem_nic(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct s2io_nic *sp;
diff --git a/drivers/net/ethernet/neterion/s2io.h b/drivers/net/ethernet/neterion/s2io.h
index 304124a61..032f9b6 100644
--- a/drivers/net/ethernet/neterion/s2io.h
+++ b/drivers/net/ethernet/neterion/s2io.h
@@ -1077,7 +1077,7 @@ static inline void SPECIAL_REG_WRITE(u64 val, void __iomem *addr, int order)
  */
 static int s2io_init_nic(struct pci_dev *pdev,
 				   const struct pci_device_id *pre);
-static void __devexit s2io_rem_nic(struct pci_dev *pdev);
+static void s2io_rem_nic(struct pci_dev *pdev);
 static int init_shared_mem(struct s2io_nic *sp);
 static void free_shared_mem(struct s2io_nic *sp);
 static int init_nic(struct s2io_nic *nic);
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 2e3a3f0..bb5770f 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -4764,7 +4764,7 @@ _exit0:
  * Description: This function is called by the Pci subsystem to release a
  * PCI device and free up all resource held up by the device.
  */
-static void __devexit vxge_remove(struct pci_dev *pdev)
+static void vxge_remove(struct pci_dev *pdev)
 {
 	struct __vxge_hw_device *hldev;
 	struct vxgedev *vdev;
diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index ea74f34..cbd6a52 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -1071,7 +1071,7 @@ failed_free:
 	return error;
 }
 
-static int __devexit w90p910_ether_remove(struct platform_device *pdev)
+static int w90p910_ether_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct w90p910_ether *ether = netdev_priv(dev);
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index fb64c04..653487d 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -5995,7 +5995,7 @@ static void nv_restore_mac_addr(struct pci_dev *pci_dev)
 	       base + NvRegTransmitPoll);
 }
 
-static void __devexit nv_remove(struct pci_dev *pci_dev)
+static void nv_remove(struct pci_dev *pci_dev)
 {
 	struct net_device *dev = pci_get_drvdata(pci_dev);
 
diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index ea88571..b549919 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -1559,7 +1559,7 @@ err:
 	return result;
 }
 
-static int __devexit octeon_mgmt_remove(struct platform_device *pdev)
+static int octeon_mgmt_remove(struct platform_device *pdev)
 {
 	struct net_device *netdev = dev_get_drvdata(&pdev->dev);
 
diff --git a/drivers/net/ethernet/packetengines/hamachi.c b/drivers/net/ethernet/packetengines/hamachi.c
index 16bd6b4..84be29b 100644
--- a/drivers/net/ethernet/packetengines/hamachi.c
+++ b/drivers/net/ethernet/packetengines/hamachi.c
@@ -1894,7 +1894,7 @@ static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 }
 
 
-static void __devexit hamachi_remove_one (struct pci_dev *pdev)
+static void hamachi_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 
diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
index 0abe8f5..0f3b782 100644
--- a/drivers/net/ethernet/packetengines/yellowfin.c
+++ b/drivers/net/ethernet/packetengines/yellowfin.c
@@ -1372,7 +1372,7 @@ static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 }
 
 
-static void __devexit yellowfin_remove_one (struct pci_dev *pdev)
+static void yellowfin_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct yellowfin_private *np;
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index 7620755..0be5844 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -1849,7 +1849,7 @@ out_disable_device:
 
 }
 
-static void __devexit pasemi_mac_remove(struct pci_dev *pdev)
+static void pasemi_mac_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct pasemi_mac *mac;
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index b36aa37..6098fd4a 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -62,7 +62,7 @@ MODULE_PARM_DESC(auto_fw_reset,"Auto firmware reset (0=disabled, 1=enabled");
 
 static int netxen_nic_probe(struct pci_dev *pdev,
 		const struct pci_device_id *ent);
-static void __devexit netxen_nic_remove(struct pci_dev *pdev);
+static void netxen_nic_remove(struct pci_dev *pdev);
 static int netxen_nic_open(struct net_device *netdev);
 static int netxen_nic_close(struct net_device *netdev);
 static netdev_tx_t netxen_nic_xmit_frame(struct sk_buff *,
@@ -1569,7 +1569,7 @@ void netxen_cleanup_minidump(struct netxen_adapter *adapter)
 	}
 }
 
-static void __devexit netxen_nic_remove(struct pci_dev *pdev)
+static void netxen_nic_remove(struct pci_dev *pdev)
 {
 	struct netxen_adapter *adapter;
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index 2528502..df6eb27 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -3925,7 +3925,7 @@ err_out:
 	return err;
 }
 
-static void __devexit ql3xxx_remove(struct pci_dev *pdev)
+static void ql3xxx_remove(struct pci_dev *pdev)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
 	struct ql3_adapter *qdev = netdev_priv(ndev);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 8d623aa..e66d3d0 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -56,7 +56,7 @@ MODULE_PARM_DESC(qlcnic_config_npars, "Configure NPARs (0=disabled, 1=enabled");
 
 static int qlcnic_probe(struct pci_dev *pdev,
 		const struct pci_device_id *ent);
-static void __devexit qlcnic_remove(struct pci_dev *pdev);
+static void qlcnic_remove(struct pci_dev *pdev);
 static int qlcnic_open(struct net_device *netdev);
 static int qlcnic_close(struct net_device *netdev);
 static void qlcnic_tx_timeout(struct net_device *netdev);
@@ -1724,7 +1724,7 @@ err_out_maintenance_mode:
 	return 0;
 }
 
-static void __devexit qlcnic_remove(struct pci_dev *pdev)
+static void qlcnic_remove(struct pci_dev *pdev)
 {
 	struct qlcnic_adapter *adapter;
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 372040d..cae881c 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -4729,7 +4729,7 @@ int ql_clean_lb_rx_ring(struct rx_ring *rx_ring, int budget)
 	return ql_clean_inbound_rx_ring(rx_ring, budget);
 }
 
-static void __devexit qlge_remove(struct pci_dev *pdev)
+static void qlge_remove(struct pci_dev *pdev)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
 	struct ql_adapter *qdev = netdev_priv(ndev);
diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 6d09efe..ae27e44 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1246,7 +1246,7 @@ err_out:
 	return err;
 }
 
-static void __devexit r6040_remove_one(struct pci_dev *pdev)
+static void r6040_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct r6040_private *lp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 90858ef..34c9d59 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -1103,7 +1103,7 @@ err_out:
 }
 
 
-static void __devexit rtl8139_remove_one (struct pci_dev *pdev)
+static void rtl8139_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
 	struct rtl8139_private *tp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b8f2737..891feee 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6610,7 +6610,7 @@ static void rtl_shutdown(struct pci_dev *pdev)
 	pm_runtime_put_noidle(d);
 }
 
-static void __devexit rtl_remove_one(struct pci_dev *pdev)
+static void rtl_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/s6gmac.c b/drivers/net/ethernet/s6gmac.c
index 2707d75..72fc57d 100644
--- a/drivers/net/ethernet/s6gmac.c
+++ b/drivers/net/ethernet/s6gmac.c
@@ -1030,7 +1030,7 @@ errirq:
 	return res;
 }
 
-static int __devexit s6gmac_remove(struct platform_device *pdev)
+static int s6gmac_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	if (dev) {
diff --git a/drivers/net/ethernet/seeq/ether3.c b/drivers/net/ethernet/seeq/ether3.c
index 9693b9b..2e70c3b 100644
--- a/drivers/net/ethernet/seeq/ether3.c
+++ b/drivers/net/ethernet/seeq/ether3.c
@@ -864,7 +864,7 @@ ether3_probe(struct expansion_card *ec, const struct ecard_id *id)
 	return ret;
 }
 
-static void __devexit ether3_remove(struct expansion_card *ec)
+static void ether3_remove(struct expansion_card *ec)
 {
 	struct net_device *dev = ecard_get_drvdata(ec);
 
diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
index 8f2975b..387e492 100644
--- a/drivers/net/ethernet/sgi/ioc3-eth.c
+++ b/drivers/net/ethernet/sgi/ioc3-eth.c
@@ -1368,7 +1368,7 @@ out:
 	return err;
 }
 
-static void __devexit ioc3_remove_one (struct pci_dev *pdev)
+static void ioc3_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct ioc3_private *ip = netdev_priv(dev);
diff --git a/drivers/net/ethernet/silan/sc92031.c b/drivers/net/ethernet/silan/sc92031.c
index 3a32673..2103449 100644
--- a/drivers/net/ethernet/silan/sc92031.c
+++ b/drivers/net/ethernet/silan/sc92031.c
@@ -1489,7 +1489,7 @@ out_enable_device:
 	return err;
 }
 
-static void __devexit sc92031_remove(struct pci_dev *pdev)
+static void sc92031_remove(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct sc92031_priv *priv = netdev_priv(dev);
diff --git a/drivers/net/ethernet/sis/sis190.c b/drivers/net/ethernet/sis/sis190.c
index 0c64837..c114c4f 100644
--- a/drivers/net/ethernet/sis/sis190.c
+++ b/drivers/net/ethernet/sis/sis190.c
@@ -1916,7 +1916,7 @@ err_release_board:
 	goto out;
 }
 
-static void __devexit sis190_remove_one(struct pci_dev *pdev)
+static void sis190_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct sis190_private *tp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index 09cd377..69547d2 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -2410,7 +2410,7 @@ static void sis900_reset(struct net_device *net_dev)
  *	remove and release SiS900 net device
  */
 
-static void __devexit sis900_remove(struct pci_dev *pci_dev)
+static void sis900_remove(struct pci_dev *pci_dev)
 {
 	struct net_device *net_dev = pci_get_drvdata(pci_dev);
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index 9ca0308..347cccb 100644
--- a/drivers/net/ethernet/smsc/epic100.c
+++ b/drivers/net/ethernet/smsc/epic100.c
@@ -1524,7 +1524,7 @@ static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 }
 
 
-static void __devexit epic_remove_one(struct pci_dev *pdev)
+static void epic_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct epic_private *ep = netdev_priv(dev);
diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index d8ac9d2..4da6fec 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -2115,7 +2115,7 @@ out:
 	return ret;
 }
 
-static int __devexit smc911x_drv_remove(struct platform_device *pdev)
+static int smc911x_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct smc911x_local *lp = netdev_priv(ndev);
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 3687de9..f7b429d 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2324,7 +2324,7 @@ static int smc_drv_probe(struct platform_device *pdev)
 	return ret;
 }
 
-static int __devexit smc_drv_remove(struct platform_device *pdev)
+static int smc_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct smc_local *lp = netdev_priv(ndev);
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 53980b5..07143ba 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2231,7 +2231,7 @@ static int smsc911x_init(struct net_device *dev)
 	return 0;
 }
 
-static int __devexit smsc911x_drv_remove(struct platform_device *pdev)
+static int smsc911x_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct smsc911x_data *pdata;
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index fa3ab62..3c58658 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -1702,7 +1702,7 @@ out_0:
 	return -ENODEV;
 }
 
-static void __devexit smsc9420_remove(struct pci_dev *pdev)
+static void smsc9420_remove(struct pci_dev *pdev)
 {
 	struct net_device *dev;
 	struct smsc9420_pdata *pd;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 572702a..5cf9eb6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -130,7 +130,7 @@ err_out_req_reg_failed:
  * Description: this function calls the main to free the net resources
  * and releases the PCI resources.
  */
-static void __devexit stmmac_pci_remove(struct pci_dev *pdev)
+static void stmmac_pci_remove(struct pci_dev *pdev)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
 	struct stmmac_priv *priv = netdev_priv(ndev);
diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index ef2f21a..85f971f 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -5175,7 +5175,7 @@ err_out_disable_pdev:
 	return -ENODEV;
 }
 
-static void __devexit cas_remove_one(struct pci_dev *pdev)
+static void cas_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct cas *cp;
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 7c604a6..6023949 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -9225,7 +9225,7 @@ static int niu_ldg_init(struct niu *np)
 	return 0;
 }
 
-static void __devexit niu_ldg_free(struct niu *np)
+static void niu_ldg_free(struct niu *np)
 {
 	if (np->flags & NIU_FLAGS_MSIX)
 		pci_disable_msix(np->pdev);
@@ -9895,7 +9895,7 @@ err_out_disable_pdev:
 	return err;
 }
 
-static void __devexit niu_pci_remove_one(struct pci_dev *pdev)
+static void niu_pci_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 
@@ -10158,7 +10158,7 @@ err_out:
 	return err;
 }
 
-static int __devexit niu_of_remove(struct platform_device *op)
+static int niu_of_remove(struct platform_device *op)
 {
 	struct net_device *dev = dev_get_drvdata(&op->dev);
 
diff --git a/drivers/net/ethernet/sun/sunbmac.c b/drivers/net/ethernet/sun/sunbmac.c
index 70d46b6..8fda910 100644
--- a/drivers/net/ethernet/sun/sunbmac.c
+++ b/drivers/net/ethernet/sun/sunbmac.c
@@ -1243,7 +1243,7 @@ static int bigmac_sbus_probe(struct platform_device *op)
 	return bigmac_ether_init(op, qec_op);
 }
 
-static int __devexit bigmac_sbus_remove(struct platform_device *op)
+static int bigmac_sbus_remove(struct platform_device *op)
 {
 	struct bigmac *bp = dev_get_drvdata(&op->dev);
 	struct device *parent = op->dev.parent;
diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 2454bd7..43babc3 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -3162,7 +3162,7 @@ err_out:
 	return err;
 }
 
-static void __devexit happy_meal_pci_remove(struct pci_dev *pdev)
+static void happy_meal_pci_remove(struct pci_dev *pdev)
 {
 	struct happy_meal *hp = dev_get_drvdata(&pdev->dev);
 	struct net_device *net_dev = hp->dev;
@@ -3234,7 +3234,7 @@ static int hme_sbus_probe(struct platform_device *op)
 	return happy_meal_sbus_probe_one(op, is_qfe);
 }
 
-static int __devexit hme_sbus_remove(struct platform_device *op)
+static int hme_sbus_remove(struct platform_device *op)
 {
 	struct happy_meal *hp = dev_get_drvdata(&op->dev);
 	struct net_device *net_dev = hp->dev;
diff --git a/drivers/net/ethernet/sun/sunqe.c b/drivers/net/ethernet/sun/sunqe.c
index 14e1523..1dcee69 100644
--- a/drivers/net/ethernet/sun/sunqe.c
+++ b/drivers/net/ethernet/sun/sunqe.c
@@ -934,7 +934,7 @@ static int qec_sbus_probe(struct platform_device *op)
 	return qec_ether_init(op);
 }
 
-static int __devexit qec_sbus_remove(struct platform_device *op)
+static int qec_sbus_remove(struct platform_device *op)
 {
 	struct sunqe *qp = dev_get_drvdata(&op->dev);
 	struct net_device *net_dev = qp->dev;
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index d6e1937..1e4d743 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -2427,7 +2427,7 @@ static void bdx_set_ethtool_ops(struct net_device *netdev)
  * Hot-Plug event, or because the driver is going to be removed from
  * memory.
  **/
-static void __devexit bdx_remove(struct pci_dev *pdev)
+static void bdx_remove(struct pci_dev *pdev)
 {
 	struct pci_nic *nic = pci_get_drvdata(pdev);
 	struct net_device *ndev;
diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 74c7200..d9625f6 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -1204,7 +1204,7 @@ fail:
 	return rc;
 }
 
-static int __devexit cpmac_remove(struct platform_device *pdev)
+static int cpmac_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	unregister_netdev(dev);
@@ -1290,7 +1290,7 @@ fail_alloc:
 	return res;
 }
 
-void __devexit cpmac_exit(void)
+void cpmac_exit(void)
 {
 	platform_driver_unregister(&cpmac_driver);
 	mdiobus_unregister(cpmac_mii);
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index b9e6f39..384f2ea 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1423,7 +1423,7 @@ clean_ndev_ret:
 	return ret;
 }
 
-static int __devexit cpsw_remove(struct platform_device *pdev)
+static int cpsw_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct cpsw_priv *priv = netdev_priv(ndev);
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 9d143c9..2a3e2c5 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -2039,7 +2039,7 @@ no_ndev:
  * Called when removing the device driver. We disable clock usage and release
  * the resources taken up by the driver and unregister network device
  */
-static int __devexit davinci_emac_remove(struct platform_device *pdev)
+static int davinci_emac_remove(struct platform_device *pdev)
 {
 	struct resource *res;
 	struct net_device *ndev = platform_get_drvdata(pdev);
diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 0a2527c..63b6236 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -416,7 +416,7 @@ bail_out:
 	return ret;
 }
 
-static int __devexit davinci_mdio_remove(struct platform_device *pdev)
+static int davinci_mdio_remove(struct platform_device *pdev)
 {
 	struct device *dev = &pdev->dev;
 	struct davinci_mdio_data *data = dev_get_drvdata(dev);
diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index 148e32f..af16081 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -300,7 +300,7 @@ these functions are more or less common to all linux network drivers.
  **************************************************************/
 
 
-static void __devexit tlan_remove_one(struct pci_dev *pdev)
+static void tlan_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct tlan_priv	*priv = netdev_priv(dev);
diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index 95195d2..f1b91fd 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -2531,7 +2531,7 @@ out:
  * spider_net_remove is called to remove the device and unregisters the
  * net_device
  **/
-static void __devexit
+static void
 spider_net_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 6fc4f95..5db09ef 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -878,7 +878,7 @@ err_out:
 }
 
 
-static void __devexit tc35815_remove_one(struct pci_dev *pdev)
+static void tc35815_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct tc35815_local *lp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index d8d3050..53ccc51 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -2232,7 +2232,7 @@ static int rhine_close(struct net_device *dev)
 }
 
 
-static void __devexit rhine_remove_one(struct pci_dev *pdev)
+static void rhine_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rhine_private *rp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index 808368f..3a6d756 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -392,7 +392,7 @@ static const char *get_chip_name(enum chip_type chip_id)
  *	unload for each active device that is present. Disconnects
  *	the device from the network layer and frees all the resources
  */
-static void __devexit velocity_remove1(struct pci_dev *pdev)
+static void velocity_remove1(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct velocity_info *vptr = netdev_priv(dev);
diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 3babcfc..b70be24 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -741,7 +741,7 @@ err_register:
 	return err;
 }
 
-static int __devexit w5100_remove(struct platform_device *pdev)
+static int w5100_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct w5100_priv *priv = netdev_priv(ndev);
diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index 3887747..2756ce3 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -653,7 +653,7 @@ err_register:
 	return err;
 }
 
-static int __devexit w5300_remove(struct platform_device *pdev)
+static int w5300_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct w5300_priv *priv = netdev_priv(ndev);
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 6039f15..aad909d 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -1144,7 +1144,7 @@ static int temac_of_probe(struct platform_device *op)
 	return rc;
 }
 
-static int __devexit temac_of_remove(struct platform_device *op)
+static int temac_of_remove(struct platform_device *op)
 {
 	struct net_device *ndev = dev_get_drvdata(&op->dev);
 	struct temac_local *lp = netdev_priv(ndev);
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 4fb86d4..f04ad05 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1630,7 +1630,7 @@ nodev:
 	return ret;
 }
 
-static int __devexit axienet_of_remove(struct platform_device *op)
+static int axienet_of_remove(struct platform_device *op)
 {
 	struct net_device *ndev = dev_get_drvdata(&op->dev);
 	struct axienet_local *lp = netdev_priv(ndev);
diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index f67922d..919b983 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -1229,7 +1229,7 @@ error2:
  *
  * Return:	0, always.
  */
-static int __devexit xemaclite_of_remove(struct platform_device *of_dev)
+static int xemaclite_of_remove(struct platform_device *of_dev)
 {
 	struct device *dev = &of_dev->dev;
 	struct net_device *ndev = dev_get_drvdata(dev);
diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index 09164c8..a432f28 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -1478,7 +1478,7 @@ err_free:
 	return err;
 }
 
-static int __devexit eth_remove_one(struct platform_device *pdev)
+static int eth_remove_one(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct port *port = netdev_priv(dev);
-- 
1.8.0
