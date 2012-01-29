From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers/net: Remove alloc_etherdev error messages
Date: Sun, 29 Jan 2012 15:47:52 -0800
Message-ID: <1327880872.2652.12.camel@joe2Laptop>
References: <1327877783.2652.10.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327877783.2652.10.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

alloc_etherdev has a generic OOM/unable to alloc message.
Remove the duplicative messages after alloc_etherdev calls.

Signed-off-by: Joe Perches <joe@perches.com>
---
Compiled x86 only.

 drivers/net/ethernet/3com/3c59x.c                  |    5 ++---
 drivers/net/ethernet/adaptec/starfire.c            |    5 ++---
 drivers/net/ethernet/adi/bfin_mac.c                |    4 +---
 drivers/net/ethernet/alteon/acenic.c               |    5 +----
 drivers/net/ethernet/amd/amd8111e.c                |    1 -
 drivers/net/ethernet/amd/au1000_eth.c              |    1 -
 drivers/net/ethernet/amd/declance.c                |    2 --
 drivers/net/ethernet/amd/pcnet32.c                 |    2 --
 drivers/net/ethernet/apple/bmac.c                  |    4 +---
 drivers/net/ethernet/apple/mace.c                  |    1 -
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |    1 -
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c    |    1 -
 drivers/net/ethernet/broadcom/b44.c                |    1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |    4 +---
 drivers/net/ethernet/broadcom/sb1250-mac.c         |    2 --
 drivers/net/ethernet/broadcom/tg3.c                |    1 -
 drivers/net/ethernet/brocade/bna/bnad.c            |    1 -
 drivers/net/ethernet/cadence/macb.c                |    4 +---
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    2 --
 drivers/net/ethernet/cisco/enic/enic_main.c        |    4 +---
 drivers/net/ethernet/davicom/dm9000.c              |    4 +---
 drivers/net/ethernet/dec/tulip/tulip_core.c        |    4 +---
 drivers/net/ethernet/dec/tulip/xircom_cb.c         |    5 ++---
 drivers/net/ethernet/dnet.c                        |    4 +---
 drivers/net/ethernet/ethoc.c                       |    1 -
 drivers/net/ethernet/hp/hp100.c                    |    1 -
 drivers/net/ethernet/ibm/ehea/ehea_main.c          |    1 -
 drivers/net/ethernet/ibm/emac/core.c               |    6 ++----
 drivers/net/ethernet/ibm/iseries_veth.c            |    4 +---
 drivers/net/ethernet/icplus/ipg.c                  |    1 -
 drivers/net/ethernet/intel/e100.c                  |    5 +----
 drivers/net/ethernet/jme.c                         |    1 -
 drivers/net/ethernet/korina.c                      |    5 ++---
 drivers/net/ethernet/lantiq_etop.c                 |    4 ++++
 drivers/net/ethernet/marvell/skge.c                |    4 +---
 drivers/net/ethernet/marvell/sky2.c                |    4 +---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |    4 +---
 drivers/net/ethernet/micrel/ks8695net.c            |    4 +---
 drivers/net/ethernet/micrel/ks8851.c               |    4 +---
 drivers/net/ethernet/microchip/enc28j60.c          |    3 ---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   |    4 +---
 drivers/net/ethernet/neterion/s2io.c               |    1 -
 drivers/net/ethernet/netx-eth.c                    |    1 -
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    2 --
 drivers/net/ethernet/packetengines/yellowfin.c     |    5 ++---
 drivers/net/ethernet/pasemi/pasemi_mac.c           |    2 --
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    1 -
 drivers/net/ethernet/qlogic/qla3xxx.c              |    1 -
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    1 -
 drivers/net/ethernet/rdc/r6040.c                   |    1 -
 drivers/net/ethernet/realtek/8139too.c             |    5 ++---
 drivers/net/ethernet/realtek/r8169.c               |    2 --
 drivers/net/ethernet/renesas/sh_eth.c              |    1 -
 drivers/net/ethernet/s6gmac.c                      |    6 +++---
 drivers/net/ethernet/seeq/sgiseeq.c                |    1 -
 drivers/net/ethernet/sis/sis190.c                  |    2 --
 drivers/net/ethernet/smsc/epic100.c                |    5 ++---
 drivers/net/ethernet/smsc/smc911x.c                |    1 -
 drivers/net/ethernet/smsc/smc91x.c                 |    1 -
 drivers/net/ethernet/smsc/smsc911x.c               |    1 -
 drivers/net/ethernet/smsc/smsc9420.c               |    4 +---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    4 +---
 drivers/net/ethernet/sun/cassini.c                 |    1 -
 drivers/net/ethernet/sun/niu.c                     |    4 +---
 drivers/net/ethernet/sun/sungem.c                  |    1 -
 drivers/net/ethernet/sun/sunvnet.c                 |    4 +---
 drivers/net/ethernet/tehuti/tehuti.c               |    1 -
 drivers/net/ethernet/ti/cpmac.c                    |    5 +----
 drivers/net/ethernet/ti/davinci_emac.c             |    1 -
 drivers/net/ethernet/ti/tlan.c                     |    1 -
 drivers/net/ethernet/toshiba/tc35815.c             |    5 ++---
 drivers/net/ethernet/tundra/tsi108_eth.c           |    4 +---
 drivers/net/ethernet/via/via-rhine.c               |    1 -
 drivers/net/ethernet/via/via-velocity.c            |    4 +---
 drivers/net/ethernet/xilinx/ll_temac_main.c        |    5 ++---
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c  |    4 +---
 drivers/net/ethernet/xilinx/xilinx_emaclite.c      |    4 +---
 drivers/net/plip/plip.c                            |    4 +---
 drivers/net/rionet.c                               |    2 --
 drivers/net/usb/pegasus.c                          |    4 +---
 drivers/net/usb/rtl8150.c                          |    4 +---
 drivers/net/usb/usbnet.c                           |    4 +---
 drivers/net/vmxnet3/vmxnet3_drv.c                  |    5 +----
 drivers/net/wireless/atmel.c                       |    5 ++---
 drivers/net/wireless/ipw2x00/libipw_module.c       |    5 ++---
 drivers/net/xen-netfront.c                         |    5 +----
 86 files changed, 63 insertions(+), 192 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 8153a3e..dc51d92 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -1121,10 +1121,9 @@ static int __devinit vortex_probe1(struct device *gendev,
 
 	dev = alloc_etherdev(sizeof(*vp));
 	retval = -ENOMEM;
-	if (!dev) {
-		pr_err(PFX "unable to allocate etherdev, aborting\n");
+	if (!dev)
 		goto out;
-	}
+
 	SET_NETDEV_DEV(dev, gendev);
 	vp = netdev_priv(dev);
 
diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index cb4f38a..11fc2ec 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -686,10 +686,9 @@ static int __devinit starfire_init_one(struct pci_dev *pdev,
 	}
 
 	dev = alloc_etherdev(sizeof(*np));
-	if (!dev) {
-		printk(KERN_ERR DRV_NAME " %d: cannot alloc etherdev, aborting\n", card_idx);
+	if (!dev)
 		return -ENOMEM;
-	}
+
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	irq = pdev->irq;
diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index d812a10..525a976 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1467,10 +1467,8 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 	int rc;
 
 	ndev = alloc_etherdev(sizeof(struct bfin_mac_local));
-	if (!ndev) {
-		dev_err(&pdev->dev, "Cannot allocate net device!\n");
+	if (!ndev)
 		return -ENOMEM;
-	}
 
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 	platform_set_drvdata(pdev, ndev);
diff --git a/drivers/net/ethernet/alteon/acenic.c b/drivers/net/ethernet/alteon/acenic.c
index f872748..6c3b1c0 100644
--- a/drivers/net/ethernet/alteon/acenic.c
+++ b/drivers/net/ethernet/alteon/acenic.c
@@ -463,11 +463,8 @@ static int __devinit acenic_probe_one(struct pci_dev *pdev,
 	static int boards_found;
 
 	dev = alloc_etherdev(sizeof(struct ace_private));
-	if (dev == NULL) {
-		printk(KERN_ERR "acenic: Unable to allocate "
-		       "net_device structure!\n");
+	if (dev == NULL)
 		return -ENOMEM;
-	}
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 33e0a8c..b8306a5 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -1859,7 +1859,6 @@ static int __devinit amd8111e_probe_one(struct pci_dev *pdev,
 
 	dev = alloc_etherdev(sizeof(struct amd8111e_priv));
 	if (!dev) {
-		printk(KERN_ERR "amd8111e: Etherdev alloc failed, exiting.\n");
 		err = -ENOMEM;
 		goto err_free_reg;
 	}
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index 8b95dd3..a81c871 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -1077,7 +1077,6 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 
 	dev = alloc_etherdev(sizeof(struct au1000_private));
 	if (!dev) {
-		dev_err(&pdev->dev, "alloc_etherdev failed\n");
 		err = -ENOMEM;
 		goto err_alloc;
 	}
diff --git a/drivers/net/ethernet/amd/declance.c b/drivers/net/ethernet/amd/declance.c
index 73f8d4f..dd82ee2 100644
--- a/drivers/net/ethernet/amd/declance.c
+++ b/drivers/net/ethernet/amd/declance.c
@@ -1052,8 +1052,6 @@ static int __devinit dec_lance_probe(struct device *bdev, const int type)
 
 	dev = alloc_etherdev(sizeof(struct lance_private));
 	if (!dev) {
-		printk(KERN_ERR "%s: Unable to allocate etherdev, aborting.\n",
-			name);
 		ret = -ENOMEM;
 		goto err_out;
 	}
diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 20e6dab..1bb388f 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -1649,8 +1649,6 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 
 	dev = alloc_etherdev(sizeof(*lp));
 	if (!dev) {
-		if (pcnet32_debug & NETIF_MSG_PROBE)
-			pr_err("Memory allocation failed\n");
 		ret = -ENOMEM;
 		goto err_release_region;
 	}
diff --git a/drivers/net/ethernet/apple/bmac.c b/drivers/net/ethernet/apple/bmac.c
index 4108ac8..ebc0dba 100644
--- a/drivers/net/ethernet/apple/bmac.c
+++ b/drivers/net/ethernet/apple/bmac.c
@@ -1269,10 +1269,8 @@ static int __devinit bmac_probe(struct macio_dev *mdev, const struct of_device_i
 	memcpy(addr, prop_addr, sizeof(addr));
 
 	dev = alloc_etherdev(PRIV_BYTES);
-	if (!dev) {
-		printk(KERN_ERR "BMAC: alloc_etherdev failed, out of memory\n");
+	if (!dev)
 		return -ENOMEM;
-	}
 
 	bp = netdev_priv(dev);
 	SET_NETDEV_DEV(dev, &mdev->ofdev.dev);
diff --git a/drivers/net/ethernet/apple/mace.c b/drivers/net/ethernet/apple/mace.c
index 45ba18e..bd5555d 100644
--- a/drivers/net/ethernet/apple/mace.c
+++ b/drivers/net/ethernet/apple/mace.c
@@ -147,7 +147,6 @@ static int __devinit mace_probe(struct macio_dev *mdev, const struct of_device_i
 
 	dev = alloc_etherdev(PRIV_BYTES);
 	if (!dev) {
-		printk(KERN_ERR "MACE: can't allocate ethernet device !\n");
 		rc = -ENOMEM;
 		goto err_release;
 	}
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index b859124..7ee4aac 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -2689,7 +2689,6 @@ static int __devinit atl1c_probe(struct pci_dev *pdev,
 	netdev = alloc_etherdev(sizeof(struct atl1c_adapter));
 	if (netdev == NULL) {
 		err = -ENOMEM;
-		dev_err(&pdev->dev, "etherdev alloc failed\n");
 		goto err_alloc_etherdev;
 	}
 
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index c915c08..93ff2b2 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -2300,7 +2300,6 @@ static int __devinit atl1e_probe(struct pci_dev *pdev,
 	netdev = alloc_etherdev(sizeof(struct atl1e_adapter));
 	if (netdev == NULL) {
 		err = -ENOMEM;
-		dev_err(&pdev->dev, "etherdev alloc failed\n");
 		goto err_alloc_etherdev;
 	}
 
diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 3fb66d0..66f53c7 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -2138,7 +2138,6 @@ static int __devinit b44_init_one(struct ssb_device *sdev,
 
 	dev = alloc_etherdev(sizeof(*bp));
 	if (!dev) {
-		dev_err(sdev->dev, "Etherdev alloc failed, aborting\n");
 		err = -ENOMEM;
 		goto out;
 	}
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 582cbcf..ff19c3c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11133,10 +11133,8 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 
 	/* dev zeroed in init_etherdev */
 	dev = alloc_etherdev_mqs(sizeof(*bp), tx_count, rx_count);
-	if (!dev) {
-		dev_err(&pdev->dev, "Cannot allocate net device\n");
+	if (!dev)
 		return -ENOMEM;
-	}
 
 	bp = netdev_priv(dev);
 
diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
index 084904c..49e7a25 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -2623,8 +2623,6 @@ static int __devinit sbmac_probe(struct platform_device *pldev)
 	 */
 	dev = alloc_etherdev(sizeof(struct sbmac_softc));
 	if (!dev) {
-		printk(KERN_ERR "%s: unable to allocate etherdev\n",
-		       dev_name(&pldev->dev));
 		err = -ENOMEM;
 		goto out_unmap;
 	}
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index a1f2e0f..3bf3adc 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -15471,7 +15471,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	dev = alloc_etherdev_mq(sizeof(*tp), TG3_IRQ_MAX_VECS);
 	if (!dev) {
-		dev_err(&pdev->dev, "Etherdev alloc failed, aborting\n");
 		err = -ENOMEM;
 		goto err_out_power_down;
 	}
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index be7d91e..ff78f77 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3284,7 +3284,6 @@ bnad_pci_probe(struct pci_dev *pdev,
 	 */
 	netdev = alloc_etherdev(sizeof(struct bnad));
 	if (!netdev) {
-		dev_err(&pdev->dev, "netdev allocation failed\n");
 		err = -ENOMEM;
 		return err;
 	}
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 2320068..3c315f4 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1308,10 +1308,8 @@ static int __init macb_probe(struct platform_device *pdev)
 
 	err = -ENOMEM;
 	dev = alloc_etherdev(sizeof(*bp));
-	if (!dev) {
-		dev_err(&pdev->dev, "etherdev alloc failed, aborting.\n");
+	if (!dev)
 		goto err_out;
-	}
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index e53365a..9045a45 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2596,8 +2596,6 @@ static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
 		netdev = alloc_etherdev_mq(sizeof(struct port_info),
 					   MAX_PORT_QSETS);
 		if (netdev == NULL) {
-			dev_err(&pdev->dev, "cannot allocate netdev for"
-				" port %d\n", port_id);
 			t4vf_free_vi(adapter, viid);
 			err = -ENOMEM;
 			goto err_free_dev;
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 07df137..2838891 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2280,10 +2280,8 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	 */
 
 	netdev = alloc_etherdev(sizeof(struct enic));
-	if (!netdev) {
-		pr_err("Etherdev alloc failed, aborting\n");
+	if (!netdev)
 		return -ENOMEM;
-	}
 
 	pci_set_drvdata(pdev, netdev);
 
diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index f801754..493cc62 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1373,10 +1373,8 @@ dm9000_probe(struct platform_device *pdev)
 
 	/* Init network device */
 	ndev = alloc_etherdev(sizeof(struct board_info));
-	if (!ndev) {
-		dev_err(&pdev->dev, "could not allocate device.\n");
+	if (!ndev)
 		return -ENOMEM;
-	}
 
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index 4eb0d76..17ecb18 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -1424,10 +1424,8 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 
 	/* alloc_etherdev ensures aligned and zeroed private structures */
 	dev = alloc_etherdev (sizeof (*tp));
-	if (!dev) {
-		pr_err("ether device alloc failed, aborting\n");
+	if (!dev)
 		return -ENOMEM;
-	}
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	if (pci_resource_len (pdev, 0) < tulip_tbl[chip_idx].io_size) {
diff --git a/drivers/net/ethernet/dec/tulip/xircom_cb.c b/drivers/net/ethernet/dec/tulip/xircom_cb.c
index 988b8eb..b7c73ee 100644
--- a/drivers/net/ethernet/dec/tulip/xircom_cb.c
+++ b/drivers/net/ethernet/dec/tulip/xircom_cb.c
@@ -222,10 +222,9 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 	   is available.
 	 */
 	dev = alloc_etherdev(sizeof(struct xircom_private));
-	if (!dev) {
-		pr_err("%s: failed to allocate etherdev\n", __func__);
+	if (!dev)
 		goto device_fail;
-	}
+
 	private = netdev_priv(dev);
 
 	/* Allocate the send/receive buffers */
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index 925c9ba..fe48cb7 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -854,10 +854,8 @@ static int __devinit dnet_probe(struct platform_device *pdev)
 
 	err = -ENOMEM;
 	dev = alloc_etherdev(sizeof(*bp));
-	if (!dev) {
-		dev_err(&pdev->dev, "etherdev alloc failed, aborting.\n");
+	if (!dev)
 		goto err_out_release_mem;
-	}
 
 	/* TODO: Actually, we have some interesting features... */
 	dev->features |= 0;
diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 60f0e78..3f97130 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -913,7 +913,6 @@ static int __devinit ethoc_probe(struct platform_device *pdev)
 	/* allocate networking device */
 	netdev = alloc_etherdev(sizeof(struct ethoc));
 	if (!netdev) {
-		dev_err(&pdev->dev, "cannot allocate network device\n");
 		ret = -ENOMEM;
 		goto out;
 	}
diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index 6a5ee07..3598c54 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -2992,7 +2992,6 @@ static int __init hp100_isa_init(void)
 	for (i = 0; i < HP100_DEVICES && hp100_port[i] != -1; ++i) {
 		dev = alloc_etherdev(sizeof(struct hp100_private));
 		if (!dev) {
-			printk(KERN_WARNING "hp100: no memory for network device\n");
 			while (cards > 0)
 				cleanup_dev(hp100_devlist[--cards]);
 
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 5d5fb26..1a4535d 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -2980,7 +2980,6 @@ static struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 	dev = alloc_etherdev_mq(sizeof(struct ehea_port), EHEA_MAX_PORT_RES);
 
 	if (!dev) {
-		pr_err("no mem for net_device\n");
 		ret = -ENOMEM;
 		goto out_err;
 	}
diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 2abce96..5d417f2 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -2706,11 +2706,9 @@ static int __devinit emac_probe(struct platform_device *ofdev)
 	/* Allocate our net_device structure */
 	err = -ENOMEM;
 	ndev = alloc_etherdev(sizeof(struct emac_instance));
-	if (!ndev) {
-		printk(KERN_ERR "%s: could not allocate ethernet device!\n",
-		       np->full_name);
+	if (!ndev)
 		goto err_gone;
-	}
+
 	dev = netdev_priv(ndev);
 	dev->ndev = ndev;
 	dev->ofdev = ofdev;
diff --git a/drivers/net/ethernet/ibm/iseries_veth.c b/drivers/net/ethernet/ibm/iseries_veth.c
index acc31af..1cafa65 100644
--- a/drivers/net/ethernet/ibm/iseries_veth.c
+++ b/drivers/net/ethernet/ibm/iseries_veth.c
@@ -1032,10 +1032,8 @@ static struct net_device *veth_probe_one(int vlan,
 	}
 
 	dev = alloc_etherdev(sizeof (struct veth_port));
-	if (! dev) {
-		veth_error("Unable to allocate net_device structure!\n");
+	if (!dev)
 		return NULL;
-	}
 
 	port = netdev_priv(dev);
 
diff --git a/drivers/net/ethernet/icplus/ipg.c b/drivers/net/ethernet/icplus/ipg.c
index 075451d..3c636f1 100644
--- a/drivers/net/ethernet/icplus/ipg.c
+++ b/drivers/net/ethernet/icplus/ipg.c
@@ -2233,7 +2233,6 @@ static int __devinit ipg_probe(struct pci_dev *pdev,
 	 */
 	dev = alloc_etherdev(sizeof(struct ipg_nic_private));
 	if (!dev) {
-		pr_err("%s: alloc_etherdev failed\n", pci_name(pdev));
 		rc = -ENOMEM;
 		goto err_disable_0;
 	}
diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 9436397..485ab8c 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2751,11 +2751,8 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	struct nic *nic;
 	int err;
 
-	if (!(netdev = alloc_etherdev(sizeof(struct nic)))) {
-		if (((1 << debug) - 1) & NETIF_MSG_PROBE)
-			pr_err("Etherdev alloc failed, aborting\n");
+	if (!(netdev = alloc_etherdev(sizeof(struct nic))))
 		return -ENOMEM;
-	}
 
 	netdev->netdev_ops = &e100_netdev_ops;
 	SET_ETHTOOL_OPS(netdev, &e100_ethtool_ops);
diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 27d651a..1b86d0b 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -2999,7 +2999,6 @@ jme_init_one(struct pci_dev *pdev,
 	 */
 	netdev = alloc_etherdev(sizeof(*jme));
 	if (!netdev) {
-		pr_err("Cannot allocate netdev structure\n");
 		rc = -ENOMEM;
 		goto err_out_release_regions;
 	}
diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 341d101..f30db1c 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -1108,10 +1108,9 @@ static int korina_probe(struct platform_device *pdev)
 	int rc;
 
 	dev = alloc_etherdev(sizeof(struct korina_private));
-	if (!dev) {
-		printk(KERN_ERR DRV_NAME ": alloc_etherdev failed\n");
+	if (!dev)
 		return -ENOMEM;
-	}
+
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	lp = netdev_priv(dev);
 
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 66ec54a..bfffe58 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -876,6 +876,10 @@ ltq_etop_probe(struct platform_device *pdev)
 	}
 
 	dev = alloc_etherdev_mq(sizeof(struct ltq_etop_priv), 4);
+	if (!dev) {
+		err = -ENOMEM;
+		goto err_out;
+	}
 	strcpy(dev->name, "eth%d");
 	dev->netdev_ops = &ltq_eth_netdev_ops;
 	priv = netdev_priv(dev);
diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index edb9bda..1d61eaa 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -3852,10 +3852,8 @@ static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 	struct skge_port *skge;
 	struct net_device *dev = alloc_etherdev(sizeof(*skge));
 
-	if (!dev) {
-		dev_err(&hw->pdev->dev, "etherdev alloc failed\n");
+	if (!dev)
 		return NULL;
-	}
 
 	SET_NETDEV_DEV(dev, &hw->pdev->dev);
 	dev->netdev_ops = &skge_netdev_ops;
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 760c2b1..82c2c86 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -4700,10 +4700,8 @@ static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 	struct sky2_port *sky2;
 	struct net_device *dev = alloc_etherdev(sizeof(*sky2));
 
-	if (!dev) {
-		dev_err(&hw->pdev->dev, "etherdev alloc failed\n");
+	if (!dev)
 		return NULL;
-	}
 
 	SET_NETDEV_DEV(dev, &hw->pdev->dev);
 	dev->irq = hw->pdev->irq;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 467ae58..25e6480 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1047,10 +1047,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 
 	dev = alloc_etherdev_mqs(sizeof(struct mlx4_en_priv),
 	    prof->tx_ring_num, prof->rx_ring_num);
-	if (dev == NULL) {
-		mlx4_err(mdev, "Net device allocation failed\n");
+	if (dev == NULL)
 		return -ENOMEM;
-	}
 
 	SET_NETDEV_DEV(dev, &mdev->dev->pdev->dev);
 	dev->dev_id =  port - 1;
diff --git a/drivers/net/ethernet/micrel/ks8695net.c b/drivers/net/ethernet/micrel/ks8695net.c
index ab81c0d..7c71727 100644
--- a/drivers/net/ethernet/micrel/ks8695net.c
+++ b/drivers/net/ethernet/micrel/ks8695net.c
@@ -1362,10 +1362,8 @@ ks8695_probe(struct platform_device *pdev)
 
 	/* Initialise a net_device */
 	ndev = alloc_etherdev(sizeof(struct ks8695_priv));
-	if (!ndev) {
-		dev_err(&pdev->dev, "could not allocate device.\n");
+	if (!ndev)
 		return -ENOMEM;
-	}
 
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index 6b35e7d..86c9c07 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1419,10 +1419,8 @@ static int __devinit ks8851_probe(struct spi_device *spi)
 	int ret;
 
 	ndev = alloc_etherdev(sizeof(struct ks8851_net));
-	if (!ndev) {
-		dev_err(&spi->dev, "failed to alloc ethernet device\n");
+	if (!ndev)
 		return -ENOMEM;
-	}
 
 	spi->bits_per_word = 8;
 
diff --git a/drivers/net/ethernet/microchip/enc28j60.c b/drivers/net/ethernet/microchip/enc28j60.c
index 50055e0..c813e5d 100644
--- a/drivers/net/ethernet/microchip/enc28j60.c
+++ b/drivers/net/ethernet/microchip/enc28j60.c
@@ -1553,9 +1553,6 @@ static int __devinit enc28j60_probe(struct spi_device *spi)
 
 	dev = alloc_etherdev(sizeof(struct enc28j60_net));
 	if (!dev) {
-		if (netif_msg_drv(&debug))
-			dev_err(&spi->dev, DRV_NAME
-				": unable to alloc new ethernet\n");
 		ret = -ENOMEM;
 		goto error_alloc;
 	}
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 20b72ec..27273ae 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -3910,10 +3910,8 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	static int board_number;
 
 	netdev = alloc_etherdev_mq(sizeof(*mgp), MYRI10GE_MAX_SLICES);
-	if (netdev == NULL) {
-		dev_err(dev, "Could not allocate ethernet device\n");
+	if (netdev == NULL)
 		return -ENOMEM;
-	}
 
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 97f63e1..1385846 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -7760,7 +7760,6 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	else
 		dev = alloc_etherdev(sizeof(struct s2io_nic));
 	if (dev == NULL) {
-		DBG_PRINT(ERR_DBG, "Device allocation failed\n");
 		pci_disable_device(pdev);
 		pci_release_regions(pdev);
 		return -ENODEV;
diff --git a/drivers/net/ethernet/netx-eth.c b/drivers/net/ethernet/netx-eth.c
index 8d288af..ba6ec28 100644
--- a/drivers/net/ethernet/netx-eth.c
+++ b/drivers/net/ethernet/netx-eth.c
@@ -383,7 +383,6 @@ static int netx_eth_drv_probe(struct platform_device *pdev)
 
 	ndev = alloc_etherdev(sizeof (struct netx_eth_priv));
 	if (!ndev) {
-		printk("%s: could not allocate device.\n", CARDNAME);
 		ret = -ENOMEM;
 		goto exit;
 	}
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 0217991..bdbec7e 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2419,8 +2419,6 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 	netdev = alloc_etherdev((int)sizeof(struct pch_gbe_adapter));
 	if (!netdev) {
 		ret = -ENOMEM;
-		dev_err(&pdev->dev,
-			"ERR: Can't allocate and set up an Ethernet device\n");
 		goto err_release_pci;
 	}
 	SET_NETDEV_DEV(netdev, &pdev->dev);
diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
index db44e9a..4a57742 100644
--- a/drivers/net/ethernet/packetengines/yellowfin.c
+++ b/drivers/net/ethernet/packetengines/yellowfin.c
@@ -397,10 +397,9 @@ static int __devinit yellowfin_init_one(struct pci_dev *pdev,
 	if (i) return i;
 
 	dev = alloc_etherdev(sizeof(*np));
-	if (!dev) {
-		pr_err("cannot allocate ethernet device\n");
+	if (!dev)
 		return -ENOMEM;
-	}
+
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	np = netdev_priv(dev);
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index 49b549f..3bb725e 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -1740,8 +1740,6 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	dev = alloc_etherdev(sizeof(struct pasemi_mac));
 	if (dev == NULL) {
-		dev_err(&pdev->dev,
-			"pasemi_mac: Could not allocate ethernet device.\n");
 		err = -ENOMEM;
 		goto out_disable_device;
 	}
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 7dd9a4b..64aa44d 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -1403,7 +1403,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netdev = alloc_etherdev(sizeof(struct netxen_adapter));
 	if(!netdev) {
-		dev_err(&pdev->dev, "failed to allocate net_device\n");
 		err = -ENOMEM;
 		goto err_out_free_res;
 	}
diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index 7931531..d49f6da 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -3805,7 +3805,6 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 
 	ndev = alloc_etherdev(sizeof(struct ql3_adapter));
 	if (!ndev) {
-		pr_err("%s could not alloc etherdev\n", pci_name(pdev));
 		err = -ENOMEM;
 		goto err_out_free_regions;
 	}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 69b8e4e..7bfdf57 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1576,7 +1576,6 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netdev = alloc_etherdev(sizeof(struct qlcnic_adapter));
 	if (!netdev) {
-		dev_err(&pdev->dev, "failed to allocate net_device\n");
 		err = -ENOMEM;
 		goto err_out_free_res;
 	}
diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index cb0eca8..76cab28 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1107,7 +1107,6 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 
 	dev = alloc_etherdev(sizeof(struct r6040_private));
 	if (!dev) {
-		dev_err(&pdev->dev, "Failed to allocate etherdev\n");
 		err = -ENOMEM;
 		goto err_out;
 	}
diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index a8779be..1c3feb0 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -754,10 +754,9 @@ static __devinit struct net_device * rtl8139_init_board (struct pci_dev *pdev)
 
 	/* dev and priv zeroed in alloc_etherdev */
 	dev = alloc_etherdev (sizeof (*tp));
-	if (dev == NULL) {
-		dev_err(&pdev->dev, "Unable to alloc new net device\n");
+	if (dev == NULL)
 		return ERR_PTR(-ENOMEM);
-	}
+
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	tp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 7a0c800..f2c1a9f 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3958,8 +3958,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	dev = alloc_etherdev(sizeof (*tp));
 	if (!dev) {
-		if (netif_msg_drv(&debug))
-			dev_err(&pdev->dev, "unable to alloc new ethernet\n");
 		rc = -ENOMEM;
 		goto out;
 	}
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 813d41c..1cb5a34 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1792,7 +1792,6 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 
 	ndev = alloc_etherdev(sizeof(struct sh_eth_private));
 	if (!ndev) {
-		dev_err(&pdev->dev, "Could not allocate device.\n");
 		ret = -ENOMEM;
 		goto out;
 	}
diff --git a/drivers/net/ethernet/s6gmac.c b/drivers/net/ethernet/s6gmac.c
index 22e9c01..bee9703 100644
--- a/drivers/net/ethernet/s6gmac.c
+++ b/drivers/net/ethernet/s6gmac.c
@@ -960,11 +960,11 @@ static int __devinit s6gmac_probe(struct platform_device *pdev)
 	int res;
 	unsigned long i;
 	struct mii_bus *mb;
+
 	dev = alloc_etherdev(sizeof(*pd));
-	if (!dev) {
-		printk(KERN_ERR DRV_PRMT "etherdev alloc failed, aborting.\n");
+	if (!dev)
 		return -ENOMEM;
-	}
+
 	dev->open = s6gmac_open;
 	dev->stop = s6gmac_stop;
 	dev->hard_start_xmit = s6gmac_tx;
diff --git a/drivers/net/ethernet/seeq/sgiseeq.c b/drivers/net/ethernet/seeq/sgiseeq.c
index f955a19..bb8c822 100644
--- a/drivers/net/ethernet/seeq/sgiseeq.c
+++ b/drivers/net/ethernet/seeq/sgiseeq.c
@@ -733,7 +733,6 @@ static int __devinit sgiseeq_probe(struct platform_device *pdev)
 
 	dev = alloc_etherdev(sizeof (struct sgiseeq_private));
 	if (!dev) {
-		printk(KERN_ERR "Sgiseeq: Etherdev alloc failed, aborting.\n");
 		err = -ENOMEM;
 		goto err_out;
 	}
diff --git a/drivers/net/ethernet/sis/sis190.c b/drivers/net/ethernet/sis/sis190.c
index 5b118cd..a9deda8 100644
--- a/drivers/net/ethernet/sis/sis190.c
+++ b/drivers/net/ethernet/sis/sis190.c
@@ -1462,8 +1462,6 @@ static struct net_device * __devinit sis190_init_board(struct pci_dev *pdev)
 
 	dev = alloc_etherdev(sizeof(*tp));
 	if (!dev) {
-		if (netif_msg_drv(&debug))
-			pr_err("unable to alloc new ethernet\n");
 		rc = -ENOMEM;
 		goto err_out_0;
 	}
diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index 2c077ce..11dcb38 100644
--- a/drivers/net/ethernet/smsc/epic100.c
+++ b/drivers/net/ethernet/smsc/epic100.c
@@ -363,10 +363,9 @@ static int __devinit epic_init_one (struct pci_dev *pdev,
 	ret = -ENOMEM;
 
 	dev = alloc_etherdev(sizeof (*ep));
-	if (!dev) {
-		dev_err(&pdev->dev, "no memory for eth device\n");
+	if (!dev)
 		goto err_out_free_res;
-	}
+
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 #ifdef USE_IO_OPS
diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index 313ba3b..c282301 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -2065,7 +2065,6 @@ static int __devinit smc911x_drv_probe(struct platform_device *pdev)
 
 	ndev = alloc_etherdev(sizeof(struct smc911x_local));
 	if (!ndev) {
-		printk("%s: could not allocate device.\n", CARDNAME);
 		ret = -ENOMEM;
 		goto release_1;
 	}
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 64ad3ed..24104a1 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2223,7 +2223,6 @@ static int __devinit smc_drv_probe(struct platform_device *pdev)
 
 	ndev = alloc_etherdev(sizeof(struct smc_local));
 	if (!ndev) {
-		printk("%s: could not allocate device.\n", CARDNAME);
 		ret = -ENOMEM;
 		goto out;
 	}
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 24d2df0..6a1cd23 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2374,7 +2374,6 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 
 	dev = alloc_etherdev(sizeof(struct smsc911x_data));
 	if (!dev) {
-		pr_warn("Could not allocate device\n");
 		retval = -ENOMEM;
 		goto out_release_io_1;
 	}
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index a9efbdf..595f988 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -1598,10 +1598,8 @@ smsc9420_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	pci_set_master(pdev);
 
 	dev = alloc_etherdev(sizeof(*pd));
-	if (!dev) {
-		printk(KERN_ERR "ether device alloc failed\n");
+	if (!dev)
 		goto out_disable_pci_device_1;
-	}
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index ffc7581..166fc95e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1801,10 +1801,8 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 	struct stmmac_priv *priv;
 
 	ndev = alloc_etherdev(sizeof(struct stmmac_priv));
-	if (!ndev) {
-		pr_err("%s: ERROR: allocating the device\n", __func__);
+	if (!ndev)
 		return NULL;
-	}
 
 	SET_NETDEV_DEV(ndev, device);
 
diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index 961b56a..f830244 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -4946,7 +4946,6 @@ static int __devinit cas_init_one(struct pci_dev *pdev,
 
 	dev = alloc_etherdev(sizeof(*cp));
 	if (!dev) {
-		dev_err(&pdev->dev, "Etherdev alloc failed, aborting\n");
 		err = -ENOMEM;
 		goto err_out_disable_pdev;
 	}
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index cf43393..d83c508 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -9685,10 +9685,8 @@ static struct net_device * __devinit niu_alloc_and_init(
 	struct niu *np;
 
 	dev = alloc_etherdev_mq(sizeof(struct niu), NIU_NUM_TXCHAN);
-	if (!dev) {
-		dev_err(gen_dev, "Etherdev alloc failed, aborting\n");
+	if (!dev)
 		return NULL;
-	}
 
 	SET_NETDEV_DEV(dev, gen_dev);
 
diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index 31441a8..ba04159 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -2885,7 +2885,6 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 
 	dev = alloc_etherdev(sizeof(*gp));
 	if (!dev) {
-		pr_err("Etherdev alloc failed, aborting\n");
 		err = -ENOMEM;
 		goto err_disable_device;
 	}
diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 2896f6e..92a037a 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -1026,10 +1026,8 @@ static struct vnet * __devinit vnet_new(const u64 *local_mac)
 	int err, i;
 
 	dev = alloc_etherdev(sizeof(*vp));
-	if (!dev) {
-		pr_err("Etherdev alloc failed, aborting\n");
+	if (!dev)
 		return ERR_PTR(-ENOMEM);
-	}
 
 	for (i = 0; i < ETH_ALEN; i++)
 		dev->dev_addr[i] = (*local_mac >> (5 - i) * 8) & 0xff;
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index 4b19e9b..df7febb 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -1978,7 +1978,6 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		ndev = alloc_etherdev(sizeof(struct bdx_priv));
 		if (!ndev) {
 			err = -ENOMEM;
-			pr_err("alloc_etherdev failed\n");
 			goto err_out_iomap;
 		}
 
diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 4d9a28f..97e1df3 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -1143,11 +1143,8 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	}
 
 	dev = alloc_etherdev_mq(sizeof(*priv), CPMAC_QUEUES);
-
-	if (!dev) {
-		printk(KERN_ERR "cpmac: Unable to allocate net_device\n");
+	if (!dev)
 		return -ENOMEM;
-	}
 
 	platform_set_drvdata(pdev, dev);
 	priv = netdev_priv(dev);
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 794ac30..efd4f3e 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1789,7 +1789,6 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 
 	ndev = alloc_etherdev(sizeof(struct emac_priv));
 	if (!ndev) {
-		dev_err(&pdev->dev, "error allocating net_device\n");
 		rc = -ENOMEM;
 		goto free_clk;
 	}
diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index 9c0dd6b..817ad3b 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -486,7 +486,6 @@ static int __devinit tlan_probe1(struct pci_dev *pdev,
 
 	dev = alloc_etherdev(sizeof(struct tlan_priv));
 	if (dev == NULL) {
-		pr_err("Could not allocate memory for device\n");
 		rc = -ENOMEM;
 		goto err_out_regions;
 	}
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 71b785c..f5ac603 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -808,10 +808,9 @@ static int __devinit tc35815_init_one(struct pci_dev *pdev,
 
 	/* dev zeroed in alloc_etherdev */
 	dev = alloc_etherdev(sizeof(*lp));
-	if (dev == NULL) {
-		dev_err(&pdev->dev, "unable to alloc new ethernet\n");
+	if (dev == NULL)
 		return -ENOMEM;
-	}
+
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	lp = netdev_priv(dev);
 	lp->dev = dev;
diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index 164fb77..fc5521c 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -1582,10 +1582,8 @@ tsi108_init_one(struct platform_device *pdev)
 	/* Create an ethernet device instance */
 
 	dev = alloc_etherdev(sizeof(struct tsi108_prv_data));
-	if (!dev) {
-		printk("tsi108_eth: Could not allocate a device structure\n");
+	if (!dev)
 		return -ENOMEM;
-	}
 
 	printk("tsi108_eth%d: probe...\n", pdev->id);
 	data = netdev_priv(dev);
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 10b18eb..1b95daa 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -927,7 +927,6 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	dev = alloc_etherdev(sizeof(struct rhine_private));
 	if (!dev) {
 		rc = -ENOMEM;
-		dev_err(&pdev->dev, "alloc_etherdev failed\n");
 		goto err_out;
 	}
 	SET_NETDEV_DEV(dev, &pdev->dev);
diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index 4128d6b..2776bbc6 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -2733,10 +2733,8 @@ static int __devinit velocity_found1(struct pci_dev *pdev, const struct pci_devi
 	}
 
 	dev = alloc_etherdev(sizeof(struct velocity_info));
-	if (!dev) {
-		dev_err(&pdev->dev, "allocate net device failed.\n");
+	if (!dev)
 		goto out;
-	}
 
 	/* Chain it all together */
 
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index f21addb..d8eb9c9 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -1011,10 +1011,9 @@ static int __devinit temac_of_probe(struct platform_device *op)
 
 	/* Init network device structure */
 	ndev = alloc_etherdev(sizeof(*lp));
-	if (!ndev) {
-		dev_err(&op->dev, "could not allocate device.\n");
+	if (!ndev)
 		return -ENOMEM;
-	}
+
 	ether_setup(ndev);
 	dev_set_drvdata(&op->dev, ndev);
 	SET_NETDEV_DEV(ndev, &op->dev);
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index ea50caf..a7cf004 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1486,10 +1486,8 @@ static int __devinit axienet_of_probe(struct platform_device *op)
 	const void *addr;
 
 	ndev = alloc_etherdev(sizeof(*lp));
-	if (!ndev) {
-		dev_err(&op->dev, "could not allocate device.\n");
+	if (!ndev)
 		return -ENOMEM;
-	}
 
 	ether_setup(ndev);
 	dev_set_drvdata(&op->dev, ndev);
diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 79013e5..90e611a 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -1136,10 +1136,8 @@ static int __devinit xemaclite_of_probe(struct platform_device *ofdev)
 
 	/* Create an ethernet device instance */
 	ndev = alloc_etherdev(sizeof(struct net_local));
-	if (!ndev) {
-		dev_err(dev, "Could not allocate network device\n");
+	if (!ndev)
 		return -ENOMEM;
-	}
 
 	dev_set_drvdata(dev, ndev);
 	SET_NETDEV_DEV(ndev, &ofdev->dev);
diff --git a/drivers/net/plip/plip.c b/drivers/net/plip/plip.c
index a9e9ca8..1a5a316 100644
--- a/drivers/net/plip/plip.c
+++ b/drivers/net/plip/plip.c
@@ -1260,10 +1260,8 @@ static void plip_attach (struct parport *port)
 
 		sprintf(name, "plip%d", unit);
 		dev = alloc_etherdev(sizeof(struct net_local));
-		if (!dev) {
-			printk(KERN_ERR "plip: memory squeeze\n");
+		if (!dev)
 			return;
-		}
 
 		strcpy(dev->name, name);
 
diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index 7145714..a57f057 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -497,8 +497,6 @@ static int rionet_probe(struct rio_dev *rdev, const struct rio_device_id *id)
 	/* Allocate our net_device structure */
 	ndev = alloc_etherdev(sizeof(struct rionet_private));
 	if (ndev == NULL) {
-		printk(KERN_INFO "%s: could not allocate ethernet device.\n",
-		       DRV_NAME);
 		rc = -ENOMEM;
 		goto out;
 	}
diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 5d99b8c..7523930 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -1332,10 +1332,8 @@ static int pegasus_probe(struct usb_interface *intf,
 	usb_get_dev(dev);
 
 	net = alloc_etherdev(sizeof(struct pegasus));
-	if (!net) {
-		dev_err(&intf->dev, "can't allocate %s\n", "device");
+	if (!net)
 		goto out;
-	}
 
 	pegasus = netdev_priv(net);
 	pegasus->dev_index = dev_index;
diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index 0710b4c..6dda2fe 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -894,10 +894,8 @@ static int rtl8150_probe(struct usb_interface *intf,
 	struct net_device *netdev;
 
 	netdev = alloc_etherdev(sizeof(rtl8150_t));
-	if (!netdev) {
-		err("Out of memory");
+	if (!netdev)
 		return -ENOMEM;
-	}
 
 	dev = netdev_priv(netdev);
 
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index fae0fbd..b924f46 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1334,10 +1334,8 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 
 	// set up our own records
 	net = alloc_etherdev(sizeof(*dev));
-	if (!net) {
-		dbg ("can't kmalloc dev");
+	if (!net)
 		goto out;
-	}
 
 	/* netdev_printk() needs this so do it as early as possible */
 	SET_NETDEV_DEV(net, &udev->dev);
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 87c0b58..482cfa8 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2918,11 +2918,8 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	printk(KERN_INFO "# of Tx queues : %d, # of Rx queues : %d\n",
 	       num_tx_queues, num_rx_queues);
 
-	if (!netdev) {
-		printk(KERN_ERR "Failed to alloc ethernet device for adapter "
-			"%s\n",	pci_name(pdev));
+	if (!netdev)
 		return -ENOMEM;
-	}
 
 	pci_set_drvdata(pdev, netdev);
 	adapter = netdev_priv(netdev);
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index 7e45ca2..3010cee 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -1533,10 +1533,9 @@ struct net_device *init_atmel_card(unsigned short irq, unsigned long port,
 
 	/* Create the network device object. */
 	dev = alloc_etherdev(sizeof(*priv));
-	if (!dev) {
-		printk(KERN_ERR "atmel: Couldn't alloc_etherdev\n");
+	if (!dev)
 		return NULL;
-	}
+
 	if (dev_alloc_name(dev, dev->name) < 0) {
 		printk(KERN_ERR "atmel: Couldn't get name!\n");
 		goto err_out_free;
diff --git a/drivers/net/wireless/ipw2x00/libipw_module.c b/drivers/net/wireless/ipw2x00/libipw_module.c
index d5ef696..3adb240 100644
--- a/drivers/net/wireless/ipw2x00/libipw_module.c
+++ b/drivers/net/wireless/ipw2x00/libipw_module.c
@@ -150,10 +150,9 @@ struct net_device *alloc_libipw(int sizeof_priv, int monitor)
 	LIBIPW_DEBUG_INFO("Initializing...\n");
 
 	dev = alloc_etherdev(sizeof(struct libipw_device) + sizeof_priv);
-	if (!dev) {
-		LIBIPW_ERROR("Unable to allocate network device.\n");
+	if (!dev)
 		goto failed;
-	}
+
 	ieee = netdev_priv(dev);
 
 	ieee->dev = dev;
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index f3182c0..b161750 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1279,11 +1279,8 @@ static struct net_device * __devinit xennet_create_dev(struct xenbus_device *dev
 	struct netfront_info *np;
 
 	netdev = alloc_etherdev(sizeof(struct netfront_info));
-	if (!netdev) {
-		printk(KERN_WARNING "%s> alloc_etherdev failed.\n",
-		       __func__);
+	if (!netdev)
 		return ERR_PTR(-ENOMEM);
-	}
 
 	np                   = netdev_priv(netdev);
 	np->xbdev            = dev;
-- 
1.7.8.111.gad25c.dirty
