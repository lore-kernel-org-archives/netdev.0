From: Dan Murphy <dmurphy@ti.com>
Subject: [PATCH] net: phy: dp83867: Fix warning check for setting the internal delay
Date: Tue, 21 Jul 2015 12:06:45 -0500
Message-ID: <1437498405-1723-1-git-send-email-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <dcb314@hotmail.com>, <f.fainelli@gmail.com>,
	Dan Murphy <dmurphy@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:56496 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755557AbbGURGs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2015 13:06:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix warning: logical =E2=80=98or=E2=80=99 of collectively exhaustive =
tests is always true

Change the internal delay check from an 'or' condition to an 'and'
condition.

Reported-by: David Binderman <dcb314@hotmail.com>
Signed-off-by: Dan Murphy <dmurphy@ti.com>
---
 drivers/net/phy/dp83867.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/dp83867.c b/drivers/net/phy/dp83867.c
index c7a12e2..8a3bf54 100644
--- a/drivers/net/phy/dp83867.c
+++ b/drivers/net/phy/dp83867.c
@@ -164,7 +164,7 @@ static int dp83867_config_init(struct phy_device *p=
hydev)
 			return ret;
 	}
=20
-	if ((phydev->interface >=3D PHY_INTERFACE_MODE_RGMII_ID) ||
+	if ((phydev->interface >=3D PHY_INTERFACE_MODE_RGMII_ID) &&
 	    (phydev->interface <=3D PHY_INTERFACE_MODE_RGMII_RXID)) {
 		val =3D phy_read_mmd_indirect(phydev, DP83867_RGMIICTL,
 					    DP83867_DEVADDR, phydev->addr);
--=20
1.9.1
