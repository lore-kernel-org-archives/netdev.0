From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: dsa: b53: Utilize mdio_module_driver
Date: Sun, 22 Jan 2017 21:17:33 -0800
Message-ID: <20170123051733.10316-3-f.fainelli@gmail.com>
References: <20170123051733.10316-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33386 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750728AbdAWFRu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 00:17:50 -0500
Received: by mail-pg0-f66.google.com with SMTP id 194so12744450pgd.0
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 21:17:45 -0800 (PST)
In-Reply-To: <20170123051733.10316-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eliminate a bit of boilerplate code.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_mdio.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_mdio.c b/drivers/net/dsa/b53/b53_mdio.c
index 477a16b5660a..fa7556f5d4fb 100644
--- a/drivers/net/dsa/b53/b53_mdio.c
+++ b/drivers/net/dsa/b53/b53_mdio.c
@@ -375,18 +375,7 @@ static struct mdio_driver b53_mdio_driver = {
 		.of_match_table = b53_of_match,
 	},
 };
-
-static int __init b53_mdio_driver_register(void)
-{
-	return mdio_driver_register(&b53_mdio_driver);
-}
-module_init(b53_mdio_driver_register);
-
-static void __exit b53_mdio_driver_unregister(void)
-{
-	mdio_driver_unregister(&b53_mdio_driver);
-}
-module_exit(b53_mdio_driver_unregister);
+mdio_module_driver(b53_mdio_driver);
 
 MODULE_DESCRIPTION("B53 MDIO access driver");
 MODULE_LICENSE("Dual BSD/GPL");
-- 
2.9.3
