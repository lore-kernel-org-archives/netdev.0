From: Kumar Gala <galak@freescale.com>
Subject: [PATCH] gianfar: Update Marvell PHY name
Date: Fri, 4 Mar 2005 01:55:11 -0600 (CST)
Message-ID: <Pine.LNX.4.61.0503040150480.16127@blarg.somerset.sps.mot.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linuxppc-embedded@ozlabs.org, netdev@oss.sgi.com
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff,

This patch updates the name identifier to list both of the Marvell PHYs 
that are supported.

Signed-off-by: Kumar Gala <kumar.gala@freescale.com>

---
diff -Nru a/drivers/net/gianfar_phy.c b/drivers/net/gianfar_phy.c
--- a/drivers/net/gianfar_phy.c	2005-03-02 14:20:27 -06:00
+++ b/drivers/net/gianfar_phy.c	2005-03-02 14:20:27 -06:00
@@ -572,7 +572,7 @@
 static struct phy_info phy_info_marvell = {
 	.phy_id		= 0x01410c00,
 	.phy_id_mask	= 0xffffff00,
-	.name		= "Marvell 88E1101",
+	.name		= "Marvell 88E1101/88E1111",
 	.features	= MII_GBIT_FEATURES,
 	.config_aneg	= &marvell_config_aneg,
 	.read_status	= &marvell_read_status,
