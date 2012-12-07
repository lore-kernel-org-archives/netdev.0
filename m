From: Greg KH <gregkh@linuxfoundation.org>
Subject: [PATCH] drivers/net: fix up function prototypes after __dev* removals
Date: Thu, 6 Dec 2012 16:30:56 -0800
Message-ID: <20121207003056.GA30167@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wfp5p@virginia.edu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:40119 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422841Ab2LGAbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 19:31:01 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so38122pad.19
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2012 16:31:00 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

The __dev* removal patches for the network drivers ended up messing up
the function prototypes for a bunch of drivers.  This patch fixes all of
them back up to be properly aligned.

Bonus is that this almost removes 100 lines of code, always a nice
surprise.

Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 drivers/net/can/c_can/c_can_pci.c                     |    2 
 drivers/net/can/cc770/cc770_platform.c                |    4 -
 drivers/net/can/mscan/mpc5xxx_can.c                   |   12 +----
 drivers/net/can/sja1000/ems_pci.c                     |    2 
 drivers/net/can/sja1000/ems_pcmcia.c                  |    3 -
 drivers/net/can/sja1000/kvaser_pci.c                  |    2 
 drivers/net/can/sja1000/peak_pci.c                    |    3 -
 drivers/net/can/sja1000/plx_pci.c                     |    2 
 drivers/net/can/softing/softing_cs.c                  |    3 -
 drivers/net/can/softing/softing_main.c                |    2 
 drivers/net/ethernet/3com/3c509.c                     |   11 +---
 drivers/net/ethernet/3com/3c59x.c                     |    7 +-
 drivers/net/ethernet/8390/hydra.c                     |    2 
 drivers/net/ethernet/8390/zorro8390.c                 |    7 +-
 drivers/net/ethernet/adaptec/starfire.c               |    2 
 drivers/net/ethernet/alteon/acenic.c                  |    7 +-
 drivers/net/ethernet/amd/a2065.c                      |    4 -
 drivers/net/ethernet/amd/ariadne.c                    |    2 
 drivers/net/ethernet/amd/hplance.c                    |    9 +--
 drivers/net/ethernet/amd/sunlance.c                   |    4 -
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c       |    3 -
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c       |    3 -
 drivers/net/ethernet/atheros/atlx/atl1.c              |    5 --
 drivers/net/ethernet/atheros/atlx/atl2.c              |    3 -
 drivers/net/ethernet/broadcom/b44.c                   |    2 
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c      |   17 ++-----
 drivers/net/ethernet/broadcom/tg3.c                   |    3 -
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c             |    3 -
 drivers/net/ethernet/chelsio/cxgb/sge.c               |    3 -
 drivers/net/ethernet/chelsio/cxgb/subr.c              |    7 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c       |    6 --
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c       |    5 --
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c            |    6 --
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c   |    2 
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c        |    3 -
 drivers/net/ethernet/cisco/enic/enic_main.c           |    3 -
 drivers/net/ethernet/dec/tulip/de2104x.c              |    3 -
 drivers/net/ethernet/dec/tulip/de4x5.c                |    2 
 drivers/net/ethernet/dec/tulip/dmfe.c                 |    3 -
 drivers/net/ethernet/dec/tulip/tulip_core.c           |    6 --
 drivers/net/ethernet/dec/tulip/winbond-840.c          |    3 -
 drivers/net/ethernet/emulex/benet/be_main.c           |    3 -
 drivers/net/ethernet/fealnx.c                         |    2 
 drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c  |    3 -
 drivers/net/ethernet/hp/hp100.c                       |    6 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c             |    4 -
 drivers/net/ethernet/ibm/emac/core.c                  |    8 +--
 drivers/net/ethernet/ibm/emac/mal.c                   |    3 -
 drivers/net/ethernet/ibm/ibmveth.c                    |    3 -
 drivers/net/ethernet/icplus/ipg.c                     |    3 -
 drivers/net/ethernet/intel/e100.c                     |    3 -
 drivers/net/ethernet/intel/e1000/e1000_main.c         |    3 -
 drivers/net/ethernet/intel/e1000/e1000_param.c        |    4 -
 drivers/net/ethernet/intel/e1000e/netdev.c            |    3 -
 drivers/net/ethernet/intel/e1000e/param.c             |    4 -
 drivers/net/ethernet/intel/igb/igb_main.c             |    3 -
 drivers/net/ethernet/intel/igbvf/netdev.c             |    3 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c         |    3 -
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c     |    3 -
 drivers/net/ethernet/marvell/skge.c                   |    3 -
 drivers/net/ethernet/marvell/sky2.c                   |    8 +--
 drivers/net/ethernet/mellanox/mlx4/main.c             |    3 -
 drivers/net/ethernet/micrel/ksz884x.c                 |    3 -
 drivers/net/ethernet/natsemi/macsonic.c               |    3 -
 drivers/net/ethernet/natsemi/natsemi.c                |    3 -
 drivers/net/ethernet/natsemi/ns83820.c                |    2 
 drivers/net/ethernet/neterion/s2io.h                  |    3 -
 drivers/net/ethernet/neterion/vxge/vxge-main.c        |   15 ++----
 drivers/net/ethernet/packetengines/yellowfin.c        |    2 
 drivers/net/ethernet/qlogic/qla3xxx.c                 |    2 
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c      |    3 -
 drivers/net/ethernet/qlogic/qlge/qlge_main.c          |    6 +-
 drivers/net/ethernet/rdc/r6040.c                      |    3 -
 drivers/net/ethernet/sfc/efx.c                        |    2 
 drivers/net/ethernet/sgi/ioc3-eth.c                   |    3 -
 drivers/net/ethernet/silan/sc92031.c                  |    3 -
 drivers/net/ethernet/sis/sis190.c                     |    9 +--
 drivers/net/ethernet/sis/sis900.c                     |    2 
 drivers/net/ethernet/smsc/epic100.c                   |    3 -
 drivers/net/ethernet/smsc/smc91x.c                    |    2 
 drivers/net/ethernet/smsc/smsc911x.c                  |    7 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c      |    2 
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |    8 +--
 drivers/net/ethernet/sun/cassini.c                    |    3 -
 drivers/net/ethernet/sun/niu.c                        |   43 +++++++-----------
 drivers/net/ethernet/sun/sunbmac.c                    |    2 
 drivers/net/ethernet/sun/sungem.c                     |    3 -
 drivers/net/ethernet/sun/sunhme.c                     |    2 
 drivers/net/ethernet/sun/sunvnet.c                    |    3 -
 drivers/net/ethernet/ti/tlan.c                        |    5 --
 drivers/net/ethernet/toshiba/ps3_gelic_net.c          |   10 +---
 drivers/net/ethernet/toshiba/tc35815.c                |    2 
 drivers/net/ethernet/via/via-rhine.c                  |    3 -
 drivers/net/ethernet/via/via-velocity.c               |    5 --
 drivers/net/fddi/defxx.c                              |   10 +---
 drivers/net/hippi/rrunner.c                           |    3 -
 drivers/net/irda/smsc-ircc2.c                         |    2 
 drivers/net/irda/via-ircc.c                           |    7 +-
 drivers/net/phy/mdio-gpio.c                           |    4 -
 drivers/net/wan/dscc4.c                               |    3 -
 drivers/net/wan/hd64570.c                             |    3 -
 drivers/net/wan/hd64572.c                             |    3 -
 drivers/net/wan/lmc/lmc_main.c                        |    3 -
 drivers/net/wan/pc300too.c                            |    2 
 drivers/net/wan/pci200syn.c                           |    2 
 drivers/net/wan/wanxl.c                               |    2 
 drivers/net/xen-netfront.c                            |    2 
 107 files changed, 188 insertions(+), 284 deletions(-)

diff --git a/drivers/net/can/c_can/c_can_pci.c b/drivers/net/can/c_can/c_can_pci.c
index a1f2631..b374be7 100644
--- a/drivers/net/can/c_can/c_can_pci.c
+++ b/drivers/net/can/c_can/c_can_pci.c
@@ -64,7 +64,7 @@ static void c_can_pci_write_reg_aligned_to_32bit(struct c_can_priv *priv,
 }
 
 static int c_can_pci_probe(struct pci_dev *pdev,
-				     const struct pci_device_id *ent)
+			   const struct pci_device_id *ent)
 {
 	struct c_can_pci_data *c_can_pci_data = (void *)ent->driver_data;
 	struct c_can_priv *priv;
diff --git a/drivers/net/can/cc770/cc770_platform.c b/drivers/net/can/cc770/cc770_platform.c
index 7d451cd..d0f6bfc 100644
--- a/drivers/net/can/cc770/cc770_platform.c
+++ b/drivers/net/can/cc770/cc770_platform.c
@@ -76,7 +76,7 @@ static void cc770_platform_write_reg(const struct cc770_priv *priv, int reg,
 }
 
 static int cc770_get_of_node_data(struct platform_device *pdev,
-					    struct cc770_priv *priv)
+				  struct cc770_priv *priv)
 {
 	struct device_node *np = pdev->dev.of_node;
 	const u32 *prop;
@@ -149,7 +149,7 @@ static int cc770_get_of_node_data(struct platform_device *pdev,
 }
 
 static int cc770_get_platform_data(struct platform_device *pdev,
-					     struct cc770_priv *priv)
+				   struct cc770_priv *priv)
 {
 
 	struct cc770_platform_data *pdata = pdev->dev.platform_data;
diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/mpc5xxx_can.c
index 06a4561..668850e 100644
--- a/drivers/net/can/mscan/mpc5xxx_can.c
+++ b/drivers/net/can/mscan/mpc5xxx_can.c
@@ -49,8 +49,7 @@ static struct of_device_id mpc52xx_cdm_ids[] = {
 };
 
 static u32 mpc52xx_can_get_clock(struct platform_device *ofdev,
-					   const char *clock_name,
-					   int *mscan_clksrc)
+				 const char *clock_name, int *mscan_clksrc)
 {
 	unsigned int pvr;
 	struct mpc52xx_cdm  __iomem *cdm;
@@ -102,8 +101,7 @@ static u32 mpc52xx_can_get_clock(struct platform_device *ofdev,
 }
 #else /* !CONFIG_PPC_MPC52xx */
 static u32 mpc52xx_can_get_clock(struct platform_device *ofdev,
-					   const char *clock_name,
-					   int *mscan_clksrc)
+				 const char *clock_name, int *mscan_clksrc)
 {
 	return 0;
 }
