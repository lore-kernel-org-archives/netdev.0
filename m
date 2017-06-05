From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH] net: phy: fix kernel-doc warnings
Date: Sun, 4 Jun 2017 19:46:53 -0700
Message-ID: <3d006e19-8c96-a752-fbcb-bf8fc7ccb386@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:41815 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751212AbdFECq6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 22:46:58 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix kernel-doc warnings (typo) in drivers/net/phy/phy.c:

..//drivers/net/phy/phy.c:259: warning: No description found for parameter 'features'
..//drivers/net/phy/phy.c:259: warning: Excess function parameter 'feature' description in 'phy_lookup_setting'

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 drivers/net/phy/phy.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- lnx-412-rc4.orig/drivers/net/phy/phy.c
+++ lnx-412-rc4/drivers/net/phy/phy.c
@@ -241,7 +241,7 @@ static const struct phy_setting settings
  * phy_lookup_setting - lookup a PHY setting
  * @speed: speed to match
  * @duplex: duplex to match
- * @feature: allowed link modes
+ * @features: allowed link modes
  * @exact: an exact match is required
  *
  * Search the settings array for a setting that matches the speed and
