From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH] net: xilinx: Remove unnecessary ether_setup after alloc_etherdev
Date: Wed,  1 Oct 2014 08:00:23 +0200
Message-ID: <d43b465eca3e2a53c930f6e02dc4ac8b3c084693.1412143216.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-6841-1412143223-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Subbaraya Sundeep Bhatta <subbaraya.sundeep.bhatta@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Julia Lawall <Julia.Lawall@lip6.fr>,
	Joe Perches <joe@perches.com>,
	Ricardo Ribalda <ricardo.ribalda@gmail.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: linux-kernel@vger.kernel.org, monstr@monstr.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-6841-1412143223-0001

From: Subbaraya Sundeep Bhatta <subbaraya.sundeep.bhatta@xilinx.com>

Calling ether_setup is redundant since alloc_etherdev calls it.

Signed-off-by: Subbaraya Sundeep Bhatta <sbhatta@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/xilinx/ll_temac_main.c       | 1 -
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 1 -
 2 files changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index fda5891835d4..629077050fce 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -1012,7 +1012,6 @@ static int temac_of_probe(struct platform_device *op)
 	if (!ndev)
 		return -ENOMEM;

-	ether_setup(ndev);
 	platform_set_drvdata(op, ndev);
 	SET_NETDEV_DEV(ndev, &op->dev);
 	ndev->flags &= ~IFF_MULTICAST;  /* clear multicast */
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index c8fd94133ecd..4ea2d4e6f1d1 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1485,7 +1485,6 @@ static int axienet_of_probe(struct platform_device *op)
 	if (!ndev)
 		return -ENOMEM;

-	ether_setup(ndev);
 	platform_set_drvdata(op, ndev);

 	SET_NETDEV_DEV(ndev, &op->dev);
--
1.8.2.3


--=_mimegpg-monstr-desktop-6841-1412143223-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlQrmHcACgkQykllyylKDCFAqgCdGA+FtiRSBFCmBc1s/RWHqCAC
H5cAniMQ25suWJP5XV/TGK1O6rCWJ0C4
=TiIR
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-6841-1412143223-0001--
