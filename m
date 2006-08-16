From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 1/2] Fix style to match drivers/net/phy/*
Date: Wed, 16 Aug 2006 16:48:17 +0100
Message-ID: <1155743298275-git-send-email-steve.glendinning@smsc.com>
Reply-To: Steve Glendinning <steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	Bahadir Balban <Bahadir.Balban@arm.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.8.5] ([86.54.8.5]:57224 "EHLO drevil.shawell.net")
	by vger.kernel.org with ESMTP id S932080AbWHPPsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 11:48:41 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Trivial style fixes to match other PHY drivers

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/phy/smsc.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 25e31fb..2119bd7 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -41,24 +41,23 @@ #define MII_LAN83C185_ISF_INT_PHYLIB_EVE
 
 static int lan83c185_config_intr(struct phy_device *phydev)
 {
-	int rc = phy_write (phydev, MII_LAN83C185_IM,
-			((PHY_INTERRUPT_ENABLED == phydev->interrupts)
-			? MII_LAN83C185_ISF_INT_PHYLIB_EVENTS
-			: 0));
+	int rc = phy_write(phydev, MII_LAN83C185_IM,
+			   ((PHY_INTERRUPT_ENABLED == phydev->interrupts)
+			    ? MII_LAN83C185_ISF_INT_PHYLIB_EVENTS : 0));
 
 	return rc < 0 ? rc : 0;
 }
 
 static int lan83c185_ack_interrupt(struct phy_device *phydev)
 {
-	int rc = phy_read (phydev, MII_LAN83C185_ISF);
+	int rc = phy_read(phydev, MII_LAN83C185_ISF);
 
 	return rc < 0 ? rc : 0;
 }
 
 static int lan83c185_config_init(struct phy_device *phydev)
 {
-	return lan83c185_ack_interrupt (phydev);
+	return lan83c185_ack_interrupt(phydev);
 }
 
 
@@ -85,12 +84,12 @@ static struct phy_driver lan83c185_drive
 
 static int __init smsc_init(void)
 {
-	return phy_driver_register (&lan83c185_driver);
+	return phy_driver_register(&lan83c185_driver);
 }
 
 static void __exit smsc_exit(void)
 {
-	phy_driver_unregister (&lan83c185_driver);
+	phy_driver_unregister(&lan83c185_driver);
 }
 
 MODULE_DESCRIPTION("SMSC PHY driver");
-- 
1.4.1

