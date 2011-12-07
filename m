From: =?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH v2 1/8][NET] fec.c: misc cleanups
Date: Wed,  7 Dec 2011 14:37:13 +0100
Message-ID: <bd4415514fa0b40ece04d56b3ac4f549e79d87d7.1323256319.git.LW@KARO-electronics.de>
References: <cover.1323256319.git.LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Shawn Guo <shawn.guo@linaro.org>,
	=?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1323256319.git.LW@KARO-electronics.de>
In-Reply-To: <cover.1323256319.git.LW@KARO-electronics.de>
References: <cover.1323256319.git.LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 - remove some bogus whitespace
 - remove line wraps from printk messages

Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/ethernet/freescale/fec.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/etherne=
t/freescale/fec.c
index 1124ce0..f224e58 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -99,7 +99,7 @@ static struct platform_device_id fec_devtype[] =3D {
 MODULE_DEVICE_TABLE(platform, fec_devtype);
=20
 enum imx_fec_type {
-	IMX25_FEC =3D 1, 	/* runs on i.mx25/50/53 */
+	IMX25_FEC =3D 1,	/* runs on i.mx25/50/53 */
 	IMX27_FEC,	/* runs on i.mx27/35/51 */
 	IMX28_FEC,
 	IMX6Q_FEC,
@@ -132,7 +132,7 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address=
");
 #elif defined (CONFIG_M5272C3)
 #define	FEC_FLASHMAC	(0xffe04000 + 4)
 #elif defined(CONFIG_MOD5272)
-#define FEC_FLASHMAC 	0xffc0406b
+#define FEC_FLASHMAC	0xffc0406b
 #else
 #define	FEC_FLASHMAC	0
 #endif
@@ -972,8 +972,9 @@ static int fec_enet_mii_probe(struct net_device *nd=
ev)
 	}
=20
 	if (phy_id >=3D PHY_MAX_ADDR) {
-		printk(KERN_INFO "%s: no PHY, assuming direct connection "
-			"to switch\n", ndev->name);
+		printk(KERN_INFO
+			"%s: no PHY, assuming direct connection to switch\n",
+			ndev->name);
 		strncpy(mdio_bus_id, "0", MII_BUS_ID_SIZE);
 		phy_id =3D 0;
 	}
@@ -998,8 +999,9 @@ static int fec_enet_mii_probe(struct net_device *nd=
ev)
 	fep->link =3D 0;
 	fep->full_duplex =3D 0;
=20
-	printk(KERN_INFO "%s: Freescale FEC PHY driver [%s] "
-		"(mii_bus:phy_addr=3D%s, irq=3D%d)\n", ndev->name,
+	printk(KERN_INFO
+		"%s: Freescale FEC PHY driver [%s] (mii_bus:phy_addr=3D%s, irq=3D%d)=
\n",
+		ndev->name,
 		fep->phy_dev->drv->name, dev_name(&fep->phy_dev->dev),
 		fep->phy_dev->irq);
=20
--=20
1.5.6.5
