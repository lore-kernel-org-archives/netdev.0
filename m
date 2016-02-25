From: <Woojung.Huh@microchip.com>
Subject: [PATCH net-next 2/4] lan78xx: remove unnecessary code
Date: Thu, 25 Feb 2016 23:33:09 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D404B83DA@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:16988 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752568AbcBYXdL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 18:33:11 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not required after commit cd772de358d6
("phy: keep pause flags in phy driver features")

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 4ec25e8..d100421 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -1623,12 +1623,7 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
 
 	/* MAC doesn't support 1000T Half */
 	phydev->supported &= ~SUPPORTED_1000baseT_Half;
-	phydev->supported |= (SUPPORTED_10baseT_Half |
-			      SUPPORTED_10baseT_Full |
-			      SUPPORTED_100baseT_Half |
-			      SUPPORTED_100baseT_Full |
-			      SUPPORTED_1000baseT_Full |
-			      SUPPORTED_Pause | SUPPORTED_Asym_Pause);
+
 	genphy_config_aneg(phydev);
 
 	phy_start(phydev);
-- 
2.7.0
