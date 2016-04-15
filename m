From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 6/7] net: dsa: mv88e6xxx: add number of database to info
Date: Fri, 15 Apr 2016 14:25:49 -0400
Message-ID: <1460744750-13896-7-git-send-email-vivien.didelot@savoirfairelinux.com>
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

Move the number of databases to the info structure.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c |  6 +++---
 drivers/net/dsa/mv88e6131.c |  8 ++++----
 drivers/net/dsa/mv88e6171.c |  8 ++++----
 drivers/net/dsa/mv88e6352.c | 12 ++++++------
 drivers/net/dsa/mv88e6xxx.c | 19 +------------------
 drivers/net/dsa/mv88e6xxx.h |  4 +++-
 6 files changed, 21 insertions(+), 36 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 2048719..9731e56 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -18,9 +18,9 @@
 #include "mv88e6xxx.h"
 
 static const struct mv88e6xxx_info mv88e6123_table[] = {
-	{ MV88E6XXX_INFO(6165, 0x121, 3, "Marvell 88E6123") },
-	{ MV88E6XXX_INFO(6165, 0x161, 6, "Marvell 88E6161") },
-	{ MV88E6XXX_INFO(6165, 0x165, 6, "Marvell 88E6165") },
+	{ MV88E6XXX_INFO(6165, 0x121, 3, 4096, "Marvell 88E6123") },
+	{ MV88E6XXX_INFO(6165, 0x161, 6, 4096, "Marvell 88E6161") },
+	{ MV88E6XXX_INFO(6165, 0x165, 6, 4096, "Marvell 88E6165") },
 };
 
 static char *mv88e6123_drv_probe(struct device *dsa_dev,
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 2eb9fa3..c507ecb 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -18,10 +18,10 @@
 #include "mv88e6xxx.h"
 
 static const struct mv88e6xxx_info mv88e6131_table[] = {
-	{ MV88E6XXX_INFO(6095, 0x095, 11, "Marvell 88E6095/88E6095F") },
-	{ MV88E6XXX_INFO(6097, 0x04a, 10, "Marvell 88E6085") },
-	{ MV88E6XXX_INFO(6185, 0x106, 8,  "Marvell 88E6131") },
-	{ MV88E6XXX_INFO(6185, 0x1a7, 10, "Marvell 88E6185") },
+	{ MV88E6XXX_INFO(6095, 0x095, 11, 256,  "Marvell 88E6095/88E6095F") },
+	{ MV88E6XXX_INFO(6097, 0x04a, 10, 4096, "Marvell 88E6085") },
+	{ MV88E6XXX_INFO(6185, 0x106, 8,  256,  "Marvell 88E6131") },
+	{ MV88E6XXX_INFO(6185, 0x1a7, 10, 256,  "Marvell 88E6185") },
 };
 
 static char *mv88e6131_drv_probe(struct device *dsa_dev,
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index d5f33d7..bce8f40 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -18,10 +18,10 @@
 #include "mv88e6xxx.h"
 
 static const struct mv88e6xxx_info mv88e6171_table[] = {
-	{ MV88E6XXX_INFO(6351, 0x171, 7, "Marvell 88E6171") },
-	{ MV88E6XXX_INFO(6351, 0x175, 7, "Marvell 88E6175") },
-	{ MV88E6XXX_INFO(6351, 0x371, 7, "Marvell 88E6350") },
-	{ MV88E6XXX_INFO(6351, 0x375, 7, "Marvell 88E6351") },
+	{ MV88E6XXX_INFO(6351, 0x171, 7, 4096, "Marvell 88E6171") },
+	{ MV88E6XXX_INFO(6351, 0x175, 7, 4096, "Marvell 88E6175") },
+	{ MV88E6XXX_INFO(6351, 0x371, 7, 4096, "Marvell 88E6350") },
+	{ MV88E6XXX_INFO(6351, 0x375, 7, 4096, "Marvell 88E6351") },
 };
 
 static char *mv88e6171_drv_probe(struct device *dsa_dev,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index e529c18..c26d674 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -23,12 +23,12 @@
 #include "mv88e6xxx.h"
 
 static const struct mv88e6xxx_info mv88e6352_table[] = {
-	{ MV88E6XXX_INFO(6320, 0x115, 7, "Marvell 88E6320") },
-	{ MV88E6XXX_INFO(6320, 0x310, 7, "Marvell 88E6321") },
-	{ MV88E6XXX_INFO(6352, 0x172, 7, "Marvell 88E6172") },
-	{ MV88E6XXX_INFO(6352, 0x176, 7, "Marvell 88E6176") },
-	{ MV88E6XXX_INFO(6352, 0x240, 7, "Marvell 88E6240") },
-	{ MV88E6XXX_INFO(6352, 0x352, 7, "Marvell 88E6352") },
+	{ MV88E6XXX_INFO(6320, 0x115, 7, 4096, "Marvell 88E6320") },
+	{ MV88E6XXX_INFO(6320, 0x310, 7, 4096, "Marvell 88E6321") },
+	{ MV88E6XXX_INFO(6352, 0x172, 7, 4096, "Marvell 88E6172") },
+	{ MV88E6XXX_INFO(6352, 0x176, 7, 4096, "Marvell 88E6176") },
+	{ MV88E6XXX_INFO(6352, 0x240, 7, 4096, "Marvell 88E6240") },
+	{ MV88E6XXX_INFO(6352, 0x352, 7, 4096, "Marvell 88E6352") },
 };
 
 static char *mv88e6352_drv_probe(struct device *dsa_dev,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index f3e8c68..d40ac4d 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -425,24 +425,7 @@ static unsigned int mv88e6xxx_num_databases(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
-	/* The following devices have 4-bit identifiers for 16 databases */
-	if (ps->id == PORT_SWITCH_ID_6061)
-		return 16;
-
-	/* The following devices have 6-bit identifiers for 64 databases */
-	if (ps->id == PORT_SWITCH_ID_6065)
-		return 64;
-
-	/* The following devices have 8-bit identifiers for 256 databases */
-	if (mv88e6xxx_6095_family(ds) || mv88e6xxx_6185_family(ds))
-		return 256;
-
-	/* The following devices have 12-bit identifiers for 4096 databases */
-	if (mv88e6xxx_6097_family(ds) || mv88e6xxx_6165_family(ds) ||
-	    mv88e6xxx_6351_family(ds) || mv88e6xxx_6352_family(ds))
-		return 4096;
-
-	return 0;
+	return ps->info->num_databases;
 }
 
 static bool mv88e6xxx_has_fid_reg(struct dsa_switch *ds)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 6b2d62e..7e86cc6 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -370,13 +370,15 @@ struct mv88e6xxx_info {
 	enum mv88e6xxx_family family;
 	u16 prod_num;
 	unsigned int num_ports;
+	unsigned int num_databases;
 	const char *name;
 };
 
-#define MV88E6XXX_INFO(_family, _prod_num, _num_ports, _name) \
+#define MV88E6XXX_INFO(_family, _prod_num, _num_ports, _num_db, _name) \
 	.family = MV88E6XXX_FAMILY_##_family, \
 	.prod_num = _prod_num, \
 	.num_ports = _num_ports, \
+	.num_databases = _num_db, \
 	.name = _name, \
 
 struct mv88e6xxx_atu_entry {
-- 
2.8.0
