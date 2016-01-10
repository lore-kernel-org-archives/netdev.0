From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH -next v2 2/2] net: tc35815: Drop unused variable
Date: Sun, 10 Jan 2016 07:10:45 -0800
Message-ID: <1452438645-29440-2-git-send-email-linux@roeck-us.net>
References: <1452438645-29440-1-git-send-email-linux@roeck-us.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452438645-29440-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit e7f4dc3536a4 ("mdio: Move allocation of interrupts into core")
removes some code from tc_mii_init(), but does not remove a now unused
variable. This results in the following build warning.

drivers/net/ethernet/toshiba/tc35815.c: In function 'tc_mii_init':
drivers/net/ethernet/toshiba/tc35815.c:670:6: warning: unused variable 'i'

Fixes: e7f4dc3536a4 ("mdio: Move allocation of interrupts into core")
Cc: Andrew Lunn <andrew@lunn.ch>
Acked-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
v2: Added Acked-by:

 drivers/net/ethernet/toshiba/tc35815.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 71efe0092bec..54874783476a 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -654,7 +654,6 @@ static int tc_mii_init(struct net_device *dev)
 {
 	struct tc35815_local *lp = netdev_priv(dev);
 	int err;
-	int i;
 
 	lp->mii_bus = mdiobus_alloc();
 	if (lp->mii_bus == NULL) {
-- 
2.1.4
