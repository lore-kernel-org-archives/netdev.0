From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 471/493] net: remove use of __devexit
Date: Mon, 19 Nov 2012 13:27:00 -0500
Message-ID: <1353349642-3677-471-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jirislaby@gmail.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	"VMware, Inc." <pv-drivers@vmware.com>,
	virtualization@lists.linux-foundation.org,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Christian Lamparter <chunkeey@googlemail.com>,
	Hin-Tak Leung <htl10@users.sourceforge.net>,
	Luciano Coelho <coelho@ti.com>, Stefano Brivio <stefano.brivio@polimi.it>,
	libertas-dev@lists.infradead.org, Dan Williams <dcbw@redhat.com>,
	ath5k-devel@lists.ath5k.org, "Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	linux-hippi@sunsite.dk, Nick Kossifidis <mickflemm@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Herton Ronaldo Krzesinski <herton@canonical.com>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	b43-dev@lists.infradead.org, Samuel Ortiz <samuel@sortiz.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-can@vger.kernel.org, xen-devel@lists.xensource.com,
	Marc K
To: gregkh@linuxfoundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

CONFIG_HOTPLUG is going away as an option so __devexit is no
longer needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Wolfgang Grandegger <wg@grandegger.com> 
Cc: Marc Kleine-Budde <mkl@pengutronix.de> 
Cc: "Maciej W. Rozycki" <macro@linux-mips.org> 
Cc: Jes Sorensen <jes@trained-monkey.org> 
Cc: Samuel Ortiz <samuel@sortiz.org> 
Cc: Rusty Russell <rusty@rustcorp.com.au> 
Cc: "Michael S. Tsirkin" <mst@redhat.com> 
Cc: Shreyas Bhatewara <sbhatewara@vmware.com> 
Cc: "VMware, Inc." <pv-drivers@vmware.com> 
Cc: Francois Romieu <romieu@fr.zoreil.com> 
Cc: Krzysztof Halasa <khc@pm.waw.pl> 
Cc: "John W. Linville" <linville@tuxdriver.com> 
Cc: Jiri Slaby <jirislaby@gmail.com> 
Cc: Nick Kossifidis <mickflemm@gmail.com> 
Cc: "Luis R. Rodriguez" <mcgrof@qca.qualcomm.com> 
Cc: Simon Kelley <simon@thekelleys.org.uk> 
Cc: Stefano Brivio <stefano.brivio@polimi.it> 
Cc: Stanislav Yakovlev <stas.yakovlev@gmail.com> 
Cc: Dan Williams <dcbw@redhat.com> 
Cc: Christian Lamparter <chunkeey@googlemail.com> 
Cc: Herton Ronaldo Krzesinski <herton@canonical.com> 
Cc: Hin-Tak Leung <htl10@users.sourceforge.net> 
Cc: Larry Finger <Larry.Finger@lwfinger.net> 
Cc: Luciano Coelho <coelho@ti.com> 
Cc: netdev@vger.kernel.org 
Cc: linux-can@vger.kernel.org 
Cc: linux-hippi@sunsite.dk 
Cc: virtualization@lists.linux-foundation.org 
Cc: linux-wireless@vger.kernel.org 
Cc: ath5k-devel@lists.ath5k.org 
Cc: b43-dev@lists.infradead.org 
Cc: libertas-dev@lists.infradead.org 
Cc: xen-devel@lists.xensource.com 
---
 drivers/net/arcnet/com20020-pci.c             |  2 +-
 drivers/net/can/at91_can.c                    |  2 +-
 drivers/net/can/bfin_can.c                    |  2 +-
 drivers/net/can/c_can/c_can_pci.c             |  2 +-
 drivers/net/can/c_can/c_can_platform.c        |  2 +-
 drivers/net/can/cc770/cc770_isa.c             |  2 +-
 drivers/net/can/cc770/cc770_platform.c        |  2 +-
 drivers/net/can/flexcan.c                     |  4 ++--
 drivers/net/can/janz-ican3.c                  |  6 +++---
 drivers/net/can/mcp251x.c                     |  2 +-
 drivers/net/can/mscan/mpc5xxx_can.c           |  2 +-
 drivers/net/can/pch_can.c                     |  2 +-
 drivers/net/can/sja1000/kvaser_pci.c          |  2 +-
 drivers/net/can/sja1000/peak_pci.c            |  2 +-
 drivers/net/can/sja1000/sja1000_isa.c         |  2 +-
 drivers/net/can/sja1000/sja1000_of_platform.c |  2 +-
 drivers/net/can/sja1000/tscan1.c              |  2 +-
 drivers/net/can/softing/softing_cs.c          |  2 +-
 drivers/net/can/softing/softing_main.c        |  2 +-
 drivers/net/can/ti_hecc.c                     |  2 +-
 drivers/net/fddi/defxx.c                      | 14 +++++++-------
 drivers/net/fddi/skfp/skfddi.c                |  2 +-
 drivers/net/hippi/rrunner.c                   |  2 +-
 drivers/net/ieee802154/at86rf230.c            |  2 +-
 drivers/net/ieee802154/fakehard.c             |  2 +-
 drivers/net/ieee802154/fakelb.c               |  2 +-
 drivers/net/ieee802154/mrf24j40.c             |  2 +-
 drivers/net/irda/au1k_ir.c                    |  2 +-
 drivers/net/irda/bfin_sir.c                   |  2 +-
 drivers/net/irda/sh_irda.c                    |  2 +-
 drivers/net/irda/sh_sir.c                     |  2 +-
 drivers/net/irda/via-ircc.c                   |  4 ++--
 drivers/net/irda/vlsi_ir.c                    |  2 +-
 drivers/net/phy/mdio-gpio.c                   |  4 ++--
 drivers/net/phy/mdio-mux-gpio.c               |  2 +-
 drivers/net/phy/mdio-mux-mmioreg.c            |  2 +-
 drivers/net/phy/mdio-octeon.c                 |  2 +-
 drivers/net/phy/spi_ks8995.c                  |  2 +-
 drivers/net/virtio_net.c                      |  2 +-
 drivers/net/vmxnet3/vmxnet3_drv.c             |  2 +-
 drivers/net/wan/dscc4.c                       |  2 +-
 drivers/net/wan/farsync.c                     |  2 +-
 drivers/net/wan/ixp4xx_hss.c                  |  2 +-
 drivers/net/wan/lmc/lmc_main.c                |  2 +-
 drivers/net/wireless/adm8211.c                |  2 +-
 drivers/net/wireless/airo.c                   |  2 +-
 drivers/net/wireless/ath/ath5k/pci.c          |  2 +-
 drivers/net/wireless/atmel_pci.c              |  2 +-
 drivers/net/wireless/b43/pcmcia.c             |  2 +-
 drivers/net/wireless/b43/sdio.c               |  2 +-
 drivers/net/wireless/ipw2x00/ipw2100.c        |  2 +-
 drivers/net/wireless/ipw2x00/ipw2200.c        |  2 +-
 drivers/net/wireless/iwlegacy/3945-mac.c      |  2 +-
 drivers/net/wireless/iwlegacy/4965-mac.c      |  2 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c       |  2 +-
 drivers/net/wireless/libertas/if_spi.c        |  2 +-
 drivers/net/wireless/mwl8k.c                  |  4 ++--
 drivers/net/wireless/orinoco/orinoco_nortel.c |  2 +-
 drivers/net/wireless/orinoco/orinoco_pci.c    |  2 +-
 drivers/net/wireless/orinoco/orinoco_plx.c    |  2 +-
 drivers/net/wireless/orinoco/orinoco_tmd.c    |  2 +-
 drivers/net/wireless/p54/p54pci.c             |  2 +-
 drivers/net/wireless/p54/p54spi.c             |  2 +-
 drivers/net/wireless/p54/p54usb.c             |  2 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c    |  2 +-
 drivers/net/wireless/rtl818x/rtl8187/dev.c    |  2 +-
 drivers/net/wireless/ti/wl1251/sdio.c         |  2 +-
 drivers/net/wireless/ti/wl1251/spi.c          |  2 +-
 drivers/net/wireless/ti/wlcore/main.c         |  2 +-
 drivers/net/wireless/ti/wlcore/sdio.c         |  2 +-
 drivers/net/wireless/ti/wlcore/spi.c          |  2 +-
 drivers/net/wireless/ti/wlcore/wlcore.h       |  2 +-
 drivers/net/xen-netfront.c                    |  2 +-
 73 files changed, 85 insertions(+), 85 deletions(-)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index e80f04b..cbc44f5 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -135,7 +135,7 @@ out_dev:
 	return err;
 }
 
