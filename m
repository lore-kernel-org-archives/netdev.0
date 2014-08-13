From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH] net: xilinx: Remove .owner field for driver
Date: Wed, 13 Aug 2014 13:54:22 +0200
Message-ID: <a63aa03f310bb32779833fc905579458a34be6ce.1407930852.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-19377-1407930862-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>,
	Joe Perches <joe@perches.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Eric Dumazet <edumazet@google.com>,
	Rob Herring <rob.herring@calxeda.com>,
	Ricardo Ribalda <ricardo.ribalda@gmail.com>,
	Libo Chen <libo.chen@huawei.com>,
	Srikanth Thokala <sthokal@xilinx.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: linux-kernel@vger.kernel.org, monstr@monstr.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-19377-1407930862-0001

There is no need to init .owner field.

Based on the patch from Peter Griffin <peter.griffin@linaro.org>
"mmc: remove .owner field for drivers using module_platform_driver"

This patch removes the superflous .owner field for drivers which
use the module_platform_driver API, as this is overriden in
platform_driver_register anyway."

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/xilinx/ll_temac_main.c       | 1 -
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 1 -
 drivers/net/ethernet/xilinx/xilinx_emaclite.c     | 1 -
 3 files changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 8a6e5c2d6f95..b58442fd15fa 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -1171,7 +1171,6 @@ static struct platform_driver temac_of_driver = {
 	.probe = temac_of_probe,
 	.remove = temac_of_remove,
 	.driver = {
-		.owner = THIS_MODULE,
 		.name = "xilinx_temac",
 		.of_match_table = temac_of_match,
 	},
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 7b0a73556264..30f133046914 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1646,7 +1646,6 @@ static struct platform_driver axienet_of_driver = {
 	.probe = axienet_of_probe,
 	.remove = axienet_of_remove,
 	.driver = {
-		 .owner = THIS_MODULE,
 		 .name = "xilinx_axienet",
 		 .of_match_table = axienet_of_match,
 	},
diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 782bb9373cd8..28dbbdc393eb 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -1245,7 +1245,6 @@ MODULE_DEVICE_TABLE(of, xemaclite_of_match);
 static struct platform_driver xemaclite_of_driver = {
 	.driver = {
 		.name = DRIVER_NAME,
-		.owner = THIS_MODULE,
 		.of_match_table = xemaclite_of_match,
 	},
 	.probe		= xemaclite_of_probe,
--
1.8.2.3


--=_mimegpg-monstr-desktop-19377-1407930862-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlPrUe4ACgkQykllyylKDCGzIACfehH8GwB6Hi7bxfrvTjG/NtJW
c0sAnAxlo7X8nmHkfvEGt1DmZurqghR7
=r+cZ
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-19377-1407930862-0001--
