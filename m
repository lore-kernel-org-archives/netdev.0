From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH 3/3] net: dsa: mv88e6060: use module_switch_driver
Date: Fri,  1 May 2015 18:09:15 -0400
Message-ID: <1430518155-29565-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1430518155-29565-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>, kernel@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:63551 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbbEAWJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 18:09:26 -0400
In-Reply-To: <1430518155-29565-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the module_switch_driver helper macro to declare the driver and thus
reduce boilerplate.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6060.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index c29aebe..c58d5c9 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -283,18 +283,7 @@ static struct dsa_switch_driver mv88e6060_switch_driver = {
 	.poll_link	= mv88e6060_poll_link,
 };
 
-static int __init mv88e6060_init(void)
-{
-	register_switch_driver(&mv88e6060_switch_driver);
-	return 0;
-}
-module_init(mv88e6060_init);
-
-static void __exit mv88e6060_cleanup(void)
-{
-	unregister_switch_driver(&mv88e6060_switch_driver);
-}
-module_exit(mv88e6060_cleanup);
+module_switch_driver(mv88e6060_switch_driver);
 
 MODULE_AUTHOR("Lennert Buytenhek <buytenh@wantstofly.org>");
 MODULE_DESCRIPTION("Driver for Marvell 88E6060 ethernet switch chip");
-- 
2.3.7
