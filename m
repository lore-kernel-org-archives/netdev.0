From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 1/2] net/phy: fix many "defined but unused" warnings
Date: Mon,  4 Oct 2010 11:43:32 +0200
Message-ID: <1286185413-22924-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52075 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754204Ab0JDJni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 05:43:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MODULE_DEVICE_TABLE only expdrivers/net/phy/bcm63xx.c:134: warning: 'bc=
m63xx_tbl' defined but not usedands to something if it's compiled
for a module.  So when building-in support for the phys, the
mdio_device_id tables are unused.  Marking them with __maybe_unused
fixes the following warnings:

	drivers/net/phy/bcm63xx.c:134: warning: 'bcm63xx_tbl' defined but not =
used
	drivers/net/phy/broadcom.c:933: warning: 'broadcom_tbl' defined but no=
t used
	drivers/net/phy/cicada.c:162: warning: 'cicada_tbl' defined but not us=
ed
	drivers/net/phy/davicom.c:222: warning: 'davicom_tbl' defined but not =
used
	drivers/net/phy/et1011c.c:114: warning: 'et1011c_tbl' defined but not =
used
	drivers/net/phy/icplus.c:137: warning: 'icplus_tbl' defined but not us=
ed
	drivers/net/phy/lxt.c:226: warning: 'lxt_tbl' defined but not used
	drivers/net/phy/marvell.c:724: warning: 'marvell_tbl' defined but not =
used
	drivers/net/phy/micrel.c:234: warning: 'micrel_tbl' defined but not us=
ed
	drivers/net/phy/national.c:154: warning: 'ns_tbl' defined but not used
	drivers/net/phy/qsemi.c:141: warning: 'qs6612_tbl' defined but not use=
d
	drivers/net/phy/realtek.c:82: warning: 'realtek_tbl' defined but not u=
sed
	drivers/net/phy/smsc.c:257: warning: 'smsc_tbl' defined but not used
	drivers/net/phy/ste10Xp.c:135: warning: 'ste10Xp_tbl' defined but not =
used
	drivers/net/phy/vitesse.c:195: warning: 'vitesse_tbl' defined but not =
used

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/phy/bcm63xx.c  |    2 +-
 drivers/net/phy/broadcom.c |    2 +-
 drivers/net/phy/cicada.c   |    2 +-
 drivers/net/phy/davicom.c  |    2 +-
 drivers/net/phy/et1011c.c  |    2 +-
 drivers/net/phy/icplus.c   |    2 +-
 drivers/net/phy/lxt.c      |    2 +-
 drivers/net/phy/marvell.c  |    2 +-
 drivers/net/phy/micrel.c   |    2 +-
 drivers/net/phy/national.c |    2 +-
 drivers/net/phy/qsemi.c    |    2 +-
 drivers/net/phy/realtek.c  |    2 +-
 drivers/net/phy/smsc.c     |    2 +-
 drivers/net/phy/ste10Xp.c  |    2 +-
 drivers/net/phy/vitesse.c  |    2 +-
 15 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/phy/bcm63xx.c b/drivers/net/phy/bcm63xx.c
index c128156..e16f98c 100644
--- a/drivers/net/phy/bcm63xx.c
+++ b/drivers/net/phy/bcm63xx.c
@@ -131,7 +131,7 @@ static void __exit bcm63xx_phy_exit(void)
 module_init(bcm63xx_phy_init);
 module_exit(bcm63xx_phy_exit);
