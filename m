From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH] net: dsa: mv88e6xxx: unregister mv88e6352 driver
Date: Fri,  1 May 2015 10:43:52 -0400
Message-ID: <1430491432-7566-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the missing unregister for the mv88e6352_switch_driver.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 51130fc..7339885 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1788,6 +1788,9 @@ static void __exit mv88e6xxx_cleanup(void)
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6171)
 	unregister_switch_driver(&mv88e6171_switch_driver);
 #endif
+#if IS_ENABLED(CONFIG_NET_DSA_MV88E6352)
+	unregister_switch_driver(&mv88e6352_switch_driver);
+#endif
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6123_61_65)
 	unregister_switch_driver(&mv88e6123_61_65_switch_driver);
 #endif
-- 
2.3.7
