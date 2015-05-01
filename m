From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH 2/3] net: dsa: sf2: use module_switch_driver
Date: Fri,  1 May 2015 18:09:14 -0400
Message-ID: <1430518155-29565-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1430518155-29565-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>, kernel@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:64102 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbbEAWJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 18:09:23 -0400
In-Reply-To: <1430518155-29565-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the module_switch_driver helper macro to declare the driver and thus
reduce boilerplate.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/bcm_sf2.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index cedb572..2b438fb 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -1071,19 +1071,7 @@ static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.port_stp_update	= bcm_sf2_sw_br_set_stp_state,
 };
 
-static int __init bcm_sf2_init(void)
-{
-	register_switch_driver(&bcm_sf2_switch_driver);
-
-	return 0;
-}
-module_init(bcm_sf2_init);
-
-static void __exit bcm_sf2_exit(void)
-{
-	unregister_switch_driver(&bcm_sf2_switch_driver);
-}
-module_exit(bcm_sf2_exit);
+module_switch_driver(bcm_sf2_switch_driver);
 
 MODULE_AUTHOR("Broadcom Corporation");
 MODULE_DESCRIPTION("Driver for Broadcom Starfighter 2 ethernet switch chip");
-- 
2.3.7
