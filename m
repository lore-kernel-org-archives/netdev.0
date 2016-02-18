From: "Andrew F. Davis" <afd@ti.com>
Subject: [PATCH] net: phy: dp83848: Fix sysfs naming collision warning
Date: Wed, 17 Feb 2016 18:10:00 -0600
Message-ID: <1455754200-4593-1-git-send-email-afd@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"Andrew F. Davis" <afd@ti.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:48268 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965331AbcBRAKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 19:10:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Files in sysfs are created using the name from the phy_driver struct,
when two names are the same we may get a duplicate filename warning,
fix this.

Reported-by: kernel test robot <ying.huang@linux.intel.com>
Signed-off-by: Andrew F. Davis <afd@ti.com>
---
 drivers/net/phy/dp83848.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/dp83848.c b/drivers/net/phy/dp83848.c
index 556904f..03d54c4 100644
--- a/drivers/net/phy/dp83848.c
+++ b/drivers/net/phy/dp83848.c
@@ -103,7 +103,7 @@ MODULE_DEVICE_TABLE(mdio, dp83848_tbl);
 
 static struct phy_driver dp83848_driver[] = {
 	DP83848_PHY_DRIVER(TI_DP83848C_PHY_ID, "TI DP83848C 10/100 Mbps PHY"),
-	DP83848_PHY_DRIVER(NS_DP83848C_PHY_ID, "TI DP83848C 10/100 Mbps PHY"),
+	DP83848_PHY_DRIVER(NS_DP83848C_PHY_ID, "NS DP83848C 10/100 Mbps PHY"),
 	DP83848_PHY_DRIVER(TLK10X_PHY_ID, "TI TLK10X 10/100 Mbps PHY"),
 };
 module_phy_driver(dp83848_driver);
-- 
2.7.1
