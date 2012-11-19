From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 202/493] can: remove use of __devinit
Date: Mon, 19 Nov 2012 13:22:31 -0500
Message-ID: <1353349642-3677-202-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41322 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753782Ab2KSScw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:32:52 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devinit is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Wolfgang Grandegger <wg@grandegger.com> 
Cc: Marc Kleine-Budde <mkl@pengutronix.de> 
Cc: linux-can@vger.kernel.org 
Cc: netdev@vger.kernel.org 
---
 drivers/net/can/at91_can.c                    |  2 +-
 drivers/net/can/bfin_can.c                    |  2 +-
 drivers/net/can/c_can/c_can_pci.c             |  2 +-
 drivers/net/can/c_can/c_can_platform.c        |  2 +-
 drivers/net/can/cc770/cc770_isa.c             |  2 +-
 drivers/net/can/cc770/cc770_platform.c        |  6 +++---
 drivers/net/can/flexcan.c                     |  4 ++--
 drivers/net/can/janz-ican3.c                  | 16 ++++++++--------
 drivers/net/can/mcp251x.c                     |  2 +-
 drivers/net/can/mscan/mpc5xxx_can.c           | 10 +++++-----
 drivers/net/can/pch_can.c                     |  2 +-
 drivers/net/can/sja1000/ems_pci.c             |  2 +-
 drivers/net/can/sja1000/ems_pcmcia.c          |  4 ++--
 drivers/net/can/sja1000/kvaser_pci.c          |  2 +-
 drivers/net/can/sja1000/peak_pci.c            |  2 +-
 drivers/net/can/sja1000/peak_pcmcia.c         |  2 +-
 drivers/net/can/sja1000/plx_pci.c             |  2 +-
 drivers/net/can/sja1000/sja1000_isa.c         |  2 +-
 drivers/net/can/sja1000/sja1000_of_platform.c |  2 +-
 drivers/net/can/sja1000/tscan1.c              |  2 +-
 drivers/net/can/softing/softing_cs.c          |  6 +++---
 drivers/net/can/softing/softing_main.c        |  8 ++++----
 22 files changed, 42 insertions(+), 42 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 0f08305..32e60dd 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -1241,7 +1241,7 @@ static struct attribute_group at91_sysfs_attr_group = {
 	.attrs = at91_sysfs_attrs,
 };
 