@@ -130,8 +128,7 @@ static struct of_device_id mpc512x_clock_ids[] = {
 };
 
 static u32 mpc512x_can_get_clock(struct platform_device *ofdev,
-					   const char *clock_name,
-					   int *mscan_clksrc)
+				 const char *clock_name, int *mscan_clksrc)
 {
 	struct mpc512x_clockctl __iomem *clockctl;
 	struct device_node *np_clock;
@@ -240,8 +237,7 @@ exit_put:
 }
 #else /* !CONFIG_PPC_MPC512x */
 static u32 mpc512x_can_get_clock(struct platform_device *ofdev,
-					   const char *clock_name,
-					   int *mscan_clksrc)
+				 const char *clock_name, int *mscan_clksrc)
 {
 	return 0;
 }
diff --git a/drivers/net/can/sja1000/ems_pci.c b/drivers/net/can/sja1000/ems_pci.c
index f232bc8..036a326 100644
--- a/drivers/net/can/sja1000/ems_pci.c
+++ b/drivers/net/can/sja1000/ems_pci.c
@@ -221,7 +221,7 @@ static void ems_pci_card_reset(struct ems_pci_card *card)
  * CAN channel to SJA1000 Socket-CAN subsystem.
  */
 static int ems_pci_add_card(struct pci_dev *pdev,
-					const struct pci_device_id *ent)
+			    const struct pci_device_id *ent)
 {
 	struct sja1000_priv *priv;
 	struct net_device *dev;
diff --git a/drivers/net/can/sja1000/ems_pcmcia.c b/drivers/net/can/sja1000/ems_pcmcia.c
index 46fc313..5c2f3fb 100644
--- a/drivers/net/can/sja1000/ems_pcmcia.c
+++ b/drivers/net/can/sja1000/ems_pcmcia.c
@@ -166,8 +166,7 @@ static void ems_pcmcia_del_card(struct pcmcia_device *pdev)
  * Probe PCI device for EMS CAN signature and register each available
  * CAN channel to SJA1000 Socket-CAN subsystem.
  */
-static int ems_pcmcia_add_card(struct pcmcia_device *pdev,
-					 unsigned long base)
+static int ems_pcmcia_add_card(struct pcmcia_device *pdev, unsigned long base)
 {
 	struct sja1000_priv *priv;
 	struct net_device *dev;
diff --git a/drivers/net/can/sja1000/kvaser_pci.c b/drivers/net/can/sja1000/kvaser_pci.c
index 4efdaf2..37b0381 100644
--- a/drivers/net/can/sja1000/kvaser_pci.c
+++ b/drivers/net/can/sja1000/kvaser_pci.c
@@ -291,7 +291,7 @@ failure:
 }
 
 static int kvaser_pci_init_one(struct pci_dev *pdev,
-					 const struct pci_device_id *ent)
+			       const struct pci_device_id *ent)
 {
 	int err;
 	struct net_device *master_dev = NULL;
diff --git a/drivers/net/can/sja1000/peak_pci.c b/drivers/net/can/sja1000/peak_pci.c
index 3faeb3d..d84888f 100644
--- a/drivers/net/can/sja1000/peak_pci.c
+++ b/drivers/net/can/sja1000/peak_pci.c
@@ -551,8 +551,7 @@ static void peak_pci_post_irq(const struct sja1000_priv *priv)
 		writew(chan->icr_mask, chan->cfg_base + PITA_ICR);
 }
 
-static int peak_pci_probe(struct pci_dev *pdev,
-				    const struct pci_device_id *ent)
+static int peak_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct sja1000_priv *priv;
 	struct peak_pci_chan *chan;