-static void __devexit com20020pci_remove(struct pci_dev *pdev)
+static void com20020pci_remove(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	unregister_netdev(dev);
diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index da807f3..e3c4c22 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -1338,7 +1338,7 @@ static int at91_can_probe(struct platform_device *pdev)
 	return err;
 }
 
-static int __devexit at91_can_remove(struct platform_device *pdev)
+static int at91_can_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct at91_priv *priv = netdev_priv(dev);
diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index 16515e3..6918334 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -611,7 +611,7 @@ exit:
 	return err;
 }
 
-static int __devexit bfin_can_remove(struct platform_device *pdev)
+static int bfin_can_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = dev_get_drvdata(&pdev->dev);
 	struct bfin_can_priv *priv = netdev_priv(dev);
diff --git a/drivers/net/can/c_can/c_can_pci.c b/drivers/net/can/c_can/c_can_pci.c
index 27db0f2..a1f2631 100644
--- a/drivers/net/can/c_can/c_can_pci.c
+++ b/drivers/net/can/c_can/c_can_pci.c
@@ -174,7 +174,7 @@ out:
 	return ret;
 }
 
-static void __devexit c_can_pci_remove(struct pci_dev *pdev)
+static void c_can_pci_remove(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct c_can_priv *priv = netdev_priv(dev);
diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index 91e7d2b..f133951 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -220,7 +220,7 @@ exit:
 	return ret;
 }
 
-static int __devexit c_can_plat_remove(struct platform_device *pdev)
+static int c_can_plat_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct c_can_priv *priv = netdev_priv(dev);
diff --git a/drivers/net/can/cc770/cc770_isa.c b/drivers/net/can/cc770/cc770_isa.c
index bed9d19..8eaaac8 100644
--- a/drivers/net/can/cc770/cc770_isa.c
+++ b/drivers/net/can/cc770/cc770_isa.c
@@ -291,7 +291,7 @@ static int cc770_isa_probe(struct platform_device *pdev)
 	return err;
 }
 
-static int __devexit cc770_isa_remove(struct platform_device *pdev)
+static int cc770_isa_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = dev_get_drvdata(&pdev->dev);
 	struct cc770_priv *priv = netdev_priv(dev);
diff --git a/drivers/net/can/cc770/cc770_platform.c b/drivers/net/can/cc770/cc770_platform.c
index caf4d70..4af9f4e 100644
--- a/drivers/net/can/cc770/cc770_platform.c
+++ b/drivers/net/can/cc770/cc770_platform.c
@@ -237,7 +237,7 @@ exit_release_mem:
 	return err;
 }
 
-static int __devexit cc770_platform_remove(struct platform_device *pdev)
+static int cc770_platform_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = dev_get_drvdata(&pdev->dev);
 	struct cc770_priv *priv = netdev_priv(dev);
diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index dd3c933..dc31c78 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -968,7 +968,7 @@ static int register_flexcandev(struct net_device *dev)
 	return err;
 }
 
-static void __devexit unregister_flexcandev(struct net_device *dev)
+static void unregister_flexcandev(struct net_device *dev)
 {
 	unregister_candev(dev);
 }
@@ -1107,7 +1107,7 @@ static int flexcan_probe(struct platform_device *pdev)
 	return err;
 }
 
-static int __devexit flexcan_remove(struct platform_device *pdev)
+static int flexcan_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct flexcan_priv *priv = netdev_priv(dev);
diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
index 6eb1916..e7d69a4 100644
--- a/drivers/net/can/janz-ican3.c
+++ b/drivers/net/can/janz-ican3.c
@@ -642,7 +642,7 @@ static int ican3_msg_connect(struct ican3_dev *mod)
 	return ican3_send_msg(mod, &msg);
 }
 
