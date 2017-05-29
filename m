From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: dsa: mv88e6xxx: Add missing static to stub functions
Date: Mon, 29 May 2017 14:56:01 +0200
Message-ID: <20170529125612.110244-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

'static' was not enough, the helpers must be 'static inline'

net/dsa/mv88e6xxx/global2.h:123:12: error: 'mv88e6xxx_g2_misc_4_bit_port' defined but not used [-Werror=unused-function]
net/dsa/mv88e6xxx/global2.h:117:12: error: 'mv88e6xxx_g2_pvt_write' defined but not used [-Werror=unused-function]

Fixes: c21fbe29f858 ("net: dsa: mv88e6xxx: Add missing static to stub functions")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/dsa/mv88e6xxx/global2.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index d8d3c5abb2a1..14c0be98e0a4 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -114,13 +114,13 @@ static inline int mv88e6xxx_g2_set_eeprom16(struct mv88e6xxx_chip *chip,
 	return -EOPNOTSUPP;
 }
 
-static int mv88e6xxx_g2_pvt_write(struct mv88e6xxx_chip *chip, int src_dev,
-				  int src_port, u16 data)
+static inline int mv88e6xxx_g2_pvt_write(struct mv88e6xxx_chip *chip,
+					 int src_dev, int src_port, u16 data)
 {
 	return -EOPNOTSUPP;
 }
 
-static int mv88e6xxx_g2_misc_4_bit_port(struct mv88e6xxx_chip *chip)
+static inline int mv88e6xxx_g2_misc_4_bit_port(struct mv88e6xxx_chip *chip)
 {
 	return -EOPNOTSUPP;
 }
-- 
2.9.0
