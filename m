From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: phy: Export mdiobus_register_board_info()
Date: Wed, 22 Mar 2017 22:40:30 -0700
Message-ID: <20170323054030.14613-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f194.google.com ([74.125.82.194]:34389 "EHLO
        mail-ot0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932484AbdCWHif (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 03:38:35 -0400
Received: by mail-ot0-f194.google.com with SMTP id y88so4937876ota.1
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 00:38:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can build modular code that uses mdiobus_register_board_info() which would
lead to linking failure since this symbol is not expoerted.

Fixes: 648ea0134069 ("net: phy: Allow pre-declaration of MDIO devices")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio-boardinfo.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/mdio-boardinfo.c b/drivers/net/phy/mdio-boardinfo.c
index 6b988f77da08..61941e29daae 100644
--- a/drivers/net/phy/mdio-boardinfo.c
+++ b/drivers/net/phy/mdio-boardinfo.c
@@ -84,3 +84,4 @@ int mdiobus_register_board_info(const struct mdio_board_info *info,
 
 	return 0;
 }
+EXPORT_SYMBOL(mdiobus_register_board_info);
-- 
2.9.3
