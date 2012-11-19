From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 198/493] ethernet: remove use of __devinit
Date: Mon, 19 Nov 2012 13:22:27 -0500
Message-ID: <1353349642-3677-198-git-send-email-wfp5p@virginia.edu>
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
        Pantelis Antoniou <pantelis.antoniou@gmail.com>,
        Vitaly Bordug <vbordug@ru.mvista.com>,
        Jaroslav Kysela <perex@perex.cz>,
        Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
        Francois Romieu <romieu@fr.zoreil.com>,
        Sorbica Shieh <sorbica@icplus.com.tw>,
        Guo-Fu Tseng <cooldavid@cooldavid.org>,
        Mirko Lindner <mlindner@marvell.com>,
        Stephen Hemminger <shemminger@vyatta.com>,
        Wan ZongS
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

CONFIG_HOTPLUG is going away as an option so __devinit is no longer
needed.

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
Cc: Pantelis Antoniou <pantelis.antoniou@gmail.com> 
Cc: Vitaly Bordug <vbordug@ru.mvista.com> 
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
Cc: Geoff Levand <geoff@infradead.org> 
Cc: Roger Luethi <rl@hellgate.ch> 
Cc: Anirudha Sarangi <anirudh@xilinx.com> 
Cc: John Linn <John.Linn@xilinx.com> 
Cc: Krzysztof Halasa <khc@pm.waw.pl> 
Cc: netdev@vger.kernel.org 
Cc: linux-arm-kernel@lists.infradead.org 
Cc: uclinux-dist-devel@blackfin.uclinux.org 
Cc: linux-acenic@sunsite.dk 
Cc: linuxppc-dev@lists.ozlabs.org 
Cc: e1000-devel@lists.sourceforge.net 
Cc: linux-mips@linux-mips.org 
Cc: cbe-oss-dev@lists.ozlabs.org 
---
 drivers/net/ethernet/3com/3c509.c                  | 10 +--
 drivers/net/ethernet/3com/3c59x.c                  |  4 +-
 drivers/net/ethernet/3com/typhoon.c                |  4 +-
 drivers/net/ethernet/8390/etherh.c                 |  4 +-
 drivers/net/ethernet/8390/hydra.c                  |  8 +-
 drivers/net/ethernet/8390/ne2k-pci.c               |  2 +-
 drivers/net/ethernet/8390/zorro8390.c              |  4 +-
 drivers/net/ethernet/adaptec/starfire.c            |  2 +-
 drivers/net/ethernet/adi/bfin_mac.c                |  4 +-
 drivers/net/ethernet/aeroflex/greth.c              |  2 +-
 drivers/net/ethernet/alteon/acenic.c               | 20 ++---
 drivers/net/ethernet/amd/a2065.c                   |  4 +-
 drivers/net/ethernet/amd/am79c961a.c               |  2 +-
 drivers/net/ethernet/amd/amd8111e.c                |  4 +-
 drivers/net/ethernet/amd/ariadne.c                 |  2 +-
 drivers/net/ethernet/amd/au1000_eth.c              |  2 +-
 drivers/net/ethernet/amd/declance.c                |  6 +-
 drivers/net/ethernet/amd/depca.c                   |  2 +-
 drivers/net/ethernet/amd/hplance.c                 |  8 +-
 drivers/net/ethernet/amd/pcnet32.c                 |  6 +-
 drivers/net/ethernet/amd/sunlance.c                |  4 +-
 drivers/net/ethernet/apple/bmac.c                  |  2 +-
 drivers/net/ethernet/apple/mace.c                  |  2 +-
 drivers/net/ethernet/apple/macmace.c               |  2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |  8 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c    |  6 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_param.c   |  4 +-
 drivers/net/ethernet/atheros/atlx/atl1.c           |  8 +-
 drivers/net/ethernet/atheros/atlx/atl2.c           |  8 +-
 drivers/net/ethernet/broadcom/b44.c                |  4 +-
 drivers/net/ethernet/broadcom/bcm63xx_enet.c       |  4 +-
 drivers/net/ethernet/broadcom/bnx2.c               | 13 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   | 56 +++++++-------
 drivers/net/ethernet/broadcom/sb1250-mac.c         |  2 +-
 drivers/net/ethernet/broadcom/tg3.c                | 86 +++++++++++-----------
 drivers/net/ethernet/brocade/bna/bnad.c            |  2 +-
 drivers/net/ethernet/cadence/macb.c                |  8 +-
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c          |  2 +-
 drivers/net/ethernet/chelsio/cxgb/sge.c            |  2 +-
 drivers/net/ethernet/chelsio/cxgb/subr.c           |  8 +-
 drivers/net/ethernet/chelsio/cxgb/tp.c             |  2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    |  8 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 18 ++---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 12 +--
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    | 12 +--
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |  4 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |  6 +-
 drivers/net/ethernet/cisco/enic/enic_main.c        |  2 +-
 drivers/net/ethernet/davicom/dm9000.c              |  2 +-
 drivers/net/ethernet/dec/tulip/de2104x.c           | 10 +--
 drivers/net/ethernet/dec/tulip/de4x5.c             |  6 +-
 drivers/net/ethernet/dec/tulip/dmfe.c              |  2 +-
 drivers/net/ethernet/dec/tulip/eeprom.c            |  6 +-
 drivers/net/ethernet/dec/tulip/media.c             |  2 +-
 drivers/net/ethernet/dec/tulip/tulip_core.c        |  4 +-
 drivers/net/ethernet/dec/tulip/uli526x.c           |  2 +-
 drivers/net/ethernet/dec/tulip/winbond-840.c       |  2 +-
 drivers/net/ethernet/dec/tulip/xircom_cb.c         |  2 +-
 drivers/net/ethernet/dlink/dl2k.c                  |  2 +-
 drivers/net/ethernet/dlink/sundance.c              |  4 +-
 drivers/net/ethernet/dnet.c                        |  4 +-
 drivers/net/ethernet/emulex/benet/be_main.c        |  2 +-
 drivers/net/ethernet/ethoc.c                       |  4 +-
 drivers/net/ethernet/fealnx.c                      |  2 +-
 drivers/net/ethernet/freescale/fec.c               |  6 +-
 drivers/net/ethernet/freescale/fec_mpc52xx.c       |  2 +-
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |  2 +-
 .../net/ethernet/freescale/fs_enet/mii-bitbang.c   |  4 +-
 drivers/net/ethernet/freescale/fs_enet/mii-fec.c   |  2 +-
 drivers/net/ethernet/freescale/xgmac_mdio.c        |  2 +-
 drivers/net/ethernet/hp/hp100.c                    |  6 +-
 drivers/net/ethernet/i825xx/ether1.c               |  8 +-
 drivers/net/ethernet/i825xx/lasi_82596.c           |  4 +-
 drivers/net/ethernet/i825xx/lib82596.c             |  2 +-
 drivers/net/ethernet/i825xx/sni_82596.c            |  4 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c          |  6 +-
 drivers/net/ethernet/ibm/emac/core.c               | 14 ++--
 drivers/net/ethernet/ibm/emac/mal.c                |  4 +-
 drivers/net/ethernet/ibm/emac/rgmii.c              |  4 +-
 drivers/net/ethernet/ibm/emac/tah.c                |  4 +-
 drivers/net/ethernet/ibm/emac/zmii.c               |  4 +-
 drivers/net/ethernet/ibm/ibmveth.c                 |  2 +-
 drivers/net/ethernet/icplus/ipg.c                  |  2 +-
 drivers/net/ethernet/intel/e100.c                  |  2 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c      |  6 +-
 drivers/net/ethernet/intel/e1000/e1000_param.c     |  8 +-
 drivers/net/ethernet/intel/e1000e/netdev.c         |  6 +-
 drivers/net/ethernet/intel/e1000e/param.c          |  4 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |  6 +-
 drivers/net/ethernet/intel/igbvf/netdev.c          |  6 +-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c        |  4 +-
 drivers/net/ethernet/intel/ixgb/ixgb_param.c       |  4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  4 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |  4 +-
 drivers/net/ethernet/jme.c                         |  2 +-
 drivers/net/ethernet/marvell/skge.c                |  4 +-
 drivers/net/ethernet/marvell/sky2.c                | 12 +--
 drivers/net/ethernet/mellanox/mlx4/main.c          |  2 +-
 drivers/net/ethernet/micrel/ks8695net.c            |  6 +-
 drivers/net/ethernet/micrel/ks8842.c               |  2 +-
 drivers/net/ethernet/micrel/ks8851.c               |  2 +-
 drivers/net/ethernet/micrel/ks8851_mll.c           |  2 +-
 drivers/net/ethernet/micrel/ksz884x.c              |  2 +-
 drivers/net/ethernet/microchip/enc28j60.c          |  2 +-
 drivers/net/ethernet/natsemi/ibmlana.c             |  2 +-
 drivers/net/ethernet/natsemi/jazzsonic.c           |  4 +-
 drivers/net/ethernet/natsemi/macsonic.c            | 14 ++--
 drivers/net/ethernet/natsemi/natsemi.c             |  4 +-
 drivers/net/ethernet/natsemi/ns83820.c             |  2 +-
 drivers/net/ethernet/natsemi/xtsonic.c             |  2 +-
 drivers/net/ethernet/neterion/s2io.c               |  2 +-
 drivers/net/ethernet/neterion/s2io.h               |  2 +-
 drivers/net/ethernet/neterion/vxge/vxge-config.c   |  6 +-
 drivers/net/ethernet/neterion/vxge/vxge-config.h   |  6 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c     | 12 +--
 drivers/net/ethernet/nuvoton/w90p910_ether.c       |  2 +-
 drivers/net/ethernet/nvidia/forcedeth.c            |  2 +-
 drivers/net/ethernet/octeon/octeon_mgmt.c          |  2 +-
 drivers/net/ethernet/packetengines/hamachi.c       |  4 +-
 drivers/net/ethernet/packetengines/yellowfin.c     |  4 +-
 drivers/net/ethernet/pasemi/pasemi_mac.c           |  2 +-
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |  4 +-
 drivers/net/ethernet/qlogic/qla3xxx.c              |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  4 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c       |  4 +-
 drivers/net/ethernet/rdc/r6040.c                   |  2 +-
 drivers/net/ethernet/realtek/8139too.c             |  6 +-
 drivers/net/ethernet/realtek/r8169.c               | 14 ++--
 drivers/net/ethernet/s6gmac.c                      |  2 +-
 drivers/net/ethernet/seeq/ether3.c                 | 10 +--
 drivers/net/ethernet/seeq/sgiseeq.c                |  2 +-
 drivers/net/ethernet/sfc/efx.c                     |  2 +-
 drivers/net/ethernet/sgi/ioc3-eth.c                |  6 +-
 drivers/net/ethernet/sgi/meth.c                    |  2 +-
 drivers/net/ethernet/silan/sc92031.c               |  2 +-
 drivers/net/ethernet/sis/sis190.c                  | 14 ++--
 drivers/net/ethernet/sis/sis900.c                  | 14 ++--
 drivers/net/ethernet/smsc/epic100.c                |  4 +-
 drivers/net/ethernet/smsc/smc911x.c                |  6 +-
 drivers/net/ethernet/smsc/smc91x.c                 |  6 +-
 drivers/net/ethernet/smsc/smsc911x.c               | 10 +--
 drivers/net/ethernet/smsc/smsc9420.c               |  2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |  2 +-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  6 +-
 drivers/net/ethernet/sun/cassini.c                 |  4 +-
 drivers/net/ethernet/sun/niu.c                     | 78 ++++++++++----------
 drivers/net/ethernet/sun/sunbmac.c                 |  4 +-
 drivers/net/ethernet/sun/sungem.c                  |  4 +-
 drivers/net/ethernet/sun/sunhme.c                  | 10 +--
 drivers/net/ethernet/sun/sunqe.c                   |  8 +-
 drivers/net/ethernet/sun/sunvnet.c                 | 12 +--
 drivers/net/ethernet/tehuti/tehuti.c               |  2 +-
 drivers/net/ethernet/ti/cpmac.c                    |  4 +-
 drivers/net/ethernet/ti/cpsw.c                     |  2 +-
 drivers/net/ethernet/ti/davinci_emac.c             |  2 +-
 drivers/net/ethernet/ti/davinci_mdio.c             |  2 +-
 drivers/net/ethernet/ti/tlan.c                     |  4 +-
 drivers/net/ethernet/toshiba/ps3_gelic_net.c       | 14 ++--
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c  |  6 +-
 drivers/net/ethernet/toshiba/spider_net.c          |  2 +-
 drivers/net/ethernet/toshiba/tc35815.c             | 10 +--
 drivers/net/ethernet/via/via-rhine.c               |  6 +-
 drivers/net/ethernet/via/via-velocity.c            | 16 ++--
 drivers/net/ethernet/wiznet/w5100.c                |  4 +-
 drivers/net/ethernet/wiznet/w5300.c                |  4 +-
 drivers/net/ethernet/xilinx/ll_temac_main.c        |  2 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c  |  2 +-
 drivers/net/ethernet/xilinx/xilinx_emaclite.c      |  2 +-
 drivers/net/ethernet/xscale/ixp4xx_eth.c           |  2 +-
 172 files changed, 516 insertions(+), 517 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index 7d7cd67..7e6466c 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -184,7 +184,7 @@ static int max_interrupt_work = 10;
 static int nopnp;
 #endif
 
-static int __devinit el3_common_init(struct net_device *dev);
+static int el3_common_init(struct net_device *dev);
 static void el3_common_remove(struct net_device *dev);
 static ushort id_read_eeprom(int index);
 static ushort read_eeprom(int ioaddr, int index);
@@ -270,7 +270,7 @@ static int el3_isa_id_sequence(__be16 *phys_addr)
 
 }
 
