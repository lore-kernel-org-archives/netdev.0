From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 02/11] phy: Add Vitesse 8211 phy ID
Date: Wed, 29 May 2013 17:33:02 +0200
Message-ID: <804de6a875a407fb0379a437f83915e7158f2f2a.1369841519.git.michal.simek@xilinx.com>
References: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-27574-1369841599-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Michal Simek <monstr@monstr.eu>,
	Michal Simek <michal.simek@xilinx.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Christian Hohnstaedt <chohnstaedt@innominate.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
In-Reply-To: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
References: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-27574-1369841599-0001

Phy is compatible with Vitesse 8221.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---
 drivers/net/phy/vitesse.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index d6e988f..69b482b 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -56,6 +56,7 @@

 #define PHY_ID_VSC8244			0x000fc6c0
 #define PHY_ID_VSC8221			0x000fc550
+#define PHY_ID_VSC8211			0x000fc4b0

 MODULE_DESCRIPTION("Vitesse PHY driver");
 MODULE_AUTHOR("Kriston Carson");
@@ -175,6 +176,19 @@ static struct phy_driver vsc82xx_driver[] = {
 	.ack_interrupt	= &vsc824x_ack_interrupt,
 	.config_intr	= &vsc82xx_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
+}, {
+	/* Vitesse 8211 */
+	.phy_id		= PHY_ID_VSC8211,
+	.phy_id_mask	= 0x000ffff0,
+	.name		= "Vitesse VSC8211",
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_init	= &vsc8221_config_init,
+	.config_aneg	= &genphy_config_aneg,
+	.read_status	= &genphy_read_status,
+	.ack_interrupt	= &vsc824x_ack_interrupt,
+	.config_intr	= &vsc82xx_config_intr,
+	.driver		= { .owner = THIS_MODULE,},
 } };

 static int __init vsc82xx_init(void)
@@ -195,6 +209,7 @@ module_exit(vsc82xx_exit);
 static struct mdio_device_id __maybe_unused vitesse_tbl[] = {
 	{ PHY_ID_VSC8244, 0x000fffc0 },
 	{ PHY_ID_VSC8221, 0x000ffff0 },
+	{ PHY_ID_VSC8211, 0x000ffff0 },
 	{ }
 };

--
1.8.2.3


--=_mimegpg-monstr-desktop-27574-1369841599-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlGmH78ACgkQykllyylKDCHxkwCfWDDCVVSXyQdHXE9WItVDMAdZ
a0gAn3UVsFV5PWtWUMWQxRToh+mVcf/a
=lFQm
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-27574-1369841599-0001--
