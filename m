From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 01/21] net: dsa: mv88e6xxx: add flags to info
Date: Fri,  6 May 2016 17:57:03 -0400
Message-ID: <1462571843-14397-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1462571843-14397-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462571843-14397-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a flags bitmap to the info structure in order to identify features
supported or not by the different switch models.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c |  3 +++
 drivers/net/dsa/mv88e6131.c |  4 ++++
 drivers/net/dsa/mv88e6171.c |  4 ++++
 drivers/net/dsa/mv88e6352.c |  6 ++++++
 drivers/net/dsa/mv88e6xxx.h | 21 +++++++++++++++++++++
 5 files changed, 38 insertions(+)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 5535a42..ab5885b 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -24,18 +24,21 @@ static const struct mv88e6xxx_info mv88e6123_table[] = {
 		.name = "Marvell 88E6123",
 		.num_databases = 4096,
 		.num_ports = 3,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6161,
 		.family = MV88E6XXX_FAMILY_6165,
 		.name = "Marvell 88E6161",
 		.num_databases = 4096,
 		.num_ports = 6,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6165,
 		.family = MV88E6XXX_FAMILY_6165,
 		.name = "Marvell 88E6165",
 		.num_databases = 4096,
 		.num_ports = 6,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 	}
 };
 
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 357ab79..d477320 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -24,24 +24,28 @@ static const struct mv88e6xxx_info mv88e6131_table[] = {
 		.name = "Marvell 88E6095/88E6095F",
 		.num_databases = 256,
 		.num_ports = 11,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6095,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6085,
 		.family = MV88E6XXX_FAMILY_6097,
 		.name = "Marvell 88E6085",
 		.num_databases = 4096,
 		.num_ports = 10,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6131,
 		.family = MV88E6XXX_FAMILY_6185,
 		.name = "Marvell 88E6131",
 		.num_databases = 256,
 		.num_ports = 8,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6185,
 		.family = MV88E6XXX_FAMILY_6185,
 		.name = "Marvell 88E6185",
 		.num_databases = 256,
 		.num_ports = 10,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 	}
 };
 
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index f75164d..e64cbee 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -24,24 +24,28 @@ static const struct mv88e6xxx_info mv88e6171_table[] = {
 		.name = "Marvell 88E6171",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6175,
 		.family = MV88E6XXX_FAMILY_6351,
 		.name = "Marvell 88E6175",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6350,
 		.family = MV88E6XXX_FAMILY_6351,
 		.name = "Marvell 88E6350",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6351,
 		.family = MV88E6XXX_FAMILY_6351,
 		.name = "Marvell 88E6351",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	}
 };
 
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index c622a1d..c61f0f4 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -29,36 +29,42 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.name = "Marvell 88E6320",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6321,
 		.family = MV88E6XXX_FAMILY_6320,
 		.name = "Marvell 88E6321",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6172,
 		.family = MV88E6XXX_FAMILY_6352,
 		.name = "Marvell 88E6172",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6176,
 		.family = MV88E6XXX_FAMILY_6352,
 		.name = "Marvell 88E6176",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6240,
 		.family = MV88E6XXX_FAMILY_6352,
 		.name = "Marvell 88E6240",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6352,
 		.family = MV88E6XXX_FAMILY_6352,
 		.name = "Marvell 88E6352",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	}
 };
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 4f455d2..c67b72a 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -350,12 +350,27 @@ enum mv88e6xxx_family {
 	MV88E6XXX_FAMILY_6352,	/* 6172 6176 6240 6352 */
 };
 
+#define MV88E6XXX_FLAGS_FAMILY_6095	0
+
+#define MV88E6XXX_FLAGS_FAMILY_6097	0
+
+#define MV88E6XXX_FLAGS_FAMILY_6165	0
+
+#define MV88E6XXX_FLAGS_FAMILY_6185	0
+
+#define MV88E6XXX_FLAGS_FAMILY_6320	0
+
+#define MV88E6XXX_FLAGS_FAMILY_6351	0
+
+#define MV88E6XXX_FLAGS_FAMILY_6352	0
+
 struct mv88e6xxx_info {
 	enum mv88e6xxx_family family;
 	u16 prod_num;
 	const char *name;
 	unsigned int num_databases;
 	unsigned int num_ports;
+	unsigned long flags;
 };
 
 struct mv88e6xxx_atu_entry {
@@ -449,6 +464,12 @@ struct mv88e6xxx_hw_stat {
 	enum stat_type type;
 };
 
+static inline bool mv88e6xxx_has(struct mv88e6xxx_priv_state *ps,
+				 unsigned long flags)
+{
+	return (ps->info->flags & flags) == flags;
+}
+
 int mv88e6xxx_switch_reset(struct mv88e6xxx_priv_state *ps, bool ppu_active);
 const char *mv88e6xxx_drv_probe(struct device *dsa_dev, struct device *host_dev,
 				int sw_addr, void **priv,
-- 
2.8.2
