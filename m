From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 04/10] net: dsa: mv88e6xxx: prefix Global 2 Device Mapping macros
Date: Mon, 19 Jun 2017 10:55:39 -0400
Message-ID: <20170619145545.26697-5-vivien.didelot@savoirfairelinux.com>
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

Prefix and document the Global 2 Device Mapping macros.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/global2.c |  2 +-
 drivers/net/dsa/mv88e6xxx/global2.h | 10 ++++++----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index d821b9591a8f..d5239c4f3a9b 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -73,7 +73,7 @@ static int mv88e6xxx_g2_device_mapping_write(struct mv88e6xxx_chip *chip,
 {
 	u16 val = (target << 8) | (port & 0xf);
 
-	return mv88e6xxx_g2_update(chip, GLOBAL2_DEVICE_MAPPING, val);
+	return mv88e6xxx_g2_update(chip, MV88E6XXX_G2_DEVICE_MAPPING, val);
 }
 
 static int mv88e6xxx_g2_set_device_mapping(struct mv88e6xxx_chip *chip)
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index c838c51cb2a1..dd9b243309a0 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -31,10 +31,12 @@
 #define GLOBAL2_SWITCH_MGMT_FLOW_CONTROL_MSG	BIT(13)
 #define GLOBAL2_SWITCH_MGMT_FORCE_FLOW_CTRL_PRI	BIT(7)
 #define GLOBAL2_SWITCH_MGMT_RSVD2CPU		BIT(3)
-#define GLOBAL2_DEVICE_MAPPING	0x06
-#define GLOBAL2_DEVICE_MAPPING_UPDATE		BIT(15)
-#define GLOBAL2_DEVICE_MAPPING_TARGET_SHIFT	8
-#define GLOBAL2_DEVICE_MAPPING_PORT_MASK	0x0f
+
+/* Offset 0x06: Device Mapping Table Register */
+#define MV88E6XXX_G2_DEVICE_MAPPING		0x06
+#define MV88E6XXX_G2_DEVICE_MAPPING_UPDATE	0x8000
+#define MV88E6XXX_G2_DEVICE_MAPPING_DEV_MASK	0x1f00
+#define MV88E6XXX_G2_DEVICE_MAPPING_PORT_MASK	0x000f
 
 /* Offset 0x07: Trunk Mask Table Register */
 #define MV88E6XXX_G2_TRUNK_MASK			0x07
-- 
2.13.1
