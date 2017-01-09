From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH] net: phy: Add Meson GXL PHY hardware dependency
Date: Mon, 9 Jan 2017 15:17:27 +0100
Message-ID: <20170109151727.6571f566@endymion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Neil Armstrong <narmstrong@baylibre.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52112 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754447AbdAIORc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 09:17:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As I understand it the Meson GXL PHY driver is only useful on one
architecture so only make it visible on that architecture.

Signed-off-by: Jean Delvare <jdelvare@suse.de>
Fixes: 7334b3e47aee ("net: phy: Add Meson GXL Internal PHY driver")
Cc: Neil Armstrong <narmstrong@baylibre.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: Andrew Lunn <andrew@lunn.ch>
Cc: David S. Miller <davem@davemloft.net>
---
If I got it wrong, please let me know the proper dependencies and
I'll resubmit.

 drivers/net/phy/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- linux-4.10-rc2.orig/drivers/net/phy/Kconfig	2017-01-01 23:31:53.000000000 +0100
+++ linux-4.10-rc2/drivers/net/phy/Kconfig	2017-01-09 15:15:12.782142790 +0100
@@ -279,6 +279,7 @@ config MARVELL_PHY
 
 config MESON_GXL_PHY
 	tristate "Amlogic Meson GXL Internal PHY"
+	depends on ARCH_MESON || COMPILE_TEST
 	---help---
 	  Currently has a driver for the Amlogic Meson GXL Internal PHY
 


-- 
Jean Delvare
SUSE L3 Support
