From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: phy: Fix typo for MDIO module boilerplate comment
Date: Sun, 22 Jan 2017 21:17:32 -0800
Message-ID: <20170123051733.10316-2-f.fainelli@gmail.com>
References: <20170123051733.10316-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36802 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750728AbdAWFRn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 00:17:43 -0500
Received: by mail-pg0-f68.google.com with SMTP id 75so12716150pgf.3
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 21:17:43 -0800 (PST)
In-Reply-To: <20170123051733.10316-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The module boilerplate macro is named mdio_module_driver and not
module_mdio_driver, fix that.

Fixes: a9049e0c513c ("mdio: Add support for mdio drivers.")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/mdio.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index b6587a4b32e7..55a80d73cfc1 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -265,7 +265,7 @@ bool mdiobus_is_registered_device(struct mii_bus *bus, int addr);
 struct phy_device *mdiobus_get_phy(struct mii_bus *bus, int addr);
 
 /**
- * module_mdio_driver() - Helper macro for registering mdio drivers
+ * mdio_module_driver() - Helper macro for registering mdio drivers
  *
  * Helper macro for MDIO drivers which do not do anything special in module
  * init/exit. Each module may only use this macro once, and calling it
-- 
2.9.3
