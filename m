From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 03/11] phy: Use macros instead of hardcoded values in marvell phy driver
Date: Wed, 29 May 2013 17:33:03 +0200
Message-ID: <1ce55f2ae709b48733bb68e05253c23a4e90f1ae.1369841519.git.michal.simek@xilinx.com>
References: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-27586-1369841601-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Michal Simek <monstr@monstr.eu>,
	Michal Simek <michal.simek@xilinx.com>,
	"David S. Miller" <davem@davemloft.net>,
	Lars-Peter Clausen <lars@metafoo.de>,
	Christian Hohnstaedt <chohnstaedt@innominate.com>,
	Rick Hoover <RHoover@digilentinc.com>, netdev@vger.kernel.org
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

--=_mimegpg-monstr-desktop-27586-1369841601-0001

Use macros from linux/marvell_phy.h instead of duplicate
magic phy ID in the driver.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---
 drivers/net/phy/marvell.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 202fe1f..371353c 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -958,15 +958,15 @@ module_init(marvell_init);
 module_exit(marvell_exit);

 static struct mdio_device_id __maybe_unused marvell_tbl[] = {
-	{ 0x01410c60, 0xfffffff0 },
-	{ 0x01410c90, 0xfffffff0 },
-	{ 0x01410cc0, 0xfffffff0 },
-	{ 0x01410e10, 0xfffffff0 },
-	{ 0x01410cb0, 0xfffffff0 },
-	{ 0x01410cd0, 0xfffffff0 },
-	{ 0x01410e50, 0xfffffff0 },
-	{ 0x01410e30, 0xfffffff0 },
-	{ 0x01410e90, 0xfffffff0 },
+	{ MARVELL_PHY_ID_88E1101, MARVELL_PHY_ID_MASK },
+	{ MARVELL_PHY_ID_88E1112, MARVELL_PHY_ID_MASK },
+	{ MARVELL_PHY_ID_88E1111, MARVELL_PHY_ID_MASK },
+	{ MARVELL_PHY_ID_88E1118, MARVELL_PHY_ID_MASK },
+	{ MARVELL_PHY_ID_88E1121R, MARVELL_PHY_ID_MASK },
+	{ MARVELL_PHY_ID_88E1145, MARVELL_PHY_ID_MASK },
+	{ MARVELL_PHY_ID_88E1149R, MARVELL_PHY_ID_MASK },
+	{ MARVELL_PHY_ID_88E1240, MARVELL_PHY_ID_MASK },
+	{ MARVELL_PHY_ID_88E1318S, MARVELL_PHY_ID_MASK },
 	{ }
 };

--
1.8.2.3


--=_mimegpg-monstr-desktop-27586-1369841601-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlGmH8EACgkQykllyylKDCFtVACdEckRxRko1/4xuch1ONcuJa5N
X2UAnReC9SBYN054F9cxAhAt/eUYit+z
=lCLx
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-27586-1369841601-0001--
