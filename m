From: Jeongtae Park <jtp.park@samsung.com>
Subject: [PATCH] smsc911x: Fix build error when SMSC_TRACE() used
Date: Tue, 15 Mar 2011 14:16:20 +0900
Message-ID: <1300166180-19103-1-git-send-email-jtp.park@samsung.com>
Cc: Jeongtae Park <jtp.park@samsung.com>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Denis Kirjanov <kirjanov@gmail.com>
To: Jeongtae Park <jtp.park@samsung.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:42862 "EHLO
	ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751Ab1COFpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 01:45:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes build error when SMSC_TRACE() used.

Signed-off-by: Jeongtae Park <jtp.park@samsung.com>
Cc: Steve Glendinning <steve.glendinning@smsc.com>
Cc: Denis Kirjanov <kirjanov@gmail.com>
---
 drivers/net/smsc911x.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 64bfdae..abf4482 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -791,8 +791,8 @@ static int smsc911x_mii_probe(struct net_device *dev)
 		return -ENODEV;
 	}
 
-	SMSC_TRACE(PROBE, "PHY %d: addr %d, phy_id 0x%08X",
-			phy_addr, phydev->addr, phydev->phy_id);
+	SMSC_TRACE(PROBE, "PHY: addr %d, phy_id 0x%08X",
+			phydev->addr, phydev->phy_id);
 
 	ret = phy_connect_direct(dev, phydev,
 			&smsc911x_phy_adjust_link, 0,
-- 
1.7.1

