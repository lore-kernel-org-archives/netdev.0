From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: b53: use module_mdio_driver
Date: Wed, 20 Jul 2016 18:26:01 -0400
Message-ID: <20160720222601.30701-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:52384 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932173AbcGTW0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 18:26:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce boilerplate for module declaration with module_mdio_driver.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/b53/b53_mdio.c | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_mdio.c b/drivers/net/dsa/b53/b53_mdio.c
index aa87c3f..87265c8 100644
--- a/drivers/net/dsa/b53/b53_mdio.c
+++ b/drivers/net/dsa/b53/b53_mdio.c
@@ -376,17 +376,7 @@ static struct mdio_driver b53_mdio_driver = {
 	},
 };
 
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
2.9.0
