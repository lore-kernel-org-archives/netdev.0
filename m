From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH v2 1/5] phy: Clean coding style in vitesse phy
Date: Fri, 31 May 2013 08:08:23 +0200
Message-ID: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369980470.git.michal.simek@xilinx.com>
References: <cover.1369980470.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-1678-1369980513-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Michal Simek <monstr@monstr.eu>,
	Michal Simek <michal.simek@xilinx.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Christian Hohnstaedt <chohnstaedt@innominate.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:58691 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041Ab3EaGIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 02:08:36 -0400
Received: by mail-ea0-f182.google.com with SMTP id r16so1154053ead.13
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 23:08:35 -0700 (PDT)
In-Reply-To: <cover.1369980470.git.michal.simek@xilinx.com>
In-Reply-To: <cover.1369980470.git.michal.simek@xilinx.com>
References: <cover.1369980470.git.michal.simek@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-1678-1369980513-0001

- Remove trailing white space
- Remove spaces before tag
- Fix comments

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---
Changes in v2: None

 drivers/net/phy/vitesse.c | 23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 3492b53..d6e988f 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -44,12 +44,12 @@
 #define MII_VSC8244_ISTAT_DUPLEX	0x1000

 /* Vitesse Auxiliary Control/Status Register */
-#define MII_VSC8244_AUX_CONSTAT        	0x1c
-#define MII_VSC8244_AUXCONSTAT_INIT    	0x0000
-#define MII_VSC8244_AUXCONSTAT_DUPLEX  	0x0020
-#define MII_VSC8244_AUXCONSTAT_SPEED   	0x0018
-#define MII_VSC8244_AUXCONSTAT_GBIT    	0x0010
-#define MII_VSC8244_AUXCONSTAT_100     	0x0008
+#define MII_VSC8244_AUX_CONSTAT		0x1c
+#define MII_VSC8244_AUXCONSTAT_INIT	0x0000
+#define MII_VSC8244_AUXCONSTAT_DUPLEX	0x0020
+#define MII_VSC8244_AUXCONSTAT_SPEED	0x0018
+#define MII_VSC8244_AUXCONSTAT_GBIT	0x0010
+#define MII_VSC8244_AUXCONSTAT_100	0x0008

 #define MII_VSC8221_AUXCONSTAT_INIT	0x0004 /* need to set this bit? */
 #define MII_VSC8221_AUXCONSTAT_RESERVED	0x0004
@@ -100,9 +100,8 @@ static int vsc824x_config_init(struct phy_device *phydev)
 static int vsc824x_ack_interrupt(struct phy_device *phydev)
 {
 	int err = 0;
-	
-	/*
-	 * Don't bother to ACK the interrupts if interrupts
+
+	/* Don't bother to ACK the interrupts if interrupts
 	 * are disabled.  The 824x cannot clear the interrupts
 	 * if they are disabled.
 	 */
@@ -122,8 +121,7 @@ static int vsc82xx_config_intr(struct phy_device *phydev)
 				MII_VSC8244_IMASK_MASK :
 				MII_VSC8221_IMASK_MASK);
 	else {
-		/*
-		 * The Vitesse PHY cannot clear the interrupt
+		/* The Vitesse PHY cannot clear the interrupt
 		 * once it has disabled them, so we clear them first
 		 */
 		err = phy_read(phydev, MII_VSC8244_ISTAT);
@@ -146,7 +144,8 @@ static int vsc8221_config_init(struct phy_device *phydev)
 	return err;

 	/* Perhaps we should set EXT_CON1 based on the interface?
-	   Options are 802.3Z SerDes or SGMII */
+	 * Options are 802.3Z SerDes or SGMII
+	 */
 }

 /* Vitesse 824x */
--
1.8.2.3


--=_mimegpg-monstr-desktop-1678-1369980513-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlGoPmEACgkQykllyylKDCGqcwCfRyrtsfbl1MV3L2jepKeBHwQF
ro0AnRdxLWUTadpMWMqIOTmibe3gjzK1
=/jWX
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-1678-1369980513-0001--
