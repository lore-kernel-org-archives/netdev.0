From: <Shruti@Freescale.com>
Subject: [PATCH] net/phy: Remove return value for a void function
Date: Tue, 1 Apr 2014 09:44:24 -0500
Message-ID: <1396363464-28923-1-git-send-email-Shruti@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <emmedve1@Freescale.com>,
	Shruti Kanetkar <Shruti@Freescale.com>
To: <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:9112 "EHLO
	va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750786AbaDAOoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 10:44:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shruti Kanetkar <Shruti@Freescale.com>

Signed-off-by: Shruti Kanetkar <Shruti@Freescale.com>
---
 drivers/net/phy/vitesse.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 14372c6..1f2f060 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -319,8 +319,8 @@ static int __init vsc82xx_init(void)
 
 static void __exit vsc82xx_exit(void)
 {
-	return phy_drivers_unregister(vsc82xx_driver,
-		ARRAY_SIZE(vsc82xx_driver));
+	phy_drivers_unregister(vsc82xx_driver,
+			       ARRAY_SIZE(vsc82xx_driver));
 }
 
 module_init(vsc82xx_init);
-- 
1.8.3.1
