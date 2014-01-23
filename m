From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 4/4] net: phy: remove unneeded parenthesis
Date: Thu, 23 Jan 2014 12:17:49 -0800
Message-ID: <1390508269-28769-5-git-send-email-f.fainelli@gmail.com>
References: <1390508269-28769-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <joe@perches.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:55167 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753040AbaAWUSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 15:18:10 -0500
In-Reply-To: <1390508269-28769-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Our if/else statement in phy_print_status() is only comprised of one
line for each, remove the parenthesis.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 36fc6e1..59aa85e 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -64,15 +64,14 @@ static const char *phy_speed_to_str(int speed)
  */
 void phy_print_status(struct phy_device *phydev)
 {
-	if (phydev->link) {
+	if (phydev->link)
 		netdev_info(phydev->attached_dev,
 			"Link is Up - %s/%s - flow control %s\n",
 			phy_speed_to_str(phydev->speed),
 			DUPLEX_FULL == phydev->duplex ? "Full" : "Half",
 			phydev->pause ? "rx/tx" : "off");
-	} else	{
+	else
 		netdev_info(phydev->attached_dev, "Link is Down\n");
-	}
 }
 EXPORT_SYMBOL(phy_print_status);
 
-- 
1.8.3.2
