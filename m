From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 08/10] net: dsa: mv88e6xxx: prefix Global 2 Switch MAC macros
Date: Mon, 19 Jun 2017 10:55:43 -0400
Message-ID: <20170619145545.26697-9-vivien.didelot@savoirfairelinux.com>
References: <20170619145545.26697-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170619145545.26697-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prefix and document the Global 2 Switch MAC registers macros.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/global2.c | 2 +-
 drivers/net/dsa/mv88e6xxx/global2.h | 7 ++++++-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 8621f5893406..0977ba1697a6 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -235,7 +235,7 @@ static int mv88e6xxx_g2_switch_mac_write(struct mv88e6xxx_chip *chip,
 {
 	u16 val = (pointer << 8) | data;
 
-	return mv88e6xxx_g2_update(chip, GLOBAL2_SWITCH_MAC, val);
+	return mv88e6xxx_g2_update(chip, MV88E6XXX_G2_SWITCH_MAC, val);
 }
 
 int mv88e6xxx_g2_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr)
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index a0a6cb3cb6fe..6b17343e481e 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -92,7 +92,12 @@
 #define MV88E6XXX_G2_PVT_DATA		0x0c
 #define MV88E6XXX_G2_PVT_DATA_MASK	0x7f
 
-#define GLOBAL2_SWITCH_MAC	0x0d
+/* Offset 0x0D: Switch MAC/WoL/WoF Register */
+#define MV88E6XXX_G2_SWITCH_MAC			0x0d
+#define MV88E6XXX_G2_SWITCH_MAC_UPDATE		0x8000
+#define MV88E6XXX_G2_SWITCH_MAC_PTR_MASK	0x1f00
+#define MV88E6XXX_G2_SWITCH_MAC_DATA_MASK	0x00ff
+
 #define GLOBAL2_ATU_STATS	0x0e
 #define GLOBAL2_PRIO_OVERRIDE	0x0f
 #define GLOBAL2_PRIO_OVERRIDE_FORCE_SNOOP	BIT(7)
-- 
2.13.1
