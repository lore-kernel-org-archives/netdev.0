From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v4 5/5] net: dsa: mv88e6xxx: Select IRQ_DOMAIN
Date: Thu, 17 Nov 2016 11:19:14 -0800
Message-ID: <20161117191914.11077-6-f.fainelli@gmail.com>
References: <20161117191914.11077-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, mw@semihalf.com, arnd@arndb.de,
        gregory.clement@free-electrons.com, Shaohui.Xie@freescale.com,
        andrew@lunn.ch, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32932 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932979AbcKQTUv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 14:20:51 -0500
Received: by mail-pf0-f196.google.com with SMTP id 144so12064866pfv.0
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 11:20:51 -0800 (PST)
In-Reply-To: <20161117191914.11077-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some architectures may not define IRQ_DOMAIN (like m32r), fixes
undefined references to IRQ_DOMAIN functions.

Fixes: dc30c35be720 ("net: dsa: mv88e6xxx: Implement interrupt support.")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/mv88e6xxx/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/dsa/mv88e6xxx/Kconfig b/drivers/net/dsa/mv88e6xxx/Kconfig
index 486668813e15..1aaa7a95ebc4 100644
--- a/drivers/net/dsa/mv88e6xxx/Kconfig
+++ b/drivers/net/dsa/mv88e6xxx/Kconfig
@@ -1,6 +1,7 @@
 config NET_DSA_MV88E6XXX
 	tristate "Marvell 88E6xxx Ethernet switch fabric support"
 	depends on NET_DSA
+	select IRQ_DOMAIN
 	select NET_DSA_TAG_EDSA
 	select NET_DSA_TAG_DSA
 	help
-- 
2.9.3