-static int __devexit ican3_msg_disconnect(struct ican3_dev *mod)
+static int ican3_msg_disconnect(struct ican3_dev *mod)
 {
 	struct ican3_msg msg;
 
@@ -1421,7 +1421,7 @@ static int ican3_reset_module(struct ican3_dev *mod)
 	return -ETIMEDOUT;
 }
 
-static void __devexit ican3_shutdown_module(struct ican3_dev *mod)
+static void ican3_shutdown_module(struct ican3_dev *mod)
 {
 	ican3_msg_disconnect(mod);
 	ican3_reset_module(mod);
@@ -1898,7 +1898,7 @@ out_return:
 	return ret;
 }
 
-static int __devexit ican3_remove(struct platform_device *pdev)
+static int ican3_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct ican3_dev *mod = netdev_priv(ndev);
diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 767fdbd..5eaf47b 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -1100,7 +1100,7 @@ error_out:
 	return ret;
 }
 
-static int __devexit mcp251x_can_remove(struct spi_device *spi)
+static int mcp251x_can_remove(struct spi_device *spi)
 {
 	struct mcp251x_platform_data *pdata = spi->dev.platform_data;
 	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/mpc5xxx_can.c
index 508cbad..12e130a 100644
--- a/drivers/net/can/mscan/mpc5xxx_can.c
+++ b/drivers/net/can/mscan/mpc5xxx_can.c
@@ -323,7 +323,7 @@ exit_unmap_mem:
 	return err;
 }
 
-static int __devexit mpc5xxx_can_remove(struct platform_device *ofdev)
+static int mpc5xxx_can_remove(struct platform_device *ofdev)
 {
 	struct net_device *dev = dev_get_drvdata(&ofdev->dev);
 	struct mscan_priv *priv = netdev_priv(dev);
diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index fad4625..7d17485 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -954,7 +954,7 @@ static const struct net_device_ops pch_can_netdev_ops = {
 	.ndo_start_xmit		= pch_xmit,
 };
 
-static void __devexit pch_can_remove(struct pci_dev *pdev)
+static void pch_can_remove(struct pci_dev *pdev)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
 	struct pch_can_priv *priv = netdev_priv(ndev);
diff --git a/drivers/net/can/sja1000/kvaser_pci.c b/drivers/net/can/sja1000/kvaser_pci.c
index a6191ac..4efdaf2 100644
--- a/drivers/net/can/sja1000/kvaser_pci.c
+++ b/drivers/net/can/sja1000/kvaser_pci.c
@@ -379,7 +379,7 @@ failure:
 
 }
 
-static void __devexit kvaser_pci_remove_one(struct pci_dev *pdev)
+static void kvaser_pci_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 
diff --git a/drivers/net/can/sja1000/peak_pci.c b/drivers/net/can/sja1000/peak_pci.c
index fbf61cf..3faeb3d 100644
--- a/drivers/net/can/sja1000/peak_pci.c
+++ b/drivers/net/can/sja1000/peak_pci.c
@@ -717,7 +717,7 @@ failure_disable_pci:
 	return err;
 }
 
-static void __devexit peak_pci_remove(struct pci_dev *pdev)
+static void peak_pci_remove(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev); /* Last device */
 	struct sja1000_priv *priv = netdev_priv(dev);
diff --git a/drivers/net/can/sja1000/sja1000_isa.c b/drivers/net/can/sja1000/sja1000_isa.c
index a872f24..5c8da46 100644
--- a/drivers/net/can/sja1000/sja1000_isa.c
+++ b/drivers/net/can/sja1000/sja1000_isa.c
@@ -223,7 +223,7 @@ static int sja1000_isa_probe(struct platform_device *pdev)
 	return err;
 }
 
-static int __devexit sja1000_isa_remove(struct platform_device *pdev)
+static int sja1000_isa_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = dev_get_drvdata(&pdev->dev);
 	struct sja1000_priv *priv = netdev_priv(dev);
diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/net/can/sja1000/sja1000_of_platform.c
index 1ca0ee1..a7b0152 100644
--- a/drivers/net/can/sja1000/sja1000_of_platform.c
+++ b/drivers/net/can/sja1000/sja1000_of_platform.c
@@ -68,7 +68,7 @@ static void sja1000_ofp_write_reg(const struct sja1000_priv *priv,
 	out_8(priv->reg_base + reg, val);
 }
 
-static int __devexit sja1000_ofp_remove(struct platform_device *ofdev)
+static int sja1000_ofp_remove(struct platform_device *ofdev)
 {
 	struct net_device *dev = dev_get_drvdata(&ofdev->dev);
 	struct sja1000_priv *priv = netdev_priv(dev);
diff --git a/drivers/net/can/sja1000/tscan1.c b/drivers/net/can/sja1000/tscan1.c
index 6a6db7e..76513dd 100644
--- a/drivers/net/can/sja1000/tscan1.c
+++ b/drivers/net/can/sja1000/tscan1.c
@@ -171,7 +171,7 @@ static int tscan1_probe(struct device *dev, unsigned id)
 	return -ENXIO;
 }
 
