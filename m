From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 13/14] net: axienet: Removed _of_ prefix in probe and remove functions
Date: Wed, 12 Feb 2014 16:55:47 +0100
Message-ID: <50c3d613305d2e8cf4cbb74fc87c9a178c6332e6.1392220536.git.michal.simek@xilinx.com>
References: <cover.1392220536.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-2352-1392220639-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Srikanth Thokala <sthokal@xilinx.com>,
	Srikanth Thokala <srikanth.thokala@xilinx.com>,
	Michal Simek <monstr@monstr.eu>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392220536.git.michal.simek@xilinx.com>
In-Reply-To: <cover.1392220536.git.michal.simek@xilinx.com>
References: <cover.1392220536.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-2352-1392220639-0001

From: Srikanth Thokala <srikanth.thokala@xilinx.com>

Synchronize names with other drivers.

Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 9a9ffbc..6dd3eee 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1479,7 +1479,7 @@ static void axienet_dma_err_handler(unsigned long data)
 }

 /**
- * axienet_of_probe - Axi Ethernet probe function.
+ * axienet_probe - Axi Ethernet probe function.
  * @pdev:	Pointer to platform device structure.
  * @match:	Pointer to device id structure
  *
@@ -1491,7 +1491,7 @@ static void axienet_dma_err_handler(unsigned long data)
  * device. Parses through device tree and populates fields of
  * axienet_local. It registers the Ethernet device.
  */
-static int axienet_of_probe(struct platform_device *pdev)
+static int axienet_probe(struct platform_device *pdev)
 {
 	int ret;
 	struct device_node *np;
@@ -1639,7 +1639,7 @@ free_netdev:
 	return ret;
 }

-static int axienet_of_remove(struct platform_device *pdev)
+static int axienet_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct axienet_local *lp = netdev_priv(ndev);
@@ -1656,9 +1656,9 @@ static int axienet_of_remove(struct platform_device *pdev)
 	return 0;
 }

-static struct platform_driver axienet_of_driver = {
-	.probe = axienet_of_probe,
-	.remove = axienet_of_remove,
+static struct platform_driver axienet_driver = {
+	.probe = axienet_probe,
+	.remove = axienet_remove,
 	.driver = {
 		 .owner = THIS_MODULE,
 		 .name = "xilinx_axienet",
@@ -1666,7 +1666,7 @@ static struct platform_driver axienet_of_driver = {
 	},
 };

-module_platform_driver(axienet_of_driver);
+module_platform_driver(axienet_driver);

 MODULE_DESCRIPTION("Xilinx Axi Ethernet driver");
 MODULE_AUTHOR("Xilinx");
--
1.8.2.3


--=_mimegpg-monstr-desktop-2352-1392220639-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlL7md8ACgkQykllyylKDCED5ACgnpqAjK3EtHlR9pOeHgSOaq2n
02wAn1FK1iA5AAM6oT5t1/T/PFxtl6L9
=dBCe
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-2352-1392220639-0001--