-static int __devinit at91_can_probe(struct platform_device *pdev)
+static int at91_can_probe(struct platform_device *pdev)
 {
 	const struct at91_devtype_data *devtype_data;
 	enum at91_devtype devtype;
diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index ee4983a..16515e3 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -531,7 +531,7 @@ static const struct net_device_ops bfin_can_netdev_ops = {
 	.ndo_start_xmit         = bfin_can_start_xmit,
 };
 
-static int __devinit bfin_can_probe(struct platform_device *pdev)
+static int bfin_can_probe(struct platform_device *pdev)
 {
 	int err;
 	struct net_device *dev;
diff --git a/drivers/net/can/c_can/c_can_pci.c b/drivers/net/can/c_can/c_can_pci.c
index 019cf71..27db0f2 100644
--- a/drivers/net/can/c_can/c_can_pci.c
+++ b/drivers/net/can/c_can/c_can_pci.c
@@ -63,7 +63,7 @@ static void c_can_pci_write_reg_aligned_to_32bit(struct c_can_priv *priv,
 	writew(val, priv->base + 2 * priv->regs[index]);
 }
 
-static int __devinit c_can_pci_probe(struct pci_dev *pdev,
+static int c_can_pci_probe(struct pci_dev *pdev,
 				     const struct pci_device_id *ent)
 {
 	struct c_can_pci_data *c_can_pci_data = (void *)ent->driver_data;
diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index fed1dd1..91e7d2b 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -90,7 +90,7 @@ static const struct of_device_id c_can_of_table[] = {
 	{ /* sentinel */ },
 };
 
-static int __devinit c_can_plat_probe(struct platform_device *pdev)
+static int c_can_plat_probe(struct platform_device *pdev)
 {
 	int ret;
 	void __iomem *addr;
diff --git a/drivers/net/can/cc770/cc770_isa.c b/drivers/net/can/cc770/cc770_isa.c
index dfa9a45..9ca0461 100644
--- a/drivers/net/can/cc770/cc770_isa.c
+++ b/drivers/net/can/cc770/cc770_isa.c
@@ -166,7 +166,7 @@ static void cc770_isa_port_write_reg_indirect(const struct cc770_priv *priv,
 	spin_unlock_irqrestore(&cc770_isa_port_lock, flags);
 }
 
-static int __devinit cc770_isa_probe(struct platform_device *pdev)
+static int cc770_isa_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct cc770_priv *priv;
diff --git a/drivers/net/can/cc770/cc770_platform.c b/drivers/net/can/cc770/cc770_platform.c
index a294926..fef046f 100644
--- a/drivers/net/can/cc770/cc770_platform.c
+++ b/drivers/net/can/cc770/cc770_platform.c
@@ -74,7 +74,7 @@ static void cc770_platform_write_reg(const struct cc770_priv *priv, int reg,
 	iowrite8(val, priv->reg_base + reg);
 }
 
-static int __devinit cc770_get_of_node_data(struct platform_device *pdev,
+static int cc770_get_of_node_data(struct platform_device *pdev,
 					    struct cc770_priv *priv)
 {
 	struct device_node *np = pdev->dev.of_node;
@@ -147,7 +147,7 @@ static int __devinit cc770_get_of_node_data(struct platform_device *pdev,
 	return 0;
 }
 
-static int __devinit cc770_get_platform_data(struct platform_device *pdev,
+static int cc770_get_platform_data(struct platform_device *pdev,
 					     struct cc770_priv *priv)
 {
 
@@ -163,7 +163,7 @@ static int __devinit cc770_get_platform_data(struct platform_device *pdev,
 	return 0;
 }
 
-static int __devinit cc770_platform_probe(struct platform_device *pdev)
+static int cc770_platform_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct cc770_priv *priv;
diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 01e0201..dd3c933 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -922,7 +922,7 @@ static const struct net_device_ops flexcan_netdev_ops = {
 	.ndo_start_xmit	= flexcan_start_xmit,
 };
 
-static int __devinit register_flexcandev(struct net_device *dev)
+static int register_flexcandev(struct net_device *dev)
 {
 	struct flexcan_priv *priv = netdev_priv(dev);
 	struct flexcan_regs __iomem *regs = priv->base;
@@ -985,7 +985,7 @@ static const struct platform_device_id flexcan_id_table[] = {
 	{ /* sentinel */ },
 };
 
-static int __devinit flexcan_probe(struct platform_device *pdev)
+static int flexcan_probe(struct platform_device *pdev)
 {
 	const struct of_device_id *of_id;
 	const struct flexcan_devtype_data *devtype_data;
diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
index a9dfcb9..6eb1916 100644
--- a/drivers/net/can/janz-ican3.c
+++ b/drivers/net/can/janz-ican3.c
@@ -365,7 +365,7 @@ static int ican3_old_send_msg(struct ican3_dev *mod, struct ican3_msg *msg)
  * ICAN3 "new-style" Host Interface Setup
  */
 
-static void __devinit ican3_init_new_host_interface(struct ican3_dev *mod)
+static void ican3_init_new_host_interface(struct ican3_dev *mod)
 {
 	struct ican3_new_desc desc;
 	unsigned long flags;
@@ -444,7 +444,7 @@ static void __devinit ican3_init_new_host_interface(struct ican3_dev *mod)
  * ICAN3 Fast Host Interface Setup
  */
 
-static void __devinit ican3_init_fast_host_interface(struct ican3_dev *mod)
+static void ican3_init_fast_host_interface(struct ican3_dev *mod)
 {
 	struct ican3_fast_desc desc;
 	unsigned long flags;
@@ -631,7 +631,7 @@ static int ican3_recv_msg(struct ican3_dev *mod, struct ican3_msg *msg)
  * Quick Pre-constructed Messages
  */
 
-static int __devinit ican3_msg_connect(struct ican3_dev *mod)
+static int ican3_msg_connect(struct ican3_dev *mod)
 {
 	struct ican3_msg msg;
 
@@ -653,7 +653,7 @@ static int __devexit ican3_msg_disconnect(struct ican3_dev *mod)
 	return ican3_send_msg(mod, &msg);
 }
 
-static int __devinit ican3_msg_newhostif(struct ican3_dev *mod)
+static int ican3_msg_newhostif(struct ican3_dev *mod)
 {
 	struct ican3_msg msg;
 	int ret;
@@ -674,7 +674,7 @@ static int __devinit ican3_msg_newhostif(struct ican3_dev *mod)
 	return 0;
 }
 
-static int __devinit ican3_msg_fasthostif(struct ican3_dev *mod)
+static int ican3_msg_fasthostif(struct ican3_dev *mod)
 {
 	struct ican3_msg msg;
 	unsigned int addr;
@@ -707,7 +707,7 @@ static int __devinit ican3_msg_fasthostif(struct ican3_dev *mod)
  * Setup the CAN filter to either accept or reject all
  * messages from the CAN bus.
  */
-static int __devinit ican3_set_id_filter(struct ican3_dev *mod, bool accept)
+static int ican3_set_id_filter(struct ican3_dev *mod, bool accept)
 {
 	struct ican3_msg msg;
 	int ret;
@@ -1430,7 +1430,7 @@ static void __devexit ican3_shutdown_module(struct ican3_dev *mod)
 /*
  * Startup an ICAN module, bringing it into fast mode
  */
-static int __devinit ican3_startup_module(struct ican3_dev *mod)
+static int ican3_startup_module(struct ican3_dev *mod)
 {
 	int ret;
 
@@ -1760,7 +1760,7 @@ static struct attribute_group ican3_sysfs_attr_group = {
  * PCI Subsystem
  */
 
-static int __devinit ican3_probe(struct platform_device *pdev)
+static int ican3_probe(struct platform_device *pdev)
 {
 	struct janz_platform_data *pdata;
 	struct net_device *ndev;
diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 7a059d1..767fdbd 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -981,7 +981,7 @@ static const struct net_device_ops mcp251x_netdev_ops = {
 	.ndo_start_xmit = mcp251x_hard_start_xmit,
 };
 
-static int __devinit mcp251x_can_probe(struct spi_device *spi)
+static int mcp251x_can_probe(struct spi_device *spi)
 {
 	struct net_device *net;
 	struct mcp251x_priv *priv;
diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/mpc5xxx_can.c
index db59bbc..752bfed 100644
--- a/drivers/net/can/mscan/mpc5xxx_can.c
+++ b/drivers/net/can/mscan/mpc5xxx_can.c
@@ -48,7 +48,7 @@ static struct of_device_id __devinitdata mpc52xx_cdm_ids[] = {
 	{}
 };
 
-static u32 __devinit mpc52xx_can_get_clock(struct platform_device *ofdev,
+static u32 mpc52xx_can_get_clock(struct platform_device *ofdev,
 					   const char *clock_name,
 					   int *mscan_clksrc)
 {
@@ -101,7 +101,7 @@ static u32 __devinit mpc52xx_can_get_clock(struct platform_device *ofdev,
 	return freq;
 }
 #else /* !CONFIG_PPC_MPC52xx */
-static u32 __devinit mpc52xx_can_get_clock(struct platform_device *ofdev,
+static u32 mpc52xx_can_get_clock(struct platform_device *ofdev,
 					   const char *clock_name,
 					   int *mscan_clksrc)
 {
@@ -129,7 +129,7 @@ static struct of_device_id __devinitdata mpc512x_clock_ids[] = {
 	{}
 };
 
-static u32 __devinit mpc512x_can_get_clock(struct platform_device *ofdev,
+static u32 mpc512x_can_get_clock(struct platform_device *ofdev,
 					   const char *clock_name,
 					   int *mscan_clksrc)
 {
@@ -239,7 +239,7 @@ exit_put:
 	return freq;
 }
 #else /* !CONFIG_PPC_MPC512x */
-static u32 __devinit mpc512x_can_get_clock(struct platform_device *ofdev,
+static u32 mpc512x_can_get_clock(struct platform_device *ofdev,
 					   const char *clock_name,
 					   int *mscan_clksrc)
 {
@@ -248,7 +248,7 @@ static u32 __devinit mpc512x_can_get_clock(struct platform_device *ofdev,
 #endif /* CONFIG_PPC_MPC512x */
 
 static const struct of_device_id mpc5xxx_can_table[];
-static int __devinit mpc5xxx_can_probe(struct platform_device *ofdev)
+static int mpc5xxx_can_probe(struct platform_device *ofdev)
 {
 	const struct of_device_id *match;
 	const struct mpc5xxx_can_data *data;
diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 56145f9..fad4625 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -1178,7 +1178,7 @@ static int pch_can_get_berr_counter(const struct net_device *dev,
 	return 0;
 }
 
-static int __devinit pch_can_probe(struct pci_dev *pdev,
+static int pch_can_probe(struct pci_dev *pdev,
 				   const struct pci_device_id *id)
 {
 	struct net_device *ndev;
diff --git a/drivers/net/can/sja1000/ems_pci.c b/drivers/net/can/sja1000/ems_pci.c
index 5c6d412..f232bc8 100644
--- a/drivers/net/can/sja1000/ems_pci.c
+++ b/drivers/net/can/sja1000/ems_pci.c
@@ -220,7 +220,7 @@ static void ems_pci_card_reset(struct ems_pci_card *card)
  * Probe PCI device for EMS CAN signature and register each available
  * CAN channel to SJA1000 Socket-CAN subsystem.
  */
-static int __devinit ems_pci_add_card(struct pci_dev *pdev,
+static int ems_pci_add_card(struct pci_dev *pdev,
 					const struct pci_device_id *ent)
 {
 	struct sja1000_priv *priv;
diff --git a/drivers/net/can/sja1000/ems_pcmcia.c b/drivers/net/can/sja1000/ems_pcmcia.c
index 075a545..46fc313 100644
--- a/drivers/net/can/sja1000/ems_pcmcia.c
+++ b/drivers/net/can/sja1000/ems_pcmcia.c
@@ -166,7 +166,7 @@ static void ems_pcmcia_del_card(struct pcmcia_device *pdev)
  * Probe PCI device for EMS CAN signature and register each available
  * CAN channel to SJA1000 Socket-CAN subsystem.
  */
-static int __devinit ems_pcmcia_add_card(struct pcmcia_device *pdev,
+static int ems_pcmcia_add_card(struct pcmcia_device *pdev,
 					 unsigned long base)
 {
 	struct sja1000_priv *priv;
@@ -256,7 +256,7 @@ failure_cleanup:
 /*
  * Setup PCMCIA socket and probe for EMS CPC-CARD
  */
-static int __devinit ems_pcmcia_probe(struct pcmcia_device *dev)
+static int ems_pcmcia_probe(struct pcmcia_device *dev)
 {
 	int csval;
 
diff --git a/drivers/net/can/sja1000/kvaser_pci.c b/drivers/net/can/sja1000/kvaser_pci.c
index be95c42..a6191ac 100644
--- a/drivers/net/can/sja1000/kvaser_pci.c
+++ b/drivers/net/can/sja1000/kvaser_pci.c
@@ -290,7 +290,7 @@ failure:
 	return err;
 }
 
-static int __devinit kvaser_pci_init_one(struct pci_dev *pdev,
+static int kvaser_pci_init_one(struct pci_dev *pdev,
 					 const struct pci_device_id *ent)
 {
 	int err;
diff --git a/drivers/net/can/sja1000/peak_pci.c b/drivers/net/can/sja1000/peak_pci.c
index 0247efa..fbf61cf 100644
--- a/drivers/net/can/sja1000/peak_pci.c
+++ b/drivers/net/can/sja1000/peak_pci.c
@@ -551,7 +551,7 @@ static void peak_pci_post_irq(const struct sja1000_priv *priv)
 		writew(chan->icr_mask, chan->cfg_base + PITA_ICR);
 }
 
-static int __devinit peak_pci_probe(struct pci_dev *pdev,
+static int peak_pci_probe(struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
 {
 	struct sja1000_priv *priv;
diff --git a/drivers/net/can/sja1000/peak_pcmcia.c b/drivers/net/can/sja1000/peak_pcmcia.c
index 272a85f..f117514 100644
--- a/drivers/net/can/sja1000/peak_pcmcia.c
+++ b/drivers/net/can/sja1000/peak_pcmcia.c
@@ -632,7 +632,7 @@ static void pcan_free(struct pcmcia_device *pdev)
 /*
  * setup PCMCIA socket and probe for PEAK-System PC-CARD
  */
-static int __devinit pcan_probe(struct pcmcia_device *pdev)
+static int pcan_probe(struct pcmcia_device *pdev)
 {
 	struct pcan_pccard *card;
 	int err;
diff --git a/drivers/net/can/sja1000/plx_pci.c b/drivers/net/can/sja1000/plx_pci.c
index 8bc9598..619b96c 100644
--- a/drivers/net/can/sja1000/plx_pci.c
+++ b/drivers/net/can/sja1000/plx_pci.c
@@ -465,7 +465,7 @@ static void plx_pci_del_card(struct pci_dev *pdev)
  * Probe PLX90xx based device for the SJA1000 chips and register each
  * available CAN channel to SJA1000 Socket-CAN subsystem.
  */
-static int __devinit plx_pci_add_card(struct pci_dev *pdev,
+static int plx_pci_add_card(struct pci_dev *pdev,
 				      const struct pci_device_id *ent)
 {
 	struct sja1000_priv *priv;
diff --git a/drivers/net/can/sja1000/sja1000_isa.c b/drivers/net/can/sja1000/sja1000_isa.c
index f910102..3f12e85 100644
--- a/drivers/net/can/sja1000/sja1000_isa.c
+++ b/drivers/net/can/sja1000/sja1000_isa.c
@@ -117,7 +117,7 @@ static void sja1000_isa_port_write_reg_indirect(const struct sja1000_priv *priv,
 	outb(val, base + 1);
 }
 
-static int __devinit sja1000_isa_probe(struct platform_device *pdev)
+static int sja1000_isa_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct sja1000_priv *priv;
diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/net/can/sja1000/sja1000_of_platform.c
index a330fe8..259d5a1d 100644
--- a/drivers/net/can/sja1000/sja1000_of_platform.c
+++ b/drivers/net/can/sja1000/sja1000_of_platform.c
@@ -88,7 +88,7 @@ static int __devexit sja1000_ofp_remove(struct platform_device *ofdev)
 	return 0;
 }
 
-static int __devinit sja1000_ofp_probe(struct platform_device *ofdev)
+static int sja1000_ofp_probe(struct platform_device *ofdev)
 {
 	struct device_node *np = ofdev->dev.of_node;
 	struct net_device *dev;
diff --git a/drivers/net/can/sja1000/tscan1.c b/drivers/net/can/sja1000/tscan1.c
index 04a9001..9b608d8 100644
--- a/drivers/net/can/sja1000/tscan1.c
+++ b/drivers/net/can/sja1000/tscan1.c
@@ -88,7 +88,7 @@ static void tscan1_write(const struct sja1000_priv *priv, int reg, u8 val)
 }
 
 /* Probe for a TS-CAN1 board with JP2:JP1 jumper setting ID */
-static int __devinit tscan1_probe(struct device *dev, unsigned id)
+static int tscan1_probe(struct device *dev, unsigned id)
 {
 	struct net_device *netdev;
 	struct sja1000_priv *priv;
diff --git a/drivers/net/can/softing/softing_cs.c b/drivers/net/can/softing/softing_cs.c
index ab132c5..04e1539 100644
--- a/drivers/net/can/softing/softing_cs.c
+++ b/drivers/net/can/softing/softing_cs.c
@@ -159,7 +159,7 @@ MODULE_FIRMWARE(fw_dir "bcard2.bin");
 MODULE_FIRMWARE(fw_dir "ldcard2.bin");
 MODULE_FIRMWARE(fw_dir "cancrd2.bin");
 
-static __devinit const struct softing_platform_data
+static const struct softing_platform_data
 *softingcs_find_platform_data(unsigned int manf, unsigned int prod)
 {
 	const struct softing_platform_data *lp;
@@ -193,7 +193,7 @@ static int softingcs_enable_irq(struct platform_device *pdev, int v)
 /*
  * pcmcia check
  */
-static __devinit int softingcs_probe_config(struct pcmcia_device *pcmcia,
+static int softingcs_probe_config(struct pcmcia_device *pcmcia,
 		void *priv_data)
 {
 	struct softing_platform_data *pdat = priv_data;
@@ -235,7 +235,7 @@ static void softingcs_pdev_release(struct device *dev)
 	kfree(pdev);
 }
 
-static __devinit int softingcs_probe(struct pcmcia_device *pcmcia)
+static int softingcs_probe(struct pcmcia_device *pcmcia)
 {
 	int ret;
 	struct platform_device *pdev;
diff --git a/drivers/net/can/softing/softing_main.c b/drivers/net/can/softing/softing_main.c
index 6337581..aefd297 100644
--- a/drivers/net/can/softing/softing_main.c
+++ b/drivers/net/can/softing/softing_main.c
@@ -478,7 +478,7 @@ static void softing_card_shutdown(struct softing *card)
 	mutex_unlock(&card->fw.lock);
 }
 
-static __devinit int softing_card_boot(struct softing *card)
+static int softing_card_boot(struct softing *card)
 {
 	int ret, j;
 	static const uint8_t stream[] = {
@@ -645,7 +645,7 @@ static const struct can_bittiming_const softing_btr_const = {
 };
 
 
-static __devinit struct net_device *softing_netdev_create(struct softing *card,
+static struct net_device *softing_netdev_create(struct softing *card,
 		uint16_t chip_id)
 {
 	struct net_device *netdev;
@@ -676,7 +676,7 @@ static __devinit struct net_device *softing_netdev_create(struct softing *card,
 	return netdev;
 }
 
-static __devinit int softing_netdev_register(struct net_device *netdev)
+static int softing_netdev_register(struct net_device *netdev)
 {
 	int ret;
 
@@ -766,7 +766,7 @@ static __devexit int softing_pdev_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static __devinit int softing_pdev_probe(struct platform_device *pdev)
+static int softing_pdev_probe(struct platform_device *pdev)
 {
 	const struct softing_platform_data *pdat = pdev->dev.platform_data;
 	struct softing *card;
-- 
1.8.0