-static int __devexit tscan1_remove(struct device *dev, unsigned id /*unused*/)
+static int tscan1_remove(struct device *dev, unsigned id /*unused*/)
 {
 	struct net_device *netdev;
 	struct sja1000_priv *priv;
diff --git a/drivers/net/can/softing/softing_cs.c b/drivers/net/can/softing/softing_cs.c
index 04e1539..ce18ba5 100644
--- a/drivers/net/can/softing/softing_cs.c
+++ b/drivers/net/can/softing/softing_cs.c
@@ -215,7 +215,7 @@ static int softingcs_probe_config(struct pcmcia_device *pcmcia,
 	return pcmcia_request_window(pcmcia, pres, memspeed);
 }
 
-static __devexit void softingcs_remove(struct pcmcia_device *pcmcia)
+static void softingcs_remove(struct pcmcia_device *pcmcia)
 {
 	struct platform_device *pdev = pcmcia->priv;
 
diff --git a/drivers/net/can/softing/softing_main.c b/drivers/net/can/softing/softing_main.c
index aefd297..50b1e0f 100644
--- a/drivers/net/can/softing/softing_main.c
+++ b/drivers/net/can/softing/softing_main.c
@@ -745,7 +745,7 @@ static const struct attribute_group softing_pdev_group = {
 /*
  * platform driver
  */
-static __devexit int softing_pdev_remove(struct platform_device *pdev)
+static int softing_pdev_remove(struct platform_device *pdev)
 {
 	struct softing *card = platform_get_drvdata(pdev);
 	int j;
diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index 80ee814..b5e1683 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -978,7 +978,7 @@ probe_exit:
 	return err;
 }
 
-static int __devexit ti_hecc_remove(struct platform_device *pdev)
+static int ti_hecc_remove(struct platform_device *pdev)
 {
 	struct resource *res;
 	struct net_device *ndev = platform_get_drvdata(pdev);
diff --git a/drivers/net/fddi/defxx.c b/drivers/net/fddi/defxx.c
index fd58f0b..3c8aab7 100644
--- a/drivers/net/fddi/defxx.c
+++ b/drivers/net/fddi/defxx.c
@@ -809,7 +809,7 @@ static void dfx_bus_init(struct net_device *dev)
  *   Interrupts are disabled at the adapter bus-specific logic.
  */
 
-static void __devexit dfx_bus_uninit(struct net_device *dev)
+static void dfx_bus_uninit(struct net_device *dev)
 {
 	DFX_board_t *bp = netdev_priv(dev);
 	struct device *bdev = bp->bus_dev;
@@ -3579,7 +3579,7 @@ static void dfx_xmt_flush( DFX_board_t *bp )
  *   Device structures for FDDI adapters (fddi0, fddi1, etc) are
  *   freed.
  */
-static void __devexit dfx_unregister(struct device *bdev)
+static void dfx_unregister(struct device *bdev)
 {
 	struct net_device *dev = dev_get_drvdata(bdev);
 	DFX_board_t *bp = netdev_priv(dev);
@@ -3620,12 +3620,12 @@ static void __devexit dfx_unregister(struct device *bdev)
 
 
 static int __maybe_unused dfx_dev_register(struct device *);
-static int __devexit __maybe_unused dfx_dev_unregister(struct device *);
+static int __maybe_unused dfx_dev_unregister(struct device *);
 
 #ifdef CONFIG_PCI
 static int dfx_pci_register(struct pci_dev *,
 				      const struct pci_device_id *);
-static void __devexit dfx_pci_unregister(struct pci_dev *);
+static void dfx_pci_unregister(struct pci_dev *);
 
 static DEFINE_PCI_DEVICE_TABLE(dfx_pci_table) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_FDDI) },
@@ -3646,7 +3646,7 @@ static int dfx_pci_register(struct pci_dev *pdev,
 	return dfx_register(&pdev->dev);
 }
 
-static void __devexit dfx_pci_unregister(struct pci_dev *pdev)
+static void dfx_pci_unregister(struct pci_dev *pdev)
 {
 	dfx_unregister(&pdev->dev);
 }
@@ -3704,7 +3704,7 @@ static int __maybe_unused dfx_dev_register(struct device *dev)
 	return status;
 }
 
-static int __devexit __maybe_unused dfx_dev_unregister(struct device *dev)
+static int __maybe_unused dfx_dev_unregister(struct device *dev)
 {
 	put_device(dev);
 	dfx_unregister(dev);
@@ -3724,7 +3724,7 @@ static int dfx_init(void)
 	return status;
 }
 
-static void __devexit dfx_cleanup(void)
+static void dfx_cleanup(void)
 {
 	tc_unregister_driver(&dfx_tc_driver);
 	eisa_driver_unregister(&dfx_eisa_driver);
diff --git a/drivers/net/fddi/skfp/skfddi.c b/drivers/net/fddi/skfp/skfddi.c
index cbabb74..d5bd563 100644
--- a/drivers/net/fddi/skfp/skfddi.c
+++ b/drivers/net/fddi/skfp/skfddi.c
@@ -321,7 +321,7 @@ err_out1:
 /*
  * Called for each adapter board from pci_unregister_driver
  */
-static void __devexit skfp_remove_one(struct pci_dev *pdev)
+static void skfp_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *p = pci_get_drvdata(pdev);
 	struct s_smc *lp = netdev_priv(p);
diff --git a/drivers/net/hippi/rrunner.c b/drivers/net/hippi/rrunner.c
index 12b7ff9..6be95ed 100644
--- a/drivers/net/hippi/rrunner.c
+++ b/drivers/net/hippi/rrunner.c
@@ -221,7 +221,7 @@ static int rr_init_one(struct pci_dev *pdev,
 	return ret;
 }
 
-static void __devexit rr_remove_one (struct pci_dev *pdev)
+static void rr_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rr_private *rr = netdev_priv(dev);
diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 1198c6b..a4a62e1 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -920,7 +920,7 @@ err_fill:
 	return rc;
 }
 
-static int __devexit at86rf230_remove(struct spi_device *spi)
+static int at86rf230_remove(struct spi_device *spi)
 {
 	struct at86rf230_local *lp = spi_get_drvdata(spi);
 
diff --git a/drivers/net/ieee802154/fakehard.c b/drivers/net/ieee802154/fakehard.c
index fd0438c..1e9cb0b 100644
--- a/drivers/net/ieee802154/fakehard.c
+++ b/drivers/net/ieee802154/fakehard.c
@@ -412,7 +412,7 @@ out:
 	return err;
 }
 
-static int __devexit ieee802154fake_remove(struct platform_device *pdev)
+static int ieee802154fake_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	unregister_netdev(dev);
diff --git a/drivers/net/ieee802154/fakelb.c b/drivers/net/ieee802154/fakelb.c
index e4b0e38..b8d2217 100644
--- a/drivers/net/ieee802154/fakelb.c
+++ b/drivers/net/ieee802154/fakelb.c
@@ -253,7 +253,7 @@ err_alloc:
 	return err;
 }
 
-static int __devexit fakelb_remove(struct platform_device *pdev)
+static int fakelb_remove(struct platform_device *pdev)
 {
 	struct fakelb_priv *priv = platform_get_drvdata(pdev);
 	struct fakelb_dev_priv *dp, *temp;
diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index ef41051..3f2c7aa 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -711,7 +711,7 @@ err_devrec:
 	return ret;
 }
 
-static int __devexit mrf24j40_remove(struct spi_device *spi)
+static int mrf24j40_remove(struct spi_device *spi)
 {
 	struct mrf24j40 *devrec = dev_get_drvdata(&spi->dev);
 
diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index 7843f50..b5151e4 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -921,7 +921,7 @@ out:
 	return err;
 }
 
-static int __devexit au1k_irda_remove(struct platform_device *pdev)
+static int au1k_irda_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct au1k_private *aup = netdev_priv(dev);
diff --git a/drivers/net/irda/bfin_sir.c b/drivers/net/irda/bfin_sir.c
index 98c903f..fed4a05 100644
--- a/drivers/net/irda/bfin_sir.c
+++ b/drivers/net/irda/bfin_sir.c
@@ -775,7 +775,7 @@ err_mem_0:
 	return err;
 }
 
-static int __devexit bfin_sir_remove(struct platform_device *pdev)
+static int bfin_sir_remove(struct platform_device *pdev)
 {
 	struct bfin_sir_port *sir_port;
 	struct net_device *dev = NULL;
diff --git a/drivers/net/irda/sh_irda.c b/drivers/net/irda/sh_irda.c
index 2d3f3e6..9448587 100644
--- a/drivers/net/irda/sh_irda.c
+++ b/drivers/net/irda/sh_irda.c
@@ -825,7 +825,7 @@ exit:
 	return err;
 }
 
-static int __devexit sh_irda_remove(struct platform_device *pdev)
+static int sh_irda_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct sh_irda_self *self = netdev_priv(ndev);
diff --git a/drivers/net/irda/sh_sir.c b/drivers/net/irda/sh_sir.c
index 150b56c..24aefcd 100644
--- a/drivers/net/irda/sh_sir.c
+++ b/drivers/net/irda/sh_sir.c
@@ -783,7 +783,7 @@ exit:
 	return err;
 }
 
