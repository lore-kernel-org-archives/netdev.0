From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v5 net-next v5 13/14] net: dsa: mv88e6xxx: add port base address to info
Date: Mon, 20 Jun 2016 13:14:10 -0400
Message-ID: <20160620171411.13746-14-vivien.didelot@savoirfairelinux.com>
References: <20160620171411.13746-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160620171411.13746-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The switch ID is located at address 0x3 of every Port Registers bank.

But not all Marvell switches have their Port Registers SMI Addresses
starting at 0x10. 88E6060 starts at 0x8 and 88E6390 starts at 0x0.

Add this data in the info structure and use it in the detection code.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 19 ++++++++++++++++++-
 drivers/net/dsa/mv88e6xxx.h |  1 +
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index cadd1e3..789f938a 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3443,6 +3443,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6085",
 		.num_databases = 4096,
 		.num_ports = 10,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
 	},
 
@@ -3452,6 +3453,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6095/88E6095F",
 		.num_databases = 256,
 		.num_ports = 11,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6095,
 	},
 
@@ -3461,6 +3463,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6123",
 		.num_databases = 4096,
 		.num_ports = 3,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 	},
 
@@ -3470,6 +3473,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6131",
 		.num_databases = 256,
 		.num_ports = 8,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 	},
 
@@ -3479,6 +3483,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6161",
 		.num_databases = 4096,
 		.num_ports = 6,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 	},
 
@@ -3488,6 +3493,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6165",
 		.num_databases = 4096,
 		.num_ports = 6,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 	},
 
@@ -3497,6 +3503,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6171",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	},
 
@@ -3506,6 +3513,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6172",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	},
 
@@ -3515,6 +3523,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6175",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	},
 
@@ -3524,6 +3533,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6176",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	},
 
@@ -3533,6 +3543,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6185",
 		.num_databases = 256,
 		.num_ports = 10,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 	},
 
@@ -3542,6 +3553,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6240",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	},
 
@@ -3551,6 +3563,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6320",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 	},
 
@@ -3560,6 +3573,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6321",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 	},
 
@@ -3569,6 +3583,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6350",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	},
 
@@ -3578,6 +3593,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6351",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	},
 
@@ -3587,6 +3603,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6352",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	},
 };
@@ -3607,7 +3624,7 @@ static int mv88e6xxx_detect(struct mv88e6xxx_priv_state *ps)
 	const struct mv88e6xxx_info *info;
 	int id, prod_num, rev;
 
-	id = mv88e6xxx_reg_read(ps, REG_PORT(0), PORT_SWITCH_ID);
+	id = mv88e6xxx_reg_read(ps, ps->info->port_base_addr, PORT_SWITCH_ID);
 	if (id < 0)
 		return id;
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index b279f8c..8e6fe6b 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -519,6 +519,7 @@ struct mv88e6xxx_info {
 	const char *name;
 	unsigned int num_databases;
 	unsigned int num_ports;
+	unsigned int port_base_addr;
 	unsigned long flags;
 };
 
-- 
2.9.0
