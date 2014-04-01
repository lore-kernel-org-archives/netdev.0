From: <Shruti@Freescale.com>
Subject: [PATCH] net/phy: Remove return value for a void function
Date: Tue, 1 Apr 2014 09:22:54 -0500
Message-ID: <1396362174-28775-1-git-send-email-Shruti@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <emmedve1@Freescale.com>,
	Shruti Kanetkar <Shruti@Freescale.com>
To: <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe003.messaging.microsoft.com ([216.32.180.13]:22538
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751452AbaDAOXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 10:23:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shruti Kanetkar <Shruti@Freescale.com>

Change-Id: I03747d79beb1ef3a9e7fc8a11495196eabbed33f
Signed-off-by: Shruti Kanetkar <Shruti@Freescale.com>
Reviewed-on: http://git.am.freescale.net:8181/8914
Tested-by: Review Code-CDREVIEW <CDREVIEW@freescale.com>
Reviewed-by: Shruti Kanetkar <Shruti@freescale.com>
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
