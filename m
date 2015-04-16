From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] dsa: mv88e6xxx: Drop duplicate declaration of 'ret' variable
Date: Thu, 16 Apr 2015 06:49:50 -0700
Message-ID: <1429192190-31229-1-git-send-email-linux@roeck-us.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A duplicate declaration of 'ret' can result in hiding an error code.
Drop it.

Fixes: 17ee3e04ddbf ("net: dsa: Provide additional RMON statistics")
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
Found by compiling the file with W=2.

 drivers/net/dsa/mv88e6xxx.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index f64186a5f634..12f186cb30cc 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -602,8 +602,6 @@ static void _mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
 		u32 high = 0;
 
 		if (s->reg >= 0x100) {
-			int ret;
-
 			ret = mv88e6xxx_reg_read(ds, REG_PORT(port),
 						 s->reg - 0x100);
 			if (ret < 0)
-- 
2.1.0