-static void __devinit el3_dev_fill(struct net_device *dev, __be16 *phys_addr,
+static void el3_dev_fill(struct net_device *dev, __be16 *phys_addr,
 				   int ioaddr, int irq, int if_port,
 				   enum el3_cardtype type)
 {
@@ -283,7 +283,7 @@ static void __devinit el3_dev_fill(struct net_device *dev, __be16 *phys_addr,
 	lp->type = type;
 }
 
-static int __devinit el3_isa_match(struct device *pdev,
+static int el3_isa_match(struct device *pdev,
 				   unsigned int ndev)
 {
 	struct net_device *dev;
@@ -406,7 +406,7 @@ static struct pnp_device_id el3_pnp_ids[] = {
 };
 MODULE_DEVICE_TABLE(pnp, el3_pnp_ids);
 
-static int __devinit el3_pnp_probe(struct pnp_dev *pdev,
+static int el3_pnp_probe(struct pnp_dev *pdev,
 				    const struct pnp_device_id *id)
 {
 	short i;
@@ -519,7 +519,7 @@ static const struct net_device_ops netdev_ops = {
 #endif
 };
 
-static int __devinit el3_common_init(struct net_device *dev)
+static int el3_common_init(struct net_device *dev)
 {
 	struct el3_private *lp = netdev_priv(dev);
 	int err;
diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 7cff8b8..7e421f3 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -1000,7 +1000,7 @@ static int __init vortex_eisa_init(void)
 }
 
 /* returns count (>= 0), or negative on error */
-static int __devinit vortex_init_one(struct pci_dev *pdev,
+static int vortex_init_one(struct pci_dev *pdev,
 				      const struct pci_device_id *ent)
 {
 	int rc, unit, pci_bar;
@@ -1088,7 +1088,7 @@ static const struct net_device_ops vortex_netdev_ops = {
  *
  * NOTE: pdev can be NULL, for the case of a Compaq device
  */
-static int __devinit vortex_probe1(struct device *gendev,
+static int vortex_probe1(struct device *gendev,
 				   void __iomem *ioaddr, int irq,
 				   int chip_idx, int card_idx)
 {
diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index e11b27f..6d2efdd 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -2200,7 +2200,7 @@ need_resume:
 }
 #endif
 
-static int __devinit
+static int
 typhoon_test_mmio(struct pci_dev *pdev)
 {
 	void __iomem *ioaddr = pci_iomap(pdev, 1, 128);
@@ -2258,7 +2258,7 @@ static const struct net_device_ops typhoon_netdev_ops = {
 	.ndo_change_mtu		= eth_change_mtu,
 };
 
-static int __devinit
+static int
 typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/8390/etherh.c b/drivers/net/ethernet/8390/etherh.c
index 96ed50d..38fc4fb 100644
--- a/drivers/net/ethernet/8390/etherh.c
+++ b/drivers/net/ethernet/8390/etherh.c
@@ -527,7 +527,7 @@ static void __init etherh_banner(void)
  * Read the ethernet address string from the on board rom.
  * This is an ascii string...
  */
-static int __devinit etherh_addr(char *addr, struct expansion_card *ec)
+static int etherh_addr(char *addr, struct expansion_card *ec)
 {
 	struct in_chunk_dir cd;
 	char *s;
@@ -657,7 +657,7 @@ static const struct net_device_ops etherh_netdev_ops = {
 static u32 etherh_regoffsets[16];
 static u32 etherm_regoffsets[16];
 
-static int __devinit
+static int
 etherh_probe(struct expansion_card *ec, const struct ecard_id *id)
 {
 	const struct etherh_data *data = id->data;
diff --git a/drivers/net/ethernet/8390/hydra.c b/drivers/net/ethernet/8390/hydra.c
index dac977f..cf638ba 100644
--- a/drivers/net/ethernet/8390/hydra.c
+++ b/drivers/net/ethernet/8390/hydra.c
@@ -53,9 +53,9 @@ static const char version[] =
 #define WORDSWAP(a)     ((((a)>>8)&0xff) | ((a)<<8))
 
 
-static int __devinit hydra_init_one(struct zorro_dev *z,
+static int hydra_init_one(struct zorro_dev *z,
 				    const struct zorro_device_id *ent);
-static int __devinit hydra_init(struct zorro_dev *z);
+static int hydra_init(struct zorro_dev *z);
 static int hydra_open(struct net_device *dev);
 static int hydra_close(struct net_device *dev);
 static void hydra_reset_8390(struct net_device *dev);
@@ -80,7 +80,7 @@ static struct zorro_driver hydra_driver = {
 	.remove   = hydra_remove_one,
 };
 
-static int __devinit hydra_init_one(struct zorro_dev *z,
+static int hydra_init_one(struct zorro_dev *z,
 				    const struct zorro_device_id *ent)
 {
     int err;
@@ -110,7 +110,7 @@ static const struct net_device_ops hydra_netdev_ops = {
 #endif
 };
 
-static int __devinit hydra_init(struct zorro_dev *z)
+static int hydra_init(struct zorro_dev *z)
 {
     struct net_device *dev;
     unsigned long board = ZTWO_VADDR(z->resource.start);
diff --git a/drivers/net/ethernet/8390/ne2k-pci.c b/drivers/net/ethernet/8390/ne2k-pci.c
index 8f09fd99..cdea7e1 100644
--- a/drivers/net/ethernet/8390/ne2k-pci.c
+++ b/drivers/net/ethernet/8390/ne2k-pci.c
@@ -215,7 +215,7 @@ static const struct net_device_ops ne2k_netdev_ops = {
 #endif
 };
 
-static int __devinit ne2k_pci_init_one (struct pci_dev *pdev,
+static int ne2k_pci_init_one (struct pci_dev *pdev,
 				     const struct pci_device_id *ent)
 {
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/8390/zorro8390.c b/drivers/net/ethernet/8390/zorro8390.c
index 9a041a6..3328eff 100644
--- a/drivers/net/ethernet/8390/zorro8390.c
+++ b/drivers/net/ethernet/8390/zorro8390.c
@@ -286,7 +286,7 @@ static const struct net_device_ops zorro8390_netdev_ops = {
 #endif
 };
 
-static int __devinit zorro8390_init(struct net_device *dev,
+static int zorro8390_init(struct net_device *dev,
 				    unsigned long board, const char *name,
 				    unsigned long ioaddr)
 {
@@ -396,7 +396,7 @@ static int __devinit zorro8390_init(struct net_device *dev,
 	return 0;
 }
 
-static int __devinit zorro8390_init_one(struct zorro_dev *z,
+static int zorro8390_init_one(struct zorro_dev *z,
 					const struct zorro_device_id *ent)
 {
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index e986818..7ec9115 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -641,7 +641,7 @@ static const struct net_device_ops netdev_ops = {
 #endif
 };
 
-static int __devinit starfire_init_one(struct pci_dev *pdev,
+static int starfire_init_one(struct pci_dev *pdev,
 				       const struct pci_device_id *ent)
 {
 	struct device *d = &pdev->dev;
diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index cfcce5b..83a8e69 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1603,7 +1603,7 @@ static const struct net_device_ops bfin_mac_netdev_ops = {
 #endif
 };
 
-static int __devinit bfin_mac_probe(struct platform_device *pdev)
+static int bfin_mac_probe(struct platform_device *pdev)
 {
 	struct net_device *ndev;
 	struct bfin_mac_local *lp;
@@ -1786,7 +1786,7 @@ static int bfin_mac_resume(struct platform_device *pdev)
 #define bfin_mac_resume NULL
 #endif	/* CONFIG_PM */
 
-static int __devinit bfin_mii_bus_probe(struct platform_device *pdev)
+static int bfin_mii_bus_probe(struct platform_device *pdev)
 {
 	struct mii_bus *miibus;
 	struct bfin_mii_bus_platform_data *mii_bus_pd;
diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index 3629690..6d99ebb 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1376,7 +1376,7 @@ error:
 }
 
 /* Initialize the GRETH MAC */
-static int __devinit greth_of_probe(struct platform_device *ofdev)
+static int greth_of_probe(struct platform_device *ofdev)
 {
 	struct net_device *dev;
 	struct greth_private *greth;
diff --git a/drivers/net/ethernet/alteon/acenic.c b/drivers/net/ethernet/alteon/acenic.c
index 9cb94b3..dba93e3 100644
--- a/drivers/net/ethernet/alteon/acenic.c
+++ b/drivers/net/ethernet/alteon/acenic.c
@@ -454,7 +454,7 @@ static const struct net_device_ops ace_netdev_ops = {
 	.ndo_change_mtu		= ace_change_mtu,
 };
 
-static int __devinit acenic_probe_one(struct pci_dev *pdev,
+static int acenic_probe_one(struct pci_dev *pdev,
 		const struct pci_device_id *id)
 {
 	struct net_device *dev;
@@ -871,7 +871,7 @@ static inline void ace_issue_cmd(struct ace_regs __iomem *regs, struct cmd *cmd)
 }
 
 
-static int __devinit ace_init(struct net_device *dev)
+static int ace_init(struct net_device *dev)
 {
 	struct ace_private *ap;
 	struct ace_regs __iomem *regs;
@@ -2824,7 +2824,7 @@ static struct net_device_stats *ace_get_stats(struct net_device *dev)
 }
 
 
-static void __devinit ace_copy(struct ace_regs __iomem *regs, const __be32 *src,
+static void ace_copy(struct ace_regs __iomem *regs, const __be32 *src,
 			       u32 dest, int size)
 {
 	void __iomem *tdest;
@@ -2851,7 +2851,7 @@ static void __devinit ace_copy(struct ace_regs __iomem *regs, const __be32 *src,
 }
 
 
-static void __devinit ace_clear(struct ace_regs __iomem *regs, u32 dest, int size)
+static void ace_clear(struct ace_regs __iomem *regs, u32 dest, int size)
 {
 	void __iomem *tdest;
 	short tsize = 0, i;
@@ -2882,7 +2882,7 @@ static void __devinit ace_clear(struct ace_regs __iomem *regs, u32 dest, int siz
  * This operation requires the NIC to be halted and is performed with
  * interrupts disabled and with the spinlock hold.
  */
-static int __devinit ace_load_firmware(struct net_device *dev)
+static int ace_load_firmware(struct net_device *dev)
 {
 	const struct firmware *fw;
 	const char *fw_name = "acenic/tg2.bin";
@@ -2962,7 +2962,7 @@ static int __devinit ace_load_firmware(struct net_device *dev)
  * Thanks to Stevarino Webinski for helping tracking down the bugs in the
  * code i2c readout code by beta testing all my hacks.
  */
-static void __devinit eeprom_start(struct ace_regs __iomem *regs)
+static void eeprom_start(struct ace_regs __iomem *regs)
 {
 	u32 local;
 
@@ -2991,7 +2991,7 @@ static void __devinit eeprom_start(struct ace_regs __iomem *regs)
 }
 
 
-static void __devinit eeprom_prep(struct ace_regs __iomem *regs, u8 magic)
+static void eeprom_prep(struct ace_regs __iomem *regs, u8 magic)
 {
 	short i;
 	u32 local;
@@ -3028,7 +3028,7 @@ static void __devinit eeprom_prep(struct ace_regs __iomem *regs, u8 magic)
 }
 
 
-static int __devinit eeprom_check_ack(struct ace_regs __iomem *regs)
+static int eeprom_check_ack(struct ace_regs __iomem *regs)
 {
 	int state;
 	u32 local;
@@ -3056,7 +3056,7 @@ static int __devinit eeprom_check_ack(struct ace_regs __iomem *regs)
 }
 
 
-static void __devinit eeprom_stop(struct ace_regs __iomem *regs)
+static void eeprom_stop(struct ace_regs __iomem *regs)
 {
 	u32 local;
 
@@ -3091,7 +3091,7 @@ static void __devinit eeprom_stop(struct ace_regs __iomem *regs)
 /*
  * Read a whole byte from the EEPROM.
  */
-static int __devinit read_eeprom_byte(struct net_device *dev,
+static int read_eeprom_byte(struct net_device *dev,
 				   unsigned long offset)
 {
 	struct ace_private *ap = netdev_priv(dev);
diff --git a/drivers/net/ethernet/amd/a2065.c b/drivers/net/ethernet/amd/a2065.c
index 2745c0a..51d917f 100644
--- a/drivers/net/ethernet/amd/a2065.c
+++ b/drivers/net/ethernet/amd/a2065.c
@@ -639,7 +639,7 @@ static void lance_set_multicast(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-static int __devinit a2065_init_one(struct zorro_dev *z,
+static int a2065_init_one(struct zorro_dev *z,
 				    const struct zorro_device_id *ent);
 static void __devexit a2065_remove_one(struct zorro_dev *z);
 
@@ -670,7 +670,7 @@ static const struct net_device_ops lance_netdev_ops = {
 	.ndo_set_mac_address	= eth_mac_addr,
 };
 
-static int __devinit a2065_init_one(struct zorro_dev *z,
+static int a2065_init_one(struct zorro_dev *z,
 				    const struct zorro_device_id *ent)
 {
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/amd/am79c961a.c b/drivers/net/ethernet/amd/am79c961a.c
index e10ffad..60e2b701a 100644
--- a/drivers/net/ethernet/amd/am79c961a.c
+++ b/drivers/net/ethernet/amd/am79c961a.c
@@ -671,7 +671,7 @@ static const struct net_device_ops am79c961_netdev_ops = {
 #endif
 };
 
-static int __devinit am79c961_probe(struct platform_device *pdev)
+static int am79c961_probe(struct platform_device *pdev)
 {
 	struct resource *res;
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 5891636..c66ae87 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -1774,7 +1774,7 @@ static void amd8111e_config_ipg(struct net_device* dev)
 
 }
 
-static void __devinit amd8111e_probe_ext_phy(struct net_device* dev)
+static void amd8111e_probe_ext_phy(struct net_device* dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	int i;
@@ -1810,7 +1810,7 @@ static const struct net_device_ops amd8111e_netdev_ops = {
 #endif
 };
 
-static int __devinit amd8111e_probe_one(struct pci_dev *pdev,
+static int amd8111e_probe_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
 	int err,i,pm_cap;
diff --git a/drivers/net/ethernet/amd/ariadne.c b/drivers/net/ethernet/amd/ariadne.c
index 72b56a8..f9c43f4 100644
--- a/drivers/net/ethernet/amd/ariadne.c
+++ b/drivers/net/ethernet/amd/ariadne.c
@@ -710,7 +710,7 @@ static const struct net_device_ops ariadne_netdev_ops = {
 	.ndo_set_mac_address	= eth_mac_addr,
 };
 
-static int __devinit ariadne_init_one(struct zorro_dev *z,
+static int ariadne_init_one(struct zorro_dev *z,
 				      const struct zorro_device_id *ent)
 {
 	unsigned long board = z->resource.start;
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index cbbfdc9..884ef9c 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -1016,7 +1016,7 @@ static const struct net_device_ops au1000_netdev_ops = {
 	.ndo_change_mtu		= eth_change_mtu,
 };
 
-static int __devinit au1000_probe(struct platform_device *pdev)
+static int au1000_probe(struct platform_device *pdev)
 {
 	static unsigned version_printed;
 	struct au1000_private *aup = NULL;
diff --git a/drivers/net/ethernet/amd/declance.c b/drivers/net/ethernet/amd/declance.c
index 7203b52..a9380b9 100644
--- a/drivers/net/ethernet/amd/declance.c
+++ b/drivers/net/ethernet/amd/declance.c
@@ -1020,7 +1020,7 @@ static const struct net_device_ops lance_netdev_ops = {
 	.ndo_set_mac_address	= eth_mac_addr,
 };
 
-static int __devinit dec_lance_probe(struct device *bdev, const int type)
+static int dec_lance_probe(struct device *bdev, const int type)
 {
 	static unsigned version_printed;
 	static const char fmt[] = "declance%d";
@@ -1322,7 +1322,7 @@ static void __exit dec_lance_platform_remove(void)
 }
 
 #ifdef CONFIG_TC
-static int __devinit dec_lance_tc_probe(struct device *dev);
+static int dec_lance_tc_probe(struct device *dev);
 static int __exit dec_lance_tc_remove(struct device *dev);
 
 static const struct tc_device_id dec_lance_tc_table[] = {
@@ -1341,7 +1341,7 @@ static struct tc_driver dec_lance_tc_driver = {
 	},
 };
 
-static int __devinit dec_lance_tc_probe(struct device *dev)
+static int dec_lance_tc_probe(struct device *dev)
 {
         int status = dec_lance_probe(dev, PMAD_LANCE);
         if (!status)
diff --git a/drivers/net/ethernet/amd/depca.c b/drivers/net/ethernet/amd/depca.c
index 8a86c06..34b6bf7 100644
--- a/drivers/net/ethernet/amd/depca.c
+++ b/drivers/net/ethernet/amd/depca.c
@@ -1320,7 +1320,7 @@ static enum depca_type __init depca_shmem_probe (ulong *mem_start)
 	return adapter;
 }
 
-static int __devinit depca_isa_probe (struct platform_device *device)
+static int depca_isa_probe (struct platform_device *device)
 {
 	struct net_device *dev;
 	struct depca_private *lp;
diff --git a/drivers/net/ethernet/amd/hplance.c b/drivers/net/ethernet/amd/hplance.c
index 1b2d4a1..d90aa7b38 100644
--- a/drivers/net/ethernet/amd/hplance.c
+++ b/drivers/net/ethernet/amd/hplance.c
@@ -46,9 +46,9 @@ struct hplance_private {
  * plus board-specific init, open and close actions.
  * Oh, and we need to tell the generic code how to read and write LANCE registers...
  */
-static int __devinit hplance_init_one(struct dio_dev *d,
+static int hplance_init_one(struct dio_dev *d,
 				const struct dio_device_id *ent);
-static void __devinit hplance_init(struct net_device *dev,
+static void hplance_init(struct net_device *dev,
 				struct dio_dev *d);
 static void __devexit hplance_remove_one(struct dio_dev *d);
 static void hplance_writerap(void *priv, unsigned short value);
@@ -83,7 +83,7 @@ static const struct net_device_ops hplance_netdev_ops = {
 };
 
 /* Find all the HP Lance boards and initialise them... */
-static int __devinit hplance_init_one(struct dio_dev *d,
+static int hplance_init_one(struct dio_dev *d,
 				const struct dio_device_id *ent)
 {
 	struct net_device *dev;
@@ -128,7 +128,7 @@ static void __devexit hplance_remove_one(struct dio_dev *d)
 }
 
 /* Initialise a single lance board at the given DIO device */
-static void __devinit hplance_init(struct net_device *dev, struct dio_dev *d)
+static void hplance_init(struct net_device *dev, struct dio_dev *d)
 {
         unsigned long va = (d->resource.start + DIO_VIRADDRBASE);
         struct hplance_private *lp;
diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index d16fcd8..9771928 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -1443,7 +1443,7 @@ static const struct ethtool_ops pcnet32_ethtool_ops = {
 /* only probes for non-PCI devices, the rest are handled by
  * pci_register_driver via pcnet32_probe_pci */
 
-static void __devinit pcnet32_probe_vlbus(unsigned int *pcnet32_portlist)
+static void pcnet32_probe_vlbus(unsigned int *pcnet32_portlist)
 {
 	unsigned int *port, ioaddr;
 
@@ -1462,7 +1462,7 @@ static void __devinit pcnet32_probe_vlbus(unsigned int *pcnet32_portlist)
 	}
 }
 
-static int __devinit
+static int
 pcnet32_probe_pci(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	unsigned long ioaddr;
@@ -1521,7 +1521,7 @@ static const struct net_device_ops pcnet32_netdev_ops = {
  *  Called from both pcnet32_probe_vlbus and pcnet_probe_pci.
  *  pdev will be NULL when called from pcnet32_probe_vlbus.
  */
-static int __devinit
+static int
 pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 {
 	struct pcnet32_private *lp;
diff --git a/drivers/net/ethernet/amd/sunlance.c b/drivers/net/ethernet/amd/sunlance.c
index d794921..3c5bf2b 100644
--- a/drivers/net/ethernet/amd/sunlance.c
+++ b/drivers/net/ethernet/amd/sunlance.c
@@ -1304,7 +1304,7 @@ static const struct net_device_ops sparc_lance_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int __devinit sparc_lance_probe_one(struct platform_device *op,
+static int sparc_lance_probe_one(struct platform_device *op,
 					   struct platform_device *ledma,
 					   struct platform_device *lebuffer)
 {
@@ -1488,7 +1488,7 @@ fail:
 	return -ENODEV;
 }
 
-static int __devinit sunlance_sbus_probe(struct platform_device *op)
+static int sunlance_sbus_probe(struct platform_device *op)
 {
 	struct platform_device *parent = to_platform_device(op->dev.parent);
 	struct device_node *parent_dp = parent->dev.of_node;
diff --git a/drivers/net/ethernet/apple/bmac.c b/drivers/net/ethernet/apple/bmac.c
index 855bdaf..420a06e 100644
--- a/drivers/net/ethernet/apple/bmac.c
+++ b/drivers/net/ethernet/apple/bmac.c
@@ -1244,7 +1244,7 @@ static const struct net_device_ops bmac_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int __devinit bmac_probe(struct macio_dev *mdev, const struct of_device_id *match)
+static int bmac_probe(struct macio_dev *mdev, const struct of_device_id *match)
 {
 	int j, rev, ret;
 	struct bmac_data *bp;
diff --git a/drivers/net/ethernet/apple/mace.c b/drivers/net/ethernet/apple/mace.c
index e1df4b7..21cf031 100644
--- a/drivers/net/ethernet/apple/mace.c
+++ b/drivers/net/ethernet/apple/mace.c
@@ -106,7 +106,7 @@ static const struct net_device_ops mace_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int __devinit mace_probe(struct macio_dev *mdev, const struct of_device_id *match)
+static int mace_probe(struct macio_dev *mdev, const struct of_device_id *match)
 {
 	struct device_node *mace = macio_get_of_node(mdev);
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/apple/macmace.c b/drivers/net/ethernet/apple/macmace.c
index c2e9ef6..7decd85 100644
--- a/drivers/net/ethernet/apple/macmace.c
+++ b/drivers/net/ethernet/apple/macmace.c
@@ -195,7 +195,7 @@ static const struct net_device_ops mace_netdev_ops = {
  * model of Macintrash has a MACE (AV macintoshes)
  */
 
-static int __devinit mace_probe(struct platform_device *pdev)
+static int mace_probe(struct platform_device *pdev)
 {
 	int j;
 	struct mace_data *mp;
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index edb5d6e..576fd4b 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -643,7 +643,7 @@ static int atl1c_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
  * @adapter: board private structure to initialize
  *
  */
-static int __devinit atl1c_alloc_queues(struct atl1c_adapter *adapter)
+static int atl1c_alloc_queues(struct atl1c_adapter *adapter)
 {
 	return 0;
 }
@@ -725,7 +725,7 @@ static const struct atl1c_platform_patch plats[] __devinitconst = {
 {0},
 };
 
-static void __devinit atl1c_patch_assign(struct atl1c_hw *hw)
+static void atl1c_patch_assign(struct atl1c_hw *hw)
 {
 	struct pci_dev	*pdev = hw->adapter->pdev;
 	u32 misc_ctrl;
@@ -764,7 +764,7 @@ static void __devinit atl1c_patch_assign(struct atl1c_hw *hw)
  * Fields are initialized based on PCI device information and
  * OS network device settings (MTU size).
  */
-static int __devinit atl1c_sw_init(struct atl1c_adapter *adapter)
+static int atl1c_sw_init(struct atl1c_adapter *adapter)
 {
 	struct atl1c_hw *hw   = &adapter->hw;
 	struct pci_dev	*pdev = adapter->pdev;
@@ -2442,7 +2442,7 @@ static int atl1c_init_netdev(struct net_device *netdev, struct pci_dev *pdev)
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
  */
-static int __devinit atl1c_probe(struct pci_dev *pdev,
+static int atl1c_probe(struct pci_dev *pdev,
 				 const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index eacf624..9fff8b9 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -534,7 +534,7 @@ static void atl1e_setup_pcicmd(struct pci_dev *pdev)
  * @adapter: board private structure to initialize
  *
  */
-static int __devinit atl1e_alloc_queues(struct atl1e_adapter *adapter)
+static int atl1e_alloc_queues(struct atl1e_adapter *adapter)
 {
 	return 0;
 }
@@ -547,7 +547,7 @@ static int __devinit atl1e_alloc_queues(struct atl1e_adapter *adapter)
  * Fields are initialized based on PCI device information and
  * OS network device settings (MTU size).
  */
-static int __devinit atl1e_sw_init(struct atl1e_adapter *adapter)
+static int atl1e_sw_init(struct atl1e_adapter *adapter)
 {
 	struct atl1e_hw *hw   = &adapter->hw;
 	struct pci_dev	*pdev = adapter->pdev;
@@ -2235,7 +2235,7 @@ static int atl1e_init_netdev(struct net_device *netdev, struct pci_dev *pdev)
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
  */
-static int __devinit atl1e_probe(struct pci_dev *pdev,
+static int atl1e_probe(struct pci_dev *pdev,
 				 const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_param.c b/drivers/net/ethernet/atheros/atl1e/atl1e_param.c
index b5086f1..b2d740a 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_param.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_param.c
@@ -116,7 +116,7 @@ struct atl1e_option {
 	} arg;
 };
 
-static int __devinit atl1e_validate_option(int *value, struct atl1e_option *opt, struct atl1e_adapter *adapter)
+static int atl1e_validate_option(int *value, struct atl1e_option *opt, struct atl1e_adapter *adapter)
 {
 	if (*value == OPTION_UNSET) {
 		*value = opt->def;
@@ -177,7 +177,7 @@ static int __devinit atl1e_validate_option(int *value, struct atl1e_option *opt,
  * value exists, a default value is used.  The final value is stored
  * in a variable in the adapter structure.
  */
-void __devinit atl1e_check_options(struct atl1e_adapter *adapter)
+void atl1e_check_options(struct atl1e_adapter *adapter)
 {
 	int bd = adapter->bd_number;
 
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index b396907..736c022 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -143,7 +143,7 @@ struct atl1_option {
 	} arg;
 };
 
-static int __devinit atl1_validate_option(int *value, struct atl1_option *opt,
+static int atl1_validate_option(int *value, struct atl1_option *opt,
 	struct pci_dev *pdev)
 {
 	if (*value == OPTION_UNSET) {
@@ -204,7 +204,7 @@ static int __devinit atl1_validate_option(int *value, struct atl1_option *opt,
  * value exists, a default value is used.  The final value is stored
  * in a variable in the adapter structure.
  */
-static void __devinit atl1_check_options(struct atl1_adapter *adapter)
+static void atl1_check_options(struct atl1_adapter *adapter)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	int bd = adapter->bd_number;
@@ -945,7 +945,7 @@ static void atl1_set_mac_addr(struct atl1_hw *hw)
  * Fields are initialized based on PCI device information and
  * OS network device settings (MTU size).
  */
-static int __devinit atl1_sw_init(struct atl1_adapter *adapter)
+static int atl1_sw_init(struct atl1_adapter *adapter)
 {
 	struct atl1_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
@@ -2934,7 +2934,7 @@ static const struct net_device_ops atl1_netdev_ops = {
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
  */
-static int __devinit atl1_probe(struct pci_dev *pdev,
+static int atl1_probe(struct pci_dev *pdev,
 	const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 0988200..2a5f117 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -83,7 +83,7 @@ static void atl2_check_options(struct atl2_adapter *adapter);
  * Fields are initialized based on PCI device information and
  * OS network device settings (MTU size).
  */
-static int __devinit atl2_sw_init(struct atl2_adapter *adapter)
+static int atl2_sw_init(struct atl2_adapter *adapter)
 {
 	struct atl2_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
@@ -1338,7 +1338,7 @@ static const struct net_device_ops atl2_netdev_ops = {
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
  */
-static int __devinit atl2_probe(struct pci_dev *pdev,
+static int atl2_probe(struct pci_dev *pdev,
 	const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
@@ -2934,7 +2934,7 @@ struct atl2_option {
 	} arg;
 };
 
-static int __devinit atl2_validate_option(int *value, struct atl2_option *opt)
+static int atl2_validate_option(int *value, struct atl2_option *opt)
 {
 	int i;
 	struct atl2_opt_list *ent;
@@ -2992,7 +2992,7 @@ static int __devinit atl2_validate_option(int *value, struct atl2_option *opt)
  * value exists, a default value is used.  The final value is stored
  * in a variable in the adapter structure.
  */
-static void __devinit atl2_check_options(struct atl2_adapter *adapter)
+static void atl2_check_options(struct atl2_adapter *adapter)
 {
 	int val;
 	struct atl2_option opt;
diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 94fa5d8..7fda109 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -2083,7 +2083,7 @@ out:
 	return err;
 }
 
-static int __devinit b44_get_invariants(struct b44 *bp)
+static int b44_get_invariants(struct b44 *bp)
 {
 	struct ssb_device *sdev = bp->sdev;
 	int err = 0;
@@ -2141,7 +2141,7 @@ static const struct net_device_ops b44_netdev_ops = {
 #endif
 };
 
-static int __devinit b44_init_one(struct ssb_device *sdev,
+static int b44_init_one(struct ssb_device *sdev,
 				  const struct ssb_device_id *ent)
 {
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index f062656..1bdff26 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1612,7 +1612,7 @@ static const struct net_device_ops bcm_enet_ops = {
 /*
  * allocate netdevice, request register memory and register device.
  */
-static int __devinit bcm_enet_probe(struct platform_device *pdev)
+static int bcm_enet_probe(struct platform_device *pdev)
 {
 	struct bcm_enet_priv *priv;
 	struct net_device *dev;
@@ -1887,7 +1887,7 @@ struct platform_driver bcm63xx_enet_driver = {
 /*
  * reserve & remap memory space shared between all macs
  */
-static int __devinit bcm_enet_shared_probe(struct platform_device *pdev)
+static int bcm_enet_shared_probe(struct platform_device *pdev)
 {
 	struct resource *res;
 	unsigned int iomem_size;
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 7b55f78..d9388a0 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -7896,7 +7896,7 @@ poll_bnx2(struct net_device *dev)
 }
 #endif
 
-static void __devinit
+static void
 bnx2_get_5709_media(struct bnx2 *bp)
 {
 	u32 val = REG_RD(bp, BNX2_MISC_DUAL_MEDIA_CTRL);
@@ -7934,7 +7934,7 @@ bnx2_get_5709_media(struct bnx2 *bp)
 	}
 }
 
-static void __devinit
+static void
 bnx2_get_pci_speed(struct bnx2 *bp)
 {
 	u32 reg;
@@ -7986,7 +7986,7 @@ bnx2_get_pci_speed(struct bnx2 *bp)
 
 }
 
-static void __devinit
+static void
 bnx2_read_vpd_fw_ver(struct bnx2 *bp)
 {
 	int rc, i, j;
@@ -8054,7 +8054,7 @@ vpd_done:
 	kfree(data);
 }
 
-static int __devinit
+static int
 bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 {
 	struct bnx2 *bp;
@@ -8439,8 +8439,7 @@ err_out:
 	return rc;
 }
 
-static char * __devinit
-bnx2_bus_string(struct bnx2 *bp, char *str)
+static char *bnx2_bus_string(struct bnx2 *bp, char *str)
 {
 	char *s = str;
 
@@ -8505,7 +8504,7 @@ static const struct net_device_ops bnx2_netdev_ops = {
 #endif
 };
 
-static int __devinit
+static int
 bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	static int version_printed = 0;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 96f5a4e..85d358a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3868,7 +3868,7 @@ void bnx2x_free_mem_bp(struct bnx2x *bp)
 	kfree(bp->ilt);
 }
 
-int __devinit bnx2x_alloc_mem_bp(struct bnx2x *bp)
+int bnx2x_alloc_mem_bp(struct bnx2x *bp)
 {
 	struct bnx2x_fastpath *fp;
 	struct msix_entry *tbl;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index ad28074..7473fb5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -563,7 +563,7 @@ int bnx2x_poll(struct napi_struct *napi, int budget);
  *
  * @bp:		driver handle
  */
-int __devinit bnx2x_alloc_mem_bp(struct bnx2x *bp);
+int bnx2x_alloc_mem_bp(struct bnx2x *bp);
 
 /**
  * bnx2x_free_mem_bp - release memories outsize main driver structure
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index d9e72fcb..0719c20 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9395,7 +9395,7 @@ static inline void bnx2x_undi_int_disable(struct bnx2x *bp)
 		bnx2x_undi_int_disable_e1h(bp);
 }
 
-static void __devinit bnx2x_prev_unload_close_mac(struct bnx2x *bp)
+static void bnx2x_prev_unload_close_mac(struct bnx2x *bp)
 {
 	u32 val, base_addr, offset, mask, reset_reg;
 	bool mac_stopped = false;
@@ -9462,7 +9462,7 @@ static void __devinit bnx2x_prev_unload_close_mac(struct bnx2x *bp)
 #define BNX2X_PREV_UNDI_BD(val)		((val) >> 16 & 0xffff)
 #define BNX2X_PREV_UNDI_PROD(rcq, bd)	((bd) << 16 | (rcq))
 
-static void __devinit bnx2x_prev_unload_undi_inc(struct bnx2x *bp, u8 port,
+static void bnx2x_prev_unload_undi_inc(struct bnx2x *bp, u8 port,
 						 u8 inc)
 {
 	u16 rcq, bd;
@@ -9478,7 +9478,7 @@ static void __devinit bnx2x_prev_unload_undi_inc(struct bnx2x *bp, u8 port,
 		       port, bd, rcq);
 }
 
-static int __devinit bnx2x_prev_mcp_done(struct bnx2x *bp)
+static int bnx2x_prev_mcp_done(struct bnx2x *bp)
 {
 	u32 rc = bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE,
 				  DRV_MSG_CODE_UNLOAD_SKIP_LINK_RESET);
@@ -9490,7 +9490,7 @@ static int __devinit bnx2x_prev_mcp_done(struct bnx2x *bp)
 	return 0;
 }
 
-static bool __devinit bnx2x_prev_is_path_marked(struct bnx2x *bp)
+static bool bnx2x_prev_is_path_marked(struct bnx2x *bp)
 {
 	struct bnx2x_prev_path_list *tmp_list;
 	int rc = false;
@@ -9514,7 +9514,7 @@ static bool __devinit bnx2x_prev_is_path_marked(struct bnx2x *bp)
 	return rc;
 }
 
-static int __devinit bnx2x_prev_mark_path(struct bnx2x *bp)
+static int bnx2x_prev_mark_path(struct bnx2x *bp)
 {
 	struct bnx2x_prev_path_list *tmp_list;
 	int rc;
@@ -9543,7 +9543,7 @@ static int __devinit bnx2x_prev_mark_path(struct bnx2x *bp)
 	return rc;
 }
 
-static int __devinit bnx2x_do_flr(struct bnx2x *bp)
+static int bnx2x_do_flr(struct bnx2x *bp)
 {
 	int i;
 	u16 status;
@@ -9583,7 +9583,7 @@ clear:
 	return 0;
 }
 
-static int __devinit bnx2x_prev_unload_uncommon(struct bnx2x *bp)
+static int bnx2x_prev_unload_uncommon(struct bnx2x *bp)
 {
 	int rc;
 
@@ -9621,7 +9621,7 @@ static int __devinit bnx2x_prev_unload_uncommon(struct bnx2x *bp)
 	return rc;
 }
 
-static int __devinit bnx2x_prev_unload_common(struct bnx2x *bp)
+static int bnx2x_prev_unload_common(struct bnx2x *bp)
 {
 	u32 reset_reg, tmp_reg = 0, rc;
 	/* It is possible a previous function received 'common' answer,
@@ -9704,7 +9704,7 @@ static int __devinit bnx2x_prev_unload_common(struct bnx2x *bp)
  * to clear the interrupt which detected this from the pglueb and the was done
  * bit
  */
-static void __devinit bnx2x_prev_interrupted_dmae(struct bnx2x *bp)
+static void bnx2x_prev_interrupted_dmae(struct bnx2x *bp)
 {
 	u32 val = REG_RD(bp, PGLUE_B_REG_PGLUE_B_INT_STS);
 	if (val & PGLUE_B_PGLUE_B_INT_STS_REG_WAS_ERROR_ATTN) {
@@ -9713,7 +9713,7 @@ static void __devinit bnx2x_prev_interrupted_dmae(struct bnx2x *bp)
 	}
 }
 
-static int __devinit bnx2x_prev_unload(struct bnx2x *bp)
+static int bnx2x_prev_unload(struct bnx2x *bp)
 {
 	int time_counter = 10;
 	u32 rc, fw, hw_lock_reg, hw_lock_val;
@@ -9780,7 +9780,7 @@ static int __devinit bnx2x_prev_unload(struct bnx2x *bp)
 	return rc;
 }
 
-static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
+static void bnx2x_get_common_hwinfo(struct bnx2x *bp)
 {
 	u32 val, val2, val3, val4, id, boot_mode;
 	u16 pmc;
@@ -9950,7 +9950,7 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 #define IGU_FID(val)	GET_FIELD((val), IGU_REG_MAPPING_MEMORY_FID)
 #define IGU_VEC(val)	GET_FIELD((val), IGU_REG_MAPPING_MEMORY_VECTOR)
 
-static void __devinit bnx2x_get_igu_cam_info(struct bnx2x *bp)
+static void bnx2x_get_igu_cam_info(struct bnx2x *bp)
 {
 	int pfid = BP_FUNC(bp);
 	int igu_sb_id;
@@ -10005,7 +10005,7 @@ static void __devinit bnx2x_get_igu_cam_info(struct bnx2x *bp)
 		BNX2X_ERR("CAM configuration error\n");
 }
 
-static void __devinit bnx2x_link_settings_supported(struct bnx2x *bp,
+static void bnx2x_link_settings_supported(struct bnx2x *bp,
 						    u32 switch_cfg)
 {
 	int cfg_size = 0, idx, port = BP_PORT(bp);
@@ -10104,7 +10104,7 @@ static void __devinit bnx2x_link_settings_supported(struct bnx2x *bp,
 		       bp->port.supported[1]);
 }
 
-static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
+static void bnx2x_link_settings_requested(struct bnx2x *bp)
 {
 	u32 link_config, idx, cfg_size = 0;
 	bp->port.advertising[0] = 0;
@@ -10288,7 +10288,7 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 	}
 }
 
-static void __devinit bnx2x_set_mac_buf(u8 *mac_buf, u32 mac_lo, u16 mac_hi)
+static void bnx2x_set_mac_buf(u8 *mac_buf, u32 mac_lo, u16 mac_hi)
 {
 	mac_hi = cpu_to_be16(mac_hi);
 	mac_lo = cpu_to_be32(mac_lo);
@@ -10296,7 +10296,7 @@ static void __devinit bnx2x_set_mac_buf(u8 *mac_buf, u32 mac_lo, u16 mac_hi)
 	memcpy(mac_buf + sizeof(mac_hi), &mac_lo, sizeof(mac_lo));
 }
 
-static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
+static void bnx2x_get_port_hwinfo(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
 	u32 config;
@@ -10411,7 +10411,7 @@ void bnx2x_get_iscsi_info(struct bnx2x *bp)
 
 }
 
-static void __devinit bnx2x_get_ext_wwn_info(struct bnx2x *bp, int func)
+static void bnx2x_get_ext_wwn_info(struct bnx2x *bp, int func)
 {
 	/* Port info */
 	bp->cnic_eth_dev.fcoe_wwn_port_name_hi =
@@ -10425,7 +10425,7 @@ static void __devinit bnx2x_get_ext_wwn_info(struct bnx2x *bp, int func)
 	bp->cnic_eth_dev.fcoe_wwn_node_name_lo =
 		MF_CFG_RD(bp, func_ext_config[func].fcoe_wwn_node_name_lower);
 }
-static void __devinit bnx2x_get_fcoe_info(struct bnx2x *bp)
+static void bnx2x_get_fcoe_info(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
 	int func = BP_ABS_FUNC(bp);
@@ -10484,7 +10484,7 @@ static void __devinit bnx2x_get_fcoe_info(struct bnx2x *bp)
 		bp->flags |= NO_FCOE_FLAG;
 }
 
-static void __devinit bnx2x_get_cnic_info(struct bnx2x *bp)
+static void bnx2x_get_cnic_info(struct bnx2x *bp)
 {
 	/*
 	 * iSCSI may be dynamically disabled but reading
@@ -10495,7 +10495,7 @@ static void __devinit bnx2x_get_cnic_info(struct bnx2x *bp)
 	bnx2x_get_fcoe_info(bp);
 }
 
-static void __devinit bnx2x_get_cnic_mac_hwinfo(struct bnx2x *bp)
+static void bnx2x_get_cnic_mac_hwinfo(struct bnx2x *bp)
 {
 	u32 val, val2;
 	int func = BP_ABS_FUNC(bp);
@@ -10589,7 +10589,7 @@ static void __devinit bnx2x_get_cnic_mac_hwinfo(struct bnx2x *bp)
 	}
 }
 
-static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
+static void bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 {
 	u32 val, val2;
 	int func = BP_ABS_FUNC(bp);
@@ -10632,7 +10632,7 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 
 }
 
-static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
+static int bnx2x_get_hwinfo(struct bnx2x *bp)
 {
 	int /*abs*/func = BP_ABS_FUNC(bp);
 	int vn;
@@ -10855,7 +10855,7 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 	return rc;
 }
 
-static void __devinit bnx2x_read_fwinfo(struct bnx2x *bp)
+static void bnx2x_read_fwinfo(struct bnx2x *bp)
 {
 	int cnt, i, block_end, rodi;
 	char vpd_start[BNX2X_VPD_LEN+1];
@@ -10940,7 +10940,7 @@ out_not_found:
 	return;
 }
 
-static void __devinit bnx2x_set_modes_bitmap(struct bnx2x *bp)
+static void bnx2x_set_modes_bitmap(struct bnx2x *bp)
 {
 	u32 flags = 0;
 
@@ -10990,7 +10990,7 @@ static void __devinit bnx2x_set_modes_bitmap(struct bnx2x *bp)
 	INIT_MODE_FLAGS(bp) = flags;
 }
 
-static int __devinit bnx2x_init_bp(struct bnx2x *bp)
+static int bnx2x_init_bp(struct bnx2x *bp)
 {
 	int func;
 	int rc;
@@ -11466,7 +11466,7 @@ static int bnx2x_set_coherency_mask(struct bnx2x *bp)
 	return 0;
 }
 
-static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
+static int bnx2x_init_dev(struct pci_dev *pdev,
 				    struct net_device *dev,
 				    unsigned long board_type)
 {
@@ -11640,7 +11640,7 @@ err_out:
 	return rc;
 }
 
-static void __devinit bnx2x_get_pcie_width_speed(struct bnx2x *bp,
+static void bnx2x_get_pcie_width_speed(struct bnx2x *bp,
 						 int *width, int *speed)
 {
 	u32 val = REG_RD(bp, PCICFG_OFFSET + PCICFG_LINK_CONTROL);
@@ -11945,7 +11945,7 @@ static int bnx2x_get_num_non_def_sbs(struct pci_dev *pdev,
 	return control & PCI_MSIX_FLAGS_QSIZE;
 }
 
-static int __devinit bnx2x_init_one(struct pci_dev *pdev,
+static int bnx2x_init_one(struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
 {
 	struct net_device *dev = NULL;
diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
index 49e7a25..3a1c8a3 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -2586,7 +2586,7 @@ static int sbmac_poll(struct napi_struct *napi, int budget)
 }
 
 
-static int __devinit sbmac_probe(struct platform_device *pldev)
+static int sbmac_probe(struct platform_device *pldev)
 {
 	struct net_device *dev;
 	struct sbmac_softc *sc;
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index d752b10..875887e 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -9891,7 +9891,7 @@ restart_timer:
 	add_timer(&tp->timer);
 }
 
-static void __devinit tg3_timer_init(struct tg3 *tp)
+static void tg3_timer_init(struct tg3 *tp)
 {
 	if (tg3_flag(tp, TAGGED_STATUS) &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717 &&
@@ -12778,7 +12778,7 @@ static const struct net_device_ops tg3_netdev_ops = {
 #endif
 };
 
-static void __devinit tg3_get_eeprom_size(struct tg3 *tp)
+static void tg3_get_eeprom_size(struct tg3 *tp)
 {
 	u32 cursize, val, magic;
 
@@ -12812,7 +12812,7 @@ static void __devinit tg3_get_eeprom_size(struct tg3 *tp)
 	tp->nvram_size = cursize;
 }
 
-static void __devinit tg3_get_nvram_size(struct tg3 *tp)
+static void tg3_get_nvram_size(struct tg3 *tp)
 {
 	u32 val;
 
@@ -12845,7 +12845,7 @@ static void __devinit tg3_get_nvram_size(struct tg3 *tp)
 	tp->nvram_size = TG3_NVRAM_SIZE_512KB;
 }
 
-static void __devinit tg3_get_nvram_info(struct tg3 *tp)
+static void tg3_get_nvram_info(struct tg3 *tp)
 {
 	u32 nvcfg1;
 
@@ -12896,7 +12896,7 @@ static void __devinit tg3_get_nvram_info(struct tg3 *tp)
 	}
 }
 
-static void __devinit tg3_nvram_get_pagesize(struct tg3 *tp, u32 nvmcfg1)
+static void tg3_nvram_get_pagesize(struct tg3 *tp, u32 nvmcfg1)
 {
 	switch (nvmcfg1 & NVRAM_CFG1_5752PAGE_SIZE_MASK) {
 	case FLASH_5752PAGE_SIZE_256:
@@ -12923,7 +12923,7 @@ static void __devinit tg3_nvram_get_pagesize(struct tg3 *tp, u32 nvmcfg1)
 	}
 }
 
-static void __devinit tg3_get_5752_nvram_info(struct tg3 *tp)
+static void tg3_get_5752_nvram_info(struct tg3 *tp)
 {
 	u32 nvcfg1;
 
@@ -12964,7 +12964,7 @@ static void __devinit tg3_get_5752_nvram_info(struct tg3 *tp)
 	}
 }
 
-static void __devinit tg3_get_5755_nvram_info(struct tg3 *tp)
+static void tg3_get_5755_nvram_info(struct tg3 *tp)
 {
 	u32 nvcfg1, protect = 0;
 
@@ -13020,7 +13020,7 @@ static void __devinit tg3_get_5755_nvram_info(struct tg3 *tp)
 	}
 }
 
-static void __devinit tg3_get_5787_nvram_info(struct tg3 *tp)
+static void tg3_get_5787_nvram_info(struct tg3 *tp)
 {
 	u32 nvcfg1;
 
@@ -13058,7 +13058,7 @@ static void __devinit tg3_get_5787_nvram_info(struct tg3 *tp)
 	}
 }
 
-static void __devinit tg3_get_5761_nvram_info(struct tg3 *tp)
+static void tg3_get_5761_nvram_info(struct tg3 *tp)
 {
 	u32 nvcfg1, protect = 0;
 
@@ -13133,14 +13133,14 @@ static void __devinit tg3_get_5761_nvram_info(struct tg3 *tp)
 	}
 }
 
-static void __devinit tg3_get_5906_nvram_info(struct tg3 *tp)
+static void tg3_get_5906_nvram_info(struct tg3 *tp)
 {
 	tp->nvram_jedecnum = JEDEC_ATMEL;
 	tg3_flag_set(tp, NVRAM_BUFFERED);
 	tp->nvram_pagesize = ATMEL_AT24C512_CHIP_SIZE;
 }
 
-static void __devinit tg3_get_57780_nvram_info(struct tg3 *tp)
+static void tg3_get_57780_nvram_info(struct tg3 *tp)
 {
 	u32 nvcfg1;
 
@@ -13213,7 +13213,7 @@ static void __devinit tg3_get_57780_nvram_info(struct tg3 *tp)
 }
 
 
-static void __devinit tg3_get_5717_nvram_info(struct tg3 *tp)
+static void tg3_get_5717_nvram_info(struct tg3 *tp)
 {
 	u32 nvcfg1;
 
@@ -13291,7 +13291,7 @@ static void __devinit tg3_get_5717_nvram_info(struct tg3 *tp)
 		tg3_flag_set(tp, NO_NVRAM_ADDR_TRANS);
 }
 
-static void __devinit tg3_get_5720_nvram_info(struct tg3 *tp)
+static void tg3_get_5720_nvram_info(struct tg3 *tp)
 {
 	u32 nvcfg1, nvmpinstrp;
 
@@ -13404,7 +13404,7 @@ static void __devinit tg3_get_5720_nvram_info(struct tg3 *tp)
 }
 
 /* Chips other than 5700/5701 use the NVRAM for fetching info. */
-static void __devinit tg3_nvram_init(struct tg3 *tp)
+static void tg3_nvram_init(struct tg3 *tp)
 {
 	tw32_f(GRC_EEPROM_ADDR,
 	     (EEPROM_ADDR_FSM_RESET |
@@ -13538,7 +13538,7 @@ static struct subsys_tbl_ent subsys_id_to_phy_id[] __devinitdata = {
 	  TG3PCI_SUBDEVICE_ID_IBM_5703SAX2, 0 }
 };
 
-static struct subsys_tbl_ent * __devinit tg3_lookup_by_subsys(struct tg3 *tp)
+static struct subsys_tbl_ent *tg3_lookup_by_subsys(struct tg3 *tp)
 {
 	int i;
 
@@ -13552,7 +13552,7 @@ static struct subsys_tbl_ent * __devinit tg3_lookup_by_subsys(struct tg3 *tp)
 	return NULL;
 }
 
-static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
+static void tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 {
 	u32 val;
 
@@ -13752,7 +13752,7 @@ done:
 		device_set_wakeup_capable(&tp->pdev->dev, false);
 }
 
-static int __devinit tg3_issue_otp_command(struct tg3 *tp, u32 cmd)
+static int tg3_issue_otp_command(struct tg3 *tp, u32 cmd)
 {
 	int i;
 	u32 val;
@@ -13775,7 +13775,7 @@ static int __devinit tg3_issue_otp_command(struct tg3 *tp, u32 cmd)
  * configuration is a 32-bit value that straddles the alignment boundary.
  * We do two 32-bit reads and then shift and merge the results.
  */
-static u32 __devinit tg3_read_otp_phycfg(struct tg3 *tp)
+static u32 tg3_read_otp_phycfg(struct tg3 *tp)
 {
 	u32 bhalf_otp, thalf_otp;
 
@@ -13801,7 +13801,7 @@ static u32 __devinit tg3_read_otp_phycfg(struct tg3 *tp)
 	return ((thalf_otp & 0x0000ffff) << 16) | (bhalf_otp >> 16);
 }
 
-static void __devinit tg3_phy_init_link_config(struct tg3 *tp)
+static void tg3_phy_init_link_config(struct tg3 *tp)
 {
 	u32 adv = ADVERTISED_Autoneg;
 
@@ -13828,7 +13828,7 @@ static void __devinit tg3_phy_init_link_config(struct tg3 *tp)
 	tp->old_link = -1;
 }
 
-static int __devinit tg3_phy_probe(struct tg3 *tp)
+static int tg3_phy_probe(struct tg3 *tp)
 {
 	u32 hw_phy_id_1, hw_phy_id_2;
 	u32 hw_phy_id, hw_phy_id_masked;
@@ -13956,7 +13956,7 @@ skip_phy_reset:
 	return err;
 }
 
-static void __devinit tg3_read_vpd(struct tg3 *tp)
+static void tg3_read_vpd(struct tg3 *tp)
 {
 	u8 *vpd_data;
 	unsigned int block_end, rosize, len;
@@ -14077,7 +14077,7 @@ nomatch:
 	}
 }
 
-static int __devinit tg3_fw_img_is_valid(struct tg3 *tp, u32 offset)
+static int tg3_fw_img_is_valid(struct tg3 *tp, u32 offset)
 {
 	u32 val;
 
@@ -14090,7 +14090,7 @@ static int __devinit tg3_fw_img_is_valid(struct tg3 *tp, u32 offset)
 	return 1;
 }
 
-static void __devinit tg3_read_bc_ver(struct tg3 *tp)
+static void tg3_read_bc_ver(struct tg3 *tp)
 {
 	u32 val, offset, start, ver_offset;
 	int i, dst_off;
@@ -14142,7 +14142,7 @@ static void __devinit tg3_read_bc_ver(struct tg3 *tp)
 	}
 }
 
-static void __devinit tg3_read_hwsb_ver(struct tg3 *tp)
+static void tg3_read_hwsb_ver(struct tg3 *tp)
 {
 	u32 val, major, minor;
 
@@ -14158,7 +14158,7 @@ static void __devinit tg3_read_hwsb_ver(struct tg3 *tp)
 	snprintf(&tp->fw_ver[0], 32, "sb v%d.%02d", major, minor);
 }
 
-static void __devinit tg3_read_sb_ver(struct tg3 *tp, u32 val)
+static void tg3_read_sb_ver(struct tg3 *tp, u32 val)
 {
 	u32 offset, major, minor, build;
 
@@ -14213,7 +14213,7 @@ static void __devinit tg3_read_sb_ver(struct tg3 *tp, u32 val)
 	}
 }
 
-static void __devinit tg3_read_mgmtfw_ver(struct tg3 *tp)
+static void tg3_read_mgmtfw_ver(struct tg3 *tp)
 {
 	u32 val, offset, start;
 	int i, vlen;
@@ -14265,7 +14265,7 @@ static void __devinit tg3_read_mgmtfw_ver(struct tg3 *tp)
 	}
 }
 
-static void __devinit tg3_probe_ncsi(struct tg3 *tp)
+static void tg3_probe_ncsi(struct tg3 *tp)
 {
 	u32 apedata;
 
@@ -14281,7 +14281,7 @@ static void __devinit tg3_probe_ncsi(struct tg3 *tp)
 		tg3_flag_set(tp, APE_HAS_NCSI);
 }
 
-static void __devinit tg3_read_dash_ver(struct tg3 *tp)
+static void tg3_read_dash_ver(struct tg3 *tp)
 {
 	int vlen;
 	u32 apedata;
@@ -14304,7 +14304,7 @@ static void __devinit tg3_read_dash_ver(struct tg3 *tp)
 		 (apedata & APE_FW_VERSION_BLDMSK));
 }
 
-static void __devinit tg3_read_fw_ver(struct tg3 *tp)
+static void tg3_read_fw_ver(struct tg3 *tp)
 {
 	u32 val;
 	bool vpd_vers = false;
@@ -14357,7 +14357,7 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_write_reorder_chipsets) = {
 	{ },
 };
 
-static struct pci_dev * __devinit tg3_find_peer(struct tg3 *tp)
+static struct pci_dev *tg3_find_peer(struct tg3 *tp)
 {
 	struct pci_dev *peer;
 	unsigned int func, devnr = tp->pdev->devfn & ~7;
@@ -14385,7 +14385,7 @@ static struct pci_dev * __devinit tg3_find_peer(struct tg3 *tp)
 	return peer;
 }
 
-static void __devinit tg3_detect_asic_rev(struct tg3 *tp, u32 misc_ctrl_reg)
+static void tg3_detect_asic_rev(struct tg3 *tp, u32 misc_ctrl_reg)
 {
 	tp->pci_chip_rev_id = misc_ctrl_reg >> MISC_HOST_CTRL_CHIPREV_SHIFT;
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_USE_PROD_ID_REG) {
@@ -14466,7 +14466,7 @@ static void __devinit tg3_detect_asic_rev(struct tg3 *tp, u32 misc_ctrl_reg)
 		tg3_flag_set(tp, 5705_PLUS);
 }
 
-static int __devinit tg3_get_invariants(struct tg3 *tp)
+static int tg3_get_invariants(struct tg3 *tp)
 {
 	u32 misc_ctrl_reg;
 	u32 pci_state_reg, grc_misc_cfg;
@@ -15240,7 +15240,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 }
 
 #ifdef CONFIG_SPARC
-static int __devinit tg3_get_macaddr_sparc(struct tg3 *tp)
+static int tg3_get_macaddr_sparc(struct tg3 *tp)
 {
 	struct net_device *dev = tp->dev;
 	struct pci_dev *pdev = tp->pdev;
@@ -15257,7 +15257,7 @@ static int __devinit tg3_get_macaddr_sparc(struct tg3 *tp)
 	return -ENODEV;
 }
 
-static int __devinit tg3_get_default_macaddr_sparc(struct tg3 *tp)
+static int tg3_get_default_macaddr_sparc(struct tg3 *tp)
 {
 	struct net_device *dev = tp->dev;
 
@@ -15267,7 +15267,7 @@ static int __devinit tg3_get_default_macaddr_sparc(struct tg3 *tp)
 }
 #endif
 
-static int __devinit tg3_get_device_address(struct tg3 *tp)
+static int tg3_get_device_address(struct tg3 *tp)
 {
 	struct net_device *dev = tp->dev;
 	u32 hi, lo, mac_offset;
@@ -15346,7 +15346,7 @@ static int __devinit tg3_get_device_address(struct tg3 *tp)
 #define BOUNDARY_SINGLE_CACHELINE	1
 #define BOUNDARY_MULTI_CACHELINE	2
 
-static u32 __devinit tg3_calc_dma_bndry(struct tg3 *tp, u32 val)
+static u32 tg3_calc_dma_bndry(struct tg3 *tp, u32 val)
 {
 	int cacheline_size;
 	u8 byte;
@@ -15487,7 +15487,7 @@ out:
 	return val;
 }
 
-static int __devinit tg3_do_test_dma(struct tg3 *tp, u32 *buf, dma_addr_t buf_dma, int size, int to_device)
+static int tg3_do_test_dma(struct tg3 *tp, u32 *buf, dma_addr_t buf_dma, int size, int to_device)
 {
 	struct tg3_internal_buffer_desc test_desc;
 	u32 sram_dma_descs;
@@ -15574,7 +15574,7 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_dma_wait_state_chipsets) = {
 	{ },
 };
 
-static int __devinit tg3_test_dma(struct tg3 *tp)
+static int tg3_test_dma(struct tg3 *tp)
 {
 	dma_addr_t buf_dma;
 	u32 *buf, saved_dma_rwctrl;
@@ -15764,7 +15764,7 @@ out_nofree:
 	return ret;
 }
 
-static void __devinit tg3_init_bufmgr_config(struct tg3 *tp)
+static void tg3_init_bufmgr_config(struct tg3 *tp)
 {
 	if (tg3_flag(tp, 57765_PLUS)) {
 		tp->bufmgr_config.mbuf_read_dma_low_water =
@@ -15820,7 +15820,7 @@ static void __devinit tg3_init_bufmgr_config(struct tg3 *tp)
 	tp->bufmgr_config.dma_high_water = DEFAULT_DMA_HIGH_WATER;
 }
 
-static char * __devinit tg3_phy_string(struct tg3 *tp)
+static char *tg3_phy_string(struct tg3 *tp)
 {
 	switch (tp->phy_id & TG3_PHY_ID_MASK) {
 	case TG3_PHY_ID_BCM5400:	return "5400";
@@ -15851,7 +15851,7 @@ static char * __devinit tg3_phy_string(struct tg3 *tp)
 	}
 }
 
-static char * __devinit tg3_bus_string(struct tg3 *tp, char *str)
+static char *tg3_bus_string(struct tg3 *tp, char *str)
 {
 	if (tg3_flag(tp, PCI_EXPRESS)) {
 		strcpy(str, "PCI Express");
@@ -15887,7 +15887,7 @@ static char * __devinit tg3_bus_string(struct tg3 *tp, char *str)
 	return str;
 }
 
-static void __devinit tg3_init_coal(struct tg3 *tp)
+static void tg3_init_coal(struct tg3 *tp)
 {
 	struct ethtool_coalesce *ec = &tp->coal;
 
@@ -15918,7 +15918,7 @@ static void __devinit tg3_init_coal(struct tg3 *tp)
 	}
 }
 
-static int __devinit tg3_init_one(struct pci_dev *pdev,
+static int tg3_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 7735469..45ec1c4 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3226,7 +3226,7 @@ bnad_pci_uninit(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
-static int __devinit
+static int
 bnad_pci_probe(struct pci_dev *pdev,
 		const struct pci_device_id *pcidev_id)
 {
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 1fac769..5efb8d2 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1452,7 +1452,7 @@ static const struct of_device_id macb_dt_ids[] = {
 
 MODULE_DEVICE_TABLE(of, macb_dt_ids);
 
-static int __devinit macb_get_phy_mode_dt(struct platform_device *pdev)
+static int macb_get_phy_mode_dt(struct platform_device *pdev)
 {
 	struct device_node *np = pdev->dev.of_node;
 
@@ -1462,7 +1462,7 @@ static int __devinit macb_get_phy_mode_dt(struct platform_device *pdev)
 	return -ENODEV;
 }
 
-static int __devinit macb_get_hwaddr_dt(struct macb *bp)
+static int macb_get_hwaddr_dt(struct macb *bp)
 {
 	struct device_node *np = bp->pdev->dev.of_node;
 	if (np) {
@@ -1476,11 +1476,11 @@ static int __devinit macb_get_hwaddr_dt(struct macb *bp)
 	return -ENODEV;
 }
 #else
-static int __devinit macb_get_phy_mode_dt(struct platform_device *pdev)
+static int macb_get_phy_mode_dt(struct platform_device *pdev)
 {
 	return -ENODEV;
 }
-static int __devinit macb_get_hwaddr_dt(struct macb *bp)
+static int macb_get_hwaddr_dt(struct macb *bp)
 {
 	return -ENODEV;
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
index 7cfa7bb..e5053ad 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
+++ b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
@@ -974,7 +974,7 @@ static const struct net_device_ops cxgb_netdev_ops = {
 #endif
 };
 
-static int __devinit init_one(struct pci_dev *pdev,
+static int init_one(struct pci_dev *pdev,
 			      const struct pci_device_id *ent)
 {
 	static int version_printed;
diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethernet/chelsio/cxgb/sge.c
index 47a8435..9a0a858 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -2071,7 +2071,7 @@ static void espibug_workaround(unsigned long data)
 /*
  * Creates a t1_sge structure and returns suggested resource parameters.
  */
-struct sge * __devinit t1_sge_create(struct adapter *adapter,
+struct sge *t1_sge_create(struct adapter *adapter,
 				     struct sge_params *p)
 {
 	struct sge *sge = kzalloc(sizeof(*sge), GFP_KERNEL);
diff --git a/drivers/net/ethernet/chelsio/cxgb/subr.c b/drivers/net/ethernet/chelsio/cxgb/subr.c
index 8a43c7e..9527dc1 100644
--- a/drivers/net/ethernet/chelsio/cxgb/subr.c
+++ b/drivers/net/ethernet/chelsio/cxgb/subr.c
@@ -892,7 +892,7 @@ static void power_sequence_xpak(adapter_t* adapter)
 	}
 }
 
-int __devinit t1_get_board_rev(adapter_t *adapter, const struct board_info *bi,
+int t1_get_board_rev(adapter_t *adapter, const struct board_info *bi,
 			       struct adapter_params *p)
 {
 	p->chip_version = bi->chip_term;
@@ -992,7 +992,7 @@ out_err:
 /*
  * Determine a card's PCI mode.
  */
-static void __devinit get_pci_mode(adapter_t *adapter, struct chelsio_pci_params *p)
+static void get_pci_mode(adapter_t *adapter, struct chelsio_pci_params *p)
 {
 	static const unsigned short speed_map[] = { 33, 66, 100, 133 };
 	u32 pci_mode;
@@ -1028,7 +1028,7 @@ void t1_free_sw_modules(adapter_t *adapter)
 		t1_espi_destroy(adapter->espi);
 }
 
-static void __devinit init_link_config(struct link_config *lc,
+static void init_link_config(struct link_config *lc,
 				       const struct board_info *bi)
 {
 	lc->supported = bi->caps;
@@ -1049,7 +1049,7 @@ static void __devinit init_link_config(struct link_config *lc,
  * Allocate and initialize the data structures that hold the SW state of
  * the Terminator HW modules.
  */
-int __devinit t1_init_sw_modules(adapter_t *adapter,
+int t1_init_sw_modules(adapter_t *adapter,
 				 const struct board_info *bi)
 {
 	unsigned int i;
diff --git a/drivers/net/ethernet/chelsio/cxgb/tp.c b/drivers/net/ethernet/chelsio/cxgb/tp.c
index 8bed4a5..aa41cfe 100644
--- a/drivers/net/ethernet/chelsio/cxgb/tp.c
+++ b/drivers/net/ethernet/chelsio/cxgb/tp.c
@@ -55,7 +55,7 @@ void t1_tp_destroy(struct petp *tp)
 	kfree(tp);
 }
 
-struct petp *__devinit t1_tp_create(adapter_t * adapter, struct tp_params *p)
+struct petp *t1_tp_create(adapter_t * adapter, struct tp_params *p)
 {
 	struct petp *tp = kzalloc(sizeof(*tp), GFP_KERNEL);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index a450f8d..9d09fcd 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -3078,7 +3078,7 @@ static void set_nqsets(struct adapter *adap)
 	}
 }
 
-static int __devinit cxgb_enable_msix(struct adapter *adap)
+static int cxgb_enable_msix(struct adapter *adap)
 {
 	struct msix_entry entries[SGE_QSETS + 1];
 	int vectors;
@@ -3108,7 +3108,7 @@ static int __devinit cxgb_enable_msix(struct adapter *adap)
 	return err;
 }
 
-static void __devinit print_port_info(struct adapter *adap,
+static void print_port_info(struct adapter *adap,
 				      const struct adapter_info *ai)
 {
 	static const char *pci_variant[] = {
@@ -3165,7 +3165,7 @@ static const struct net_device_ops cxgb_netdev_ops = {
 #endif
 };
 
-static void __devinit cxgb3_init_iscsi_mac(struct net_device *dev)
+static void cxgb3_init_iscsi_mac(struct net_device *dev)
 {
 	struct port_info *pi = netdev_priv(dev);
 
@@ -3176,7 +3176,7 @@ static void __devinit cxgb3_init_iscsi_mac(struct net_device *dev)
 #define TSO_FLAGS (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
 #define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | TSO_FLAGS | \
 			NETIF_F_IPV6_CSUM | NETIF_F_HIGHDMA)
-static int __devinit init_one(struct pci_dev *pdev,
+static int init_one(struct pci_dev *pdev,
 			      const struct pci_device_id *ent)
 {
 	static int version_printed;
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
index 2dbbcbb..67986cc 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
@@ -1382,7 +1382,7 @@ static inline int adap2type(struct adapter *adapter)
 	return type;
 }
 
-void __devinit cxgb3_adapter_ofld(struct adapter *adapter)
+void cxgb3_adapter_ofld(struct adapter *adapter)
 {
 	struct t3cdev *tdev = &adapter->tdev;
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index f344190..3321e1b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2148,7 +2148,7 @@ static const struct file_operations mem_debugfs_fops = {
 	.llseek  = default_llseek,
 };
 
-static void __devinit add_debugfs_mem(struct adapter *adap, const char *name,
+static void add_debugfs_mem(struct adapter *adap, const char *name,
 				      unsigned int idx, unsigned int size_mb)
 {
 	struct dentry *de;
@@ -2159,7 +2159,7 @@ static void __devinit add_debugfs_mem(struct adapter *adap, const char *name,
 		de->d_inode->i_size = size_mb << 20;
 }
 
-static int __devinit setup_debugfs(struct adapter *adap)
+static int setup_debugfs(struct adapter *adap)
 {
 	int i;
 
@@ -4173,7 +4173,7 @@ static inline void init_rspq(struct sge_rspq *q, u8 timer_idx, u8 pkt_cnt_idx,
  * of ports we found and the number of available CPUs.  Most settings can be
  * modified by the admin prior to actual use.
  */
-static void __devinit cfg_queues(struct adapter *adap)
+static void cfg_queues(struct adapter *adap)
 {
 	struct sge *s = &adap->sge;
 	int i, q10g = 0, n10g = 0, qidx = 0;
@@ -4257,7 +4257,7 @@ static void __devinit cfg_queues(struct adapter *adap)
  * Reduce the number of Ethernet queues across all ports to at most n.
  * n provides at least one queue per port.
  */
-static void __devinit reduce_ethqs(struct adapter *adap, int n)
+static void reduce_ethqs(struct adapter *adap, int n)
 {
 	int i;
 	struct port_info *pi;
@@ -4284,7 +4284,7 @@ static void __devinit reduce_ethqs(struct adapter *adap, int n)
 /* 2 MSI-X vectors needed for the FW queue and non-data interrupts */
 #define EXTRA_VECS 2
 
-static int __devinit enable_msix(struct adapter *adap)
+static int enable_msix(struct adapter *adap)
 {
 	int ofld_need = 0;
 	int i, err, want, need;
@@ -4333,7 +4333,7 @@ static int __devinit enable_msix(struct adapter *adap)
 
 #undef EXTRA_VECS
 
-static int __devinit init_rss(struct adapter *adap)
+static int init_rss(struct adapter *adap)
 {
 	unsigned int i, j;
 
@@ -4349,7 +4349,7 @@ static int __devinit init_rss(struct adapter *adap)
 	return 0;
 }
 
-static void __devinit print_port_info(const struct net_device *dev)
+static void print_port_info(const struct net_device *dev)
 {
 	static const char *base[] = {
 		"R XFI", "R XAUI", "T SGMII", "T XFI", "T XAUI", "KX4", "CX4",
@@ -4386,7 +4386,7 @@ static void __devinit print_port_info(const struct net_device *dev)
 		    adap->params.vpd.sn, adap->params.vpd.ec);
 }
 
-static void __devinit enable_pcie_relaxed_ordering(struct pci_dev *dev)
+static void enable_pcie_relaxed_ordering(struct pci_dev *dev)
 {
 	pcie_capability_set_word(dev, PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_RELAX_EN);
 }
@@ -4419,7 +4419,7 @@ static void free_some_resources(struct adapter *adapter)
 #define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | TSO_FLAGS | \
 		   NETIF_F_IPV6_CSUM | NETIF_F_HIGHDMA)
 
-static int __devinit init_one(struct pci_dev *pdev,
+static int init_one(struct pci_dev *pdev,
 			      const struct pci_device_id *ent)
 {
 	int func, i, err;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 730ae2c..8ea7736 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -2003,7 +2003,7 @@ void t4_tp_wr_bits_indirect(struct adapter *adap, unsigned int addr,
  *
  *	Initialize the congestion control parameters.
  */
-static void __devinit init_cong_ctrl(unsigned short *a, unsigned short *b)
+static void init_cong_ctrl(unsigned short *a, unsigned short *b)
 {
 	a[0] = a[1] = a[2] = a[3] = a[4] = a[5] = a[6] = a[7] = a[8] = 1;
 	a[9] = 2;
@@ -3440,7 +3440,7 @@ int t4_handle_fw_rpl(struct adapter *adap, const __be64 *rpl)
 	return 0;
 }
 
-static void __devinit get_pci_mode(struct adapter *adapter,
+static void get_pci_mode(struct adapter *adapter,
 				   struct pci_params *p)
 {
 	u16 val;
@@ -3460,7 +3460,7 @@ static void __devinit get_pci_mode(struct adapter *adapter,
  *	Initializes the SW state maintained for each link, including the link's
  *	capabilities and default speed/flow-control/autonegotiation settings.
  */
-static void __devinit init_link_config(struct link_config *lc,
+static void init_link_config(struct link_config *lc,
 				       unsigned int caps)
 {
 	lc->supported = caps;
@@ -3485,7 +3485,7 @@ int t4_wait_dev_ready(struct adapter *adap)
 	return t4_read_reg(adap, PL_WHOAMI) != 0xffffffff ? 0 : -EIO;
 }
 
-static int __devinit get_flash_params(struct adapter *adap)
+static int get_flash_params(struct adapter *adap)
 {
 	int ret;
 	u32 info;
@@ -3521,7 +3521,7 @@ static int __devinit get_flash_params(struct adapter *adap)
  *	values for some adapter tunables, take PHYs out of reset, and
  *	initialize the MDIO interface.
  */
-int __devinit t4_prep_adapter(struct adapter *adapter)
+int t4_prep_adapter(struct adapter *adapter)
 {
 	int ret;
 
@@ -3549,7 +3549,7 @@ int __devinit t4_prep_adapter(struct adapter *adapter)
 	return 0;
 }
 
-int __devinit t4_port_init(struct adapter *adap, int mbox, int pf, int vf)
+int t4_port_init(struct adapter *adap, int mbox, int pf, int vf)
 {
 	u8 addr[6];
 	int ret, i, j = 0;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 1ccd28b..5ffc34e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2023,7 +2023,7 @@ static struct cxgb4vf_debugfs_entry debugfs_files[] = {
  * Set up out /sys/kernel/debug/cxgb4vf sub-nodes.  We assume that the
  * directory (debugfs_root) has already been set up.
  */
-static int __devinit setup_debugfs(struct adapter *adapter)
+static int setup_debugfs(struct adapter *adapter)
 {
 	int i;
 
@@ -2064,7 +2064,7 @@ static void cleanup_debugfs(struct adapter *adapter)
  * adapter parameters we're going to be using and initialize basic adapter
  * hardware support.
  */
-static int __devinit adap_init0(struct adapter *adapter)
+static int adap_init0(struct adapter *adapter)
 {
 	struct vf_resources *vfres = &adapter->params.vfres;
 	struct sge_params *sge_params = &adapter->params.sge;
@@ -2266,7 +2266,7 @@ static inline void init_rspq(struct sge_rspq *rspq, u8 timer_idx,
  * be modified by the admin via ethtool and cxgbtool prior to the adapter
  * being brought up for the first time.
  */
-static void __devinit cfg_queues(struct adapter *adapter)
+static void cfg_queues(struct adapter *adapter)
 {
 	struct sge *s = &adapter->sge;
 	int q10g, n10g, qidx, pidx, qs;
@@ -2361,7 +2361,7 @@ static void __devinit cfg_queues(struct adapter *adapter)
  * Reduce the number of Ethernet queues across all ports to at most n.
  * n provides at least one queue per port.
  */
-static void __devinit reduce_ethqs(struct adapter *adapter, int n)
+static void reduce_ethqs(struct adapter *adapter, int n)
 {
 	int i;
 	struct port_info *pi;
@@ -2400,7 +2400,7 @@ static void __devinit reduce_ethqs(struct adapter *adapter, int n)
  * for our "extras".  Note that this process may lower the maximum number of
  * allowed Queue Sets ...
  */
-static int __devinit enable_msix(struct adapter *adapter)
+static int enable_msix(struct adapter *adapter)
 {
 	int i, err, want, need;
 	struct msix_entry entries[MSIX_ENTRIES];
@@ -2462,7 +2462,7 @@ static const struct net_device_ops cxgb4vf_netdev_ops	= {
  * state needed to manage the device.  This routine is called "init_one" in
  * the PF Driver ...
  */
-static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
+static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 				       const struct pci_device_id *ent)
 {
 	static int version_printed;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
index a65c80a..283f9d0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
@@ -232,8 +232,8 @@ static inline int t4vf_wr_mbox_ns(struct adapter *adapter, const void *cmd,
 	return t4vf_wr_mbox_core(adapter, cmd, size, rpl, false);
 }
 
-int __devinit t4vf_wait_dev_ready(struct adapter *);
-int __devinit t4vf_port_init(struct adapter *, int);
+int t4vf_wait_dev_ready(struct adapter *);
+int t4vf_port_init(struct adapter *, int);
 
 int t4vf_fw_reset(struct adapter *);
 int t4vf_query_params(struct adapter *, unsigned int, const u32 *, u32 *);
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index fe3fd3d..9b70ccc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -46,7 +46,7 @@
  * returning a value other than all 1's).  Return an error if it doesn't
  * become ready ...
  */
-int __devinit t4vf_wait_dev_ready(struct adapter *adapter)
+int t4vf_wait_dev_ready(struct adapter *adapter)
 {
 	const u32 whoami = T4VF_PL_BASE_ADDR + PL_VF_WHOAMI;
 	const u32 notready1 = 0xffffffff;
@@ -253,7 +253,7 @@ static int hash_mac_addr(const u8 *addr)
  *	Initializes the SW state maintained for each link, including the link's
  *	capabilities and default speed/flow-control/autonegotiation settings.
  */
-static void __devinit init_link_config(struct link_config *lc,
+static void init_link_config(struct link_config *lc,
 				       unsigned int caps)
 {
 	lc->supported = caps;
@@ -275,7 +275,7 @@ static void __devinit init_link_config(struct link_config *lc,
  *	@adapter: the adapter
  *	@pidx: the adapter port index
  */
-int __devinit t4vf_port_init(struct adapter *adapter, int pidx)
+int t4vf_port_init(struct adapter *adapter, int pidx)
 {
 	struct port_info *pi = adap2pinfo(adapter, pidx);
 	struct fw_vi_cmd vi_cmd, vi_rpl;
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 612438a..44525d2 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2275,7 +2275,7 @@ static void enic_iounmap(struct enic *enic)
 			iounmap(enic->bar[i].vaddr);
 }
 
-static int __devinit enic_probe(struct pci_dev *pdev,
+static int enic_probe(struct pci_dev *pdev,
 	const struct pci_device_id *ent)
 {
 	struct device *dev = &pdev->dev;
diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 87d7c35..d176ec5 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1359,7 +1359,7 @@ static const struct net_device_ops dm9000_netdev_ops = {
 /*
  * Search DM9000 board, allocate space and register it
  */
-static int __devinit
+static int
 dm9000_probe(struct platform_device *pdev)
 {
 	struct dm9000_plat_data *pdata = pdev->dev.platform_data;
diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/ethernet/dec/tulip/de2104x.c
index 18fd028..ae4d5f5 100644
--- a/drivers/net/ethernet/dec/tulip/de2104x.c
+++ b/drivers/net/ethernet/dec/tulip/de2104x.c
@@ -1700,7 +1700,7 @@ static const struct ethtool_ops de_ethtool_ops = {
 	.get_regs		= de_get_regs,
 };
 
-static void __devinit de21040_get_mac_address (struct de_private *de)
+static void de21040_get_mac_address (struct de_private *de)
 {
 	unsigned i;
 
@@ -1721,7 +1721,7 @@ static void __devinit de21040_get_mac_address (struct de_private *de)
 	}
 }
 
-static void __devinit de21040_get_media_info(struct de_private *de)
+static void de21040_get_media_info(struct de_private *de)
 {
 	unsigned int i;
 
@@ -1748,7 +1748,7 @@ static void __devinit de21040_get_media_info(struct de_private *de)
 }
 
 /* Note: this routine returns extra data bits for size detection. */
-static unsigned __devinit tulip_read_eeprom(void __iomem *regs, int location, int addr_len)
+static unsigned tulip_read_eeprom(void __iomem *regs, int location, int addr_len)
 {
 	int i;
 	unsigned retval = 0;
@@ -1783,7 +1783,7 @@ static unsigned __devinit tulip_read_eeprom(void __iomem *regs, int location, in
 	return retval;
 }
 
-static void __devinit de21041_get_srom_info (struct de_private *de)
+static void de21041_get_srom_info (struct de_private *de)
 {
 	unsigned i, sa_offset = 0, ofs;
 	u8 ee_data[DE_EEPROM_SIZE + 6] = {};
@@ -1961,7 +1961,7 @@ static const struct net_device_ops de_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int __devinit de_init_one (struct pci_dev *pdev,
+static int de_init_one (struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index 8a4264f..f809302 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -1092,7 +1092,7 @@ static const struct net_device_ops de4x5_netdev_ops = {
 };
 
 
-static int __devinit
+static int
 de4x5_hw_init(struct net_device *dev, u_long iobase, struct device *gendev)
 {
     char name[DE4X5_NAME_LENGTH + 1];
@@ -2118,7 +2118,7 @@ MODULE_DEVICE_TABLE(eisa, de4x5_eisa_ids);
 ** DECchips, we can find the base SROM irrespective of the BIOS scan direction.
 ** For single port cards this is a time waster...
 */
-static void __devinit
+static void
 srom_search(struct net_device *dev, struct pci_dev *pdev)
 {
     u_char pb;
@@ -2192,7 +2192,7 @@ srom_search(struct net_device *dev, struct pci_dev *pdev)
 ** kernels use the V0.535[n] drivers.
 */
 
-static int __devinit de4x5_pci_probe (struct pci_dev *pdev,
+static int de4x5_pci_probe (struct pci_dev *pdev,
 				   const struct pci_device_id *ent)
 {
 	u_char pb, pbus = 0, dev_num, dnum = 0, timer;
diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index a631448..204da23 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -367,7 +367,7 @@ static const struct net_device_ops netdev_ops = {
  *	Search DM910X board ,allocate space and register it
  */
 
-static int __devinit dmfe_init_one (struct pci_dev *pdev,
+static int dmfe_init_one (struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
 {
 	struct dmfe_board_info *db;	/* board information structure */
diff --git a/drivers/net/ethernet/dec/tulip/eeprom.c b/drivers/net/ethernet/dec/tulip/eeprom.c
index 44f7e8e..8692a72 100644
--- a/drivers/net/ethernet/dec/tulip/eeprom.c
+++ b/drivers/net/ethernet/dec/tulip/eeprom.c
@@ -102,7 +102,7 @@ static const char *const block_name[] __devinitconst = {
  * #ifdef __hppa__ should completely optimize this function away for
  * non-parisc hardware.
  */
-static void __devinit tulip_build_fake_mediatable(struct tulip_private *tp)
+static void tulip_build_fake_mediatable(struct tulip_private *tp)
 {
 #ifdef CONFIG_GSC
 	if (tp->flags & NEEDS_FAKE_MEDIA_TABLE) {
@@ -140,7 +140,7 @@ static void __devinit tulip_build_fake_mediatable(struct tulip_private *tp)
 #endif
 }
 
-void __devinit tulip_parse_eeprom(struct net_device *dev)
+void tulip_parse_eeprom(struct net_device *dev)
 {
 	/*
 	  dev is not registered at this point, so logging messages can't
@@ -339,7 +339,7 @@ subsequent_board:
 #define EE_READ_CMD		(6)
 
 /* Note: this routine returns extra data bits for size detection. */
-int __devinit tulip_read_eeprom(struct net_device *dev, int location, int addr_len)
+int tulip_read_eeprom(struct net_device *dev, int location, int addr_len)
 {
 	int i;
 	unsigned retval = 0;
diff --git a/drivers/net/ethernet/dec/tulip/media.c b/drivers/net/ethernet/dec/tulip/media.c
index ae937c6..6ad755b 100644
--- a/drivers/net/ethernet/dec/tulip/media.c
+++ b/drivers/net/ethernet/dec/tulip/media.c
@@ -447,7 +447,7 @@ int tulip_check_duplex(struct net_device *dev)
 	return 0;
 }
 
-void __devinit tulip_find_mii (struct net_device *dev, int board_idx)
+void tulip_find_mii (struct net_device *dev, int board_idx)
 {
 	struct tulip_private *tp = netdev_priv(dev);
 	int phyn, phy_idx = 0;
diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index 2a3736e..4eb705f 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -1191,7 +1191,7 @@ static void set_rx_mode(struct net_device *dev)
 }
 
 #ifdef CONFIG_TULIP_MWI
-static void __devinit tulip_mwi_config (struct pci_dev *pdev,
+static void tulip_mwi_config (struct pci_dev *pdev,
 					struct net_device *dev)
 {
 	struct tulip_private *tp = netdev_priv(dev);
@@ -1301,7 +1301,7 @@ DEFINE_PCI_DEVICE_TABLE(early_486_chipsets) = {
 	{ },
 };
 
-static int __devinit tulip_init_one (struct pci_dev *pdev,
+static int tulip_init_one (struct pci_dev *pdev,
 				     const struct pci_device_id *ent)
 {
 	struct tulip_private *tp;
diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index 9c24c95..b1aa454 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -281,7 +281,7 @@ static const struct net_device_ops netdev_ops = {
  *	Search ULI526X board, allocate space and register it
  */
 
-static int __devinit uli526x_init_one (struct pci_dev *pdev,
+static int uli526x_init_one (struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
 {
 	struct uli526x_board_info *db;	/* board information structure */
diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
index 6c5db4f..a5865dd 100644
--- a/drivers/net/ethernet/dec/tulip/winbond-840.c
+++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
@@ -358,7 +358,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int __devinit w840_probe1 (struct pci_dev *pdev,
+static int w840_probe1 (struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/dec/tulip/xircom_cb.c b/drivers/net/ethernet/dec/tulip/xircom_cb.c
index 4310e97..8e1f8f6 100644
--- a/drivers/net/ethernet/dec/tulip/xircom_cb.c
+++ b/drivers/net/ethernet/dec/tulip/xircom_cb.c
@@ -190,7 +190,7 @@ static const struct net_device_ops netdev_ops = {
          first two packets that get send, and pump hates that.
 
  */
-static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_id *id)
+static int xircom_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 {
 	struct device *d = &pdev->dev;
 	struct net_device *dev = NULL;
diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index 21db34c..eba0822 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -110,7 +110,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_change_mtu		= change_mtu,
 };
 
-static int __devinit
+static int
 rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethernet/dlink/sundance.c
index 65187b9..618a314 100644
--- a/drivers/net/ethernet/dlink/sundance.c
+++ b/drivers/net/ethernet/dlink/sundance.c
@@ -472,7 +472,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int __devinit sundance_probe1 (struct pci_dev *pdev,
+static int sundance_probe1 (struct pci_dev *pdev,
 				      const struct pci_device_id *ent)
 {
 	struct net_device *dev;
@@ -701,7 +701,7 @@ static int change_mtu(struct net_device *dev, int new_mtu)
 
 #define eeprom_delay(ee_addr)	ioread32(ee_addr)
 /* Read the EEPROM and MII Management Data I/O (MDIO) interfaces. */
-static int __devinit eeprom_read(void __iomem *ioaddr, int location)
+static int eeprom_read(void __iomem *ioaddr, int location)
 {
 	int boguscnt = 10000;		/* Typical 1900 ticks. */
 	iowrite16(0x0200 | (location & 0xff), ioaddr + EECtrl);
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index dfdf553..e409525 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -72,7 +72,7 @@ static void __dnet_set_hwaddr(struct dnet *bp)
 	dnet_writew_mac(bp, DNET_INTERNAL_MAC_ADDR_2_REG, tmp);
 }
 
-static void __devinit dnet_get_hwaddr(struct dnet *bp)
+static void dnet_get_hwaddr(struct dnet *bp)
 {
 	u16 tmp;
 	u8 addr[6];
@@ -829,7 +829,7 @@ static const struct net_device_ops dnet_netdev_ops = {
 	.ndo_change_mtu		= eth_change_mtu,
 };
 
-static int __devinit dnet_probe(struct platform_device *pdev)
+static int dnet_probe(struct platform_device *pdev)
 {
 	struct resource *res;
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index c365722..92c2f5d 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3999,7 +3999,7 @@ static inline char *func_name(struct be_adapter *adapter)
 	return be_physfn(adapter) ? "PF" : "VF";
 }
 
-static int __devinit be_probe(struct pci_dev *pdev,
+static int be_probe(struct pci_dev *pdev,
 			const struct pci_device_id *pdev_id)
 {
 	int status = 0;
diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 198d587..78764bb 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -665,7 +665,7 @@ static void ethoc_mdio_poll(struct net_device *dev)
 {
 }
 
-static int __devinit ethoc_mdio_probe(struct net_device *dev)
+static int ethoc_mdio_probe(struct net_device *dev)
 {
 	struct ethoc *priv = netdev_priv(dev);
 	struct phy_device *phy;
@@ -905,7 +905,7 @@ static const struct net_device_ops ethoc_netdev_ops = {
  * ethoc_probe - initialize OpenCores ethernet MAC
  * pdev:	platform device
  */
-static int __devinit ethoc_probe(struct platform_device *pdev)
+static int ethoc_probe(struct platform_device *pdev)
 {
 	struct net_device *netdev = NULL;
 	struct resource *res = NULL;
diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
index fce1d35..b1dcd1c 100644
--- a/drivers/net/ethernet/fealnx.c
+++ b/drivers/net/ethernet/fealnx.c
@@ -477,7 +477,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int __devinit fealnx_init_one(struct pci_dev *pdev,
+static int fealnx_init_one(struct pci_dev *pdev,
 				     const struct pci_device_id *ent)
 {
 	struct netdev_private *np;
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 3729996..ae7ebd7 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1484,7 +1484,7 @@ static int fec_enet_init(struct net_device *ndev)
 }
 
 #ifdef CONFIG_OF
-static int __devinit fec_get_phy_mode_dt(struct platform_device *pdev)
+static int fec_get_phy_mode_dt(struct platform_device *pdev)
 {
 	struct device_node *np = pdev->dev.of_node;
 
@@ -1494,7 +1494,7 @@ static int __devinit fec_get_phy_mode_dt(struct platform_device *pdev)
 	return -ENODEV;
 }
 
-static void __devinit fec_reset_phy(struct platform_device *pdev)
+static void fec_reset_phy(struct platform_device *pdev)
 {
 	int err, phy_reset;
 	int msec = 1;
@@ -1533,7 +1533,7 @@ static inline void fec_reset_phy(struct platform_device *pdev)
 }
 #endif /* CONFIG_OF */
 
-static int __devinit
+static int
 fec_probe(struct platform_device *pdev)
 {
 	struct fec_enet_private *fep;
diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index 2933d08..817d081 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -845,7 +845,7 @@ static const struct net_device_ops mpc52xx_fec_netdev_ops = {
 /* OF Driver                                                                */
 /* ======================================================================== */
 
-static int __devinit mpc52xx_fec_probe(struct platform_device *op)
+static int mpc52xx_fec_probe(struct platform_device *op)
 {
 	int rv;
 	struct net_device *ndev;
diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 2b7633f..e9879c5 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -1004,7 +1004,7 @@ static const struct net_device_ops fs_enet_netdev_ops = {
 };
 
 static struct of_device_id fs_enet_match[];
-static int __devinit fs_enet_probe(struct platform_device *ofdev)
+static int fs_enet_probe(struct platform_device *ofdev)
 {
 	const struct of_device_id *match;
 	struct net_device *ndev;
diff --git a/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c b/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
index 1514533..3f35b6a 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
@@ -108,7 +108,7 @@ static struct mdiobb_ops bb_ops = {
 	.get_mdio_data = mdio_read,
 };
 
-static int __devinit fs_mii_bitbang_init(struct mii_bus *bus,
+static int fs_mii_bitbang_init(struct mii_bus *bus,
                                          struct device_node *np)
 {
 	struct resource res;
@@ -150,7 +150,7 @@ static int __devinit fs_mii_bitbang_init(struct mii_bus *bus,
 	return 0;
 }
 
-static int __devinit fs_enet_mdio_probe(struct platform_device *ofdev)
+static int fs_enet_mdio_probe(struct platform_device *ofdev)
 {
 	struct mii_bus *new_bus;
 	struct bb_info *bitbang;
diff --git a/drivers/net/ethernet/freescale/fs_enet/mii-fec.c b/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
index cdf702a..18e8ef2 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
@@ -102,7 +102,7 @@ static int fs_enet_fec_mii_reset(struct mii_bus *bus)
 }
 
 static struct of_device_id fs_enet_mdio_fec_match[];
-static int __devinit fs_enet_mdio_probe(struct platform_device *ofdev)
+static int fs_enet_mdio_probe(struct platform_device *ofdev)
 {
 	const struct of_device_id *match;
 	struct resource res;
diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
index 1afb5ea..ac8378b 100644
--- a/drivers/net/ethernet/freescale/xgmac_mdio.c
+++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
@@ -189,7 +189,7 @@ static int xgmac_mdio_reset(struct mii_bus *bus)
 	return ret;
 }
 
-static int __devinit xgmac_mdio_probe(struct platform_device *pdev)
+static int xgmac_mdio_probe(struct platform_device *pdev)
 {
 	struct device_node *np = pdev->dev.of_node;
 	struct mii_bus *bus;
diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index 9aba3fb..af986d6 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -308,7 +308,7 @@ static void wait(void)
  * Read board id and convert to string.
  * Effectively same code as decode_eisa_sig
  */
-static __devinit const char *hp100_read_id(int ioaddr)
+static const char *hp100_read_id(int ioaddr)
 {
 	int i;
 	static char str[HP100_SIG_LEN];
@@ -447,7 +447,7 @@ static const struct net_device_ops hp100_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int __devinit hp100_probe1(struct net_device *dev, int ioaddr,
+static int hp100_probe1(struct net_device *dev, int ioaddr,
 				  u_char bus, struct pci_dev *pci_dev)
 {
 	int i;
@@ -2884,7 +2884,7 @@ static struct eisa_driver hp100_eisa_driver = {
 #endif
 
 #ifdef CONFIG_PCI
-static int __devinit hp100_pci_probe (struct pci_dev *pdev,
+static int hp100_pci_probe (struct pci_dev *pdev,
 				     const struct pci_device_id *ent)
 {
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/i825xx/ether1.c b/drivers/net/ethernet/i825xx/ether1.c
index 75a1b57..d65dd24 100644
--- a/drivers/net/ethernet/i825xx/ether1.c
+++ b/drivers/net/ethernet/i825xx/ether1.c
@@ -250,7 +250,7 @@ ether1_readbuffer (struct net_device *dev, void *data, unsigned int start, unsig
 	} while (thislen);
 }
 
-static int __devinit
+static int
 ether1_ramtest(struct net_device *dev, unsigned char byte)
 {
 	unsigned char *buffer = kmalloc (BUFFER_SIZE, GFP_KERNEL);
@@ -304,7 +304,7 @@ ether1_reset (struct net_device *dev)
 	return BUS_16;
 }
 
-static int __devinit
+static int
 ether1_init_2(struct net_device *dev)
 {
 	int i;
@@ -972,7 +972,7 @@ ether1_setmulticastlist (struct net_device *dev)
 
 /* ------------------------------------------------------------------------- */
 
-static void __devinit ether1_banner(void)
+static void ether1_banner(void)
 {
 	static unsigned int version_printed = 0;
 
@@ -991,7 +991,7 @@ static const struct net_device_ops ether1_netdev_ops = {
 	.ndo_set_mac_address	= eth_mac_addr,
 };
 
-static int __devinit
+static int
 ether1_probe(struct expansion_card *ec, const struct ecard_id *id)
 {
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/i825xx/lasi_82596.c b/drivers/net/ethernet/i825xx/lasi_82596.c
index a79cc24..6bd7941 100644
--- a/drivers/net/ethernet/i825xx/lasi_82596.c
+++ b/drivers/net/ethernet/i825xx/lasi_82596.c
@@ -150,7 +150,7 @@ static void mpu_port(struct net_device *dev, int c, dma_addr_t x)
 
 #define LAN_PROM_ADDR	0xF0810000
 
-static int __devinit
+static int
 lan_init_chip(struct parisc_device *dev)
 {
 	struct	net_device *netdevice;
@@ -222,7 +222,7 @@ static struct parisc_driver lan_driver = {
 	.remove         = lan_remove_chip,
 };
 
-static int __devinit lasi_82596_init(void)
+static int lasi_82596_init(void)
 {
 	printk(KERN_INFO LASI_82596_DRIVER_VERSION "\n");
 	return register_parisc_driver(&lan_driver);
diff --git a/drivers/net/ethernet/i825xx/lib82596.c b/drivers/net/ethernet/i825xx/lib82596.c
index 3efbd8d..f045ea4 100644
--- a/drivers/net/ethernet/i825xx/lib82596.c
+++ b/drivers/net/ethernet/i825xx/lib82596.c
@@ -1048,7 +1048,7 @@ static const struct net_device_ops i596_netdev_ops = {
 #endif
 };
 
-static int __devinit i82596_probe(struct net_device *dev)
+static int i82596_probe(struct net_device *dev)
 {
 	int i;
 	struct i596_private *lp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/i825xx/sni_82596.c b/drivers/net/ethernet/i825xx/sni_82596.c
index 4442c6e..349b5f9 100644
--- a/drivers/net/ethernet/i825xx/sni_82596.c
+++ b/drivers/net/ethernet/i825xx/sni_82596.c
@@ -75,7 +75,7 @@ static void mpu_port(struct net_device *dev, int c, dma_addr_t x)
 }
 
 
-static int __devinit sni_82596_probe(struct platform_device *dev)
+static int sni_82596_probe(struct platform_device *dev)
 {
 	struct	net_device *netdevice;
 	struct i596_private *lp;
@@ -170,7 +170,7 @@ static struct platform_driver sni_82596_driver = {
 	},
 };
 
-static int __devinit sni_82596_init(void)
+static int sni_82596_init(void)
 {
 	printk(KERN_INFO SNI_82596_DRIVER_VERSION "\n");
 	return platform_driver_register(&sni_82596_driver);
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index f4d2da0..9fc453d 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -98,7 +98,7 @@ static struct ehea_fw_handle_array ehea_fw_handles;
 static struct ehea_bcmc_reg_array ehea_bcmc_regs;
 
 
-static int __devinit ehea_probe_adapter(struct platform_device *dev,
+static int ehea_probe_adapter(struct platform_device *dev,
 					const struct of_device_id *id);
 
 static int __devexit ehea_remove(struct platform_device *dev);
@@ -2909,7 +2909,7 @@ static ssize_t ehea_show_port_id(struct device *dev,
 static DEVICE_ATTR(log_port_id, S_IRUSR | S_IRGRP | S_IROTH, ehea_show_port_id,
 		   NULL);
 
-static void __devinit logical_port_release(struct device *dev)
+static void logical_port_release(struct device *dev)
 {
 	struct ehea_port *port = container_of(dev, struct ehea_port, ofdev.dev);
 	of_node_put(port->ofdev.dev.of_node);
@@ -3257,7 +3257,7 @@ static void ehea_remove_device_sysfs(struct platform_device *dev)
 	device_remove_file(&dev->dev, &dev_attr_remove_port);
 }
 
-static int __devinit ehea_probe_adapter(struct platform_device *dev,
+static int ehea_probe_adapter(struct platform_device *dev,
 					const struct of_device_id *id)
 {
 	struct ehea_adapter *adapter;
diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index a0fe6e3..914413f 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -2261,7 +2261,7 @@ struct emac_depentry {
 #define	EMAC_DEP_PREV_IDX	5
 #define	EMAC_DEP_COUNT		6
 
-static int __devinit emac_check_deps(struct emac_instance *dev,
+static int emac_check_deps(struct emac_instance *dev,
 				     struct emac_depentry *deps)
 {
 	int i, there = 0;
@@ -2314,7 +2314,7 @@ static void emac_put_deps(struct emac_instance *dev)
 		of_dev_put(dev->tah_dev);
 }
 
-static int __devinit emac_of_bus_notify(struct notifier_block *nb,
+static int emac_of_bus_notify(struct notifier_block *nb,
 					unsigned long action, void *data)
 {
 	/* We are only intereted in device addition */
@@ -2327,7 +2327,7 @@ static struct notifier_block emac_of_bus_notifier __devinitdata = {
 	.notifier_call = emac_of_bus_notify
 };
 
-static int __devinit emac_wait_deps(struct emac_instance *dev)
+static int emac_wait_deps(struct emac_instance *dev)
 {
 	struct emac_depentry deps[EMAC_DEP_COUNT];
 	int i, err;
@@ -2367,7 +2367,7 @@ static int __devinit emac_wait_deps(struct emac_instance *dev)
 	return err;
 }
 
-static int __devinit emac_read_uint_prop(struct device_node *np, const char *name,
+static int emac_read_uint_prop(struct device_node *np, const char *name,
 					 u32 *val, int fatal)
 {
 	int len;
@@ -2382,7 +2382,7 @@ static int __devinit emac_read_uint_prop(struct device_node *np, const char *nam
 	return 0;
 }
 
-static int __devinit emac_init_phy(struct emac_instance *dev)
+static int emac_init_phy(struct emac_instance *dev)
 {
 	struct device_node *np = dev->ofdev->dev.of_node;
 	struct net_device *ndev = dev->ndev;
@@ -2518,7 +2518,7 @@ static int __devinit emac_init_phy(struct emac_instance *dev)
 	return 0;
 }
 
-static int __devinit emac_init_config(struct emac_instance *dev)
+static int emac_init_config(struct emac_instance *dev)
 {
 	struct device_node *np = dev->ofdev->dev.of_node;
 	const void *p;
@@ -2703,7 +2703,7 @@ static const struct net_device_ops emac_gige_netdev_ops = {
 	.ndo_change_mtu		= emac_change_mtu,
 };
 
-static int __devinit emac_probe(struct platform_device *ofdev)
+static int emac_probe(struct platform_device *ofdev)
 {
 	struct net_device *ndev;
 	struct emac_instance *dev;
diff --git a/drivers/net/ethernet/ibm/emac/mal.c b/drivers/net/ethernet/ibm/emac/mal.c
index 84c6b6c..a8fded5 100644
--- a/drivers/net/ethernet/ibm/emac/mal.c
+++ b/drivers/net/ethernet/ibm/emac/mal.c
@@ -33,7 +33,7 @@
 
 static int mal_count;
 
-int __devinit mal_register_commac(struct mal_instance	*mal,
+int mal_register_commac(struct mal_instance	*mal,
 				  struct mal_commac	*commac)
 {
 	unsigned long flags;
@@ -517,7 +517,7 @@ void *mal_dump_regs(struct mal_instance *mal, void *buf)
 	return regs + 1;
 }
 
-static int __devinit mal_probe(struct platform_device *ofdev)
+static int mal_probe(struct platform_device *ofdev)
 {
 	struct mal_instance *mal;
 	int err = 0, i, bd_size;
diff --git a/drivers/net/ethernet/ibm/emac/rgmii.c b/drivers/net/ethernet/ibm/emac/rgmii.c
index d312328..8b1f02f 100644
--- a/drivers/net/ethernet/ibm/emac/rgmii.c
+++ b/drivers/net/ethernet/ibm/emac/rgmii.c
@@ -93,7 +93,7 @@ static inline u32 rgmii_mode_mask(int mode, int input)
 	}
 }
 
-int __devinit rgmii_attach(struct platform_device *ofdev, int input, int mode)
+int rgmii_attach(struct platform_device *ofdev, int input, int mode)
 {
 	struct rgmii_instance *dev = dev_get_drvdata(&ofdev->dev);
 	struct rgmii_regs __iomem *p = dev->base;
@@ -228,7 +228,7 @@ void *rgmii_dump_regs(struct platform_device *ofdev, void *buf)
 }
 
 
-static int __devinit rgmii_probe(struct platform_device *ofdev)
+static int rgmii_probe(struct platform_device *ofdev)
 {
 	struct device_node *np = ofdev->dev.of_node;
 	struct rgmii_instance *dev;
diff --git a/drivers/net/ethernet/ibm/emac/tah.c b/drivers/net/ethernet/ibm/emac/tah.c
index 872912e..a6d3144 100644
--- a/drivers/net/ethernet/ibm/emac/tah.c
+++ b/drivers/net/ethernet/ibm/emac/tah.c
@@ -23,7 +23,7 @@
 #include "emac.h"
 #include "core.h"
 
-int __devinit tah_attach(struct platform_device *ofdev, int channel)
+int tah_attach(struct platform_device *ofdev, int channel)
 {
 	struct tah_instance *dev = dev_get_drvdata(&ofdev->dev);
 
@@ -87,7 +87,7 @@ void *tah_dump_regs(struct platform_device *ofdev, void *buf)
 	return regs + 1;
 }
 
-static int __devinit tah_probe(struct platform_device *ofdev)
+static int tah_probe(struct platform_device *ofdev)
 {
 	struct device_node *np = ofdev->dev.of_node;
 	struct tah_instance *dev;
diff --git a/drivers/net/ethernet/ibm/emac/zmii.c b/drivers/net/ethernet/ibm/emac/zmii.c
index 415e9b4..f958310 100644
--- a/drivers/net/ethernet/ibm/emac/zmii.c
+++ b/drivers/net/ethernet/ibm/emac/zmii.c
@@ -82,7 +82,7 @@ static inline u32 zmii_mode_mask(int mode, int input)
 	}
 }
 
-int __devinit zmii_attach(struct platform_device *ofdev, int input, int *mode)
+int zmii_attach(struct platform_device *ofdev, int input, int *mode)
 {
 	struct zmii_instance *dev = dev_get_drvdata(&ofdev->dev);
 	struct zmii_regs __iomem *p = dev->base;
@@ -231,7 +231,7 @@ void *zmii_dump_regs(struct platform_device *ofdev, void *buf)
 	return regs + 1;
 }
 
-static int __devinit zmii_probe(struct platform_device *ofdev)
+static int zmii_probe(struct platform_device *ofdev)
 {
 	struct device_node *np = ofdev->dev.of_node;
 	struct zmii_instance *dev;
diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index b68d28a..f9fa90b 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1324,7 +1324,7 @@ static const struct net_device_ops ibmveth_netdev_ops = {
 #endif
 };
 
-static int __devinit ibmveth_probe(struct vio_dev *dev,
+static int ibmveth_probe(struct vio_dev *dev,
 				   const struct vio_device_id *id)
 {
 	int rc, i;
diff --git a/drivers/net/ethernet/icplus/ipg.c b/drivers/net/ethernet/icplus/ipg.c
index 549de0e..4558459 100644
--- a/drivers/net/ethernet/icplus/ipg.c
+++ b/drivers/net/ethernet/icplus/ipg.c
@@ -2199,7 +2199,7 @@ static const struct net_device_ops ipg_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int __devinit ipg_probe(struct pci_dev *pdev,
+static int ipg_probe(struct pci_dev *pdev,
 			       const struct pci_device_id *id)
 {
 	unsigned int i = id->driver_data;
diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index f41eaed..d0a4e2f 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2829,7 +2829,7 @@ static const struct net_device_ops e100_netdev_ops = {
 	.ndo_set_features	= e100_set_features,
 };
 
-static int __devinit e100_probe(struct pci_dev *pdev,
+static int e100_probe(struct pci_dev *pdev,
 	const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 3ca5fd3..77d8c0d 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -938,7 +938,7 @@ static int e1000_init_hw_struct(struct e1000_adapter *adapter,
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
  **/
-static int __devinit e1000_probe(struct pci_dev *pdev,
+static int e1000_probe(struct pci_dev *pdev,
 				 const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
@@ -1309,7 +1309,7 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
  * e1000_init_hw_struct MUST be called before this function
  **/
 
-static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
+static int e1000_sw_init(struct e1000_adapter *adapter)
 {
 	adapter->rx_buffer_len = MAXIMUM_ETHERNET_VLAN_SIZE;
 
@@ -1340,7 +1340,7 @@ static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
  * number of queues at compile-time.
  **/
 
-static int __devinit e1000_alloc_queues(struct e1000_adapter *adapter)
+static int e1000_alloc_queues(struct e1000_adapter *adapter)
 {
 	adapter->tx_ring = kcalloc(adapter->num_tx_queues,
 	                           sizeof(struct e1000_tx_ring), GFP_KERNEL);
diff --git a/drivers/net/ethernet/intel/e1000/e1000_param.c b/drivers/net/ethernet/intel/e1000/e1000_param.c
index 1301eba..605a0f0 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_param.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_param.c
@@ -205,7 +205,7 @@ struct e1000_option {
 	} arg;
 };
 
-static int __devinit e1000_validate_option(unsigned int *value,
+static int e1000_validate_option(unsigned int *value,
 					   const struct e1000_option *opt,
 					   struct e1000_adapter *adapter)
 {
@@ -268,7 +268,7 @@ static void e1000_check_copper_options(struct e1000_adapter *adapter);
  * in a variable in the adapter structure.
  **/
 
-void __devinit e1000_check_options(struct e1000_adapter *adapter)
+void e1000_check_options(struct e1000_adapter *adapter)
 {
 	struct e1000_option opt;
 	int bd = adapter->bd_number;
@@ -534,7 +534,7 @@ void __devinit e1000_check_options(struct e1000_adapter *adapter)
  * Handles speed and duplex options on fiber adapters
  **/
 
-static void __devinit e1000_check_fiber_options(struct e1000_adapter *adapter)
+static void e1000_check_fiber_options(struct e1000_adapter *adapter)
 {
 	int bd = adapter->bd_number;
 	if (num_Speed > bd) {
@@ -560,7 +560,7 @@ static void __devinit e1000_check_fiber_options(struct e1000_adapter *adapter)
  * Handles speed and duplex options on copper adapters
  **/
 
-static void __devinit e1000_check_copper_options(struct e1000_adapter *adapter)
+static void e1000_check_copper_options(struct e1000_adapter *adapter)
 {
 	struct e1000_option opt;
 	unsigned int speed, dplx, an;
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 2f5bfd3..5dc54df 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -2517,7 +2517,7 @@ void e1000e_write_itr(struct e1000_adapter *adapter, u32 itr)
  * e1000_alloc_queues - Allocate memory for all rings
  * @adapter: board private structure to initialize
  **/
-static int __devinit e1000_alloc_queues(struct e1000_adapter *adapter)
+static int e1000_alloc_queues(struct e1000_adapter *adapter)
 {
 	int size = sizeof(struct e1000_ring);
 
@@ -3715,7 +3715,7 @@ void e1000e_reinit_locked(struct e1000_adapter *adapter)
  * Fields are initialized based on PCI device information and
  * OS network device settings (MTU size).
  **/
-static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
+static int e1000_sw_init(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 
@@ -6094,7 +6094,7 @@ static const struct net_device_ops e1000e_netdev_ops = {
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
  **/
-static int __devinit e1000_probe(struct pci_dev *pdev,
+static int e1000_probe(struct pci_dev *pdev,
 				 const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/intel/e1000e/param.c b/drivers/net/ethernet/intel/e1000e/param.c
index dfbfa7f..62bf36c 100644
--- a/drivers/net/ethernet/intel/e1000e/param.c
+++ b/drivers/net/ethernet/intel/e1000e/param.c
@@ -186,7 +186,7 @@ struct e1000_option {
 	} arg;
 };
 
-static int __devinit e1000_validate_option(unsigned int *value,
+static int e1000_validate_option(unsigned int *value,
 					   const struct e1000_option *opt,
 					   struct e1000_adapter *adapter)
 {
@@ -249,7 +249,7 @@ static int __devinit e1000_validate_option(unsigned int *value,
  * value exists, a default value is used.  The final value is stored
  * in a variable in the adapter structure.
  **/
-void __devinit e1000e_check_options(struct e1000_adapter *adapter)
+void e1000e_check_options(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	int bd = adapter->bd_number;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index fdb2282..b5557cb 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1825,7 +1825,7 @@ void igb_set_fw_version(struct igb_adapter *adapter)
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
  **/
-static int __devinit igb_probe(struct pci_dev *pdev,
+static int igb_probe(struct pci_dev *pdev,
 			       const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
@@ -2266,7 +2266,7 @@ static void __devexit igb_remove(struct pci_dev *pdev)
  * mor expensive time wise to disable SR-IOV than it is to allocate and free
  * the memory for the VFs.
  **/
-static void __devinit igb_probe_vfs(struct igb_adapter * adapter)
+static void igb_probe_vfs(struct igb_adapter * adapter)
 {
 #ifdef CONFIG_PCI_IOV
 	struct pci_dev *pdev = adapter->pdev;
@@ -2327,7 +2327,7 @@ out:
  * Fields are initialized based on PCI device information and
  * OS network device settings (MTU size).
  **/
-static int __devinit igb_sw_init(struct igb_adapter *adapter)
+static int igb_sw_init(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 935173a..6124032 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1091,7 +1091,7 @@ out:
  * igbvf_alloc_queues - Allocate memory for all rings
  * @adapter: board private structure to initialize
  **/
-static int __devinit igbvf_alloc_queues(struct igbvf_adapter *adapter)
+static int igbvf_alloc_queues(struct igbvf_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 
@@ -1543,7 +1543,7 @@ void igbvf_reinit_locked(struct igbvf_adapter *adapter)
  * Fields are initialized based on PCI device information and
  * OS network device settings (MTU size).
  **/
-static int __devinit igbvf_sw_init(struct igbvf_adapter *adapter)
+static int igbvf_sw_init(struct igbvf_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	s32 rc;
@@ -2611,7 +2611,7 @@ static const struct net_device_ops igbvf_netdev_ops = {
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
  **/
-static int __devinit igbvf_probe(struct pci_dev *pdev,
+static int igbvf_probe(struct pci_dev *pdev,
                                  const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 5b44d8a..407e226 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -391,7 +391,7 @@ static const struct net_device_ops ixgb_netdev_ops = {
  * and a hardware reset occur.
  **/
 
-static int __devinit
+static int
 ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev = NULL;
@@ -584,7 +584,7 @@ ixgb_remove(struct pci_dev *pdev)
  * OS network device settings (MTU size).
  **/
 
-static int __devinit
+static int
 ixgb_sw_init(struct ixgb_adapter *adapter)
 {
 	struct ixgb_hw *hw = &adapter->hw;
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_param.c b/drivers/net/ethernet/intel/ixgb/ixgb_param.c
index 07d83ab..4f3a9aa 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_param.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_param.c
@@ -199,7 +199,7 @@ struct ixgb_option {
 	} arg;
 };
 
-static int __devinit
+static int
 ixgb_validate_option(unsigned int *value, const struct ixgb_option *opt)
 {
 	if (*value == OPTION_UNSET) {
@@ -257,7 +257,7 @@ ixgb_validate_option(unsigned int *value, const struct ixgb_option *opt)
  * in a variable in the adapter structure.
  **/
 
-void __devinit
+void
 ixgb_check_options(struct ixgb_adapter *adapter)
 {
 	int bd = adapter->bd_number;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 4258ffa..0125ffa 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4456,7 +4456,7 @@ static void ixgbe_tx_timeout(struct net_device *netdev)
  * Fields are initialized based on PCI device information and
  * OS network device settings (MTU size).
  **/
-static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
+static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
@@ -7171,7 +7171,7 @@ int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
  **/
-static int __devinit ixgbe_probe(struct pci_dev *pdev,
+static int ixgbe_probe(struct pci_dev *pdev,
 				 const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index da8b116..b8fbdab 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2030,7 +2030,7 @@ static void ixgbevf_clear_interrupt_scheme(struct ixgbevf_adapter *adapter)
  * Fields are initialized based on PCI device information and
  * OS network device settings (MTU size).
  **/
-static int __devinit ixgbevf_sw_init(struct ixgbevf_adapter *adapter)
+static int ixgbevf_sw_init(struct ixgbevf_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
@@ -3267,7 +3267,7 @@ static void ixgbevf_assign_netdev_ops(struct net_device *dev)
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
  **/
-static int __devinit ixgbevf_probe(struct pci_dev *pdev,
+static int ixgbevf_probe(struct pci_dev *pdev,
 				   const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 939cddc..768023c 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -2961,7 +2961,7 @@ static const struct net_device_ops jme_netdev_ops = {
 #endif
 };
 
-static int __devinit
+static int
 jme_init_one(struct pci_dev *pdev,
 	     const struct pci_device_id *ent)
 {
diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 0912768..79b7bbd 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -3860,7 +3860,7 @@ static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 	return dev;
 }
 
-static void __devinit skge_show_addr(struct net_device *dev)
+static void skge_show_addr(struct net_device *dev)
 {
 	const struct skge_port *skge = netdev_priv(dev);
 
@@ -3869,7 +3869,7 @@ static void __devinit skge_show_addr(struct net_device *dev)
 
 static int only_32bit_dma;
 
-static int __devinit skge_probe(struct pci_dev *pdev,
+static int skge_probe(struct pci_dev *pdev,
 				const struct pci_device_id *ent)
 {
 	struct net_device *dev, *dev1;
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 3c6314f..07d195f 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -3140,7 +3140,7 @@ static inline u32 sky2_clk2us(const struct sky2_hw *hw, u32 clk)
 }
 
 
-static int __devinit sky2_init(struct sky2_hw *hw)
+static int sky2_init(struct sky2_hw *hw)
 {
 	u8 t8;
 
@@ -4741,7 +4741,7 @@ static const struct net_device_ops sky2_netdev_ops[2] = {
 };
 
 /* Initialize network device */
-static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
+static struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 						     unsigned port,
 						     int highmem, int wol)
 {
@@ -4807,7 +4807,7 @@ static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 	return dev;
 }
 
-static void __devinit sky2_show_addr(struct net_device *dev)
+static void sky2_show_addr(struct net_device *dev)
 {
 	const struct sky2_port *sky2 = netdev_priv(dev);
 
@@ -4815,7 +4815,7 @@ static void __devinit sky2_show_addr(struct net_device *dev)
 }
 
 /* Handle software interrupt used during MSI test */
-static irqreturn_t __devinit sky2_test_intr(int irq, void *dev_id)
+static irqreturn_t sky2_test_intr(int irq, void *dev_id)
 {
 	struct sky2_hw *hw = dev_id;
 	u32 status = sky2_read32(hw, B0_Y2_SP_ISRC2);
@@ -4834,7 +4834,7 @@ static irqreturn_t __devinit sky2_test_intr(int irq, void *dev_id)
 }
 
 /* Test interrupt path by forcing a a software IRQ */
-static int __devinit sky2_test_msi(struct sky2_hw *hw)
+static int sky2_test_msi(struct sky2_hw *hw)
 {
 	struct pci_dev *pdev = hw->pdev;
 	int err;
@@ -4896,7 +4896,7 @@ static const char *sky2_name(u8 chipid, char *buf, int sz)
 	return buf;
 }
 
-static int __devinit sky2_probe(struct pci_dev *pdev,
+static int sky2_probe(struct pci_dev *pdev,
 				const struct pci_device_id *ent)
 {
 	struct net_device *dev, *dev1;
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 877b74a..8f744f0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2224,7 +2224,7 @@ err_disable_pdev:
 	return err;
 }
 
-static int __devinit mlx4_init_one(struct pci_dev *pdev,
+static int mlx4_init_one(struct pci_dev *pdev,
 				   const struct pci_device_id *id)
 {
 	printk_once(KERN_INFO "%s", mlx4_version);
diff --git a/drivers/net/ethernet/micrel/ks8695net.c b/drivers/net/ethernet/micrel/ks8695net.c
index 786cc0f..7ac240d 100644
--- a/drivers/net/ethernet/micrel/ks8695net.c
+++ b/drivers/net/ethernet/micrel/ks8695net.c
@@ -1277,7 +1277,7 @@ ks8695_open(struct net_device *ndev)
  *	This initialises the LAN switch in the KS8695 to a known-good
  *	set of defaults.
  */
-static void __devinit
+static void
 ks8695_init_switch(struct ks8695_priv *ksp)
 {
 	u32 ctrl;
@@ -1305,7 +1305,7 @@ ks8695_init_switch(struct ks8695_priv *ksp)
  *	This initialises a KS8695's WAN phy to sensible values for
  *	autonegotiation etc.
  */
-static void __devinit
+static void
 ks8695_init_wan_phy(struct ks8695_priv *ksp)
 {
 	u32 ctrl;
@@ -1349,7 +1349,7 @@ static const struct net_device_ops ks8695_netdev_ops = {
  *	wan ports, and an IORESOURCE_IRQ for the link IRQ for the wan
  *	port.
  */
-static int __devinit
+static int
 ks8695_probe(struct platform_device *pdev)
 {
 	struct ks8695_priv *ksp;
diff --git a/drivers/net/ethernet/micrel/ks8842.c b/drivers/net/ethernet/micrel/ks8842.c
index f84dd2d..a23b534 100644
--- a/drivers/net/ethernet/micrel/ks8842.c
+++ b/drivers/net/ethernet/micrel/ks8842.c
@@ -1141,7 +1141,7 @@ static const struct ethtool_ops ks8842_ethtool_ops = {
 	.get_link		= ethtool_op_get_link,
 };
 
-static int __devinit ks8842_probe(struct platform_device *pdev)
+static int ks8842_probe(struct platform_device *pdev)
 {
 	int err = -ENOMEM;
 	struct resource *iomem;
diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index a1f7d7d..dbd2ece 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1415,7 +1415,7 @@ static int ks8851_resume(struct spi_device *spi)
 #define ks8851_resume NULL
 #endif
 
-static int __devinit ks8851_probe(struct spi_device *spi)
+static int ks8851_probe(struct spi_device *spi)
 {
 	struct net_device *ndev;
 	struct ks8851_net *ks;
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index 80fe0b3..2070af2 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -1506,7 +1506,7 @@ static int ks_hw_init(struct ks_net *ks)
 }
 
 
-static int __devinit ks8851_probe(struct platform_device *pdev)
+static int ks8851_probe(struct platform_device *pdev)
 {
 	int err = -ENOMEM;
 	struct resource *io_d, *io_c;
diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index e4ba868..2f4d051 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -6917,7 +6917,7 @@ static void read_other_addr(struct ksz_hw *hw)
 #define PCI_VENDOR_ID_MICREL_KS		0x16c6
 #endif
 
-static int __devinit pcidev_init(struct pci_dev *pdev,
+static int pcidev_init(struct pci_dev *pdev,
 	const struct pci_device_id *id)
 {
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/microchip/enc28j60.c b/drivers/net/ethernet/microchip/enc28j60.c
index 1373b02..2851829 100644
--- a/drivers/net/ethernet/microchip/enc28j60.c
+++ b/drivers/net/ethernet/microchip/enc28j60.c
@@ -1541,7 +1541,7 @@ static const struct net_device_ops enc28j60_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int __devinit enc28j60_probe(struct spi_device *spi)
+static int enc28j60_probe(struct spi_device *spi)
 {
 	struct net_device *dev;
 	struct enc28j60_net *priv;
diff --git a/drivers/net/ethernet/natsemi/ibmlana.c b/drivers/net/ethernet/natsemi/ibmlana.c
index 3f94ddb..076bc45 100644
--- a/drivers/net/ethernet/natsemi/ibmlana.c
+++ b/drivers/net/ethernet/natsemi/ibmlana.c
@@ -916,7 +916,7 @@ static const struct net_device_ops ibmlana_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int __devinit ibmlana_init_one(struct device *kdev)
+static int ibmlana_init_one(struct device *kdev)
 {
 	struct mca_device *mdev = to_mca_device(kdev);
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/natsemi/jazzsonic.c b/drivers/net/ethernet/natsemi/jazzsonic.c
index 1b2ed23..90c6670 100644
--- a/drivers/net/ethernet/natsemi/jazzsonic.c
+++ b/drivers/net/ethernet/natsemi/jazzsonic.c
@@ -117,7 +117,7 @@ static const struct net_device_ops sonic_netdev_ops = {
 	.ndo_set_mac_address	= eth_mac_addr,
 };
 
-static int __devinit sonic_probe1(struct net_device *dev)
+static int sonic_probe1(struct net_device *dev)
 {
 	static unsigned version_printed;
 	unsigned int silicon_revision;
@@ -220,7 +220,7 @@ out:
  * Probe for a SONIC ethernet controller on a Mips Jazz board.
  * Actually probing is superfluous but we're paranoid.
  */
-static int __devinit jazz_sonic_probe(struct platform_device *pdev)
+static int jazz_sonic_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct sonic_local *lp;
diff --git a/drivers/net/ethernet/natsemi/macsonic.c b/drivers/net/ethernet/natsemi/macsonic.c
index 1d6a789..a7d07c4 100644
--- a/drivers/net/ethernet/natsemi/macsonic.c
+++ b/drivers/net/ethernet/natsemi/macsonic.c
@@ -196,7 +196,7 @@ static const struct net_device_ops macsonic_netdev_ops = {
 	.ndo_set_mac_address	= eth_mac_addr,
 };
 
-static int __devinit macsonic_init(struct net_device *dev)
+static int macsonic_init(struct net_device *dev)
 {
 	struct sonic_local* lp = netdev_priv(dev);
 
@@ -245,7 +245,7 @@ static int __devinit macsonic_init(struct net_device *dev)
                           memcmp(mac, "\x00\x80\x19", 3) && \
                           memcmp(mac, "\x00\x05\x02", 3))
 
-static void __devinit mac_onboard_sonic_ethernet_addr(struct net_device *dev)
+static void mac_onboard_sonic_ethernet_addr(struct net_device *dev)
 {
 	struct sonic_local *lp = netdev_priv(dev);
 	const int prom_addr = ONBOARD_SONIC_PROM_BASE;
@@ -309,7 +309,7 @@ static void __devinit mac_onboard_sonic_ethernet_addr(struct net_device *dev)
 	eth_hw_addr_random(dev);
 }
 
-static int __devinit mac_onboard_sonic_probe(struct net_device *dev)
+static int mac_onboard_sonic_probe(struct net_device *dev)
 {
 	struct sonic_local* lp = netdev_priv(dev);
 	int sr;
@@ -420,7 +420,7 @@ static int __devinit mac_onboard_sonic_probe(struct net_device *dev)
 	return macsonic_init(dev);
 }
 
-static int __devinit mac_nubus_sonic_ethernet_addr(struct net_device *dev,
+static int mac_nubus_sonic_ethernet_addr(struct net_device *dev,
 						unsigned long prom_addr,
 						int id)
 {
@@ -435,7 +435,7 @@ static int __devinit mac_nubus_sonic_ethernet_addr(struct net_device *dev,
 	return 0;
 }
 
-static int __devinit macsonic_ident(struct nubus_dev *ndev)
+static int macsonic_ident(struct nubus_dev *ndev)
 {
 	if (ndev->dr_hw == NUBUS_DRHW_ASANTE_LC &&
 	    ndev->dr_sw == NUBUS_DRSW_SONIC_LC)
@@ -460,7 +460,7 @@ static int __devinit macsonic_ident(struct nubus_dev *ndev)
 	return -1;
 }
 
-static int __devinit mac_nubus_sonic_probe(struct net_device *dev)
+static int mac_nubus_sonic_probe(struct net_device *dev)
 {
 	static int slots;
 	struct nubus_dev* ndev = NULL;
@@ -573,7 +573,7 @@ static int __devinit mac_nubus_sonic_probe(struct net_device *dev)
 	return macsonic_init(dev);
 }
 
-static int __devinit mac_sonic_probe(struct platform_device *pdev)
+static int mac_sonic_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct sonic_local *lp;
diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index 119930b..63b94c3 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -742,7 +742,7 @@ static void move_int_phy(struct net_device *dev, int addr)
 	udelay(1);
 }
 
-static void __devinit natsemi_init_media (struct net_device *dev)
+static void natsemi_init_media (struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	u32 tmp;
@@ -797,7 +797,7 @@ static const struct net_device_ops natsemi_netdev_ops = {
 #endif
 };
 
-static int __devinit natsemi_probe1 (struct pci_dev *pdev,
+static int natsemi_probe1 (struct pci_dev *pdev,
 	const struct pci_device_id *ent)
 {
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index 70ec426..0131b18 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -1941,7 +1941,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_tx_timeout		= ns83820_tx_timeout,
 };
 
-static int __devinit ns83820_init_one(struct pci_dev *pci_dev,
+static int ns83820_init_one(struct pci_dev *pci_dev,
 				      const struct pci_device_id *id)
 {
 	struct net_device *ndev;
diff --git a/drivers/net/ethernet/natsemi/xtsonic.c b/drivers/net/ethernet/natsemi/xtsonic.c
index 9bc1fc7..c265a5e 100644
--- a/drivers/net/ethernet/natsemi/xtsonic.c
+++ b/drivers/net/ethernet/natsemi/xtsonic.c
@@ -249,7 +249,7 @@ out:
  * Actually probing is superfluous but we're paranoid.
  */
 
-int __devinit xtsonic_probe(struct platform_device *pdev)
+int xtsonic_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct sonic_local *lp;
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 0c8742a..1b70a92 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -7702,7 +7702,7 @@ static const struct net_device_ops s2io_netdev_ops = {
  *  returns 0 on success and negative on failure.
  */
 
-static int __devinit
+static int
 s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 {
 	struct s2io_nic *sp;
diff --git a/drivers/net/ethernet/neterion/s2io.h b/drivers/net/ethernet/neterion/s2io.h
index d559692..304124a61 100644
--- a/drivers/net/ethernet/neterion/s2io.h
+++ b/drivers/net/ethernet/neterion/s2io.h
@@ -1075,7 +1075,7 @@ static inline void SPECIAL_REG_WRITE(u64 val, void __iomem *addr, int order)
 /*
  * Prototype declaration.
  */
-static int __devinit s2io_init_nic(struct pci_dev *pdev,
+static int s2io_init_nic(struct pci_dev *pdev,
 				   const struct pci_device_id *pre);
 static void __devexit s2io_rem_nic(struct pci_dev *pdev);
 static int init_shared_mem(struct s2io_nic *sp);
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-config.c b/drivers/net/ethernet/neterion/vxge/vxge-config.c
index c2e420a..fbe5363 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-config.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-config.c
@@ -993,7 +993,7 @@ exit:
  * for the driver, FW version information, and the first mac address for
  * each vpath
  */
-enum vxge_hw_status __devinit
+enum vxge_hw_status
 vxge_hw_device_hw_info_get(void __iomem *bar0,
 			   struct vxge_hw_device_hw_info *hw_info)
 {
@@ -1310,7 +1310,7 @@ __vxge_hw_device_config_check(struct vxge_hw_device_config *new_config)
  * When done, the driver allocates sizeof(struct __vxge_hw_device) bytes for HW
  * to enable the latter to perform Titan hardware initialization.
  */
-enum vxge_hw_status __devinit
+enum vxge_hw_status
 vxge_hw_device_initialize(
 	struct __vxge_hw_device **devh,
 	struct vxge_hw_device_attr *attr,
@@ -2917,7 +2917,7 @@ exit:
  * vxge_hw_device_config_default_get - Initialize device config with defaults.
  * Initialize Titan device config with default values.
  */
-enum vxge_hw_status __devinit
+enum vxge_hw_status
 vxge_hw_device_config_default_get(struct vxge_hw_device_config *device_config)
 {
 	u32 i;
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-config.h b/drivers/net/ethernet/neterion/vxge/vxge-config.h
index 9e0c1ee..6ce4412 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-config.h
+++ b/drivers/net/ethernet/neterion/vxge/vxge-config.h
@@ -1846,11 +1846,11 @@ struct vxge_hw_vpath_attr {
 	struct vxge_hw_fifo_attr	fifo_attr;
 };
 
-enum vxge_hw_status __devinit vxge_hw_device_hw_info_get(
+enum vxge_hw_status vxge_hw_device_hw_info_get(
 	void __iomem *bar0,
 	struct vxge_hw_device_hw_info *hw_info);
 
-enum vxge_hw_status __devinit vxge_hw_device_config_default_get(
+enum vxge_hw_status vxge_hw_device_config_default_get(
 	struct vxge_hw_device_config *device_config);
 
 /**
@@ -1877,7 +1877,7 @@ u16 vxge_hw_device_link_width_get(struct __vxge_hw_device *devh);
 const u8 *
 vxge_hw_device_product_name_get(struct __vxge_hw_device *devh);
 
-enum vxge_hw_status __devinit vxge_hw_device_initialize(
+enum vxge_hw_status vxge_hw_device_initialize(
 	struct __vxge_hw_device **devh,
 	struct vxge_hw_device_attr *attr,
 	struct vxge_hw_device_config *device_config);
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 4af32a3..2e3a3f0 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -3371,7 +3371,7 @@ static const struct net_device_ops vxge_netdev_ops = {
 #endif
 };
 
-static int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
+static int vxge_device_register(struct __vxge_hw_device *hldev,
 					  struct vxge_config *config,
 					  int high_dma, int no_of_vpath,
 					  struct vxgedev **vdev_out)
@@ -3672,7 +3672,7 @@ static void verify_bandwidth(void)
 /*
  * Vpath configuration
  */
-static int __devinit vxge_config_vpaths(
+static int vxge_config_vpaths(
 			struct vxge_hw_device_config *device_config,
 			u64 vpath_mask, struct vxge_config *config_param)
 {
@@ -3859,7 +3859,7 @@ static int __devinit vxge_config_vpaths(
 }
 
 /* initialize device configuratrions */
-static void __devinit vxge_device_config_init(
+static void vxge_device_config_init(
 				struct vxge_hw_device_config *device_config,
 				int *intr_type)
 {
@@ -3912,7 +3912,7 @@ static void __devinit vxge_device_config_init(
 			device_config->rth_it_type);
 }
 
-static void __devinit vxge_print_parm(struct vxgedev *vdev, u64 vpath_mask)
+static void vxge_print_parm(struct vxgedev *vdev, u64 vpath_mask)
 {
 	int i;
 
@@ -4269,7 +4269,7 @@ static int vxge_probe_fw_update(struct vxgedev *vdev)
 	return ret;
 }
 
-static int __devinit is_sriov_initialized(struct pci_dev *pdev)
+static int is_sriov_initialized(struct pci_dev *pdev)
 {
 	int pos;
 	u16 ctrl;
@@ -4300,7 +4300,7 @@ static const struct vxge_hw_uld_cbs vxge_callbacks = {
  * returns 0 on success and negative on failure.
  *
  */
-static int __devinit
+static int
 vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 {
 	struct __vxge_hw_device *hldev;
diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index fceec55..ea74f34 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -978,7 +978,7 @@ static int w90p910_ether_setup(struct net_device *dev)
 	return 0;
 }
 
-static int __devinit w90p910_ether_probe(struct platform_device *pdev)
+static int w90p910_ether_probe(struct platform_device *pdev)
 {
 	struct w90p910_ether *ether;
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 7f89407..fb64c04 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -5520,7 +5520,7 @@ static const struct net_device_ops nv_netdev_ops_optimized = {
 #endif
 };
 
-static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
+static int nv_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 {
 	struct net_device *dev;
 	struct fe_priv *np;
diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index 5fca4a2..ea88571 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -1419,7 +1419,7 @@ static const struct net_device_ops octeon_mgmt_ops = {
 #endif
 };
 
-static int __devinit octeon_mgmt_probe(struct platform_device *pdev)
+static int octeon_mgmt_probe(struct platform_device *pdev)
 {
 	struct net_device *netdev;
 	struct octeon_mgmt *p;
diff --git a/drivers/net/ethernet/packetengines/hamachi.c b/drivers/net/ethernet/packetengines/hamachi.c
index 9664732..628de39 100644
--- a/drivers/net/ethernet/packetengines/hamachi.c
+++ b/drivers/net/ethernet/packetengines/hamachi.c
@@ -576,7 +576,7 @@ static const struct net_device_ops hamachi_netdev_ops = {
 };
 
 
-static int __devinit hamachi_init_one (struct pci_dev *pdev,
+static int hamachi_init_one (struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
 {
 	struct hamachi_private *hmp;
@@ -791,7 +791,7 @@ err_out:
 	return ret;
 }
 
-static int __devinit read_eeprom(void __iomem *ioaddr, int location)
+static int read_eeprom(void __iomem *ioaddr, int location)
 {
 	int bogus_cnt = 1000;
 
diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
index aec57c0..3037a60 100644
--- a/drivers/net/ethernet/packetengines/yellowfin.c
+++ b/drivers/net/ethernet/packetengines/yellowfin.c
@@ -367,7 +367,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_tx_timeout 	= yellowfin_tx_timeout,
 };
 
-static int __devinit yellowfin_init_one(struct pci_dev *pdev,
+static int yellowfin_init_one(struct pci_dev *pdev,
 					const struct pci_device_id *ent)
 {
 	struct net_device *dev;
@@ -522,7 +522,7 @@ err_out_free_netdev:
 	return -ENODEV;
 }
 
-static int __devinit read_eeprom(void __iomem *ioaddr, int location)
+static int read_eeprom(void __iomem *ioaddr, int location)
 {
 	int bogus_cnt = 10000;		/* Typical 33Mhz: 1050 ticks */
 
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index 07943a3..7620755 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -1727,7 +1727,7 @@ static const struct net_device_ops pasemi_netdev_ops = {
 #endif
 };
 
-static int __devinit
+static int
 pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index f0546b0..b36aa37 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -60,7 +60,7 @@ static int auto_fw_reset = AUTO_FW_RESET_ENABLED;
 module_param(auto_fw_reset, int, 0644);
 MODULE_PARM_DESC(auto_fw_reset,"Auto firmware reset (0=disabled, 1=enabled");
 
-static int __devinit netxen_nic_probe(struct pci_dev *pdev,
+static int netxen_nic_probe(struct pci_dev *pdev,
 		const struct pci_device_id *ent);
 static void __devexit netxen_nic_remove(struct pci_dev *pdev);
 static int netxen_nic_open(struct net_device *netdev);
@@ -1397,7 +1397,7 @@ static void netxen_mask_aer_correctable(struct netxen_adapter *adapter)
 }
 #endif
 
-static int __devinit
+static int
 netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev = NULL;
diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index 506c72f..2528502 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -3769,7 +3769,7 @@ static const struct net_device_ops ql3xxx_netdev_ops = {
 	.ndo_tx_timeout		= ql3xxx_tx_timeout,
 };
 
-static int __devinit ql3xxx_probe(struct pci_dev *pdev,
+static int ql3xxx_probe(struct pci_dev *pdev,
 				  const struct pci_device_id *pci_entry)
 {
 	struct net_device *ndev = NULL;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index e553684..8d623aa 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -54,7 +54,7 @@ static int qlcnic_config_npars;
 module_param(qlcnic_config_npars, int, 0444);
 MODULE_PARM_DESC(qlcnic_config_npars, "Configure NPARs (0=disabled, 1=enabled");
 
-static int __devinit qlcnic_probe(struct pci_dev *pdev,
+static int qlcnic_probe(struct pci_dev *pdev,
 		const struct pci_device_id *ent);
 static void __devexit qlcnic_remove(struct pci_dev *pdev);
 static int qlcnic_open(struct net_device *netdev);
@@ -1559,7 +1559,7 @@ qlcnic_alloc_msix_entries(struct qlcnic_adapter *adapter, u16 count)
 	return -ENOMEM;
 }
 
-static int __devinit
+static int
 qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev = NULL;
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index a576a8d2..372040d 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -4491,7 +4491,7 @@ static void ql_release_all(struct pci_dev *pdev)
 	pci_set_drvdata(pdev, NULL);
 }
 
-static int __devinit ql_init_device(struct pci_dev *pdev,
+static int ql_init_device(struct pci_dev *pdev,
 				    struct net_device *ndev, int cards_found)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
@@ -4656,7 +4656,7 @@ static void ql_timer(unsigned long data)
 	mod_timer(&qdev->timer, jiffies + (5*HZ));
 }
 
-static int __devinit qlge_probe(struct pci_dev *pdev,
+static int qlge_probe(struct pci_dev *pdev,
 				const struct pci_device_id *pci_entry)
 {
 	struct net_device *ndev = NULL;
diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 4e91e18..f0bba8c 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1073,7 +1073,7 @@ static int r6040_mii_probe(struct net_device *dev)
 	return 0;
 }
 
-static int __devinit r6040_init_one(struct pci_dev *pdev,
+static int r6040_init_one(struct pci_dev *pdev,
 					 const struct pci_device_id *ent)
 {
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 59d8d70..ccae0d7 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -748,7 +748,7 @@ static void rtl8139_chip_reset (void __iomem *ioaddr)
 }
 
 
-static __devinit struct net_device * rtl8139_init_board (struct pci_dev *pdev)
+static struct net_device * rtl8139_init_board (struct pci_dev *pdev)
 {
 	struct device *d = &pdev->dev;
 	void __iomem *ioaddr;
@@ -935,7 +935,7 @@ static const struct net_device_ops rtl8139_netdev_ops = {
 	.ndo_set_features	= rtl8139_set_features,
 };
 
-static int __devinit rtl8139_init_one (struct pci_dev *pdev,
+static int rtl8139_init_one (struct pci_dev *pdev,
 				       const struct pci_device_id *ent)
 {
 	struct net_device *dev = NULL;
@@ -1141,7 +1141,7 @@ static void __devexit rtl8139_remove_one (struct pci_dev *pdev)
 #define EE_READ_CMD		(6)
 #define EE_ERASE_CMD	(7)
 
-static int __devinit read_eeprom (void __iomem *ioaddr, int location, int addr_len)
+static int read_eeprom (void __iomem *ioaddr, int location, int addr_len)
 {
 	int i;
 	unsigned retval = 0;
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 1a01b9f..b8f2737 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3828,7 +3828,7 @@ static void rtl_disable_msi(struct pci_dev *pdev, struct rtl8169_private *tp)
 	}
 }
 
-static void __devinit rtl_init_mdio_ops(struct rtl8169_private *tp)
+static void rtl_init_mdio_ops(struct rtl8169_private *tp)
 {
 	struct mdio_ops *ops = &tp->mdio_ops;
 
@@ -4080,7 +4080,7 @@ static void rtl_pll_power_up(struct rtl8169_private *tp)
 	rtl_generic_op(tp, tp->pll_power_ops.up);
 }
 
-static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
+static void rtl_init_pll_power_ops(struct rtl8169_private *tp)
 {
 	struct pll_power_ops *ops = &tp->pll_power_ops;
 
@@ -4274,7 +4274,7 @@ static void r8168b_1_hw_jumbo_disable(struct rtl8169_private *tp)
 	RTL_W8(Config4, RTL_R8(Config4) & ~(1 << 0));
 }
 
-static void __devinit rtl_init_jumbo_ops(struct rtl8169_private *tp)
+static void rtl_init_jumbo_ops(struct rtl8169_private *tp)
 {
 	struct jumbo_ops *ops = &tp->jumbo_ops;
 
@@ -4715,7 +4715,7 @@ static u32 r8402_csi_read(struct rtl8169_private *tp, int addr)
 		RTL_R32(CSIDR) : ~0;
 }
 
-static void __devinit rtl_init_csi_ops(struct rtl8169_private *tp)
+static void rtl_init_csi_ops(struct rtl8169_private *tp)
 {
 	struct csi_ops *ops = &tp->csi_ops;
 
@@ -6730,7 +6730,7 @@ DECLARE_RTL_COND(rtl_rxtx_empty_cond)
 	return (RTL_R8(MCU) & RXTX_EMPTY) == RXTX_EMPTY;
 }
 
-static void __devinit rtl_hw_init_8168g(struct rtl8169_private *tp)
+static void rtl_hw_init_8168g(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 	u32 data;
@@ -6764,7 +6764,7 @@ static void __devinit rtl_hw_init_8168g(struct rtl8169_private *tp)
 		return;
 }
 
-static void __devinit rtl_hw_initialize(struct rtl8169_private *tp)
+static void rtl_hw_initialize(struct rtl8169_private *tp)
 {
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_40:
@@ -6777,7 +6777,7 @@ static void __devinit rtl_hw_initialize(struct rtl8169_private *tp)
 	}
 }
 
-static int __devinit
+static int
 rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	const struct rtl_cfg_info *cfg = rtl_cfg_infos + ent->driver_data;
diff --git a/drivers/net/ethernet/s6gmac.c b/drivers/net/ethernet/s6gmac.c
index 988e27d..2707d75 100644
--- a/drivers/net/ethernet/s6gmac.c
+++ b/drivers/net/ethernet/s6gmac.c
@@ -954,7 +954,7 @@ static struct net_device_stats *s6gmac_stats(struct net_device *dev)
 	return st;
 }
 
-static int __devinit s6gmac_probe(struct platform_device *pdev)
+static int s6gmac_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct s6gmac *pd;
diff --git a/drivers/net/ethernet/seeq/ether3.c b/drivers/net/ethernet/seeq/ether3.c
index 0baae6a..d968f7b 100644
--- a/drivers/net/ethernet/seeq/ether3.c
+++ b/drivers/net/ethernet/seeq/ether3.c
@@ -194,7 +194,7 @@ static inline void ether3_ledon(struct net_device *dev)
  * Read the ethernet address string from the on board rom.
  * This is an ascii string!!!
  */
-static int __devinit
+static int
 ether3_addr(char *addr, struct expansion_card *ec)
 {
 	struct in_chunk_dir cd;
@@ -219,7 +219,7 @@ ether3_addr(char *addr, struct expansion_card *ec)
 
 /* --------------------------------------------------------------------------- */
 
-static int __devinit
+static int
 ether3_ramtest(struct net_device *dev, unsigned char byte)
 {
 	unsigned char *buffer = kmalloc(RX_END, GFP_KERNEL);
@@ -268,7 +268,7 @@ ether3_ramtest(struct net_device *dev, unsigned char byte)
 
 /* ------------------------------------------------------------------------------- */
 
-static int __devinit ether3_init_2(struct net_device *dev)
+static int ether3_init_2(struct net_device *dev)
 {
 	int i;
 
@@ -748,7 +748,7 @@ static void ether3_tx(struct net_device *dev)
 	}
 }
 
-static void __devinit ether3_banner(void)
+static void ether3_banner(void)
 {
 	static unsigned version_printed = 0;
 
@@ -767,7 +767,7 @@ static const struct net_device_ops ether3_netdev_ops = {
 	.ndo_set_mac_address	= eth_mac_addr,
 };
 
-static int __devinit
+static int
 ether3_probe(struct expansion_card *ec, const struct ecard_id *id)
 {
 	const struct ether3_data *data = id->data;
diff --git a/drivers/net/ethernet/seeq/sgiseeq.c b/drivers/net/ethernet/seeq/sgiseeq.c
index 4d15bf4..0fde9ca 100644
--- a/drivers/net/ethernet/seeq/sgiseeq.c
+++ b/drivers/net/ethernet/seeq/sgiseeq.c
@@ -721,7 +721,7 @@ static const struct net_device_ops sgiseeq_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int __devinit sgiseeq_probe(struct platform_device *pdev)
+static int sgiseeq_probe(struct platform_device *pdev)
 {
 	struct sgiseeq_platform_data *pd = pdev->dev.platform_data;
 	struct hpc3_regs *hpcregs = pd->hpc;
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 4f86d0c..32745de 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2669,7 +2669,7 @@ static int efx_pci_probe_main(struct efx_nic *efx)
  * transmission; this is left to the first time one of the network
  * interfaces is brought up (i.e. efx_net_open).
  */
-static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
+static int efx_pci_probe(struct pci_dev *pci_dev,
 				   const struct pci_device_id *entry)
 {
 	struct net_device *net_dev;
diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
index 8d6546d..8f2975b 100644
--- a/drivers/net/ethernet/sgi/ioc3-eth.c
+++ b/drivers/net/ethernet/sgi/ioc3-eth.c
@@ -1143,7 +1143,7 @@ static int ioc3_is_menet(struct pci_dev *pdev)
  * Can't use UPF_IOREMAP as the whole of IOC3 resources have already been
  * registered.
  */
-static void __devinit ioc3_8250_register(struct ioc3_uartregs __iomem *uart)
+static void ioc3_8250_register(struct ioc3_uartregs __iomem *uart)
 {
 #define COSMISC_CONSTANT 6
 
@@ -1169,7 +1169,7 @@ static void __devinit ioc3_8250_register(struct ioc3_uartregs __iomem *uart)
 	serial8250_register_8250_port(&port);
 }
 
-static void __devinit ioc3_serial_probe(struct pci_dev *pdev, struct ioc3 *ioc3)
+static void ioc3_serial_probe(struct pci_dev *pdev, struct ioc3 *ioc3)
 {
 	/*
 	 * We need to recognice and treat the fourth MENET serial as it
@@ -1229,7 +1229,7 @@ static const struct net_device_ops ioc3_netdev_ops = {
 	.ndo_change_mtu		= eth_change_mtu,
 };
 
-static int __devinit ioc3_probe(struct pci_dev *pdev,
+static int ioc3_probe(struct pci_dev *pdev,
 	const struct pci_device_id *ent)
 {
 	unsigned int sw_physid1, sw_physid2;
diff --git a/drivers/net/ethernet/sgi/meth.c b/drivers/net/ethernet/sgi/meth.c
index 53efe7c..79ad9c9 100644
--- a/drivers/net/ethernet/sgi/meth.c
+++ b/drivers/net/ethernet/sgi/meth.c
@@ -825,7 +825,7 @@ static const struct net_device_ops meth_netdev_ops = {
 /*
  * The init function.
  */
-static int __devinit meth_probe(struct platform_device *pdev)
+static int meth_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct meth_private *priv;
diff --git a/drivers/net/ethernet/silan/sc92031.c b/drivers/net/ethernet/silan/sc92031.c
index a0a2e76..3a32673 100644
--- a/drivers/net/ethernet/silan/sc92031.c
+++ b/drivers/net/ethernet/silan/sc92031.c
@@ -1395,7 +1395,7 @@ static const struct net_device_ops sc92031_netdev_ops = {
 #endif
 };
 
-static int __devinit sc92031_probe(struct pci_dev *pdev,
+static int sc92031_probe(struct pci_dev *pdev,
 		const struct pci_device_id *id)
 {
 	int err;
diff --git a/drivers/net/ethernet/sis/sis190.c b/drivers/net/ethernet/sis/sis190.c
index 67fbd4a..7e81755 100644
--- a/drivers/net/ethernet/sis/sis190.c
+++ b/drivers/net/ethernet/sis/sis190.c
@@ -415,7 +415,7 @@ static u16 mdio_read_latched(void __iomem *ioaddr, int phy_id, int reg)
 	return mdio_read(ioaddr, phy_id, reg);
 }
 
-static u16 __devinit sis190_read_eeprom(void __iomem *ioaddr, u32 reg)
+static u16 sis190_read_eeprom(void __iomem *ioaddr, u32 reg)
 {
 	u16 data = 0xffff;
 	unsigned int i;
@@ -1379,7 +1379,7 @@ static void sis190_mii_probe_88e1111_fixup(struct sis190_private *tp)
  *	Identify and set current phy if found one,
  *	return error if it failed to found.
  */
-static int __devinit sis190_mii_probe(struct net_device *dev)
+static int sis190_mii_probe(struct net_device *dev)
 {
 	struct sis190_private *tp = netdev_priv(dev);
 	struct mii_if_info *mii_if = &tp->mii_if;
@@ -1451,7 +1451,7 @@ static void sis190_release_board(struct pci_dev *pdev)
 	free_netdev(dev);
 }
 
-static struct net_device * __devinit sis190_init_board(struct pci_dev *pdev)
+static struct net_device *sis190_init_board(struct pci_dev *pdev)
 {
 	struct sis190_private *tp;
 	struct net_device *dev;
@@ -1573,7 +1573,7 @@ static void sis190_set_rgmii(struct sis190_private *tp, u8 reg)
 	tp->features |= (reg & 0x80) ? F_HAS_RGMII : 0;
 }
 
-static int __devinit sis190_get_mac_addr_from_eeprom(struct pci_dev *pdev,
+static int sis190_get_mac_addr_from_eeprom(struct pci_dev *pdev,
 						     struct net_device *dev)
 {
 	struct sis190_private *tp = netdev_priv(dev);
@@ -1615,7 +1615,7 @@ static int __devinit sis190_get_mac_addr_from_eeprom(struct pci_dev *pdev,
  *	APC CMOS RAM is accessed through ISA bridge.
  *	MAC address is read into @net_dev->dev_addr.
  */
-static int __devinit sis190_get_mac_addr_from_apc(struct pci_dev *pdev,
+static int sis190_get_mac_addr_from_apc(struct pci_dev *pdev,
 						  struct net_device *dev)
 {
 	static const u16 __devinitconst ids[] = { 0x0965, 0x0966, 0x0968 };
@@ -1693,7 +1693,7 @@ static inline void sis190_init_rxfilter(struct net_device *dev)
 	SIS_PCI_COMMIT();
 }
 
-static int __devinit sis190_get_mac_addr(struct pci_dev *pdev,
+static int sis190_get_mac_addr(struct pci_dev *pdev,
 					 struct net_device *dev)
 {
 	int rc;
@@ -1845,7 +1845,7 @@ static const struct net_device_ops sis190_netdev_ops = {
 #endif
 };
 
-static int __devinit sis190_init_one(struct pci_dev *pdev,
+static int sis190_init_one(struct pci_dev *pdev,
 				     const struct pci_device_id *ent)
 {
 	static int printed_version = 0;
diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index d068e2b..5a799c9 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -251,7 +251,7 @@ static const struct ethtool_ops sis900_ethtool_ops;
  *	@net_dev->perm_addr.
  */
 
-static int __devinit sis900_get_mac_addr(struct pci_dev * pci_dev, struct net_device *net_dev)
+static int sis900_get_mac_addr(struct pci_dev * pci_dev, struct net_device *net_dev)
 {
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	void __iomem *ioaddr = sis_priv->ioaddr;
@@ -287,7 +287,7 @@ static int __devinit sis900_get_mac_addr(struct pci_dev * pci_dev, struct net_de
  *	@net_dev->perm_addr.
  */
 
-static int __devinit sis630e_get_mac_addr(struct pci_dev * pci_dev,
+static int sis630e_get_mac_addr(struct pci_dev * pci_dev,
 					struct net_device *net_dev)
 {
 	struct pci_dev *isa_bridge = NULL;
@@ -330,7 +330,7 @@ static int __devinit sis630e_get_mac_addr(struct pci_dev * pci_dev,
  *	@net_dev->dev_addr and @net_dev->perm_addr.
  */
 
-static int __devinit sis635_get_mac_addr(struct pci_dev * pci_dev,
+static int sis635_get_mac_addr(struct pci_dev * pci_dev,
 					struct net_device *net_dev)
 {
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
@@ -377,7 +377,7 @@ static int __devinit sis635_get_mac_addr(struct pci_dev * pci_dev,
  *	MAC address is read into @net_dev->dev_addr and @net_dev->perm_addr.
  */
 
-static int __devinit sis96x_get_mac_addr(struct pci_dev * pci_dev,
+static int sis96x_get_mac_addr(struct pci_dev * pci_dev,
 					struct net_device *net_dev)
 {
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
@@ -433,7 +433,7 @@ static const struct net_device_ops sis900_netdev_ops = {
  *	ie: sis900_open(), sis900_start_xmit(), sis900_close(), etc.
  */
 
-static int __devinit sis900_probe(struct pci_dev *pci_dev,
+static int sis900_probe(struct pci_dev *pci_dev,
 				const struct pci_device_id *pci_id)
 {
 	struct sis900_private *sis_priv;
@@ -605,7 +605,7 @@ err_out_cleardev:
  *	return error if it failed to found.
  */
 
-static int __devinit sis900_mii_probe(struct net_device * net_dev)
+static int sis900_mii_probe(struct net_device * net_dev)
 {
 	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	const char *dev_name = pci_name(sis_priv->pci_dev);
@@ -824,7 +824,7 @@ static void sis900_set_capability(struct net_device *net_dev, struct mii_phy *ph
  *	Note that location is in word (16 bits) unit
  */
 
-static u16 __devinit read_eeprom(void __iomem *ioaddr, int location)
+static u16 read_eeprom(void __iomem *ioaddr, int location)
 {
 	u32 read_cmd = location | EEread;
 	int i;
diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index 67e694b..d5ef36f 100644
--- a/drivers/net/ethernet/smsc/epic100.c
+++ b/drivers/net/ethernet/smsc/epic100.c
@@ -318,7 +318,7 @@ static const struct net_device_ops epic_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int __devinit epic_init_one(struct pci_dev *pdev,
+static int epic_init_one(struct pci_dev *pdev,
 				   const struct pci_device_id *ent)
 {
 	static int card_idx = -1;
@@ -569,7 +569,7 @@ static inline void epic_napi_irq_on(struct net_device *dev,
 	ew32(INTMASK, ep->irq_mask | EpicNapiEvent);
 }
 
-static int __devinit read_eeprom(struct epic_private *ep, int location)
+static int read_eeprom(struct epic_private *ep, int location)
 {
 	void __iomem *ioaddr = ep->ioaddr;
 	int i;
diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index f19fba7..d8ac9d2 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -1722,7 +1722,7 @@ static const struct ethtool_ops smc911x_ethtool_ops = {
  * This routine has a simple purpose -- make the SMC chip generate an
  * interrupt, so an auto-detect routine can detect it, and find the IRQ,
  */
-static int __devinit smc911x_findirq(struct net_device *dev)
+static int smc911x_findirq(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
 	int timeout = 20;
@@ -1800,7 +1800,7 @@ static const struct net_device_ops smc911x_netdev_ops = {
  * o  actually GRAB the irq.
  * o  GRAB the region
  */
-static int __devinit smc911x_probe(struct net_device *dev)
+static int smc911x_probe(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
 	int i, retval;
@@ -2040,7 +2040,7 @@ err_out:
  *	 0 --> there is a device
  *	 anything else, error
  */
-static int __devinit smc911x_drv_probe(struct platform_device *pdev)
+static int smc911x_drv_probe(struct platform_device *pdev)
 {
 	struct net_device *ndev;
 	struct resource *res;
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 8d85cbd..3687de9 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -1789,7 +1789,7 @@ static const struct net_device_ops smc_netdev_ops = {
  * I just deleted auto_irq.c, since it was never built...
  *   --jgarzik
  */
-static int __devinit smc_findirq(struct smc_local *lp)
+static int smc_findirq(struct smc_local *lp)
 {
 	void __iomem *ioaddr = lp->base;
 	int timeout = 20;
@@ -1863,7 +1863,7 @@ static int __devinit smc_findirq(struct smc_local *lp)
  * o  actually GRAB the irq.
  * o  GRAB the region
  */
-static int __devinit smc_probe(struct net_device *dev, void __iomem *ioaddr,
+static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 			    unsigned long irq_flags)
 {
 	struct smc_local *lp = netdev_priv(dev);
@@ -2211,7 +2211,7 @@ static void smc_release_datacs(struct platform_device *pdev, struct net_device *
  *	0 --> there is a device
  *	anything else, error
  */
-static int __devinit smc_drv_probe(struct platform_device *pdev)
+static int smc_drv_probe(struct platform_device *pdev)
 {
 	struct smc91x_platdata *pd = pdev->dev.platform_data;
 	struct smc_local *lp;
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 7d034fc..53980b5 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1031,7 +1031,7 @@ static int smsc911x_mii_probe(struct net_device *dev)
 	return 0;
 }
 
-static int __devinit smsc911x_mii_init(struct platform_device *pdev,
+static int smsc911x_mii_init(struct platform_device *pdev,
 				       struct net_device *dev)
 {
 	struct smsc911x_data *pdata = netdev_priv(dev);
@@ -2092,7 +2092,7 @@ static const struct net_device_ops smsc911x_netdev_ops = {
 };
 
 /* copies the current mac address from hardware to dev->dev_addr */
-static void __devinit smsc911x_read_mac_address(struct net_device *dev)
+static void smsc911x_read_mac_address(struct net_device *dev)
 {
 	struct smsc911x_data *pdata = netdev_priv(dev);
 	u32 mac_high16 = smsc911x_mac_read(pdata, ADDRH);
@@ -2107,7 +2107,7 @@ static void __devinit smsc911x_read_mac_address(struct net_device *dev)
 }
 
 /* Initializing private device structures, only called from probe */
-static int __devinit smsc911x_init(struct net_device *dev)
+static int smsc911x_init(struct net_device *dev)
 {
 	struct smsc911x_data *pdata = netdev_priv(dev);
 	unsigned int byte_test;
@@ -2288,7 +2288,7 @@ static const struct smsc911x_ops shifted_smsc911x_ops = {
 };
 
 #ifdef CONFIG_OF
-static int __devinit smsc911x_probe_config_dt(
+static int smsc911x_probe_config_dt(
 				struct smsc911x_platform_config *config,
 				struct device_node *np)
 {
@@ -2338,7 +2338,7 @@ static inline int smsc911x_probe_config_dt(
 }
 #endif /* CONFIG_OF */
 
-static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
+static int smsc911x_drv_probe(struct platform_device *pdev)
 {
 	struct device_node *np = pdev->dev.of_node;
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index ed96967..fa3ab62 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -1577,7 +1577,7 @@ static const struct net_device_ops smsc9420_netdev_ops = {
 #endif /* CONFIG_NET_POLL_CONTROLLER */
 };
 
-static int __devinit
+static int
 smsc9420_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 {
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 743ab67..572702a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -61,7 +61,7 @@ static void stmmac_default_data(void)
  * matches the device. The probe functions returns zero when the driver choose
  * to take "ownership" of the device or an error code(-ve no) otherwise.
  */
-static int __devinit stmmac_pci_probe(struct pci_dev *pdev,
+static int stmmac_pci_probe(struct pci_dev *pdev,
 				      const struct pci_device_id *id)
 {
 	int ret = 0;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index ed112b5..b77b913 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -29,7 +29,7 @@
 #include "stmmac.h"
 
 #ifdef CONFIG_OF
-static int __devinit stmmac_probe_config_dt(struct platform_device *pdev,
+static int stmmac_probe_config_dt(struct platform_device *pdev,
 					    struct plat_stmmacenet_data *plat,
 					    const char **mac)
 {
@@ -59,7 +59,7 @@ static int __devinit stmmac_probe_config_dt(struct platform_device *pdev,
 	return 0;
 }
 #else
-static int __devinit stmmac_probe_config_dt(struct platform_device *pdev,
+static int stmmac_probe_config_dt(struct platform_device *pdev,
 					    struct plat_stmmacenet_data *plat,
 					    const char **mac)
 {
@@ -74,7 +74,7 @@ static int __devinit stmmac_probe_config_dt(struct platform_device *pdev,
  * the necessary resources and invokes the main to init
  * the net device, register the mdio bus etc.
  */
-static int __devinit stmmac_pltfr_probe(struct platform_device *pdev)
+static int stmmac_pltfr_probe(struct platform_device *pdev)
 {
 	int ret = 0;
 	struct resource *res;
diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index 9d716c6..9c7f797 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -4820,7 +4820,7 @@ static int cas_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
  * only subordinate device and we can tweak the bridge settings to
  * reflect that fact.
  */
-static void __devinit cas_program_bridge(struct pci_dev *cas_pdev)
+static void cas_program_bridge(struct pci_dev *cas_pdev)
 {
 	struct pci_dev *pdev = cas_pdev->bus->self;
 	u32 val;
@@ -4916,7 +4916,7 @@ static const struct net_device_ops cas_netdev_ops = {
 #endif
 };
 
-static int __devinit cas_init_one(struct pci_dev *pdev,
+static int cas_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
 	static int cas_version_printed = 0;
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 94b0085..926ed9f 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -7977,7 +7977,7 @@ static int niu_set_ldg_sid(struct niu *np, int ldg, int func, int vector)
 	return 0;
 }
 
-static int __devinit niu_pci_eeprom_read(struct niu *np, u32 addr)
+static int niu_pci_eeprom_read(struct niu *np, u32 addr)
 {
 	u64 frame, frame_base = (ESPC_PIO_STAT_READ_START |
 				 (addr << ESPC_PIO_STAT_ADDR_SHIFT));
@@ -8020,7 +8020,7 @@ static int __devinit niu_pci_eeprom_read(struct niu *np, u32 addr)
 	return (frame & ESPC_PIO_STAT_DATA) >> ESPC_PIO_STAT_DATA_SHIFT;
 }
 
-static int __devinit niu_pci_eeprom_read16(struct niu *np, u32 off)
+static int niu_pci_eeprom_read16(struct niu *np, u32 off)
 {
 	int err = niu_pci_eeprom_read(np, off);
 	u16 val;
@@ -8036,7 +8036,7 @@ static int __devinit niu_pci_eeprom_read16(struct niu *np, u32 off)
 	return val;
 }
 
-static int __devinit niu_pci_eeprom_read16_swp(struct niu *np, u32 off)
+static int niu_pci_eeprom_read16_swp(struct niu *np, u32 off)
 {
 	int err = niu_pci_eeprom_read(np, off);
 	u16 val;
@@ -8054,7 +8054,7 @@ static int __devinit niu_pci_eeprom_read16_swp(struct niu *np, u32 off)
 	return val;
 }
 
-static int __devinit niu_pci_vpd_get_propname(struct niu *np,
+static int niu_pci_vpd_get_propname(struct niu *np,
 					      u32 off,
 					      char *namebuf,
 					      int namebuf_len)
@@ -8075,7 +8075,7 @@ static int __devinit niu_pci_vpd_get_propname(struct niu *np,
 	return i + 1;
 }
 
-static void __devinit niu_vpd_parse_version(struct niu *np)
+static void niu_vpd_parse_version(struct niu *np)
 {
 	struct niu_vpd *vpd = &np->vpd;
 	int len = strlen(vpd->version) + 1;
@@ -8102,7 +8102,7 @@ static void __devinit niu_vpd_parse_version(struct niu *np)
 }
 
 /* ESPC_PIO_EN_ENABLE must be set */
-static int __devinit niu_pci_vpd_scan_props(struct niu *np,
+static int niu_pci_vpd_scan_props(struct niu *np,
 					    u32 start, u32 end)
 {
 	unsigned int found_mask = 0;
@@ -8189,7 +8189,7 @@ static int __devinit niu_pci_vpd_scan_props(struct niu *np,
 }
 
 /* ESPC_PIO_EN_ENABLE must be set */
-static void __devinit niu_pci_vpd_fetch(struct niu *np, u32 start)
+static void niu_pci_vpd_fetch(struct niu *np, u32 start)
 {
 	u32 offset;
 	int err;
@@ -8224,7 +8224,7 @@ static void __devinit niu_pci_vpd_fetch(struct niu *np, u32 start)
 }
 
 /* ESPC_PIO_EN_ENABLE must be set */
-static u32 __devinit niu_pci_vpd_offset(struct niu *np)
+static u32 niu_pci_vpd_offset(struct niu *np)
 {
 	u32 start = 0, end = ESPC_EEPROM_SIZE, ret;
 	int err;
@@ -8279,7 +8279,7 @@ static u32 __devinit niu_pci_vpd_offset(struct niu *np)
 	return 0;
 }
 
-static int __devinit niu_phy_type_prop_decode(struct niu *np,
+static int niu_phy_type_prop_decode(struct niu *np,
 					      const char *phy_prop)
 {
 	if (!strcmp(phy_prop, "mif")) {
@@ -8334,7 +8334,7 @@ static int niu_pci_vpd_get_nports(struct niu *np)
 	return ports;
 }
 
-static void __devinit niu_pci_vpd_validate(struct niu *np)
+static void niu_pci_vpd_validate(struct niu *np)
 {
 	struct net_device *dev = np->dev;
 	struct niu_vpd *vpd = &np->vpd;
@@ -8380,7 +8380,7 @@ static void __devinit niu_pci_vpd_validate(struct niu *np)
 	memcpy(dev->dev_addr, dev->perm_addr, dev->addr_len);
 }
 
-static int __devinit niu_pci_probe_sprom(struct niu *np)
+static int niu_pci_probe_sprom(struct niu *np)
 {
 	struct net_device *dev = np->dev;
 	int len, i;
@@ -8538,7 +8538,7 @@ static int __devinit niu_pci_probe_sprom(struct niu *np)
 	return 0;
 }
 
-static int __devinit niu_get_and_validate_port(struct niu *np)
+static int niu_get_and_validate_port(struct niu *np)
 {
 	struct niu_parent *parent = np->parent;
 
@@ -8572,7 +8572,7 @@ static int __devinit niu_get_and_validate_port(struct niu *np)
 	return 0;
 }
 
-static int __devinit phy_record(struct niu_parent *parent,
+static int phy_record(struct niu_parent *parent,
 				struct phy_probe_info *p,
 				int dev_id_1, int dev_id_2, u8 phy_port,
 				int type)
@@ -8611,7 +8611,7 @@ static int __devinit phy_record(struct niu_parent *parent,
 	return 0;
 }
 
-static int __devinit port_has_10g(struct phy_probe_info *p, int port)
+static int port_has_10g(struct phy_probe_info *p, int port)
 {
 	int i;
 
@@ -8627,7 +8627,7 @@ static int __devinit port_has_10g(struct phy_probe_info *p, int port)
 	return 0;
 }
 
-static int __devinit count_10g_ports(struct phy_probe_info *p, int *lowest)
+static int count_10g_ports(struct phy_probe_info *p, int *lowest)
 {
 	int port, cnt;
 
@@ -8644,7 +8644,7 @@ static int __devinit count_10g_ports(struct phy_probe_info *p, int *lowest)
 	return cnt;
 }
 
-static int __devinit count_1g_ports(struct phy_probe_info *p, int *lowest)
+static int count_1g_ports(struct phy_probe_info *p, int *lowest)
 {
 	*lowest = 32;
 	if (p->cur[PHY_TYPE_MII])
@@ -8653,7 +8653,7 @@ static int __devinit count_1g_ports(struct phy_probe_info *p, int *lowest)
 	return p->cur[PHY_TYPE_MII];
 }
 
-static void __devinit niu_n2_divide_channels(struct niu_parent *parent)
+static void niu_n2_divide_channels(struct niu_parent *parent)
 {
 	int num_ports = parent->num_ports;
 	int i;
@@ -8669,7 +8669,7 @@ static void __devinit niu_n2_divide_channels(struct niu_parent *parent)
 	}
 }
 
-static void __devinit niu_divide_channels(struct niu_parent *parent,
+static void niu_divide_channels(struct niu_parent *parent,
 					  int num_10g, int num_1g)
 {
 	int num_ports = parent->num_ports;
@@ -8731,7 +8731,7 @@ static void __devinit niu_divide_channels(struct niu_parent *parent,
 	}
 }
 
-static void __devinit niu_divide_rdc_groups(struct niu_parent *parent,
+static void niu_divide_rdc_groups(struct niu_parent *parent,
 					    int num_10g, int num_1g)
 {
 	int i, num_ports = parent->num_ports;
@@ -8776,7 +8776,7 @@ static void __devinit niu_divide_rdc_groups(struct niu_parent *parent,
 	}
 }
 
-static int __devinit fill_phy_probe_info(struct niu *np,
+static int fill_phy_probe_info(struct niu *np,
 					 struct niu_parent *parent,
 					 struct phy_probe_info *info)
 {
@@ -8819,7 +8819,7 @@ static int __devinit fill_phy_probe_info(struct niu *np,
 	return err;
 }
 
-static int __devinit walk_phys(struct niu *np, struct niu_parent *parent)
+static int walk_phys(struct niu *np, struct niu_parent *parent)
 {
 	struct phy_probe_info *info = &parent->phy_probe_info;
 	int lowest_10g, lowest_1g;
@@ -8948,7 +8948,7 @@ unknown_vg_1g_port:
 	return -EINVAL;
 }
 
-static int __devinit niu_probe_ports(struct niu *np)
+static int niu_probe_ports(struct niu *np)
 {
 	struct niu_parent *parent = np->parent;
 	int err, i;
@@ -8969,7 +8969,7 @@ static int __devinit niu_probe_ports(struct niu *np)
 	return 0;
 }
 
-static int __devinit niu_classifier_swstate_init(struct niu *np)
+static int niu_classifier_swstate_init(struct niu *np)
 {
 	struct niu_classifier *cp = &np->clas;
 
@@ -8981,7 +8981,7 @@ static int __devinit niu_classifier_swstate_init(struct niu *np)
 	return fflp_early_init(np);
 }
 
-static void __devinit niu_link_config_init(struct niu *np)
+static void niu_link_config_init(struct niu *np)
 {
 	struct niu_link_config *lp = &np->link_config;
 
@@ -9006,7 +9006,7 @@ static void __devinit niu_link_config_init(struct niu *np)
 #endif
 }
 
-static int __devinit niu_init_mac_ipp_pcs_base(struct niu *np)
+static int niu_init_mac_ipp_pcs_base(struct niu *np)
 {
 	switch (np->port) {
 	case 0:
@@ -9045,7 +9045,7 @@ static int __devinit niu_init_mac_ipp_pcs_base(struct niu *np)
 	return 0;
 }
 
-static void __devinit niu_try_msix(struct niu *np, u8 *ldg_num_map)
+static void niu_try_msix(struct niu *np, u8 *ldg_num_map)
 {
 	struct msix_entry msi_vec[NIU_NUM_LDG];
 	struct niu_parent *parent = np->parent;
@@ -9084,7 +9084,7 @@ retry:
 	np->num_ldg = num_irqs;
 }
 
-static int __devinit niu_n2_irq_init(struct niu *np, u8 *ldg_num_map)
+static int niu_n2_irq_init(struct niu *np, u8 *ldg_num_map)
 {
 #ifdef CONFIG_SPARC64
 	struct platform_device *op = np->op;
@@ -9108,7 +9108,7 @@ static int __devinit niu_n2_irq_init(struct niu *np, u8 *ldg_num_map)
 #endif
 }
 
-static int __devinit niu_ldg_init(struct niu *np)
+static int niu_ldg_init(struct niu *np)
 {
 	struct niu_parent *parent = np->parent;
 	u8 ldg_num_map[NIU_NUM_LDG];
@@ -9231,7 +9231,7 @@ static void __devexit niu_ldg_free(struct niu *np)
 		pci_disable_msix(np->pdev);
 }
 
-static int __devinit niu_get_of_props(struct niu *np)
+static int niu_get_of_props(struct niu *np)
 {
 #ifdef CONFIG_SPARC64
 	struct net_device *dev = np->dev;
@@ -9300,7 +9300,7 @@ static int __devinit niu_get_of_props(struct niu *np)
 #endif
 }
 
-static int __devinit niu_get_invariants(struct niu *np)
+static int niu_get_invariants(struct niu *np)
 {
 	int err, have_props;
 	u32 offset;
@@ -9479,7 +9479,7 @@ static struct device_attribute niu_parent_attributes[] = {
 	{}
 };
 
-static struct niu_parent * __devinit niu_new_parent(struct niu *np,
+static struct niu_parent *niu_new_parent(struct niu *np,
 						    union niu_parent_id *id,
 						    u8 ptype)
 {
@@ -9544,7 +9544,7 @@ fail_unregister:
 	return NULL;
 }
 
-static struct niu_parent * __devinit niu_get_parent(struct niu *np,
+static struct niu_parent *niu_get_parent(struct niu *np,
 						    union niu_parent_id *id,
 						    u8 ptype)
 {
@@ -9662,7 +9662,7 @@ static const struct niu_ops niu_pci_ops = {
 	.unmap_single	= niu_pci_unmap_single,
 };
 
-static void __devinit niu_driver_version(void)
+static void niu_driver_version(void)
 {
 	static int niu_version_printed;
 
@@ -9670,7 +9670,7 @@ static void __devinit niu_driver_version(void)
 		pr_info("%s", version);
 }
 
-static struct net_device * __devinit niu_alloc_and_init(
+static struct net_device *niu_alloc_and_init(
 	struct device *gen_dev, struct pci_dev *pdev,
 	struct platform_device *op, const struct niu_ops *ops,
 	u8 port)
@@ -9714,14 +9714,14 @@ static const struct net_device_ops niu_netdev_ops = {
 	.ndo_change_mtu		= niu_change_mtu,
 };
 
-static void __devinit niu_assign_netdev_ops(struct net_device *dev)
+static void niu_assign_netdev_ops(struct net_device *dev)
 {
 	dev->netdev_ops = &niu_netdev_ops;
 	dev->ethtool_ops = &niu_ethtool_ops;
 	dev->watchdog_timeo = NIU_TX_TIMEOUT;
 }
 
-static void __devinit niu_device_announce(struct niu *np)
+static void niu_device_announce(struct niu *np)
 {
 	struct net_device *dev = np->dev;
 
@@ -9750,13 +9750,13 @@ static void __devinit niu_device_announce(struct niu *np)
 	}
 }
 
-static void __devinit niu_set_basic_features(struct net_device *dev)
+static void niu_set_basic_features(struct net_device *dev)
 {
 	dev->hw_features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_RXHASH;
 	dev->features |= dev->hw_features | NETIF_F_RXCSUM;
 }
 
-static int __devinit niu_pci_init_one(struct pci_dev *pdev,
+static int niu_pci_init_one(struct pci_dev *pdev,
 				      const struct pci_device_id *ent)
 {
 	union niu_parent_id parent_id;
@@ -10044,7 +10044,7 @@ static const struct niu_ops niu_phys_ops = {
 	.unmap_single	= niu_phys_unmap_single,
 };
 
-static int __devinit niu_of_probe(struct platform_device *op)
+static int niu_of_probe(struct platform_device *op)
 {
 	union niu_parent_id parent_id;
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/sun/sunbmac.c b/drivers/net/ethernet/sun/sunbmac.c
index 41609b8..70d46b6 100644
--- a/drivers/net/ethernet/sun/sunbmac.c
+++ b/drivers/net/ethernet/sun/sunbmac.c
@@ -1074,7 +1074,7 @@ static const struct net_device_ops bigmac_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int __devinit bigmac_ether_init(struct platform_device *op,
+static int bigmac_ether_init(struct platform_device *op,
 				       struct platform_device *qec_op)
 {
 	static int version_printed;
@@ -1233,7 +1233,7 @@ fail_and_cleanup:
 /* QEC can be the parent of either QuadEthernet or a BigMAC.  We want
  * the latter.
  */
-static int __devinit bigmac_sbus_probe(struct platform_device *op)
+static int bigmac_sbus_probe(struct platform_device *op)
 {
 	struct device *parent = op->dev.parent;
 	struct platform_device *qec_op;
diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index 6c8695e..fd0e61d 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -2763,7 +2763,7 @@ static void get_gem_mac_nonobp(struct pci_dev *pdev, unsigned char *dev_addr)
 }
 #endif /* not Sparc and not PPC */
 
-static int __devinit gem_get_device_address(struct gem *gp)
+static int gem_get_device_address(struct gem *gp)
 {
 #if defined(CONFIG_SPARC) || defined(CONFIG_PPC_PMAC)
 	struct net_device *dev = gp->dev;
@@ -2827,7 +2827,7 @@ static const struct net_device_ops gem_netdev_ops = {
 #endif
 };
 
-static int __devinit gem_init_one(struct pci_dev *pdev,
+static int gem_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
 	unsigned long gemreg_base, gemreg_len;
diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 61147c2..2454bd7 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -2499,7 +2499,7 @@ static int hme_version_printed;
  *
  * Return NULL on failure.
  */
-static struct quattro * __devinit quattro_sbus_find(struct platform_device *child)
+static struct quattro *quattro_sbus_find(struct platform_device *child)
 {
 	struct device *parent = child->dev.parent;
 	struct platform_device *op;
@@ -2580,7 +2580,7 @@ static void quattro_sbus_free_irqs(void)
 #endif /* CONFIG_SBUS */
 
 #ifdef CONFIG_PCI
-static struct quattro * __devinit quattro_pci_find(struct pci_dev *pdev)
+static struct quattro *quattro_pci_find(struct pci_dev *pdev)
 {
 	struct pci_dev *bdev = pdev->bus->self;
 	struct quattro *qp;
@@ -2623,7 +2623,7 @@ static const struct net_device_ops hme_netdev_ops = {
 };
 
 #ifdef CONFIG_SBUS
-static int __devinit happy_meal_sbus_probe_one(struct platform_device *op, int is_qfe)
+static int happy_meal_sbus_probe_one(struct platform_device *op, int is_qfe)
 {
 	struct device_node *dp = op->dev.of_node, *sbus_dp;
 	struct quattro *qp = NULL;
@@ -2927,7 +2927,7 @@ static void get_hme_mac_nonsparc(struct pci_dev *pdev, unsigned char *dev_addr)
 }
 #endif /* !(CONFIG_SPARC) */
 
-static int __devinit happy_meal_pci_probe(struct pci_dev *pdev,
+static int happy_meal_pci_probe(struct pci_dev *pdev,
 					  const struct pci_device_id *ent)
 {
 	struct quattro *qp = NULL;
@@ -3216,7 +3216,7 @@ static void happy_meal_pci_exit(void)
 
 #ifdef CONFIG_SBUS
 static const struct of_device_id hme_sbus_match[];
-static int __devinit hme_sbus_probe(struct platform_device *op)
+static int hme_sbus_probe(struct platform_device *op)
 {
 	const struct of_device_id *match;
 	struct device_node *dp = op->dev.of_node;
diff --git a/drivers/net/ethernet/sun/sunqe.c b/drivers/net/ethernet/sun/sunqe.c
index 10b0f50..14e1523 100644
--- a/drivers/net/ethernet/sun/sunqe.c
+++ b/drivers/net/ethernet/sun/sunqe.c
@@ -744,7 +744,7 @@ static void qec_init_once(struct sunqec *qecp, struct platform_device *op)
 		    qecp->gregs + GLOB_RSIZE);
 }
 
-static u8 __devinit qec_get_burst(struct device_node *dp)
+static u8 qec_get_burst(struct device_node *dp)
 {
 	u8 bsizes, bsizes_more;
 
@@ -764,7 +764,7 @@ static u8 __devinit qec_get_burst(struct device_node *dp)
 	return bsizes;
 }
 
-static struct sunqec * __devinit get_qec(struct platform_device *child)
+static struct sunqec *get_qec(struct platform_device *child)
 {
 	struct platform_device *op = to_platform_device(child->dev.parent);
 	struct sunqec *qecp;
@@ -830,7 +830,7 @@ static const struct net_device_ops qec_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int __devinit qec_ether_init(struct platform_device *op)
+static int qec_ether_init(struct platform_device *op)
 {
 	static unsigned version_printed;
 	struct net_device *dev;
@@ -929,7 +929,7 @@ fail:
 	return res;
 }
 
-static int __devinit qec_sbus_probe(struct platform_device *op)
+static int qec_sbus_probe(struct platform_device *op)
 {
 	return qec_ether_init(op);
 }
diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index a108db3..d94563b 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -937,7 +937,7 @@ static void vnet_port_free_tx_bufs(struct vnet_port *port)
 	}
 }
 
-static int __devinit vnet_port_alloc_tx_bufs(struct vnet_port *port)
+static int vnet_port_alloc_tx_bufs(struct vnet_port *port)
 {
 	struct vio_dring_state *dr;
 	unsigned long len;
@@ -1019,7 +1019,7 @@ static const struct net_device_ops vnet_ops = {
 	.ndo_start_xmit		= vnet_start_xmit,
 };
 
-static struct vnet * __devinit vnet_new(const u64 *local_mac)
+static struct vnet *vnet_new(const u64 *local_mac)
 {
 	struct net_device *dev;
 	struct vnet *vp;
@@ -1067,7 +1067,7 @@ err_out_free_dev:
 	return ERR_PTR(err);
 }
 
-static struct vnet * __devinit vnet_find_or_create(const u64 *local_mac)
+static struct vnet *vnet_find_or_create(const u64 *local_mac)
 {
 	struct vnet *iter, *vp;
 
@@ -1088,7 +1088,7 @@ static struct vnet * __devinit vnet_find_or_create(const u64 *local_mac)
 
 static const char *local_mac_prop = "local-mac-address";
 
-static struct vnet * __devinit vnet_find_parent(struct mdesc_handle *hp,
+static struct vnet *vnet_find_parent(struct mdesc_handle *hp,
 						u64 port_node)
 {
 	const u64 *local_mac = NULL;
@@ -1125,14 +1125,14 @@ static struct vio_driver_ops vnet_vio_ops = {
 	.handshake_complete	= vnet_handshake_complete,
 };
 
-static void __devinit print_version(void)
+static void print_version(void)
 {
 	printk_once(KERN_INFO "%s", version);
 }
 
 const char *remote_macaddr_prop = "remote-mac-address";
 
-static int __devinit vnet_port_probe(struct vio_dev *vdev,
+static int vnet_port_probe(struct vio_dev *vdev,
 				     const struct vio_device_id *id)
 {
 	struct mdesc_handle *hp;
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index 5f6d1f0..d6e1937 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -1914,7 +1914,7 @@ static const struct net_device_ops bdx_netdev_ops = {
  */
 
 /* TBD: netif_msg should be checked and implemented. I disable it for now */
-static int __devinit
+static int
 bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *ndev;
diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 723cba0..74c7200 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -1110,7 +1110,7 @@ static const struct net_device_ops cpmac_netdev_ops = {
 
 static int external_switch;
 
-static int __devinit cpmac_probe(struct platform_device *pdev)
+static int cpmac_probe(struct platform_device *pdev)
 {
 	int rc, phy_id;
 	char mdio_bus_id[MII_BUS_ID_SIZE];
@@ -1219,7 +1219,7 @@ static struct platform_driver cpmac_driver = {
 	.remove = cpmac_remove,
 };
 
-int __devinit cpmac_init(void)
+int cpmac_init(void)
 {
 	u32 mask;
 	int i, res;
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 64ea9a9..b9e6f39 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1186,7 +1186,7 @@ error_ret:
 	return ret;
 }
 
-static int __devinit cpsw_probe(struct platform_device *pdev)
+static int cpsw_probe(struct platform_device *pdev)
 {
 	struct cpsw_platform_data	*data = pdev->dev.platform_data;
 	struct net_device		*ndev;
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index e6cbedc..9d143c9 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1850,7 +1850,7 @@ static struct emac_platform_data
  * resource information from platform init and register a network device
  * and allocate resources necessary for driver to perform
  */
-static int __devinit davinci_emac_probe(struct platform_device *pdev)
+static int davinci_emac_probe(struct platform_device *pdev)
 {
 	int rc = 0;
 	struct resource *res;
diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index ca69af8..0a2527c 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -310,7 +310,7 @@ static int davinci_mdio_probe_dt(struct mdio_platform_data *data,
 }
 
 
-static int __devinit davinci_mdio_probe(struct platform_device *pdev)
+static int davinci_mdio_probe(struct platform_device *pdev)
 {
 	struct mdio_platform_data *pdata = pdev->dev.platform_data;
 	struct device *dev = &pdev->dev;
diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index 9e326b2..148e32f 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -434,7 +434,7 @@ err_out_pci_free:
 }
 
 
-static int __devinit tlan_init_one(struct pci_dev *pdev,
+static int tlan_init_one(struct pci_dev *pdev,
 				   const struct pci_device_id *ent)
 {
 	return tlan_probe1(pdev, -1, -1, 0, ent);
@@ -460,7 +460,7 @@ static int __devinit tlan_init_one(struct pci_dev *pdev,
 *
 **************************************************************/
 
-static int __devinit tlan_probe1(struct pci_dev *pdev,
+static int tlan_probe1(struct pci_dev *pdev,
 				 long ioaddr, int irq, int rev,
 				 const struct pci_device_id *ent)
 {
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
index 5ee82a7..d7c8af7 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
@@ -234,7 +234,7 @@ static void gelic_card_free_chain(struct gelic_card *card,
  *
  * returns 0 on success, <0 on failure
  */
-static int __devinit gelic_card_init_chain(struct gelic_card *card,
+static int gelic_card_init_chain(struct gelic_card *card,
 					   struct gelic_descr_chain *chain,
 					   struct gelic_descr *start_descr,
 					   int no)
@@ -428,7 +428,7 @@ rewind:
  *
  * returns 0 on success, < 0 on failure
  */
-static int __devinit gelic_card_alloc_rx_skbs(struct gelic_card *card)
+static int gelic_card_alloc_rx_skbs(struct gelic_card *card)
 {
 	struct gelic_descr_chain *chain;
 	int ret;
@@ -1468,7 +1468,7 @@ static const struct net_device_ops gelic_netdevice_ops = {
  *
  * fills out function pointers in the net_device structure
  */
-static void __devinit gelic_ether_setup_netdev_ops(struct net_device *netdev,
+static void gelic_ether_setup_netdev_ops(struct net_device *netdev,
 						   struct napi_struct *napi)
 {
 	netdev->watchdog_timeo = GELIC_NET_WATCHDOG_TIMEOUT;
@@ -1489,7 +1489,7 @@ static void __devinit gelic_ether_setup_netdev_ops(struct net_device *netdev,
  * gelic_ether_setup_netdev initializes the net_device structure
  * and register it.
  **/
-int __devinit gelic_net_setup_netdev(struct net_device *netdev,
+int gelic_net_setup_netdev(struct net_device *netdev,
 				     struct gelic_card *card)
 {
 	int status;
@@ -1542,7 +1542,7 @@ int __devinit gelic_net_setup_netdev(struct net_device *netdev,
  * the card and net_device structures are linked to each other
  */
 #define GELIC_ALIGN (32)
-static struct gelic_card * __devinit gelic_alloc_card_net(struct net_device **netdev)
+static struct gelic_card *gelic_alloc_card_net(struct net_device **netdev)
 {
 	struct gelic_card *card;
 	struct gelic_port *port;
@@ -1593,7 +1593,7 @@ static struct gelic_card * __devinit gelic_alloc_card_net(struct net_device **ne
 	return card;
 }
 
-static void __devinit gelic_card_get_vlan_info(struct gelic_card *card)
+static void gelic_card_get_vlan_info(struct gelic_card *card)
 {
 	u64 v1, v2;
 	int status;
@@ -1667,7 +1667,7 @@ static void __devinit gelic_card_get_vlan_info(struct gelic_card *card)
 /**
  * ps3_gelic_driver_probe - add a device to the control of this driver
  */
-static int __devinit ps3_gelic_driver_probe(struct ps3_system_bus_device *dev)
+static int ps3_gelic_driver_probe(struct ps3_system_bus_device *dev)
 {
 	struct gelic_card *card;
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
index 72b775f..d568af1 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
@@ -2305,7 +2305,7 @@ static const struct iw_handler_def gelic_wl_wext_handler_def = {
 	.get_wireless_stats	= gelic_wl_get_wireless_stats,
 };
 
-static struct net_device * __devinit gelic_wl_alloc(struct gelic_card *card)
+static struct net_device *gelic_wl_alloc(struct gelic_card *card)
 {
 	struct net_device *netdev;
 	struct gelic_port *port;
@@ -2582,7 +2582,7 @@ static const struct ethtool_ops gelic_wl_ethtool_ops = {
 	.get_link	= gelic_wl_get_link,
 };
 
-static void __devinit gelic_wl_setup_netdev_ops(struct net_device *netdev)
+static void gelic_wl_setup_netdev_ops(struct net_device *netdev)
 {
 	struct gelic_wl_info *wl;
 	wl = port_wl(netdev_priv(netdev));
@@ -2598,7 +2598,7 @@ static void __devinit gelic_wl_setup_netdev_ops(struct net_device *netdev)
 /*
  * driver probe/remove
  */
-int __devinit gelic_wl_driver_probe(struct gelic_card *card)
+int gelic_wl_driver_probe(struct gelic_card *card)
 {
 	int ret;
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index a89279f..95195d2 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -2492,7 +2492,7 @@ out_disable_dev:
  * spider_net_probe initializes pdev and registers a net_device
  * structure for it. After that, the device can be ifconfig'ed up
  **/
-static int __devinit
+static int
 spider_net_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	int err = -EIO;
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 6d6af5d..0dafa25 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -719,7 +719,7 @@ err_out:
  * should provide a "tc35815-mac" device with a MAC address in its
  * platform_data.
  */
-static int __devinit tc35815_mac_match(struct device *dev, void *data)
+static int tc35815_mac_match(struct device *dev, void *data)
 {
 	struct platform_device *plat_dev = to_platform_device(dev);
 	struct pci_dev *pci_dev = data;
@@ -727,7 +727,7 @@ static int __devinit tc35815_mac_match(struct device *dev, void *data)
 	return !strcmp(plat_dev->name, "tc35815-mac") && plat_dev->id == id;
 }
 
-static int __devinit tc35815_read_plat_dev_addr(struct net_device *dev)
+static int tc35815_read_plat_dev_addr(struct net_device *dev)
 {
 	struct tc35815_local *lp = netdev_priv(dev);
 	struct device *pd = bus_find_device(&platform_bus_type, NULL,
@@ -741,13 +741,13 @@ static int __devinit tc35815_read_plat_dev_addr(struct net_device *dev)
 	return -ENODEV;
 }
 #else
-static int __devinit tc35815_read_plat_dev_addr(struct net_device *dev)
+static int tc35815_read_plat_dev_addr(struct net_device *dev)
 {
 	return -ENODEV;
 }
 #endif
 
-static int __devinit tc35815_init_dev_addr(struct net_device *dev)
+static int tc35815_init_dev_addr(struct net_device *dev)
 {
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
@@ -785,7 +785,7 @@ static const struct net_device_ops tc35815_netdev_ops = {
 #endif
 };
 
-static int __devinit tc35815_init_one(struct pci_dev *pdev,
+static int tc35815_init_one(struct pci_dev *pdev,
 				      const struct pci_device_id *ent)
 {
 	void __iomem *ioaddr = NULL;
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 565f077..f745825 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -657,7 +657,7 @@ static void enable_mmio(long pioaddr, u32 quirks)
  * Loads bytes 0x00-0x05, 0x6E-0x6F, 0x78-0x7B from EEPROM
  * (plus 0x6C for Rhine-I/II)
  */
-static void __devinit rhine_reload_eeprom(long pioaddr, struct net_device *dev)
+static void rhine_reload_eeprom(long pioaddr, struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
@@ -823,7 +823,7 @@ static int rhine_napipoll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
-static void __devinit rhine_hw_init(struct net_device *dev, long pioaddr)
+static void rhine_hw_init(struct net_device *dev, long pioaddr)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 
@@ -856,7 +856,7 @@ static const struct net_device_ops rhine_netdev_ops = {
 #endif
 };
 
-static int __devinit rhine_init_one(struct pci_dev *pdev,
+static int rhine_init_one(struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
 {
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index 44e2fa4..808368f 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -375,7 +375,7 @@ MODULE_DEVICE_TABLE(pci, velocity_id_table);
  *	Given a chip identifier return a suitable description. Returns
  *	a pointer a static string valid while the driver is loaded.
  */
-static const char __devinit *get_chip_name(enum chip_type chip_id)
+static const char *get_chip_name(enum chip_type chip_id)
 {
 	int i;
 	for (i = 0; chip_info_table[i].name != NULL; i++)
@@ -421,7 +421,7 @@ static void __devexit velocity_remove1(struct pci_dev *pdev)
  *	all the verification and checking as well as reporting so that
  *	we don't duplicate code for each option.
  */
-static void __devinit velocity_set_int_opt(int *opt, int val, int min, int max, int def, char *name, const char *devname)
+static void velocity_set_int_opt(int *opt, int val, int min, int max, int def, char *name, const char *devname)
 {
 	if (val == -1)
 		*opt = def;
@@ -449,7 +449,7 @@ static void __devinit velocity_set_int_opt(int *opt, int val, int min, int max,
  *	all the verification and checking as well as reporting so that
  *	we don't duplicate code for each option.
  */
-static void __devinit velocity_set_bool_opt(u32 *opt, int val, int def, u32 flag, char *name, const char *devname)
+static void velocity_set_bool_opt(u32 *opt, int val, int def, u32 flag, char *name, const char *devname)
 {
 	(*opt) &= (~flag);
 	if (val == -1)
@@ -474,7 +474,7 @@ static void __devinit velocity_set_bool_opt(u32 *opt, int val, int def, u32 flag
  *	Turn the module and command options into a single structure
  *	for the current device
  */
-static void __devinit velocity_get_options(struct velocity_opt *opts, int index, const char *devname)
+static void velocity_get_options(struct velocity_opt *opts, int index, const char *devname)
 {
 
 	velocity_set_int_opt(&opts->rx_thresh, rx_thresh[index], RX_THRESH_MIN, RX_THRESH_MAX, RX_THRESH_DEF, "rx_thresh", devname);
@@ -2627,7 +2627,7 @@ static const struct net_device_ops velocity_netdev_ops = {
  *	Set up the initial velocity_info struct for the device that has been
  *	discovered.
  */
-static void __devinit velocity_init_info(struct pci_dev *pdev,
+static void velocity_init_info(struct pci_dev *pdev,
 					 struct velocity_info *vptr,
 					 const struct velocity_info_tbl *info)
 {
@@ -2648,7 +2648,7 @@ static void __devinit velocity_init_info(struct pci_dev *pdev,
  *	Retrieve the PCI configuration space data that interests us from
  *	the kernel PCI layer
  */
-static int __devinit velocity_get_pci_info(struct velocity_info *vptr, struct pci_dev *pdev)
+static int velocity_get_pci_info(struct velocity_info *vptr, struct pci_dev *pdev)
 {
 	vptr->rev_id = pdev->revision;
 
@@ -2685,7 +2685,7 @@ static int __devinit velocity_get_pci_info(struct velocity_info *vptr, struct pc
  *	Print per driver data as the kernel driver finds Velocity
  *	hardware
  */
-static void __devinit velocity_print_info(struct velocity_info *vptr)
+static void velocity_print_info(struct velocity_info *vptr)
 {
 	struct net_device *dev = vptr->dev;
 
@@ -2709,7 +2709,7 @@ static u32 velocity_get_link(struct net_device *dev)
  *	Configure a discovered adapter from scratch. Return a negative
  *	errno error code on failure paths.
  */
-static int __devinit velocity_found1(struct pci_dev *pdev, const struct pci_device_id *ent)
+static int velocity_found1(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	static int first = 1;
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 82187f3..3babcfc 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -623,7 +623,7 @@ static const struct net_device_ops w5100_netdev_ops = {
 	.ndo_change_mtu		= eth_change_mtu,
 };
 
-static int __devinit w5100_hw_probe(struct platform_device *pdev)
+static int w5100_hw_probe(struct platform_device *pdev)
 {
 	struct wiznet_platform_data *data = pdev->dev.platform_data;
 	struct net_device *ndev = platform_get_drvdata(pdev);
@@ -698,7 +698,7 @@ static int __devinit w5100_hw_probe(struct platform_device *pdev)
 	return 0;
 }
 
-static int __devinit w5100_probe(struct platform_device *pdev)
+static int w5100_probe(struct platform_device *pdev)
 {
 	struct w5100_priv *priv;
 	struct net_device *ndev;
diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index 48c182e..3887747 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -543,7 +543,7 @@ static const struct net_device_ops w5300_netdev_ops = {
 	.ndo_change_mtu		= eth_change_mtu,
 };
 
-static int __devinit w5300_hw_probe(struct platform_device *pdev)
+static int w5300_hw_probe(struct platform_device *pdev)
 {
 	struct wiznet_platform_data *data = pdev->dev.platform_data;
 	struct net_device *ndev = platform_get_drvdata(pdev);
@@ -610,7 +610,7 @@ static int __devinit w5300_hw_probe(struct platform_device *pdev)
 	return 0;
 }
 
-static int __devinit w5300_probe(struct platform_device *pdev)
+static int w5300_probe(struct platform_device *pdev)
 {
 	struct w5300_priv *priv;
 	struct net_device *ndev;
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 6ac9e4c..c7375a8 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -1002,7 +1002,7 @@ static const struct ethtool_ops temac_ethtool_ops = {
 	.get_ts_info = ethtool_op_get_ts_info,
 };
 
-static int __devinit temac_of_probe(struct platform_device *op)
+static int temac_of_probe(struct platform_device *op)
 {
 	struct device_node *np;
 	struct temac_local *lp;
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 6020244..b8c9a33 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1476,7 +1476,7 @@ static void axienet_dma_err_handler(unsigned long data)
  * device. Parses through device tree and populates fields of
  * axienet_local. It registers the Ethernet device.
  */
-static int __devinit axienet_of_probe(struct platform_device *op)
+static int axienet_of_probe(struct platform_device *op)
 {
 	__be32 *p;
 	int size, ret = 0;
diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index c4d7a80..8d4f32d 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -1107,7 +1107,7 @@ static struct net_device_ops xemaclite_netdev_ops;
  * Return:	0, if the driver is bound to the Emaclite device, or
  *		a negative error if there is failure.
  */
-static int __devinit xemaclite_of_probe(struct platform_device *ofdev)
+static int xemaclite_of_probe(struct platform_device *ofdev)
 {
 	struct resource r_irq; /* Interrupt resources */
 	struct resource r_mem; /* IO mem resources */
diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index 98934bd..09164c8 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -1377,7 +1377,7 @@ static const struct net_device_ops ixp4xx_netdev_ops = {
 	.ndo_validate_addr = eth_validate_addr,
 };
 
-static int __devinit eth_init_one(struct platform_device *pdev)
+static int eth_init_one(struct platform_device *pdev)
 {
 	struct port *port;
 	struct net_device *dev;
-- 
1.8.0
