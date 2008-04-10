From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.26] phy: Clean up header style
Date: Wed,  9 Apr 2008 19:38:27 -0500
Message-ID: <1207787907-9222-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:52182 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752465AbYDJAia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2008 20:38:30 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m3A0cS5Y009443
	for <netdev@vger.kernel.org>; Wed, 9 Apr 2008 17:38:28 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id m3A0cS1t013059
	for <netdev@vger.kernel.org>; Wed, 9 Apr 2008 19:38:28 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Multi-line comments weren't all CodingStyle compliant

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 include/linux/phy.h |   48 ++++++++++++++++++++++++++++++++----------------
 1 files changed, 32 insertions(+), 16 deletions(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 6509f37..2d83844 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -39,7 +39,8 @@
 				 SUPPORTED_1000baseT_Half | \
 				 SUPPORTED_1000baseT_Full)
 
-/* Set phydev->irq to PHY_POLL if interrupts are not supported,
+/*
+ * Set phydev->irq to PHY_POLL if interrupts are not supported,
  * or not desired for this PHY.  Set to PHY_IGNORE_INTERRUPT if
  * the attached driver handles the interrupt
  */
@@ -80,8 +81,10 @@ typedef enum {
  */
 #define MII_BUS_ID_SIZE	(BUS_ID_SIZE - 3)
 
-/* The Bus class for PHYs.  Devices which provide access to
- * PHYs should register using this structure */
+/*
+ * The Bus class for PHYs.  Devices which provide access to
+ * PHYs should register using this structure
+ */
 struct mii_bus {
 	const char *name;
 	char id[MII_BUS_ID_SIZE];
@@ -90,8 +93,10 @@ struct mii_bus {
 	int (*write)(struct mii_bus *bus, int phy_id, int regnum, u16 val);
 	int (*reset)(struct mii_bus *bus);
 
-	/* A lock to ensure that only one thing can read/write
-	 * the MDIO bus at a time */
+	/*
+	 * A lock to ensure that only one thing can read/write
+	 * the MDIO bus at a time
+	 */
 	struct mutex mdio_lock;
 
 	struct device *dev;
@@ -102,8 +107,10 @@ struct mii_bus {
 	/* Phy addresses to be ignored when probing */
 	u32 phy_mask;
 
-	/* Pointer to an array of interrupts, each PHY's
-	 * interrupt at the index matching its address */
+	/*
+	 * Pointer to an array of interrupts, each PHY's
+	 * interrupt at the index matching its address
+	 */
 	int *irq;
 };
 
@@ -255,7 +262,8 @@ struct phy_device {
 	/* Bus address of the PHY (0-32) */
 	int addr;
 
-	/* forced speed & duplex (no autoneg)
+	/*
+	 * forced speed & duplex (no autoneg)
 	 * partner speed & duplex & pause (autoneg)
 	 */
 	int speed;
@@ -278,8 +286,10 @@ struct phy_device {
 
 	int link_timeout;
 
-	/* Interrupt number for this PHY
-	 * -1 means no interrupt */
+	/*
+	 * Interrupt number for this PHY
+	 * -1 means no interrupt
+	 */
 	int irq;
 
 	/* private data pointer */
@@ -329,22 +339,28 @@ struct phy_driver {
 	u32 features;
 	u32 flags;
 
-	/* Called to initialize the PHY,
-	 * including after a reset */
+	/*
+	 * Called to initialize the PHY,
+	 * including after a reset
+	 */
 	int (*config_init)(struct phy_device *phydev);
 
-	/* Called during discovery.  Used to set
-	 * up device-specific structures, if any */
+	/*
+	 * Called during discovery.  Used to set
+	 * up device-specific structures, if any
+	 */
 	int (*probe)(struct phy_device *phydev);
 
 	/* PHY Power Management */
 	int (*suspend)(struct phy_device *phydev);
 	int (*resume)(struct phy_device *phydev);
 
-	/* Configures the advertisement and resets
+	/*
+	 * Configures the advertisement and resets
 	 * autonegotiation if phydev->autoneg is on,
 	 * forces the speed to the current settings in phydev
-	 * if phydev->autoneg is off */
+	 * if phydev->autoneg is off
+	 */
 	int (*config_aneg)(struct phy_device *phydev);
 
 	/* Determines the negotiated speed and duplex */
-- 
1.5.4.GIT