-static int __devexit sh_sir_remove(struct platform_device *pdev)
+static int sh_sir_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct sh_sir_self *self = netdev_priv(ndev);
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index d678f52..5488247 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -103,7 +103,7 @@ static void hwreset(struct via_ircc_cb *self);
 static int via_ircc_dma_xmit(struct via_ircc_cb *self, u16 iobase);
 static int upload_rxdata(struct via_ircc_cb *self, int iobase);
 static int via_init_one (struct pci_dev *pcidev, const struct pci_device_id *id);
-static void __devexit via_remove_one (struct pci_dev *pdev);
+static void via_remove_one (struct pci_dev *pdev);
 
 /* FIXME : Should use udelay() instead, even if we are x86 only - Jean II */
 static void iodelay(int udelay)
@@ -424,7 +424,7 @@ static int via_ircc_open(struct pci_dev *pdev, chipio_t * info,
  *    Close driver instance
  *
  */
-static void __devexit via_remove_one(struct pci_dev *pdev)
+static void via_remove_one(struct pci_dev *pdev)
 {
 	struct via_ircc_cb *self = pci_get_drvdata(pdev);
 	int iobase;
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index e255b65..2f99f88 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -1699,7 +1699,7 @@ out:
 	return -ENODEV;
 }
 
-static void __devexit vlsi_irda_remove(struct pci_dev *pdev)
+static void vlsi_irda_remove(struct pci_dev *pdev)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
 	vlsi_irda_dev_t *idev;
diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index bf30b1d..6b2fdb8 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -173,7 +173,7 @@ static void mdio_gpio_bus_deinit(struct device *dev)
 	kfree(bitbang);
 }
 
-static void __devexit mdio_gpio_bus_destroy(struct device *dev)
+static void mdio_gpio_bus_destroy(struct device *dev)
 {
 	struct mii_bus *bus = dev_get_drvdata(dev);
 
@@ -210,7 +210,7 @@ static int mdio_gpio_probe(struct platform_device *pdev)
 	return ret;
 }
 
-static int __devexit mdio_gpio_remove(struct platform_device *pdev)
+static int mdio_gpio_remove(struct platform_device *pdev)
 {
 	mdio_gpio_bus_destroy(&pdev->dev);
 
diff --git a/drivers/net/phy/mdio-mux-gpio.c b/drivers/net/phy/mdio-mux-gpio.c
index 23ee064..0c9accb 100644
--- a/drivers/net/phy/mdio-mux-gpio.c
+++ b/drivers/net/phy/mdio-mux-gpio.c
@@ -104,7 +104,7 @@ err:
 	return r;
 }
 
-static int __devexit mdio_mux_gpio_remove(struct platform_device *pdev)
+static int mdio_mux_gpio_remove(struct platform_device *pdev)
 {
 	struct mdio_mux_gpio_state *s = pdev->dev.platform_data;
 	mdio_mux_uninit(s->mux_handle);
diff --git a/drivers/net/phy/mdio-mux-mmioreg.c b/drivers/net/phy/mdio-mux-mmioreg.c
index a38951f..9733bd2 100644
--- a/drivers/net/phy/mdio-mux-mmioreg.c
+++ b/drivers/net/phy/mdio-mux-mmioreg.c
@@ -137,7 +137,7 @@ static int mdio_mux_mmioreg_probe(struct platform_device *pdev)
 	return 0;
 }
 
-static int __devexit mdio_mux_mmioreg_remove(struct platform_device *pdev)
+static int mdio_mux_mmioreg_remove(struct platform_device *pdev)
 {
 	struct mdio_mux_mmioreg_state *s = dev_get_platdata(&pdev->dev);
 
diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
index 7a07985..09297fe 100644
--- a/drivers/net/phy/mdio-octeon.c
+++ b/drivers/net/phy/mdio-octeon.c
@@ -159,7 +159,7 @@ fail:
 	return err;
 }
 
-static int __devexit octeon_mdiobus_remove(struct platform_device *pdev)
+static int octeon_mdiobus_remove(struct platform_device *pdev)
 {
 	struct octeon_mdiobus *bus;
 	union cvmx_smix_en smi_en;
diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index 1321c99..41eb8ff 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -332,7 +332,7 @@ err_drvdata:
 	return err;
 }
 