=20
-static struct mdio_device_id bcm63xx_tbl[] =3D {
+static struct mdio_device_id __maybe_unused bcm63xx_tbl[] =3D {
 	{ 0x00406000, 0xfffffc00 },
 	{ 0x002bdc00, 0xfffffc00 },
 	{ }
diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 4accd83..d84c422 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -930,7 +930,7 @@ static void __exit broadcom_exit(void)
 module_init(broadcom_init);
 module_exit(broadcom_exit);
=20
-static struct mdio_device_id broadcom_tbl[] =3D {
+static struct mdio_device_id __maybe_unused broadcom_tbl[] =3D {
 	{ PHY_ID_BCM5411, 0xfffffff0 },
 	{ PHY_ID_BCM5421, 0xfffffff0 },
 	{ PHY_ID_BCM5461, 0xfffffff0 },
diff --git a/drivers/net/phy/cicada.c b/drivers/net/phy/cicada.c
index 1a325d6..d281731 100644
--- a/drivers/net/phy/cicada.c
+++ b/drivers/net/phy/cicada.c
@@ -159,7 +159,7 @@ static void __exit cicada_exit(void)
 module_init(cicada_init);
 module_exit(cicada_exit);
=20
-static struct mdio_device_id cicada_tbl[] =3D {
+static struct mdio_device_id __maybe_unused cicada_tbl[] =3D {
 	{ 0x000fc410, 0x000ffff0 },
 	{ 0x000fc440, 0x000fffc0 },
 	{ }
diff --git a/drivers/net/phy/davicom.c b/drivers/net/phy/davicom.c
index 29c1761..2f774ac 100644
--- a/drivers/net/phy/davicom.c
+++ b/drivers/net/phy/davicom.c
@@ -219,7 +219,7 @@ static void __exit davicom_exit(void)
 module_init(davicom_init);
 module_exit(davicom_exit);
=20
-static struct mdio_device_id davicom_tbl[] =3D {
+static struct mdio_device_id __maybe_unused davicom_tbl[] =3D {
 	{ 0x0181b880, 0x0ffffff0 },
 	{ 0x0181b8a0, 0x0ffffff0 },
 	{ 0x00181b80, 0x0ffffff0 },
diff --git a/drivers/net/phy/et1011c.c b/drivers/net/phy/et1011c.c
index 13995f5..a8eb19e 100644
--- a/drivers/net/phy/et1011c.c
+++ b/drivers/net/phy/et1011c.c
@@ -111,7 +111,7 @@ static void __exit et1011c_exit(void)
 module_init(et1011c_init);
 module_exit(et1011c_exit);
=20
-static struct mdio_device_id et1011c_tbl[] =3D {
+static struct mdio_device_id __maybe_unused et1011c_tbl[] =3D {
 	{ 0x0282f014, 0xfffffff0 },
 	{ }
 };
diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index 3f2583f..c1d2d25 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -134,7 +134,7 @@ static void __exit ip175c_exit(void)
 module_init(ip175c_init);
 module_exit(ip175c_exit);
=20
-static struct mdio_device_id icplus_tbl[] =3D {
+static struct mdio_device_id __maybe_unused icplus_tbl[] =3D {
 	{ 0x02430d80, 0x0ffffff0 },
 	{ }
 };
diff --git a/drivers/net/phy/lxt.c b/drivers/net/phy/lxt.c
index 29c39ff..6f6e8b6 100644
--- a/drivers/net/phy/lxt.c
+++ b/drivers/net/phy/lxt.c
@@ -223,7 +223,7 @@ static void __exit lxt_exit(void)
 module_init(lxt_init);
 module_exit(lxt_exit);
=20
-static struct mdio_device_id lxt_tbl[] =3D {
+static struct mdio_device_id __maybe_unused lxt_tbl[] =3D {
 	{ 0x78100000, 0xfffffff0 },
 	{ 0x001378e0, 0xfffffff0 },
 	{ 0x00137a10, 0xfffffff0 },
diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 0101f2b..ed43c00 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -721,7 +721,7 @@ static void __exit marvell_exit(void)
 module_init(marvell_init);
 module_exit(marvell_exit);
=20
-static struct mdio_device_id marvell_tbl[] =3D {
+static struct mdio_device_id __maybe_unused marvell_tbl[] =3D {
 	{ 0x01410c60, 0xfffffff0 },
 	{ 0x01410c90, 0xfffffff0 },
 	{ 0x01410cc0, 0xfffffff0 },
diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 8bb7db6..0fd1678 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -231,7 +231,7 @@ MODULE_DESCRIPTION("Micrel PHY driver");
 MODULE_AUTHOR("David J. Choi");
 MODULE_LICENSE("GPL");
=20
-static struct mdio_device_id micrel_tbl[] =3D {
+static struct mdio_device_id __maybe_unused micrel_tbl[] =3D {
 	{ PHY_ID_KSZ9021, 0x000fff10 },
 	{ PHY_ID_KS8001, 0x00fffff0 },
 	{ PHY_ID_KS8737, 0x00fffff0 },
diff --git a/drivers/net/phy/national.c b/drivers/net/phy/national.c
index a73ba0b..0620ba9 100644
--- a/drivers/net/phy/national.c
+++ b/drivers/net/phy/national.c
@@ -151,7 +151,7 @@ MODULE_LICENSE("GPL");
 module_init(ns_init);
 module_exit(ns_exit);
=20
-static struct mdio_device_id ns_tbl[] =3D {
+static struct mdio_device_id __maybe_unused ns_tbl[] =3D {
 	{ DP83865_PHY_ID, 0xfffffff0 },
 	{ }
 };
diff --git a/drivers/net/phy/qsemi.c b/drivers/net/phy/qsemi.c
index 6736b23..fe0d0a1 100644
--- a/drivers/net/phy/qsemi.c
+++ b/drivers/net/phy/qsemi.c
@@ -138,7 +138,7 @@ static void __exit qs6612_exit(void)
 module_init(qs6612_init);
 module_exit(qs6612_exit);
=20
-static struct mdio_device_id qs6612_tbl[] =3D {
+static struct mdio_device_id __maybe_unused qs6612_tbl[] =3D {
 	{ 0x00181440, 0xfffffff0 },
 	{ }
 };
diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index f567c0e..a4eae75 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -79,7 +79,7 @@ static void __exit realtek_exit(void)
 module_init(realtek_init);
 module_exit(realtek_exit);
=20
-static struct mdio_device_id realtek_tbl[] =3D {
+static struct mdio_device_id __maybe_unused realtek_tbl[] =3D {
 	{ 0x001cc912, 0x001fffff },
 	{ }
 };
diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 78fa988..342505c 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -254,7 +254,7 @@ MODULE_LICENSE("GPL");
 module_init(smsc_init);
 module_exit(smsc_exit);
=20
-static struct mdio_device_id smsc_tbl[] =3D {
+static struct mdio_device_id __maybe_unused smsc_tbl[] =3D {
 	{ 0x0007c0a0, 0xfffffff0 },
 	{ 0x0007c0b0, 0xfffffff0 },
 	{ 0x0007c0c0, 0xfffffff0 },
diff --git a/drivers/net/phy/ste10Xp.c b/drivers/net/phy/ste10Xp.c
index 7229009..187a2fa 100644
--- a/drivers/net/phy/ste10Xp.c
+++ b/drivers/net/phy/ste10Xp.c
@@ -132,7 +132,7 @@ static void __exit ste10Xp_exit(void)
 module_init(ste10Xp_init);
 module_exit(ste10Xp_exit);
=20
-static struct mdio_device_id ste10Xp_tbl[] =3D {
+static struct mdio_device_id __maybe_unused ste10Xp_tbl[] =3D {
 	{ STE101P_PHY_ID, 0xfffffff0 },
 	{ STE100P_PHY_ID, 0xffffffff },
 	{ }
diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 45cce50..5d8f6e1 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -192,7 +192,7 @@ static void __exit vsc82xx_exit(void)
 module_init(vsc82xx_init);
 module_exit(vsc82xx_exit);
=20
-static struct mdio_device_id vitesse_tbl[] =3D {
+static struct mdio_device_id __maybe_unused vitesse_tbl[] =3D {
 	{ PHY_ID_VSC8244, 0x000fffc0 },
 	{ PHY_ID_VSC8221, 0x000ffff0 },
 	{ }
--=20
1.7.2.3

