From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 1/3] net: dsa: mv88e6xxx: remove unused phy_mutex
Date: Wed, 20 Jul 2016 18:18:34 -0400
Message-ID: <20160720221836.28218-2-vivien.didelot@savoirfairelinux.com>
References: <20160720221836.28218-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160720221836.28218-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Only reg_lock is necessary now and phy_mutex is dead. Remove it.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 899ca1d..99de41f 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -629,12 +629,6 @@ struct mv88e6xxx_chip {
 	 */
 	struct mutex	stats_mutex;
 
-	/* This mutex serializes phy access for chips with
-	 * indirect phy addressing. It is unused for chips
-	 * with direct phy access.
-	 */
-	struct mutex	phy_mutex;
-
 	/* This mutex serializes eeprom access for chips with
 	 * eeprom support.
 	 */
-- 
2.9.0