-static int __devexit ks8995_remove(struct spi_device *spi)
+static int ks8995_remove(struct spi_device *spi)
 {
 	struct ks8995_data      *ks8995;
 
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index b0c1630..c5f0ed2 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1195,7 +1195,7 @@ static void remove_vq_common(struct virtnet_info *vi)
 		__free_pages(get_a_page(vi, GFP_KERNEL), 0);
 }
 
-static void __devexit virtnet_remove(struct virtio_device *vdev)
+static void virtnet_remove(struct virtio_device *vdev)
 {
 	struct virtnet_info *vi = vdev->priv;
 
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index ac322e5..71b762f 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -3096,7 +3096,7 @@ err_alloc_shared:
 }
 
 
-static void __devexit
+static void
 vmxnet3_remove_device(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 863df17..d502230 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -1968,7 +1968,7 @@ err_out:
 	return -ENOMEM;
 }
 
-static void __devexit dscc4_remove_one(struct pci_dev *pdev)
+static void dscc4_remove_one(struct pci_dev *pdev)
 {
 	struct dscc4_pci_priv *ppriv;
 	struct dscc4_dev_priv *root;
diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index dbbe06e..d7adba4 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -2615,7 +2615,7 @@ fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 /*
  *      Cleanup and close down a card
  */
-static void __devexit
+static void
 fst_remove_one(struct pci_dev *pdev)
 {
 	struct fst_card_info *card;
diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.c
index beecbe8..b056691 100644
--- a/drivers/net/wan/ixp4xx_hss.c
+++ b/drivers/net/wan/ixp4xx_hss.c
@@ -1375,7 +1375,7 @@ err_free:
 	return err;
 }
 
-static int __devexit hss_remove_one(struct platform_device *pdev)
+static int hss_remove_one(struct platform_device *pdev)
 {
 	struct port *port = platform_get_drvdata(pdev);
 
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 41a401a..0e443fd 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -986,7 +986,7 @@ err_req_io:
 /*
  * Called from pci when removing module.
  */
-static void __devexit lmc_remove_one(struct pci_dev *pdev)
+static void lmc_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 
diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index bd89a29..3d339e0 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -1935,7 +1935,7 @@ static int adm8211_probe(struct pci_dev *pdev,
 }
 
 
-static void __devexit adm8211_remove(struct pci_dev *pdev)
+static void adm8211_remove(struct pci_dev *pdev)
 {
 	struct ieee80211_hw *dev = pci_get_drvdata(pdev);
 	struct adm8211_priv *priv;
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index b010f41..5329541 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -5606,7 +5606,7 @@ static int airo_pci_probe(struct pci_dev *pdev,
 	return 0;
 }
 
-static void __devexit airo_pci_remove(struct pci_dev *pdev)
+static void airo_pci_remove(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 
diff --git a/drivers/net/wireless/ath/ath5k/pci.c b/drivers/net/wireless/ath/ath5k/pci.c
index 1a78ba3..859db7c 100644
--- a/drivers/net/wireless/ath/ath5k/pci.c
+++ b/drivers/net/wireless/ath/ath5k/pci.c
@@ -285,7 +285,7 @@ err:
 	return ret;
 }
 
-static void __devexit
+static void
 ath5k_pci_remove(struct pci_dev *pdev)
 {
 	struct ieee80211_hw *hw = pci_get_drvdata(pdev);
diff --git a/drivers/net/wireless/atmel_pci.c b/drivers/net/wireless/atmel_pci.c
index 1c12fec..c1b159e 100644
--- a/drivers/net/wireless/atmel_pci.c
+++ b/drivers/net/wireless/atmel_pci.c
@@ -69,7 +69,7 @@ static int atmel_pci_probe(struct pci_dev *pdev,
 	return 0;
 }
 
-static void __devexit atmel_pci_remove(struct pci_dev *pdev)
+static void atmel_pci_remove(struct pci_dev *pdev)
 {
 	stop_atmel_card(pci_get_drvdata(pdev));
 }
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index 3506cca..f2ea2ce 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -110,7 +110,7 @@ out_error:
 	return err;
 }
 
-static void __devexit b43_pcmcia_remove(struct pcmcia_device *dev)
+static void b43_pcmcia_remove(struct pcmcia_device *dev)
 {
 	struct ssb_bus *ssb = dev->priv;
 
diff --git a/drivers/net/wireless/b43/sdio.c b/drivers/net/wireless/b43/sdio.c
index d2b1f98..59a5218 100644
--- a/drivers/net/wireless/b43/sdio.c
+++ b/drivers/net/wireless/b43/sdio.c
@@ -171,7 +171,7 @@ out:
 	return error;
 }
 
-static void __devexit b43_sdio_remove(struct sdio_func *func)
+static void b43_sdio_remove(struct sdio_func *func)
 {
 	struct b43_sdio *sdio = sdio_get_drvdata(func);
 
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index b96c615..7588484 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -6413,7 +6413,7 @@ out:
 	goto out;
 }
 
-static void __devexit ipw2100_pci_remove_one(struct pci_dev *pci_dev)
+static void ipw2100_pci_remove_one(struct pci_dev *pci_dev)
 {
 	struct ipw2100_priv *priv = pci_get_drvdata(pci_dev);
 	struct net_device *dev = priv->net_dev;
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 3f099a6..941c6b5 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -11895,7 +11895,7 @@ static int ipw_pci_probe(struct pci_dev *pdev,
 	return err;
 }
 
-static void __devexit ipw_pci_remove(struct pci_dev *pdev)
+static void ipw_pci_remove(struct pci_dev *pdev)
 {
 	struct ipw_priv *priv = pci_get_drvdata(pdev);
 	struct list_head *p, *q;
diff --git a/drivers/net/wireless/iwlegacy/3945-mac.c b/drivers/net/wireless/iwlegacy/3945-mac.c
index 88fdd39..d604b40 100644
--- a/drivers/net/wireless/iwlegacy/3945-mac.c
+++ b/drivers/net/wireless/iwlegacy/3945-mac.c
@@ -3794,7 +3794,7 @@ out:
 	return err;
 }
 
-static void __devexit
+static void
 il3945_pci_remove(struct pci_dev *pdev)
 {
 	struct il_priv *il = pci_get_drvdata(pdev);
diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireless/iwlegacy/4965-mac.c
index 14e0a94..569e1ae5 100644
--- a/drivers/net/wireless/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/iwlegacy/4965-mac.c
@@ -6664,7 +6664,7 @@ out:
 	return err;
 }
 
-static void __devexit
+static void
 il4965_pci_remove(struct pci_dev *pdev)
 {
 	struct il_priv *il = pci_get_drvdata(pdev);
diff --git a/drivers/net/wireless/iwlwifi/pcie/drv.c b/drivers/net/wireless/iwlwifi/pcie/drv.c
index 7cb27af..1f21d60 100644
--- a/drivers/net/wireless/iwlwifi/pcie/drv.c
+++ b/drivers/net/wireless/iwlwifi/pcie/drv.c
@@ -294,7 +294,7 @@ out_free_trans:
 	return -EFAULT;
 }
 
-static void __devexit iwl_pci_remove(struct pci_dev *pdev)
+static void iwl_pci_remove(struct pci_dev *pdev)
 {
 	struct iwl_trans *trans = pci_get_drvdata(pdev);
 	struct iwl_trans_pcie *trans_pcie = IWL_TRANS_GET_PCIE_TRANS(trans);
diff --git a/drivers/net/wireless/libertas/if_spi.c b/drivers/net/wireless/libertas/if_spi.c
index abc32e3..4bb6574 100644
--- a/drivers/net/wireless/libertas/if_spi.c
+++ b/drivers/net/wireless/libertas/if_spi.c
@@ -1226,7 +1226,7 @@ out:
 	return err;
 }
 
-static int __devexit libertas_spi_remove(struct spi_device *spi)
+static int libertas_spi_remove(struct spi_device *spi)
 {
 	struct if_spi_card *card = spi_get_drvdata(spi);
 	struct lbs_private *priv = card->priv;
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index b9f71fd..19cad01 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -5872,12 +5872,12 @@ err_disable_device:
 	return rc;
 }
 
-static void __devexit mwl8k_shutdown(struct pci_dev *pdev)
+static void mwl8k_shutdown(struct pci_dev *pdev)
 {
 	printk(KERN_ERR "===>%s(%u)\n", __func__, __LINE__);
 }
 
-static void __devexit mwl8k_remove(struct pci_dev *pdev)
+static void mwl8k_remove(struct pci_dev *pdev)
 {
 	struct ieee80211_hw *hw = pci_get_drvdata(pdev);
 	struct mwl8k_priv *priv;
diff --git a/drivers/net/wireless/orinoco/orinoco_nortel.c b/drivers/net/wireless/orinoco/orinoco_nortel.c
index f286540..d73fdf6 100644
--- a/drivers/net/wireless/orinoco/orinoco_nortel.c
+++ b/drivers/net/wireless/orinoco/orinoco_nortel.c
@@ -255,7 +255,7 @@ static int orinoco_nortel_init_one(struct pci_dev *pdev,
 	return err;
 }
 
-static void __devexit orinoco_nortel_remove_one(struct pci_dev *pdev)
+static void orinoco_nortel_remove_one(struct pci_dev *pdev)
 {
 	struct orinoco_private *priv = pci_get_drvdata(pdev);
 	struct orinoco_pci_card *card = priv->card;
diff --git a/drivers/net/wireless/orinoco/orinoco_pci.c b/drivers/net/wireless/orinoco/orinoco_pci.c
index bf6d436..677bf14 100644
--- a/drivers/net/wireless/orinoco/orinoco_pci.c
+++ b/drivers/net/wireless/orinoco/orinoco_pci.c
@@ -199,7 +199,7 @@ static int orinoco_pci_init_one(struct pci_dev *pdev,
 	return err;
 }
 
-static void __devexit orinoco_pci_remove_one(struct pci_dev *pdev)
+static void orinoco_pci_remove_one(struct pci_dev *pdev)
 {
 	struct orinoco_private *priv = pci_get_drvdata(pdev);
 
diff --git a/drivers/net/wireless/orinoco/orinoco_plx.c b/drivers/net/wireless/orinoco/orinoco_plx.c
index 63a614f..2559dbd 100644
--- a/drivers/net/wireless/orinoco/orinoco_plx.c
+++ b/drivers/net/wireless/orinoco/orinoco_plx.c
@@ -294,7 +294,7 @@ static int orinoco_plx_init_one(struct pci_dev *pdev,
 	return err;
 }
 
-static void __devexit orinoco_plx_remove_one(struct pci_dev *pdev)
+static void orinoco_plx_remove_one(struct pci_dev *pdev)
 {
 	struct orinoco_private *priv = pci_get_drvdata(pdev);
 	struct orinoco_pci_card *card = priv->card;
diff --git a/drivers/net/wireless/orinoco/orinoco_tmd.c b/drivers/net/wireless/orinoco/orinoco_tmd.c
index f67f43e..42afeee 100644
--- a/drivers/net/wireless/orinoco/orinoco_tmd.c
+++ b/drivers/net/wireless/orinoco/orinoco_tmd.c
@@ -188,7 +188,7 @@ static int orinoco_tmd_init_one(struct pci_dev *pdev,
 	return err;
 }
 
-static void __devexit orinoco_tmd_remove_one(struct pci_dev *pdev)
+static void orinoco_tmd_remove_one(struct pci_dev *pdev)
 {
 	struct orinoco_private *priv = pci_get_drvdata(pdev);
 	struct orinoco_pci_card *card = priv->card;
diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
index e5b29e9..04eb0ed 100644
--- a/drivers/net/wireless/p54/p54pci.c
+++ b/drivers/net/wireless/p54/p54pci.c
@@ -639,7 +639,7 @@ static int p54p_probe(struct pci_dev *pdev,
 	return err;
 }
 
-static void __devexit p54p_remove(struct pci_dev *pdev)
+static void p54p_remove(struct pci_dev *pdev)
 {
 	struct ieee80211_hw *dev = pci_get_drvdata(pdev);
 	struct p54p_priv *priv;
diff --git a/drivers/net/wireless/p54/p54spi.c b/drivers/net/wireless/p54/p54spi.c
index d75ab3e..4fd49a0 100644
--- a/drivers/net/wireless/p54/p54spi.c
+++ b/drivers/net/wireless/p54/p54spi.c
@@ -683,7 +683,7 @@ err_free:
 	return ret;
 }
 
-static int __devexit p54spi_remove(struct spi_device *spi)
+static int p54spi_remove(struct spi_device *spi)
 {
 	struct p54s_priv *priv = dev_get_drvdata(&spi->dev);
 
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
index 000f7ba..e71c702 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -1057,7 +1057,7 @@ static int p54u_probe(struct usb_interface *intf,
 	return err;
 }
 
-static void __devexit p54u_disconnect(struct usb_interface *intf)
+static void p54u_disconnect(struct usb_interface *intf)
 {
 	struct ieee80211_hw *dev = usb_get_intfdata(intf);
 	struct p54u_priv *priv;
diff --git a/drivers/net/wireless/rtl818x/rtl8180/dev.c b/drivers/net/wireless/rtl818x/rtl8180/dev.c
index 6a5c0b8..4af3f91 100644
--- a/drivers/net/wireless/rtl818x/rtl8180/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8180/dev.c
@@ -1131,7 +1131,7 @@ static int rtl8180_probe(struct pci_dev *pdev,
 	return err;
 }
 
-static void __devexit rtl8180_remove(struct pci_dev *pdev)
+static void rtl8180_remove(struct pci_dev *pdev)
 {
 	struct ieee80211_hw *dev = pci_get_drvdata(pdev);
 	struct rtl8180_priv *priv;
diff --git a/drivers/net/wireless/rtl818x/rtl8187/dev.c b/drivers/net/wireless/rtl818x/rtl8187/dev.c
index f879bc3..be36935 100644
--- a/drivers/net/wireless/rtl818x/rtl8187/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8187/dev.c
@@ -1639,7 +1639,7 @@ static int rtl8187_probe(struct usb_interface *intf,
 	return err;
 }
 
-static void __devexit rtl8187_disconnect(struct usb_interface *intf)
+static void rtl8187_disconnect(struct usb_interface *intf)
 {
 	struct ieee80211_hw *dev = usb_get_intfdata(intf);
 	struct rtl8187_priv *priv;
diff --git a/drivers/net/wireless/ti/wl1251/sdio.c b/drivers/net/wireless/ti/wl1251/sdio.c
index e3f287f..e57ee48 100644
--- a/drivers/net/wireless/ti/wl1251/sdio.c
+++ b/drivers/net/wireless/ti/wl1251/sdio.c
@@ -305,7 +305,7 @@ out_free_hw:
 	return ret;
 }
 
-static void __devexit wl1251_sdio_remove(struct sdio_func *func)
+static void wl1251_sdio_remove(struct sdio_func *func)
 {
 	struct wl1251 *wl = sdio_get_drvdata(func);
 	struct wl1251_sdio *wl_sdio = wl->if_priv;
diff --git a/drivers/net/wireless/ti/wl1251/spi.c b/drivers/net/wireless/ti/wl1251/spi.c
index 640a3d5..3b266d3 100644
--- a/drivers/net/wireless/ti/wl1251/spi.c
+++ b/drivers/net/wireless/ti/wl1251/spi.c
@@ -309,7 +309,7 @@ static int wl1251_spi_probe(struct spi_device *spi)
 	return ret;
 }
 
-static int __devexit wl1251_spi_remove(struct spi_device *spi)
+static int wl1251_spi_remove(struct spi_device *spi)
 {
 	struct wl1251 *wl = dev_get_drvdata(&spi->dev);
 
diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index 2dd4ada..dd38f61 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -5682,7 +5682,7 @@ int wlcore_probe(struct wl1271 *wl, struct platform_device *pdev)
 }
 EXPORT_SYMBOL_GPL(wlcore_probe);
 
-int __devexit wlcore_remove(struct platform_device *pdev)
+int wlcore_remove(struct platform_device *pdev)
 {
 	struct wl1271 *wl = platform_get_drvdata(pdev);
 
diff --git a/drivers/net/wireless/ti/wlcore/sdio.c b/drivers/net/wireless/ti/wlcore/sdio.c
index 7bf612c..646f703 100644
--- a/drivers/net/wireless/ti/wlcore/sdio.c
+++ b/drivers/net/wireless/ti/wlcore/sdio.c
@@ -319,7 +319,7 @@ out:
 	return ret;
 }
 
-static void __devexit wl1271_remove(struct sdio_func *func)
+static void wl1271_remove(struct sdio_func *func)
 {
 	struct wl12xx_sdio_glue *glue = sdio_get_drvdata(func);
 
diff --git a/drivers/net/wireless/ti/wlcore/spi.c b/drivers/net/wireless/ti/wlcore/spi.c
index ee39484..f06f477 100644
--- a/drivers/net/wireless/ti/wlcore/spi.c
+++ b/drivers/net/wireless/ti/wlcore/spi.c
@@ -403,7 +403,7 @@ out:
 	return ret;
 }
 
-static int __devexit wl1271_remove(struct spi_device *spi)
+static int wl1271_remove(struct spi_device *spi)
 {
 	struct wl12xx_spi_glue *glue = spi_get_drvdata(spi);
 
diff --git a/drivers/net/wireless/ti/wlcore/wlcore.h b/drivers/net/wireless/ti/wlcore/wlcore.h
index adc6152..c388493 100644
--- a/drivers/net/wireless/ti/wlcore/wlcore.h
+++ b/drivers/net/wireless/ti/wlcore/wlcore.h
@@ -415,7 +415,7 @@ struct wl1271 {
 };
 
 int wlcore_probe(struct wl1271 *wl, struct platform_device *pdev);
-int __devexit wlcore_remove(struct platform_device *pdev);
+int wlcore_remove(struct platform_device *pdev);
 struct ieee80211_hw *wlcore_alloc_hw(size_t priv_size, u32 aggr_buf_size);
 int wlcore_free_hw(struct wl1271 *wl);
 int wlcore_set_key(struct wl1271 *wl, enum set_key_cmd cmd,
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 6f695fc..b31198c 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1911,7 +1911,7 @@ static const struct xenbus_device_id netfront_ids[] = {
 };
 
 
-static int __devexit xennet_remove(struct xenbus_device *dev)
+static int xennet_remove(struct xenbus_device *dev)
 {
 	struct netfront_info *info = dev_get_drvdata(&dev->dev);
 
-- 
1.8.0