diff --git a/drivers/net/can/sja1000/plx_pci.c b/drivers/net/can/sja1000/plx_pci.c
index 8b233f8..11d1062 100644
--- a/drivers/net/can/sja1000/plx_pci.c
+++ b/drivers/net/can/sja1000/plx_pci.c
@@ -485,7 +485,7 @@ static void plx_pci_del_card(struct pci_dev *pdev)
  * available CAN channel to SJA1000 Socket-CAN subsystem.
  */
 static int plx_pci_add_card(struct pci_dev *pdev,
-				      const struct pci_device_id *ent)
+			    const struct pci_device_id *ent)
 {
 	struct sja1000_priv *priv;
 	struct net_device *dev;
diff --git a/drivers/net/can/softing/softing_cs.c b/drivers/net/can/softing/softing_cs.c
index ce18ba5..c2c0a5b 100644
--- a/drivers/net/can/softing/softing_cs.c
+++ b/drivers/net/can/softing/softing_cs.c
@@ -193,8 +193,7 @@ static int softingcs_enable_irq(struct platform_device *pdev, int v)
 /*
  * pcmcia check
  */
-static int softingcs_probe_config(struct pcmcia_device *pcmcia,
-		void *priv_data)
+static int softingcs_probe_config(struct pcmcia_device *pcmcia, void *priv_data)
 {
 	struct softing_platform_data *pdat = priv_data;
 	struct resource *pres;
diff --git a/drivers/net/can/softing/softing_main.c b/drivers/net/can/softing/softing_main.c
index 50b1e0f..3a2b456 100644
--- a/drivers/net/can/softing/softing_main.c
+++ b/drivers/net/can/softing/softing_main.c
@@ -646,7 +646,7 @@ static const struct can_bittiming_const softing_btr_const = {
 
 
 static struct net_device *softing_netdev_create(struct softing *card,
-		uint16_t chip_id)
+						uint16_t chip_id)
 {
 	struct net_device *netdev;
 	struct softing_priv *priv;
diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index 9300185..633c709 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -270,9 +270,8 @@ static int el3_isa_id_sequence(__be16 *phys_addr)
 
 }
 
-static void el3_dev_fill(struct net_device *dev, __be16 *phys_addr,
-				   int ioaddr, int irq, int if_port,
-				   enum el3_cardtype type)
+static void el3_dev_fill(struct net_device *dev, __be16 *phys_addr, int ioaddr,
+			 int irq, int if_port, enum el3_cardtype type)
 {
 	struct el3_private *lp = netdev_priv(dev);
 
@@ -283,8 +282,7 @@ static void el3_dev_fill(struct net_device *dev, __be16 *phys_addr,
 	lp->type = type;
 }
 
-static int el3_isa_match(struct device *pdev,
-				   unsigned int ndev)
+static int el3_isa_match(struct device *pdev, unsigned int ndev)
 {
 	struct net_device *dev;
 	int ioaddr, isa_irq, if_port, err;
@@ -406,8 +404,7 @@ static struct pnp_device_id el3_pnp_ids[] = {
 };
 MODULE_DEVICE_TABLE(pnp, el3_pnp_ids);
 
-static int el3_pnp_probe(struct pnp_dev *pdev,
-				    const struct pnp_device_id *id)
+static int el3_pnp_probe(struct pnp_dev *pdev, const struct pnp_device_id *id)
 {
 	short i;
 	int ioaddr, irq, if_port;
diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 658e224..ed0feb3 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -1001,7 +1001,7 @@ static int __init vortex_eisa_init(void)
 
 /* returns count (>= 0), or negative on error */
 static int vortex_init_one(struct pci_dev *pdev,
-				      const struct pci_device_id *ent)
+			   const struct pci_device_id *ent)
 {
 	int rc, unit, pci_bar;
 	struct vortex_chip_info *vci;
@@ -1088,9 +1088,8 @@ static const struct net_device_ops vortex_netdev_ops = {
  *
  * NOTE: pdev can be NULL, for the case of a Compaq device
  */
-static int vortex_probe1(struct device *gendev,
-				   void __iomem *ioaddr, int irq,
-				   int chip_idx, int card_idx)
+static int vortex_probe1(struct device *gendev, void __iomem *ioaddr, int irq,
+			 int chip_idx, int card_idx)
 {
 	struct vortex_private *vp;
 	int option;
diff --git a/drivers/net/ethernet/8390/hydra.c b/drivers/net/ethernet/8390/hydra.c
index bc81de1..fb3dd43 100644
--- a/drivers/net/ethernet/8390/hydra.c
+++ b/drivers/net/ethernet/8390/hydra.c
@@ -81,7 +81,7 @@ static struct zorro_driver hydra_driver = {
 };
 
 static int hydra_init_one(struct zorro_dev *z,
-				    const struct zorro_device_id *ent)
+			  const struct zorro_device_id *ent)
 {
     int err;
 
diff --git a/drivers/net/ethernet/8390/zorro8390.c b/drivers/net/ethernet/8390/zorro8390.c
index ceb89d9..85ec4c2 100644
--- a/drivers/net/ethernet/8390/zorro8390.c
+++ b/drivers/net/ethernet/8390/zorro8390.c
@@ -286,9 +286,8 @@ static const struct net_device_ops zorro8390_netdev_ops = {
 #endif
 };
 
-static int zorro8390_init(struct net_device *dev,
-				    unsigned long board, const char *name,
-				    unsigned long ioaddr)
+static int zorro8390_init(struct net_device *dev, unsigned long board,
+			  const char *name, unsigned long ioaddr)
 {
 	int i;
 	int err;
@@ -397,7 +396,7 @@ static int zorro8390_init(struct net_device *dev,
 }
 
 static int zorro8390_init_one(struct zorro_dev *z,
-					const struct zorro_device_id *ent)
+			      const struct zorro_device_id *ent)
 {
 	struct net_device *dev;
 	unsigned long board, ioaddr;
diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index d67c192..549b775 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -642,7 +642,7 @@ static const struct net_device_ops netdev_ops = {
 };
 
 static int starfire_init_one(struct pci_dev *pdev,
-				       const struct pci_device_id *ent)
+			     const struct pci_device_id *ent)
 {
 	struct device *d = &pdev->dev;
 	struct netdev_private *np;
diff --git a/drivers/net/ethernet/alteon/acenic.c b/drivers/net/ethernet/alteon/acenic.c
index dfddce6..c0bc41a 100644
--- a/drivers/net/ethernet/alteon/acenic.c
+++ b/drivers/net/ethernet/alteon/acenic.c
@@ -455,7 +455,7 @@ static const struct net_device_ops ace_netdev_ops = {
 };
 
 static int acenic_probe_one(struct pci_dev *pdev,
-		const struct pci_device_id *id)
+			    const struct pci_device_id *id)
 {
 	struct net_device *dev;
 	struct ace_private *ap;
@@ -2825,7 +2825,7 @@ static struct net_device_stats *ace_get_stats(struct net_device *dev)
 
 
 static void ace_copy(struct ace_regs __iomem *regs, const __be32 *src,
-			       u32 dest, int size)
+		     u32 dest, int size)
 {
 	void __iomem *tdest;
 	short tsize, i;
@@ -3091,8 +3091,7 @@ static void eeprom_stop(struct ace_regs __iomem *regs)
 /*
  * Read a whole byte from the EEPROM.
  */
-static int read_eeprom_byte(struct net_device *dev,
-				   unsigned long offset)
+static int read_eeprom_byte(struct net_device *dev, unsigned long offset)
 {
 	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs __iomem *regs = ap->regs;
diff --git a/drivers/net/ethernet/amd/a2065.c b/drivers/net/ethernet/amd/a2065.c
index 818f6d6..3789aff 100644
--- a/drivers/net/ethernet/amd/a2065.c
+++ b/drivers/net/ethernet/amd/a2065.c
@@ -640,7 +640,7 @@ static void lance_set_multicast(struct net_device *dev)
 }
 
 static int a2065_init_one(struct zorro_dev *z,
-				    const struct zorro_device_id *ent);
+			  const struct zorro_device_id *ent);
 static void a2065_remove_one(struct zorro_dev *z);
 
 
@@ -671,7 +671,7 @@ static const struct net_device_ops lance_netdev_ops = {
 };
 
 static int a2065_init_one(struct zorro_dev *z,
-				    const struct zorro_device_id *ent)
+			  const struct zorro_device_id *ent)
 {
 	struct net_device *dev;
 	struct lance_private *priv;
diff --git a/drivers/net/ethernet/amd/ariadne.c b/drivers/net/ethernet/amd/ariadne.c
index 2ea7a23..98f4522 100644
--- a/drivers/net/ethernet/amd/ariadne.c
+++ b/drivers/net/ethernet/amd/ariadne.c
@@ -711,7 +711,7 @@ static const struct net_device_ops ariadne_netdev_ops = {
 };
 
 static int ariadne_init_one(struct zorro_dev *z,
-				      const struct zorro_device_id *ent)
+			    const struct zorro_device_id *ent)
 {
 	unsigned long board = z->resource.start;
 	unsigned long base_addr = board + ARIADNE_LANCE;
diff --git a/drivers/net/ethernet/amd/hplance.c b/drivers/net/ethernet/amd/hplance.c
index 705333e..0c61fd5 100644
--- a/drivers/net/ethernet/amd/hplance.c
+++ b/drivers/net/ethernet/amd/hplance.c
@@ -46,10 +46,8 @@ struct hplance_private {
  * plus board-specific init, open and close actions.
  * Oh, and we need to tell the generic code how to read and write LANCE registers...
  */
-static int hplance_init_one(struct dio_dev *d,
-				const struct dio_device_id *ent);
-static void hplance_init(struct net_device *dev,
-				struct dio_dev *d);
+static int hplance_init_one(struct dio_dev *d, const struct dio_device_id *ent);
+static void hplance_init(struct net_device *dev, struct dio_dev *d);
 static void hplance_remove_one(struct dio_dev *d);
 static void hplance_writerap(void *priv, unsigned short value);
 static void hplance_writerdp(void *priv, unsigned short value);
@@ -83,8 +81,7 @@ static const struct net_device_ops hplance_netdev_ops = {
 };
 
 /* Find all the HP Lance boards and initialise them... */
-static int hplance_init_one(struct dio_dev *d,
-				const struct dio_device_id *ent)
+static int hplance_init_one(struct dio_dev *d, const struct dio_device_id *ent)
 {
 	struct net_device *dev;
 	int err = -ENOMEM;
diff --git a/drivers/net/ethernet/amd/sunlance.c b/drivers/net/ethernet/amd/sunlance.c
index 64dbffa..c2d696c 100644
--- a/drivers/net/ethernet/amd/sunlance.c
+++ b/drivers/net/ethernet/amd/sunlance.c
@@ -1305,8 +1305,8 @@ static const struct net_device_ops sparc_lance_ops = {
 };
 
 static int sparc_lance_probe_one(struct platform_device *op,
-					   struct platform_device *ledma,
-					   struct platform_device *lebuffer)
+				 struct platform_device *ledma,
+				 struct platform_device *lebuffer)
 {
 	struct device_node *dp = op->dev.of_node;
 	static unsigned version_printed;
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 44bee4a..56d3f69 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -2442,8 +2442,7 @@ static int atl1c_init_netdev(struct net_device *netdev, struct pci_dev *pdev)
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
  */
-static int atl1c_probe(struct pci_dev *pdev,
-				 const struct pci_device_id *ent)
+static int atl1c_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
 	struct atl1c_adapter *adapter;
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index dec5d2c..e4466a3 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -2235,8 +2235,7 @@ static int atl1e_init_netdev(struct net_device *netdev, struct pci_dev *pdev)
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
  */
-static int atl1e_probe(struct pci_dev *pdev,
-				 const struct pci_device_id *ent)
+static int atl1e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
 	struct atl1e_adapter *adapter = NULL;
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 3e7327e..71b3d7d 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -144,7 +144,7 @@ struct atl1_option {
 };
 
 static int atl1_validate_option(int *value, struct atl1_option *opt,
-	struct pci_dev *pdev)
+				struct pci_dev *pdev)
 {
 	if (*value == OPTION_UNSET) {
 		*value = opt->def;
@@ -2934,8 +2934,7 @@ static const struct net_device_ops atl1_netdev_ops = {
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
  */
-static int atl1_probe(struct pci_dev *pdev,
-	const struct pci_device_id *ent)
+static int atl1_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
 	struct atl1_adapter *adapter;
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 7dc9766..aab83a2 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -1338,8 +1338,7 @@ static const struct net_device_ops atl2_netdev_ops = {
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
  */
-static int atl2_probe(struct pci_dev *pdev,
-	const struct pci_device_id *ent)
+static int atl2_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
 	struct atl2_adapter *adapter;
diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index c64351f..219f622 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -2142,7 +2142,7 @@ static const struct net_device_ops b44_netdev_ops = {
 };
 
 static int b44_init_one(struct ssb_device *sdev,
-				  const struct ssb_device_id *ent)
+			const struct ssb_device_id *ent)
 {
 	struct net_device *dev;
 	struct b44 *bp;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 75aea83..abefccf 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9487,8 +9487,7 @@ static void bnx2x_prev_unload_close_mac(struct bnx2x *bp)
 #define BNX2X_PREV_UNDI_BD(val)		((val) >> 16 & 0xffff)
 #define BNX2X_PREV_UNDI_PROD(rcq, bd)	((bd) << 16 | (rcq))
 
-static void bnx2x_prev_unload_undi_inc(struct bnx2x *bp, u8 port,
-						 u8 inc)
+static void bnx2x_prev_unload_undi_inc(struct bnx2x *bp, u8 port, u8 inc)
 {
 	u16 rcq, bd;
 	u32 tmp_reg = REG_RD(bp, BNX2X_PREV_UNDI_PROD_ADDR(port));
@@ -10050,8 +10049,7 @@ static int bnx2x_get_igu_cam_info(struct bnx2x *bp)
 	return 0;
 }
 
-static void bnx2x_link_settings_supported(struct bnx2x *bp,
-						    u32 switch_cfg)
+static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
 {
 	int cfg_size = 0, idx, port = BP_PORT(bp);
 
@@ -11531,9 +11529,8 @@ static int bnx2x_set_coherency_mask(struct bnx2x *bp)
 	return 0;
 }
 
-static int bnx2x_init_dev(struct pci_dev *pdev,
-				    struct net_device *dev,
-				    unsigned long board_type)
+static int bnx2x_init_dev(struct pci_dev *pdev, struct net_device *dev,
+			  unsigned long board_type)
 {
 	struct bnx2x *bp;
 	int rc;
@@ -11713,8 +11710,7 @@ err_out:
 	return rc;
 }
 
-static void bnx2x_get_pcie_width_speed(struct bnx2x *bp,
-						 int *width, int *speed)
+static void bnx2x_get_pcie_width_speed(struct bnx2x *bp, int *width, int *speed)
 {
 	u32 val = REG_RD(bp, PCICFG_OFFSET + PCICFG_LINK_CONTROL);
 
@@ -12018,8 +12014,7 @@ static int bnx2x_get_num_non_def_sbs(struct pci_dev *pdev,
 	return control & PCI_MSIX_FLAGS_QSIZE;
 }
 
-static int bnx2x_init_one(struct pci_dev *pdev,
-				    const struct pci_device_id *ent)
+static int bnx2x_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *dev = NULL;
 	struct bnx2x *bp;
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 3f7b1c3..78ea90c 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -14873,8 +14873,7 @@ static bool tg3_10_100_only_device(struct tg3 *tp,
 	return false;
 }
 
-static int tg3_get_invariants(struct tg3 *tp,
-					const struct pci_device_id *ent)
+static int tg3_get_invariants(struct tg3 *tp, const struct pci_device_id *ent)
 {
 	u32 misc_ctrl_reg;
 	u32 pci_state_reg, grc_misc_cfg;
diff --git a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
index 5f60623..c8fdeaa 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
+++ b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
@@ -974,8 +974,7 @@ static const struct net_device_ops cxgb_netdev_ops = {
 #endif
 };
 
-static int init_one(struct pci_dev *pdev,
-			      const struct pci_device_id *ent)
+static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	static int version_printed;
 
diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethernet/chelsio/cxgb/sge.c
index 9a0a858..112665b 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -2071,8 +2071,7 @@ static void espibug_workaround(unsigned long data)
 /*
  * Creates a t1_sge structure and returns suggested resource parameters.
  */
-struct sge *t1_sge_create(struct adapter *adapter,
-				     struct sge_params *p)
+struct sge *t1_sge_create(struct adapter *adapter, struct sge_params *p)
 {
 	struct sge *sge = kzalloc(sizeof(*sge), GFP_KERNEL);
 	int i;
diff --git a/drivers/net/ethernet/chelsio/cxgb/subr.c b/drivers/net/ethernet/chelsio/cxgb/subr.c
index 9527dc1..e0a03a3 100644
--- a/drivers/net/ethernet/chelsio/cxgb/subr.c
+++ b/drivers/net/ethernet/chelsio/cxgb/subr.c
@@ -893,7 +893,7 @@ static void power_sequence_xpak(adapter_t* adapter)
 }
 
 int t1_get_board_rev(adapter_t *adapter, const struct board_info *bi,
-			       struct adapter_params *p)
+		     struct adapter_params *p)
 {
 	p->chip_version = bi->chip_term;
 	p->is_asic = (p->chip_version != CHBT_TERM_FPGA);
@@ -1029,7 +1029,7 @@ void t1_free_sw_modules(adapter_t *adapter)
 }
 
 static void init_link_config(struct link_config *lc,
-				       const struct board_info *bi)
+			     const struct board_info *bi)
 {
 	lc->supported = bi->caps;
 	lc->requested_speed = lc->speed = SPEED_INVALID;
@@ -1049,8 +1049,7 @@ static void init_link_config(struct link_config *lc,
  * Allocate and initialize the data structures that hold the SW state of
  * the Terminator HW modules.
  */
-int t1_init_sw_modules(adapter_t *adapter,
-				 const struct board_info *bi)
+int t1_init_sw_modules(adapter_t *adapter, const struct board_info *bi)
 {
 	unsigned int i;
 
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 4aa3b21..f15ee32 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -3108,8 +3108,7 @@ static int cxgb_enable_msix(struct adapter *adap)
 	return err;
 }
 
-static void print_port_info(struct adapter *adap,
-				      const struct adapter_info *ai)
+static void print_port_info(struct adapter *adap, const struct adapter_info *ai)
 {
 	static const char *pci_variant[] = {
 		"PCI", "PCI-X", "PCI-X ECC", "PCI-X 266", "PCI Express"
@@ -3176,8 +3175,7 @@ static void cxgb3_init_iscsi_mac(struct net_device *dev)
 #define TSO_FLAGS (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
 #define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | TSO_FLAGS | \
 			NETIF_F_IPV6_CSUM | NETIF_F_HIGHDMA)
-static int init_one(struct pci_dev *pdev,
-			      const struct pci_device_id *ent)
+static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	static int version_printed;
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index bef893d..130dd9d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2149,7 +2149,7 @@ static const struct file_operations mem_debugfs_fops = {
 };
 
 static void add_debugfs_mem(struct adapter *adap, const char *name,
-				      unsigned int idx, unsigned int size_mb)
+			    unsigned int idx, unsigned int size_mb)
 {
 	struct dentry *de;
 
@@ -4419,8 +4419,7 @@ static void free_some_resources(struct adapter *adapter)
 #define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | TSO_FLAGS | \
 		   NETIF_F_IPV6_CSUM | NETIF_F_HIGHDMA)
 
-static int init_one(struct pci_dev *pdev,
-			      const struct pci_device_id *ent)
+static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	int func, i, err;
 	struct port_info *pi;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 8ea7736..45f2bea 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -3440,8 +3440,7 @@ int t4_handle_fw_rpl(struct adapter *adap, const __be64 *rpl)
 	return 0;
 }
 
-static void get_pci_mode(struct adapter *adapter,
-				   struct pci_params *p)
+static void get_pci_mode(struct adapter *adapter, struct pci_params *p)
 {
 	u16 val;
 
@@ -3460,8 +3459,7 @@ static void get_pci_mode(struct adapter *adapter,
  *	Initializes the SW state maintained for each link, including the link's
  *	capabilities and default speed/flow-control/autonegotiation settings.
  */
-static void init_link_config(struct link_config *lc,
-				       unsigned int caps)
+static void init_link_config(struct link_config *lc, unsigned int caps)
 {
 	lc->supported = caps;
 	lc->requested_speed = 0;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index f866eb5..0188df7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2463,7 +2463,7 @@ static const struct net_device_ops cxgb4vf_netdev_ops	= {
  * the PF Driver ...
  */
 static int cxgb4vf_pci_probe(struct pci_dev *pdev,
-				       const struct pci_device_id *ent)
+			     const struct pci_device_id *ent)
 {
 	static int version_printed;
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 9b70ccc..7127c7b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -253,8 +253,7 @@ static int hash_mac_addr(const u8 *addr)
  *	Initializes the SW state maintained for each link, including the link's
  *	capabilities and default speed/flow-control/autonegotiation settings.
  */
-static void init_link_config(struct link_config *lc,
-				       unsigned int caps)
+static void init_link_config(struct link_config *lc, unsigned int caps)
 {
 	lc->supported = caps;
 	lc->requested_speed = 0;
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 930f03b..64866ff 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2275,8 +2275,7 @@ static void enic_iounmap(struct enic *enic)
 			iounmap(enic->bar[i].vaddr);
 }
 
-static int enic_probe(struct pci_dev *pdev,
-	const struct pci_device_id *ent)
+static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct device *dev = &pdev->dev;
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/ethernet/dec/tulip/de2104x.c
index 0918e38..eaab73c 100644
--- a/drivers/net/ethernet/dec/tulip/de2104x.c
+++ b/drivers/net/ethernet/dec/tulip/de2104x.c
@@ -1962,8 +1962,7 @@ static const struct net_device_ops de_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int de_init_one(struct pci_dev *pdev,
-		       const struct pci_device_id *ent)
+static int de_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *dev;
 	struct de_private *de;
diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index c411aed..4c83003 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -2104,7 +2104,7 @@ static struct eisa_driver de4x5_eisa_driver = {
         .driver   = {
                 .name    = "de4x5",
                 .probe   = de4x5_eisa_probe,
-		.remove	 = de4x5_eisa_remove,
+		.remove  = de4x5_eisa_remove,
         }
 };
 MODULE_DEVICE_TABLE(eisa, de4x5_eisa_ids);
diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index 56a8fe7..8313930 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -367,8 +367,7 @@ static const struct net_device_ops netdev_ops = {
  *	Search DM910X board ,allocate space and register it
  */
 
-static int dmfe_init_one(struct pci_dev *pdev,
-			 const struct pci_device_id *ent)
+static int dmfe_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct dmfe_board_info *db;	/* board information structure */
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index 157c8e6..1e9443d 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -1191,8 +1191,7 @@ static void set_rx_mode(struct net_device *dev)
 }
 
 #ifdef CONFIG_TULIP_MWI
-static void tulip_mwi_config(struct pci_dev *pdev,
-			     struct net_device *dev)
+static void tulip_mwi_config(struct pci_dev *pdev, struct net_device *dev)
 {
 	struct tulip_private *tp = netdev_priv(dev);
 	u8 cache;
@@ -1301,8 +1300,7 @@ DEFINE_PCI_DEVICE_TABLE(early_486_chipsets) = {
 	{ },
 };
 
-static int tulip_init_one(struct pci_dev *pdev,
-			  const struct pci_device_id *ent)
+static int tulip_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct tulip_private *tp;
 	/* See note below on the multiport cards. */
diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
index 0a1bda8..c7b04ec 100644
--- a/drivers/net/ethernet/dec/tulip/winbond-840.c
+++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
@@ -358,8 +358,7 @@ static const struct net_device_ops netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int w840_probe1(struct pci_dev *pdev,
-		       const struct pci_device_id *ent)
+static int w840_probe1(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *dev;
 	struct netdev_private *np;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index b003abc..f95612b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3994,8 +3994,7 @@ static inline char *func_name(struct be_adapter *adapter)
 	return be_physfn(adapter) ? "PF" : "VF";
 }
 
-static int be_probe(struct pci_dev *pdev,
-			const struct pci_device_id *pdev_id)
+static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 {
 	int status = 0;
 	struct be_adapter *adapter;
diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
index 519c289..c706b7a 100644
--- a/drivers/net/ethernet/fealnx.c
+++ b/drivers/net/ethernet/fealnx.c
@@ -478,7 +478,7 @@ static const struct net_device_ops netdev_ops = {
 };
 
 static int fealnx_init_one(struct pci_dev *pdev,
-				     const struct pci_device_id *ent)
+			   const struct pci_device_id *ent)
 {
 	struct netdev_private *np;
 	int i, option, err, irq;
diff --git a/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c b/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
index 3f35b6a..2bafbd3 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
@@ -108,8 +108,7 @@ static struct mdiobb_ops bb_ops = {
 	.get_mdio_data = mdio_read,
 };
 
-static int fs_mii_bitbang_init(struct mii_bus *bus,
-                                         struct device_node *np)
+static int fs_mii_bitbang_init(struct mii_bus *bus, struct device_node *np)
 {
 	struct resource res;
 	const u32 *data;
diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index 598e576..e3c7c69 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -447,8 +447,8 @@ static const struct net_device_ops hp100_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int hp100_probe1(struct net_device *dev, int ioaddr,
-				  u_char bus, struct pci_dev *pci_dev)
+static int hp100_probe1(struct net_device *dev, int ioaddr, u_char bus,
+			struct pci_dev *pci_dev)
 {
 	int i;
 	int err = -ENODEV;
@@ -2878,7 +2878,7 @@ static struct eisa_driver hp100_eisa_driver = {
         .driver   = {
                 .name    = "hp100",
                 .probe   = hp100_eisa_probe,
-		.remove	 = hp100_eisa_remove,
+		.remove  = hp100_eisa_remove,
         }
 };
 #endif
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index e238130..19b64de 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -99,7 +99,7 @@ static struct ehea_bcmc_reg_array ehea_bcmc_regs;
 
 
 static int ehea_probe_adapter(struct platform_device *dev,
-					const struct of_device_id *id);
+			      const struct of_device_id *id);
 
 static int ehea_remove(struct platform_device *dev);
 
@@ -3258,7 +3258,7 @@ static void ehea_remove_device_sysfs(struct platform_device *dev)
 }
 
 static int ehea_probe_adapter(struct platform_device *dev,
-					const struct of_device_id *id)
+			      const struct of_device_id *id)
 {
 	struct ehea_adapter *adapter;
 	const u64 *adapter_handle;
diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index c791ad3..256bdb8 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -2262,7 +2262,7 @@ struct emac_depentry {
 #define	EMAC_DEP_COUNT		6
 
 static int emac_check_deps(struct emac_instance *dev,
-				     struct emac_depentry *deps)
+			   struct emac_depentry *deps)
 {
 	int i, there = 0;
 	struct device_node *np;
@@ -2314,8 +2314,8 @@ static void emac_put_deps(struct emac_instance *dev)
 		of_dev_put(dev->tah_dev);
 }
 
-static int emac_of_bus_notify(struct notifier_block *nb,
-					unsigned long action, void *data)
+static int emac_of_bus_notify(struct notifier_block *nb, unsigned long action,
+			      void *data)
 {
 	/* We are only intereted in device addition */
 	if (action == BUS_NOTIFY_BOUND_DRIVER)
@@ -2368,7 +2368,7 @@ static int emac_wait_deps(struct emac_instance *dev)
 }
 
 static int emac_read_uint_prop(struct device_node *np, const char *name,
-					 u32 *val, int fatal)
+			       u32 *val, int fatal)
 {
 	int len;
 	const u32 *prop = of_get_property(np, name, &len);
diff --git a/drivers/net/ethernet/ibm/emac/mal.c b/drivers/net/ethernet/ibm/emac/mal.c
index 8becaaf..50ea12b 100644
--- a/drivers/net/ethernet/ibm/emac/mal.c
+++ b/drivers/net/ethernet/ibm/emac/mal.c
@@ -33,8 +33,7 @@
 
 static int mal_count;
 
-int mal_register_commac(struct mal_instance	*mal,
-				  struct mal_commac	*commac)
+int mal_register_commac(struct mal_instance *mal, struct mal_commac *commac)
 {
 	unsigned long flags;
 
diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 35485f2..f2fdbb7 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1324,8 +1324,7 @@ static const struct net_device_ops ibmveth_netdev_ops = {
 #endif
 };
 
-static int ibmveth_probe(struct vio_dev *dev,
-				   const struct vio_device_id *id)
+static int ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
 {
 	int rc, i;
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/icplus/ipg.c b/drivers/net/ethernet/icplus/ipg.c
index f80ae74..068d781 100644
--- a/drivers/net/ethernet/icplus/ipg.c
+++ b/drivers/net/ethernet/icplus/ipg.c
@@ -2199,8 +2199,7 @@ static const struct net_device_ops ipg_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int ipg_probe(struct pci_dev *pdev,
-			       const struct pci_device_id *id)
+static int ipg_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 {
 	unsigned int i = id->driver_data;
 	struct ipg_nic_private *sp;
diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 50c2050..a59f077 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2829,8 +2829,7 @@ static const struct net_device_ops e100_netdev_ops = {
 	.ndo_set_features	= e100_set_features,
 };
 
-static int e100_probe(struct pci_dev *pdev,
-	const struct pci_device_id *ent)
+static int e100_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
 	struct nic *nic;
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 840fb0d..294da56 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -938,8 +938,7 @@ static int e1000_init_hw_struct(struct e1000_adapter *adapter,
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
  **/
-static int e1000_probe(struct pci_dev *pdev,
-				 const struct pci_device_id *ent)
+static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
 	struct e1000_adapter *adapter;
diff --git a/drivers/net/ethernet/intel/e1000/e1000_param.c b/drivers/net/ethernet/intel/e1000/e1000_param.c
index 4e19aa0..750fc01 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_param.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_param.c
@@ -206,8 +206,8 @@ struct e1000_option {
 };
 
 static int e1000_validate_option(unsigned int *value,
-					   const struct e1000_option *opt,
-					   struct e1000_adapter *adapter)
+				 const struct e1000_option *opt,
+				 struct e1000_adapter *adapter)
 {
 	if (*value == OPTION_UNSET) {
 		*value = opt->def;
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 829e814..fbf75fd 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6024,8 +6024,7 @@ static const struct net_device_ops e1000e_netdev_ops = {
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
  **/
-static int e1000_probe(struct pci_dev *pdev,
-				 const struct pci_device_id *ent)
+static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
 	struct e1000_adapter *adapter;
diff --git a/drivers/net/ethernet/intel/e1000e/param.c b/drivers/net/ethernet/intel/e1000e/param.c
index b3beed2..89d536d 100644
--- a/drivers/net/ethernet/intel/e1000e/param.c
+++ b/drivers/net/ethernet/intel/e1000e/param.c
@@ -173,8 +173,8 @@ struct e1000_option {
 };
 
 static int e1000_validate_option(unsigned int *value,
-					   const struct e1000_option *opt,
-					   struct e1000_adapter *adapter)
+				 const struct e1000_option *opt,
+				 struct e1000_adapter *adapter)
 {
 	if (*value == OPTION_UNSET) {
 		*value = opt->def;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index de4ebb3..bd0f166 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1824,8 +1824,7 @@ void igb_set_fw_version(struct igb_adapter *adapter)
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
  **/
-static int igb_probe(struct pci_dev *pdev,
-			       const struct pci_device_id *ent)
+static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
 	struct igb_adapter *adapter;
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index b494309..277f5df 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -2618,8 +2618,7 @@ static const struct net_device_ops igbvf_netdev_ops = {
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
  **/
-static int igbvf_probe(struct pci_dev *pdev,
-                                 const struct pci_device_id *ent)
+static int igbvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
 	struct igbvf_adapter *adapter;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 2fa16de..c20a0e2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7183,8 +7183,7 @@ int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
  **/
-static int ixgbe_probe(struct pci_dev *pdev,
-				 const struct pci_device_id *ent)
+static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
 	struct ixgbe_adapter *adapter = NULL;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 1e2f02a..257357a 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3242,8 +3242,7 @@ static void ixgbevf_assign_netdev_ops(struct net_device *dev)
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
  **/
-static int ixgbevf_probe(struct pci_dev *pdev,
-				   const struct pci_device_id *ent)
+static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
 	struct ixgbevf_adapter *adapter = NULL;
diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 3d66e95..5544a1f 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -3869,8 +3869,7 @@ static void skge_show_addr(struct net_device *dev)
 
 static int only_32bit_dma;
 
-static int skge_probe(struct pci_dev *pdev,
-				const struct pci_device_id *ent)
+static int skge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *dev, *dev1;
 	struct skge_hw *hw;
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 6ddfbca..3269eb3 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -4741,9 +4741,8 @@ static const struct net_device_ops sky2_netdev_ops[2] = {
 };
 
 /* Initialize network device */
-static struct net_device *sky2_init_netdev(struct sky2_hw *hw,
-						     unsigned port,
-						     int highmem, int wol)
+static struct net_device *sky2_init_netdev(struct sky2_hw *hw, unsigned port,
+					   int highmem, int wol)
 {
 	struct sky2_port *sky2;
 	struct net_device *dev = alloc_etherdev(sizeof(*sky2));
@@ -4896,8 +4895,7 @@ static const char *sky2_name(u8 chipid, char *buf, int sz)
 	return buf;
 }
 
-static int sky2_probe(struct pci_dev *pdev,
-				const struct pci_device_id *ent)
+static int sky2_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *dev, *dev1;
 	struct sky2_hw *hw;
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 340551e..200cc0e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2224,8 +2224,7 @@ err_disable_pdev:
 	return err;
 }
 
-static int mlx4_init_one(struct pci_dev *pdev,
-				   const struct pci_device_id *id)
+static int mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 {
 	printk_once(KERN_INFO "%s", mlx4_version);
 
diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index f3f09b1..093d594 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -6919,8 +6919,7 @@ static void read_other_addr(struct ksz_hw *hw)
 #define PCI_VENDOR_ID_MICREL_KS		0x16c6
 #endif
 
-static int pcidev_init(struct pci_dev *pdev,
-	const struct pci_device_id *id)
+static int pcidev_init(struct pci_dev *pdev, const struct pci_device_id *id)
 {
 	struct net_device *dev;
 	struct dev_priv *priv;
diff --git a/drivers/net/ethernet/natsemi/macsonic.c b/drivers/net/ethernet/natsemi/macsonic.c
index eaddbb7..0ffde69 100644
--- a/drivers/net/ethernet/natsemi/macsonic.c
+++ b/drivers/net/ethernet/natsemi/macsonic.c
@@ -421,8 +421,7 @@ static int mac_onboard_sonic_probe(struct net_device *dev)
 }
 
 static int mac_nubus_sonic_ethernet_addr(struct net_device *dev,
-						unsigned long prom_addr,
-						int id)
+					 unsigned long prom_addr, int id)
 {
 	int i;
 	for(i = 0; i < 6; i++)
diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index 77f7cd3..f4ad60c 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -797,8 +797,7 @@ static const struct net_device_ops natsemi_netdev_ops = {
 #endif
 };
 
-static int natsemi_probe1(struct pci_dev *pdev,
-			  const struct pci_device_id *ent)
+static int natsemi_probe1(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *dev;
 	struct netdev_private *np;
diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index 0281755..77c070d 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -1942,7 +1942,7 @@ static const struct net_device_ops netdev_ops = {
 };
 
 static int ns83820_init_one(struct pci_dev *pci_dev,
-				      const struct pci_device_id *id)
+			    const struct pci_device_id *id)
 {
 	struct net_device *ndev;
 	struct ns83820 *dev;
diff --git a/drivers/net/ethernet/neterion/s2io.h b/drivers/net/ethernet/neterion/s2io.h
index 032f9b6..d89b6ed 100644
--- a/drivers/net/ethernet/neterion/s2io.h
+++ b/drivers/net/ethernet/neterion/s2io.h
@@ -1075,8 +1075,7 @@ static inline void SPECIAL_REG_WRITE(u64 val, void __iomem *addr, int order)
 /*
  * Prototype declaration.
  */
-static int s2io_init_nic(struct pci_dev *pdev,
-				   const struct pci_device_id *pre);
+static int s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre);
 static void s2io_rem_nic(struct pci_dev *pdev);
 static int init_shared_mem(struct s2io_nic *sp);
 static void free_shared_mem(struct s2io_nic *sp);
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index bb5770f..7c87105 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -3372,9 +3372,8 @@ static const struct net_device_ops vxge_netdev_ops = {
 };
 
 static int vxge_device_register(struct __vxge_hw_device *hldev,
-					  struct vxge_config *config,
-					  int high_dma, int no_of_vpath,
-					  struct vxgedev **vdev_out)
+				struct vxge_config *config, int high_dma,
+				int no_of_vpath, struct vxgedev **vdev_out)
 {
 	struct net_device *ndev;
 	enum vxge_hw_status status = VXGE_HW_OK;
@@ -3672,9 +3671,8 @@ static void verify_bandwidth(void)
 /*
  * Vpath configuration
  */
-static int vxge_config_vpaths(
-			struct vxge_hw_device_config *device_config,
-			u64 vpath_mask, struct vxge_config *config_param)
+static int vxge_config_vpaths(struct vxge_hw_device_config *device_config,
+			      u64 vpath_mask, struct vxge_config *config_param)
 {
 	int i, no_of_vpaths = 0, default_no_vpath = 0, temp;
 	u32 txdl_size, txdl_per_memblock;
@@ -3859,9 +3857,8 @@ static int vxge_config_vpaths(
 }
 
 /* initialize device configuratrions */
-static void vxge_device_config_init(
-				struct vxge_hw_device_config *device_config,
-				int *intr_type)
+static void vxge_device_config_init(struct vxge_hw_device_config *device_config,
+				    int *intr_type)
 {
 	/* Used for CQRQ/SRQ. */
 	device_config->dma_blockpool_initial =
diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
index 2800c44..fbaed4f 100644
--- a/drivers/net/ethernet/packetengines/yellowfin.c
+++ b/drivers/net/ethernet/packetengines/yellowfin.c
@@ -368,7 +368,7 @@ static const struct net_device_ops netdev_ops = {
 };
 
 static int yellowfin_init_one(struct pci_dev *pdev,
-					const struct pci_device_id *ent)
+			      const struct pci_device_id *ent)
 {
 	struct net_device *dev;
 	struct yellowfin_private *np;
diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index df6eb27..67a679a 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -3770,7 +3770,7 @@ static const struct net_device_ops ql3xxx_netdev_ops = {
 };
 
 static int ql3xxx_probe(struct pci_dev *pdev,
-				  const struct pci_device_id *pci_entry)
+			const struct pci_device_id *pci_entry)
 {
 	struct net_device *ndev = NULL;
 	struct ql3_adapter *qdev = NULL;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 8d58092..a7554d9 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -54,8 +54,7 @@ static int qlcnic_config_npars;
 module_param(qlcnic_config_npars, int, 0444);
 MODULE_PARM_DESC(qlcnic_config_npars, "Configure NPARs (0=disabled, 1=enabled");
 
-static int qlcnic_probe(struct pci_dev *pdev,
-		const struct pci_device_id *ent);
+static int qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent);
 static void qlcnic_remove(struct pci_dev *pdev);
 static int qlcnic_open(struct net_device *netdev);
 static int qlcnic_close(struct net_device *netdev);
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index cae881c..f80cd97 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -4491,8 +4491,8 @@ static void ql_release_all(struct pci_dev *pdev)
 	pci_set_drvdata(pdev, NULL);
 }
 
-static int ql_init_device(struct pci_dev *pdev,
-				    struct net_device *ndev, int cards_found)
+static int ql_init_device(struct pci_dev *pdev, struct net_device *ndev,
+			  int cards_found)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
 	int err = 0;
@@ -4657,7 +4657,7 @@ static void ql_timer(unsigned long data)
 }
 
 static int qlge_probe(struct pci_dev *pdev,
-				const struct pci_device_id *pci_entry)
+		      const struct pci_device_id *pci_entry)
 {
 	struct net_device *ndev = NULL;
 	struct ql_adapter *qdev = NULL;
diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index ae27e44..63c1312 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1073,8 +1073,7 @@ static int r6040_mii_probe(struct net_device *dev)
 	return 0;
 }
 
-static int r6040_init_one(struct pci_dev *pdev,
-					 const struct pci_device_id *ent)
+static int r6040_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *dev;
 	struct r6040_private *lp;
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index e95cc7b..bf57b3c 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2670,7 +2670,7 @@ static int efx_pci_probe_main(struct efx_nic *efx)
  * interfaces is brought up (i.e. efx_net_open).
  */
 static int efx_pci_probe(struct pci_dev *pci_dev,
-				   const struct pci_device_id *entry)
+			 const struct pci_device_id *entry)
 {
 	struct net_device *net_dev;
 	struct efx_nic *efx;
diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
index 4b1deec..dc171b4 100644
--- a/drivers/net/ethernet/sgi/ioc3-eth.c
+++ b/drivers/net/ethernet/sgi/ioc3-eth.c
@@ -1229,8 +1229,7 @@ static const struct net_device_ops ioc3_netdev_ops = {
 	.ndo_change_mtu		= eth_change_mtu,
 };
 
-static int ioc3_probe(struct pci_dev *pdev,
-	const struct pci_device_id *ent)
+static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	unsigned int sw_physid1, sw_physid2;
 	struct net_device *dev = NULL;
diff --git a/drivers/net/ethernet/silan/sc92031.c b/drivers/net/ethernet/silan/sc92031.c
index 2103449..b231532 100644
--- a/drivers/net/ethernet/silan/sc92031.c
+++ b/drivers/net/ethernet/silan/sc92031.c
@@ -1395,8 +1395,7 @@ static const struct net_device_ops sc92031_netdev_ops = {
 #endif
 };
 
-static int sc92031_probe(struct pci_dev *pdev,
-		const struct pci_device_id *id)
+static int sc92031_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 {
 	int err;
 	void __iomem* port_base;
diff --git a/drivers/net/ethernet/sis/sis190.c b/drivers/net/ethernet/sis/sis190.c
index c114c4f..9a9c379 100644
--- a/drivers/net/ethernet/sis/sis190.c
+++ b/drivers/net/ethernet/sis/sis190.c
@@ -1574,7 +1574,7 @@ static void sis190_set_rgmii(struct sis190_private *tp, u8 reg)
 }
 
 static int sis190_get_mac_addr_from_eeprom(struct pci_dev *pdev,
-						     struct net_device *dev)
+					   struct net_device *dev)
 {
 	struct sis190_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -1616,7 +1616,7 @@ static int sis190_get_mac_addr_from_eeprom(struct pci_dev *pdev,
  *	MAC address is read into @net_dev->dev_addr.
  */
 static int sis190_get_mac_addr_from_apc(struct pci_dev *pdev,
-						  struct net_device *dev)
+					struct net_device *dev)
 {
 	static const u16 ids[] = { 0x0965, 0x0966, 0x0968 };
 	struct sis190_private *tp = netdev_priv(dev);
@@ -1693,8 +1693,7 @@ static inline void sis190_init_rxfilter(struct net_device *dev)
 	SIS_PCI_COMMIT();
 }
 
-static int sis190_get_mac_addr(struct pci_dev *pdev,
-					 struct net_device *dev)
+static int sis190_get_mac_addr(struct pci_dev *pdev, struct net_device *dev)
 {
 	int rc;
 
@@ -1846,7 +1845,7 @@ static const struct net_device_ops sis190_netdev_ops = {
 };
 
 static int sis190_init_one(struct pci_dev *pdev,
-				     const struct pci_device_id *ent)
+			   const struct pci_device_id *ent)
 {
 	static int printed_version = 0;
 	struct sis190_private *tp;
diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index 88c6c42..5bffd97 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -435,7 +435,7 @@ static const struct net_device_ops sis900_netdev_ops = {
  */
 
 static int sis900_probe(struct pci_dev *pci_dev,
-				const struct pci_device_id *pci_id)
+			const struct pci_device_id *pci_id)
 {
 	struct sis900_private *sis_priv;
 	struct net_device *net_dev;
diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index 347cccb..03b256a 100644
--- a/drivers/net/ethernet/smsc/epic100.c
+++ b/drivers/net/ethernet/smsc/epic100.c
@@ -318,8 +318,7 @@ static const struct net_device_ops epic_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int epic_init_one(struct pci_dev *pdev,
-				   const struct pci_device_id *ent)
+static int epic_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	static int card_idx = -1;
 	void __iomem *ioaddr;
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index b085692..022b45b 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -1854,7 +1854,7 @@ static int smc_findirq(struct smc_local *lp)
  * o  GRAB the region
  */
 static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
-			    unsigned long irq_flags)
+		     unsigned long irq_flags)
 {
 	struct smc_local *lp = netdev_priv(dev);
 	static int version_printed = 0;
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index c52a5ce..39a7a49 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1032,7 +1032,7 @@ static int smsc911x_mii_probe(struct net_device *dev)
 }
 
 static int smsc911x_mii_init(struct platform_device *pdev,
-				       struct net_device *dev)
+			     struct net_device *dev)
 {
 	struct smsc911x_data *pdata = netdev_priv(dev);
 	int err = -ENXIO, i;
@@ -2296,9 +2296,8 @@ static const struct smsc911x_ops shifted_smsc911x_ops = {
 };
 
 #ifdef CONFIG_OF
-static int smsc911x_probe_config_dt(
-				struct smsc911x_platform_config *config,
-				struct device_node *np)
+static int smsc911x_probe_config_dt(struct smsc911x_platform_config *config,
+				    struct device_node *np)
 {
 	const char *mac;
 	u32 width = 0;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 5cf9eb6..064eaac 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -62,7 +62,7 @@ static void stmmac_default_data(void)
  * to take "ownership" of the device or an error code(-ve no) otherwise.
  */
 static int stmmac_pci_probe(struct pci_dev *pdev,
-				      const struct pci_device_id *id)
+			    const struct pci_device_id *id)
 {
 	int ret = 0;
 	void __iomem *addr = NULL;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index b77b913..b43d68b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -30,8 +30,8 @@
 
 #ifdef CONFIG_OF
 static int stmmac_probe_config_dt(struct platform_device *pdev,
-					    struct plat_stmmacenet_data *plat,
-					    const char **mac)
+				  struct plat_stmmacenet_data *plat,
+				  const char **mac)
 {
 	struct device_node *np = pdev->dev.of_node;
 
@@ -60,8 +60,8 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 }
 #else
 static int stmmac_probe_config_dt(struct platform_device *pdev,
-					    struct plat_stmmacenet_data *plat,
-					    const char **mac)
+				  struct plat_stmmacenet_data *plat,
+				  const char **mac)
 {
 	return -ENOSYS;
 }
diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index 85f971f..4c682a3 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -4916,8 +4916,7 @@ static const struct net_device_ops cas_netdev_ops = {
 #endif
 };
 
-static int cas_init_one(struct pci_dev *pdev,
-				  const struct pci_device_id *ent)
+static int cas_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	static int cas_version_printed = 0;
 	unsigned long casreg_len;
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 6023949..a0bdf07 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -8054,10 +8054,8 @@ static int niu_pci_eeprom_read16_swp(struct niu *np, u32 off)
 	return val;
 }
 
-static int niu_pci_vpd_get_propname(struct niu *np,
-					      u32 off,
-					      char *namebuf,
-					      int namebuf_len)
+static int niu_pci_vpd_get_propname(struct niu *np, u32 off, char *namebuf,
+				    int namebuf_len)
 {
 	int i;
 
@@ -8102,8 +8100,7 @@ static void niu_vpd_parse_version(struct niu *np)
 }
 
 /* ESPC_PIO_EN_ENABLE must be set */
-static int niu_pci_vpd_scan_props(struct niu *np,
-					    u32 start, u32 end)
+static int niu_pci_vpd_scan_props(struct niu *np, u32 start, u32 end)
 {
 	unsigned int found_mask = 0;
 #define FOUND_MASK_MODEL	0x00000001
@@ -8279,8 +8276,7 @@ static u32 niu_pci_vpd_offset(struct niu *np)
 	return 0;
 }
 
-static int niu_phy_type_prop_decode(struct niu *np,
-					      const char *phy_prop)
+static int niu_phy_type_prop_decode(struct niu *np, const char *phy_prop)
 {
 	if (!strcmp(phy_prop, "mif")) {
 		/* 1G copper, MII */
@@ -8572,10 +8568,8 @@ static int niu_get_and_validate_port(struct niu *np)
 	return 0;
 }
 
-static int phy_record(struct niu_parent *parent,
-				struct phy_probe_info *p,
-				int dev_id_1, int dev_id_2, u8 phy_port,
-				int type)
+static int phy_record(struct niu_parent *parent, struct phy_probe_info *p,
+		      int dev_id_1, int dev_id_2, u8 phy_port, int type)
 {
 	u32 id = (dev_id_1 << 16) | dev_id_2;
 	u8 idx;
@@ -8670,7 +8664,7 @@ static void niu_n2_divide_channels(struct niu_parent *parent)
 }
 
 static void niu_divide_channels(struct niu_parent *parent,
-					  int num_10g, int num_1g)
+				int num_10g, int num_1g)
 {
 	int num_ports = parent->num_ports;
 	int rx_chans_per_10g, rx_chans_per_1g;
@@ -8732,7 +8726,7 @@ static void niu_divide_channels(struct niu_parent *parent,
 }
 
 static void niu_divide_rdc_groups(struct niu_parent *parent,
-					    int num_10g, int num_1g)
+				  int num_10g, int num_1g)
 {
 	int i, num_ports = parent->num_ports;
 	int rdc_group, rdc_groups_per_port;
@@ -8776,9 +8770,8 @@ static void niu_divide_rdc_groups(struct niu_parent *parent,
 	}
 }
 
-static int fill_phy_probe_info(struct niu *np,
-					 struct niu_parent *parent,
-					 struct phy_probe_info *info)
+static int fill_phy_probe_info(struct niu *np, struct niu_parent *parent,
+			       struct phy_probe_info *info)
 {
 	unsigned long flags;
 	int port, err;
@@ -9480,8 +9473,7 @@ static struct device_attribute niu_parent_attributes[] = {
 };
 
 static struct niu_parent *niu_new_parent(struct niu *np,
-						    union niu_parent_id *id,
-						    u8 ptype)
+					 union niu_parent_id *id, u8 ptype)
 {
 	struct platform_device *plat_dev;
 	struct niu_parent *p;
@@ -9545,8 +9537,7 @@ fail_unregister:
 }
 
 static struct niu_parent *niu_get_parent(struct niu *np,
-						    union niu_parent_id *id,
-						    u8 ptype)
+					 union niu_parent_id *id, u8 ptype)
 {
 	struct niu_parent *p, *tmp;
 	int port = np->port;
@@ -9670,10 +9661,10 @@ static void niu_driver_version(void)
 		pr_info("%s", version);
 }
 
-static struct net_device *niu_alloc_and_init(
-	struct device *gen_dev, struct pci_dev *pdev,
-	struct platform_device *op, const struct niu_ops *ops,
-	u8 port)
+static struct net_device *niu_alloc_and_init(struct device *gen_dev,
+					     struct pci_dev *pdev,
+					     struct platform_device *op,
+					     const struct niu_ops *ops, u8 port)
 {
 	struct net_device *dev;
 	struct niu *np;
@@ -9757,7 +9748,7 @@ static void niu_set_basic_features(struct net_device *dev)
 }
 
 static int niu_pci_init_one(struct pci_dev *pdev,
-				      const struct pci_device_id *ent)
+			    const struct pci_device_id *ent)
 {
 	union niu_parent_id parent_id;
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/sun/sunbmac.c b/drivers/net/ethernet/sun/sunbmac.c
index 8fda910..be82f6d 100644
--- a/drivers/net/ethernet/sun/sunbmac.c
+++ b/drivers/net/ethernet/sun/sunbmac.c
@@ -1075,7 +1075,7 @@ static const struct net_device_ops bigmac_ops = {
 };
 
 static int bigmac_ether_init(struct platform_device *op,
-				       struct platform_device *qec_op)
+			     struct platform_device *qec_op)
 {
 	static int version_printed;
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index c7bc056..5f3f9d5 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -2827,8 +2827,7 @@ static const struct net_device_ops gem_netdev_ops = {
 #endif
 };
 
-static int gem_init_one(struct pci_dev *pdev,
-				  const struct pci_device_id *ent)
+static int gem_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	unsigned long gemreg_base, gemreg_len;
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 43babc3..a1bff49 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -2928,7 +2928,7 @@ static void get_hme_mac_nonsparc(struct pci_dev *pdev, unsigned char *dev_addr)
 #endif /* !(CONFIG_SPARC) */
 
 static int happy_meal_pci_probe(struct pci_dev *pdev,
-					  const struct pci_device_id *ent)
+				const struct pci_device_id *ent)
 {
 	struct quattro *qp = NULL;
 #ifdef CONFIG_SPARC
diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 2852b70..e1b8955 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -1132,8 +1132,7 @@ static void print_version(void)
 
 const char *remote_macaddr_prop = "remote-mac-address";
 
-static int vnet_port_probe(struct vio_dev *vdev,
-				     const struct vio_device_id *id)
+static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 {
 	struct mdesc_handle *hp;
 	struct vnet_port *port;
diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index af16081..2272538 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -460,9 +460,8 @@ static int tlan_init_one(struct pci_dev *pdev,
 *
 **************************************************************/
 
-static int tlan_probe1(struct pci_dev *pdev,
-				 long ioaddr, int irq, int rev,
-				 const struct pci_device_id *ent)
+static int tlan_probe1(struct pci_dev *pdev, long ioaddr, int irq, int rev,
+		       const struct pci_device_id *ent)
 {
 
 	struct net_device  *dev;
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
index d7c8af7..e321d0b 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
@@ -235,9 +235,8 @@ static void gelic_card_free_chain(struct gelic_card *card,
  * returns 0 on success, <0 on failure
  */
 static int gelic_card_init_chain(struct gelic_card *card,
-					   struct gelic_descr_chain *chain,
-					   struct gelic_descr *start_descr,
-					   int no)
+				 struct gelic_descr_chain *chain,
+				 struct gelic_descr *start_descr, int no)
 {
 	int i;
 	struct gelic_descr *descr;
@@ -1469,7 +1468,7 @@ static const struct net_device_ops gelic_netdevice_ops = {
  * fills out function pointers in the net_device structure
  */
 static void gelic_ether_setup_netdev_ops(struct net_device *netdev,
-						   struct napi_struct *napi)
+					 struct napi_struct *napi)
 {
 	netdev->watchdog_timeo = GELIC_NET_WATCHDOG_TIMEOUT;
 	/* NAPI */
@@ -1489,8 +1488,7 @@ static void gelic_ether_setup_netdev_ops(struct net_device *netdev,
  * gelic_ether_setup_netdev initializes the net_device structure
  * and register it.
  **/
-int gelic_net_setup_netdev(struct net_device *netdev,
-				     struct gelic_card *card)
+int gelic_net_setup_netdev(struct net_device *netdev, struct gelic_card *card)
 {
 	int status;
 	u64 v1, v2;
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 5db09ef..9819349 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -786,7 +786,7 @@ static const struct net_device_ops tc35815_netdev_ops = {
 };
 
 static int tc35815_init_one(struct pci_dev *pdev,
-				      const struct pci_device_id *ent)
+			    const struct pci_device_id *ent)
 {
 	void __iomem *ioaddr = NULL;
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 53ccc51..7992b3e 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -856,8 +856,7 @@ static const struct net_device_ops rhine_netdev_ops = {
 #endif
 };
 
-static int rhine_init_one(struct pci_dev *pdev,
-				    const struct pci_device_id *ent)
+static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *dev;
 	struct rhine_private *rp;
diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index dc9edd4..1bc7f9fd 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -2630,9 +2630,8 @@ static const struct net_device_ops velocity_netdev_ops = {
  *	Set up the initial velocity_info struct for the device that has been
  *	discovered.
  */
-static void velocity_init_info(struct pci_dev *pdev,
-					 struct velocity_info *vptr,
-					 const struct velocity_info_tbl *info)
+static void velocity_init_info(struct pci_dev *pdev, struct velocity_info *vptr,
+			       const struct velocity_info_tbl *info)
 {
 	memset(vptr, 0, sizeof(struct velocity_info));
 
diff --git a/drivers/net/fddi/defxx.c b/drivers/net/fddi/defxx.c
index 3c8aab7..502c8ff 100644
--- a/drivers/net/fddi/defxx.c
+++ b/drivers/net/fddi/defxx.c
@@ -962,9 +962,8 @@ static void dfx_bus_config_check(DFX_board_t *bp)
  *   returning from this routine.
  */
 
-static int dfx_driver_init(struct net_device *dev,
-				     const char *print_name,
-				     resource_size_t bar_start)
+static int dfx_driver_init(struct net_device *dev, const char *print_name,
+			   resource_size_t bar_start)
 {
 	DFX_board_t *bp = netdev_priv(dev);
 	struct device *bdev = bp->bus_dev;
@@ -3623,8 +3622,7 @@ static int __maybe_unused dfx_dev_register(struct device *);
 static int __maybe_unused dfx_dev_unregister(struct device *);
 
 #ifdef CONFIG_PCI
-static int dfx_pci_register(struct pci_dev *,
-				      const struct pci_device_id *);
+static int dfx_pci_register(struct pci_dev *, const struct pci_device_id *);
 static void dfx_pci_unregister(struct pci_dev *);
 
 static DEFINE_PCI_DEVICE_TABLE(dfx_pci_table) = {
@@ -3641,7 +3639,7 @@ static struct pci_driver dfx_pci_driver = {
 };
 
 static int dfx_pci_register(struct pci_dev *pdev,
-				      const struct pci_device_id *ent)
+			    const struct pci_device_id *ent)
 {
 	return dfx_register(&pdev->dev);
 }
diff --git a/drivers/net/hippi/rrunner.c b/drivers/net/hippi/rrunner.c
index e54b84d..e5b19b0 100644
--- a/drivers/net/hippi/rrunner.c
+++ b/drivers/net/hippi/rrunner.c
@@ -88,8 +88,7 @@ static const struct net_device_ops rr_netdev_ops = {
  * stack will need to know about I/O vectors or something similar.
  */
 
-static int rr_init_one(struct pci_dev *pdev,
-	const struct pci_device_id *ent)
+static int rr_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *dev;
 	static int version_disp;
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 82c5f30a..5290952 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -377,7 +377,7 @@ static int pnp_driver_registered;
 
 #ifdef CONFIG_PNP
 static int smsc_ircc_pnp_probe(struct pnp_dev *dev,
-				      const struct pnp_device_id *dev_id)
+			       const struct pnp_device_id *dev_id)
 {
 	unsigned int firbase, sirbase;
 	u8 dma, irq;
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 63efbf4..f9033c6 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -77,7 +77,7 @@ static int dongle_id = 0;	/* default: probe */
 module_param(dongle_id, int, 0);
 
 /* Some prototypes */
-static int via_ircc_open(struct pci_dev *pdev, chipio_t * info,
+static int via_ircc_open(struct pci_dev *pdev, chipio_t *info,
 			 unsigned int id);
 static int via_ircc_dma_receive(struct via_ircc_cb *self);
 static int via_ircc_dma_receive_complete(struct via_ircc_cb *self,
@@ -103,7 +103,7 @@ static void hwreset(struct via_ircc_cb *self);
 static int via_ircc_dma_xmit(struct via_ircc_cb *self, u16 iobase);
 static int upload_rxdata(struct via_ircc_cb *self, int iobase);
 static int via_init_one(struct pci_dev *pcidev, const struct pci_device_id *id);
-static void via_remove_one (struct pci_dev *pdev);
+static void via_remove_one(struct pci_dev *pdev);
 
 /* FIXME : Should use udelay() instead, even if we are x86 only - Jean II */
 static void iodelay(int udelay)
@@ -286,8 +286,7 @@ static const struct net_device_ops via_ircc_fir_ops = {
  *    Open driver instance
  *
  */
-static int via_ircc_open(struct pci_dev *pdev, chipio_t *info,
-			 unsigned int id)
+static int via_ircc_open(struct pci_dev *pdev, chipio_t *info, unsigned int id)
 {
 	struct net_device *dev;
 	struct via_ircc_cb *self;
diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 36fe08a..2727498 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -104,8 +104,8 @@ static struct mdiobb_ops mdio_gpio_ops = {
 };
 
 static struct mii_bus *mdio_gpio_bus_init(struct device *dev,
-					struct mdio_gpio_platform_data *pdata,
-					int bus_id)
+					  struct mdio_gpio_platform_data *pdata,
+					  int bus_id)
 {
 	struct mii_bus *new_bus;
 	struct mdio_gpio_info *bitbang;
diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index d502230..851dc7b 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -707,8 +707,7 @@ static void dscc4_free1(struct pci_dev *pdev)
 	kfree(ppriv);
 }
 
-static int dscc4_init_one(struct pci_dev *pdev,
-				  const struct pci_device_id *ent)
+static int dscc4_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct dscc4_pci_priv *priv;
 	struct dscc4_dev_priv *dpriv;
diff --git a/drivers/net/wan/hd64570.c b/drivers/net/wan/hd64570.c
index c6e1a4b..62f01b7 100644
--- a/drivers/net/wan/hd64570.c
+++ b/drivers/net/wan/hd64570.c
@@ -676,8 +676,7 @@ static netdev_tx_t sca_xmit(struct sk_buff *skb, struct net_device *dev)
 
 
 #ifdef NEED_DETECT_RAM
-static u32 sca_detect_ram(card_t *card, u8 __iomem *rambase,
-				    u32 ramsize)
+static u32 sca_detect_ram(card_t *card, u8 __iomem *rambase, u32 ramsize)
 {
 	/* Round RAM size to 32 bits, fill from end to start */
 	u32 i = ramsize &= ~3;
diff --git a/drivers/net/wan/hd64572.c b/drivers/net/wan/hd64572.c
index f1685d9..6269a09 100644
--- a/drivers/net/wan/hd64572.c
+++ b/drivers/net/wan/hd64572.c
@@ -605,8 +605,7 @@ static netdev_tx_t sca_xmit(struct sk_buff *skb, struct net_device *dev)
 }
 
 
-static u32 sca_detect_ram(card_t *card, u8 __iomem *rambase,
-				    u32 ramsize)
+static u32 sca_detect_ram(card_t *card, u8 __iomem *rambase, u32 ramsize)
 {
 	/* Round RAM size to 32 bits, fill from end to start */
 	u32 i = ramsize &= ~3;
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 0e443fd..7ef435b 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -816,8 +816,7 @@ static const struct net_device_ops lmc_ops = {
 	.ndo_get_stats  = lmc_get_stats,
 };
 
-static int lmc_init_one(struct pci_dev *pdev,
-				  const struct pci_device_id *ent)
+static int lmc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	lmc_softc_t *sc;
 	struct net_device *dev;
diff --git a/drivers/net/wan/pc300too.c b/drivers/net/wan/pc300too.c
index a51cfa7..53efc57 100644
--- a/drivers/net/wan/pc300too.c
+++ b/drivers/net/wan/pc300too.c
@@ -298,7 +298,7 @@ static const struct net_device_ops pc300_ops = {
 };
 
 static int pc300_pci_init_one(struct pci_dev *pdev,
-					const struct pci_device_id *ent)
+			      const struct pci_device_id *ent)
 {
 	card_t *card;
 	u32 __iomem *p;
diff --git a/drivers/net/wan/pci200syn.c b/drivers/net/wan/pci200syn.c
index 037c423..ddbce54 100644
--- a/drivers/net/wan/pci200syn.c
+++ b/drivers/net/wan/pci200syn.c
@@ -277,7 +277,7 @@ static const struct net_device_ops pci200_ops = {
 };
 
 static int pci200_pci_init_one(struct pci_dev *pdev,
-					 const struct pci_device_id *ent)
+			       const struct pci_device_id *ent)
 {
 	card_t *card;
 	u32 __iomem *p;
diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index b72be12..6a24a5a 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -558,7 +558,7 @@ static const struct net_device_ops wanxl_ops = {
 };
 
 static int wanxl_pci_init_one(struct pci_dev *pdev,
-					const struct pci_device_id *ent)
+			      const struct pci_device_id *ent)
 {
 	card_t *card;
 	u32 ramsize, stat;
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 53451dd..c26e28b 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1408,7 +1408,7 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
  * inform the backend of the appropriate details for those.
  */
 static int netfront_probe(struct xenbus_device *dev,
-				    const struct xenbus_device_id *id)
+			  const struct xenbus_device_id *id)
 {
 	int err;
 	struct net_device *netdev;
