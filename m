From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/7] net: dsa: mv88e6xxx: add family to info
Date: Fri, 15 Apr 2016 14:25:47 -0400
Message-ID: <1460744750-13896-5-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1460744750-13896-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460744750-13896-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add an mv88e6xxx_family enum to the info structure for better family
indentification.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c |  6 ++--
 drivers/net/dsa/mv88e6131.c |  8 ++---
 drivers/net/dsa/mv88e6171.c |  8 ++---
 drivers/net/dsa/mv88e6352.c | 12 ++++----
 drivers/net/dsa/mv88e6xxx.c | 71 +++++----------------------------------------
 drivers/net/dsa/mv88e6xxx.h | 16 +++++++++-
 6 files changed, 40 insertions(+), 81 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 02bf16c..36a0340 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -18,9 +18,9 @@
 #include "mv88e6xxx.h"
 
 static const struct mv88e6xxx_info mv88e6123_table[] = {
-	{ MV88E6XXX_INFO(0x121, "Marvell 88E6123") },
-	{ MV88E6XXX_INFO(0x161, "Marvell 88E6161") },
-	{ MV88E6XXX_INFO(0x165, "Marvell 88E6165") },
+	{ MV88E6XXX_INFO(6165, 0x121, "Marvell 88E6123") },
+	{ MV88E6XXX_INFO(6165, 0x161, "Marvell 88E6161") },
+	{ MV88E6XXX_INFO(6165, 0x165, "Marvell 88E6165") },
 };
 
 static char *mv88e6123_drv_probe(struct device *dsa_dev,
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 27dd102..f75d2dd 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -18,10 +18,10 @@
 #include "mv88e6xxx.h"
 
 static const struct mv88e6xxx_info mv88e6131_table[] = {
-	{ MV88E6XXX_INFO(0x095, "Marvell 88E6095/88E6095F") },
-	{ MV88E6XXX_INFO(0x04a, "Marvell 88E6085") },
-	{ MV88E6XXX_INFO(0x106, "Marvell 88E6131") },
-	{ MV88E6XXX_INFO(0x1a7, "Marvell 88E6185") },
+	{ MV88E6XXX_INFO(6095, 0x095, "Marvell 88E6095/88E6095F") },
+	{ MV88E6XXX_INFO(6097, 0x04a, "Marvell 88E6085") },
+	{ MV88E6XXX_INFO(6185, 0x106, "Marvell 88E6131") },
+	{ MV88E6XXX_INFO(6185, 0x1a7, "Marvell 88E6185") },
 };
 
 static char *mv88e6131_drv_probe(struct device *dsa_dev,
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 334e097..cb5bb19 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -18,10 +18,10 @@
 #include "mv88e6xxx.h"
 
 static const struct mv88e6xxx_info mv88e6171_table[] = {
-	{ MV88E6XXX_INFO(0x171, "Marvell 88E6171") },
-	{ MV88E6XXX_INFO(0x175, "Marvell 88E6175") },
-	{ MV88E6XXX_INFO(0x371, "Marvell 88E6350") },
-	{ MV88E6XXX_INFO(0x375, "Marvell 88E6351") },
+	{ MV88E6XXX_INFO(6351, 0x171, "Marvell 88E6171") },
+	{ MV88E6XXX_INFO(6351, 0x175, "Marvell 88E6175") },
+	{ MV88E6XXX_INFO(6351, 0x371, "Marvell 88E6350") },
+	{ MV88E6XXX_INFO(6351, 0x375, "Marvell 88E6351") },
 };
 
 static char *mv88e6171_drv_probe(struct device *dsa_dev,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 371edd7..94db0c3 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -23,12 +23,12 @@
 #include "mv88e6xxx.h"
 
 static const struct mv88e6xxx_info mv88e6352_table[] = {
-	{ MV88E6XXX_INFO(0x115, "Marvell 88E6320") },
-	{ MV88E6XXX_INFO(0x310, "Marvell 88E6321") },
-	{ MV88E6XXX_INFO(0x172, "Marvell 88E6172") },
-	{ MV88E6XXX_INFO(0x176, "Marvell 88E6176") },
-	{ MV88E6XXX_INFO(0x240, "Marvell 88E6240") },
-	{ MV88E6XXX_INFO(0x352, "Marvell 88E6352") },
+	{ MV88E6XXX_INFO(6320, 0x115, "Marvell 88E6320") },
+	{ MV88E6XXX_INFO(6320, 0x310, "Marvell 88E6321") },
+	{ MV88E6XXX_INFO(6352, 0x172, "Marvell 88E6172") },
+	{ MV88E6XXX_INFO(6352, 0x176, "Marvell 88E6176") },
+	{ MV88E6XXX_INFO(6352, 0x240, "Marvell 88E6240") },
+	{ MV88E6XXX_INFO(6352, 0x352, "Marvell 88E6352") },
 };
 
 static char *mv88e6352_drv_probe(struct device *dsa_dev,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 48fd1f4..05d59f9 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -369,111 +369,56 @@ static bool mv88e6xxx_6065_family(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
-	switch (ps->id) {
-	case PORT_SWITCH_ID_6031:
-	case PORT_SWITCH_ID_6061:
-	case PORT_SWITCH_ID_6035:
-	case PORT_SWITCH_ID_6065:
-		return true;
-	}
-	return false;
+	return ps->info->family == MV88E6XXX_FAMILY_6065;
 }
 
 static bool mv88e6xxx_6095_family(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
-	switch (ps->id) {
-	case PORT_SWITCH_ID_6092:
-	case PORT_SWITCH_ID_6095:
-		return true;
-	}
-	return false;
+	return ps->info->family == MV88E6XXX_FAMILY_6095;
 }
 
 static bool mv88e6xxx_6097_family(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
-	switch (ps->id) {
-	case PORT_SWITCH_ID_6046:
-	case PORT_SWITCH_ID_6085:
-	case PORT_SWITCH_ID_6096:
-	case PORT_SWITCH_ID_6097:
-		return true;
-	}
-	return false;
+	return ps->info->family == MV88E6XXX_FAMILY_6097;
 }
 
 static bool mv88e6xxx_6165_family(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
-	switch (ps->id) {
-	case PORT_SWITCH_ID_6123:
-	case PORT_SWITCH_ID_6161:
-	case PORT_SWITCH_ID_6165:
-		return true;
-	}
-	return false;
+	return ps->info->family == MV88E6XXX_FAMILY_6165;
 }
 
 static bool mv88e6xxx_6185_family(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
-	switch (ps->id) {
-	case PORT_SWITCH_ID_6121:
-	case PORT_SWITCH_ID_6122:
-	case PORT_SWITCH_ID_6152:
-	case PORT_SWITCH_ID_6155:
-	case PORT_SWITCH_ID_6182:
-	case PORT_SWITCH_ID_6185:
-	case PORT_SWITCH_ID_6108:
-	case PORT_SWITCH_ID_6131:
-		return true;
-	}
-	return false;
+	return ps->info->family == MV88E6XXX_FAMILY_6185;
 }
 
 static bool mv88e6xxx_6320_family(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
-	switch (ps->id) {
-	case PORT_SWITCH_ID_6320:
-	case PORT_SWITCH_ID_6321:
-		return true;
-	}
-	return false;
+	return ps->info->family == MV88E6XXX_FAMILY_6320;
 }
 
 static bool mv88e6xxx_6351_family(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
-	switch (ps->id) {
-	case PORT_SWITCH_ID_6171:
-	case PORT_SWITCH_ID_6175:
-	case PORT_SWITCH_ID_6350:
-	case PORT_SWITCH_ID_6351:
-		return true;
-	}
-	return false;
+	return ps->info->family == MV88E6XXX_FAMILY_6351;
 }
 
 static bool mv88e6xxx_6352_family(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
-	switch (ps->id) {
-	case PORT_SWITCH_ID_6172:
-	case PORT_SWITCH_ID_6176:
-	case PORT_SWITCH_ID_6240:
-	case PORT_SWITCH_ID_6352:
-		return true;
-	}
-	return false;
+	return ps->info->family == MV88E6XXX_FAMILY_6352;
 }
 
 static unsigned int mv88e6xxx_num_databases(struct dsa_switch *ds)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 5556098..3d2a186 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -352,14 +352,28 @@
 #define GLOBAL2_QOS_WEIGHT	0x1c
 #define GLOBAL2_MISC		0x1d
 
+enum mv88e6xxx_family {
+	MV88E6XXX_FAMILY_NONE,
+	MV88E6XXX_FAMILY_6065,	/* 6031 6035 6061 6065 */
+	MV88E6XXX_FAMILY_6095,	/* 6092 6095 */
+	MV88E6XXX_FAMILY_6097,	/* 6046 6085 6096 6097 */
+	MV88E6XXX_FAMILY_6165,	/* 6123 6161 6165 */
+	MV88E6XXX_FAMILY_6185,	/* 6108 6121 6122 6131 6152 6155 6182 6185 */
+	MV88E6XXX_FAMILY_6320,	/* 6320 6321 */
+	MV88E6XXX_FAMILY_6351,	/* 6171 6175 6350 6351 */
+	MV88E6XXX_FAMILY_6352,	/* 6172 6176 6240 6352 */
+};
+
 #define MV88E6XXX_N_FID		4096
 
 struct mv88e6xxx_info {
+	enum mv88e6xxx_family family;
 	u16 prod_num;
 	const char *name;
 };
 
-#define MV88E6XXX_INFO(_prod_num, _name) \
+#define MV88E6XXX_INFO(_family, _prod_num, _name) \
+	.family = MV88E6XXX_FAMILY_##_family, \
 	.prod_num = _prod_num, \
 	.name = _name, \
 
-- 
2.8.0
