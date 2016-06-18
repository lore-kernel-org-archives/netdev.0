From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v3 net-next v3 14/14] net: dsa: mv88e6xxx: add port base address to info
Date: Fri, 17 Jun 2016 20:07:36 -0400
Message-ID: <20160618000736.5598-15-vivien.didelot@savoirfairelinux.com>
References: <20160618000736.5598-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160618000736.5598-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The switch ID is located at address 0x3 of every Port Registers bank.

But not all Marvell switches have their Port Registers SMI Addresses
starting at 0x10. 88E6060 starts at 0x8 and 88E6390 starts at 0x0.

Add this data in the info structure and use it in the detection code.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 19 ++++++++++++++++++-
 drivers/net/dsa/mv88e6xxx.h |  1 +
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 4d32f5a..aeb96db 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3511,6 +3511,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6085",
 		.num_databases = 4096,
 		.num_ports = 10,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
 	},
 
@@ -3520,6 +3521,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6095/88E6095F",
 		.num_databases = 256,
 		.num_ports = 11,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6095,
 	},
 
@@ -3529,6 +3531,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6123",
 		.num_databases = 4096,
 		.num_ports = 3,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 	},
 
@@ -3538,6 +3541,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6131",
 		.num_databases = 256,
 		.num_ports = 8,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 	},
 
@@ -3547,6 +3551,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6161",
 		.num_databases = 4096,
 		.num_ports = 6,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 	},
 
@@ -3556,6 +3561,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6165",
 		.num_databases = 4096,
 		.num_ports = 6,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 	},
 
@@ -3565,6 +3571,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6171",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	},
 
@@ -3574,6 +3581,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6172",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	},
 
@@ -3583,6 +3591,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6175",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	},
 
@@ -3592,6 +3601,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6176",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	},
 
@@ -3601,6 +3611,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6185",
 		.num_databases = 256,
 		.num_ports = 10,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 	},
 
@@ -3610,6 +3621,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6240",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	},
 
@@ -3619,6 +3631,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6320",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 	},
 
@@ -3628,6 +3641,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6321",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 	},
 
@@ -3637,6 +3651,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6350",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	},
 
@@ -3646,6 +3661,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6351",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	},
 
@@ -3655,6 +3671,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6352",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	},
 };
@@ -3675,7 +3692,7 @@ static int mv88e6xxx_detect(struct mv88e6xxx_priv_state *ps)
 	const struct mv88e6xxx_info *info;
 	int id, prod_num, rev;
 
-	id = mv88e6xxx_reg_read(ps, REG_PORT(0), PORT_SWITCH_ID);
+	id = mv88e6xxx_reg_read(ps, ps->info->port_base_addr, PORT_SWITCH_ID);
 	if (id < 0)
 		return id;
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index c82bd18..b0b5a84 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -533,6 +533,7 @@ struct mv88e6xxx_info {
 	const char *name;
 	unsigned int num_databases;
 	unsigned int num_ports;
+	unsigned int port_base_addr;
 	unsigned long flags;
 };
 
-- 
2.8.3
