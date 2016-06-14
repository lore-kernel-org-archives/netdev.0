From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 net-next v2 06/12] net: dsa: mv88e6xxx: add port base address to info
Date: Tue, 14 Jun 2016 14:31:47 -0400
Message-ID: <20160614183153.32327-7-vivien.didelot@savoirfairelinux.com>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Not all Marvell switches have their Port Registers SMI Addresses
starting at 0x10. Add this data in the info structure.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 17 +++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  1 +
 2 files changed, 18 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index ad7735d..6f43280 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3442,6 +3442,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6085",
 		.num_databases = 4096,
 		.num_ports = 10,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
 	},
 
@@ -3451,6 +3452,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6095/88E6095F",
 		.num_databases = 256,
 		.num_ports = 11,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6095,
 	},
 
@@ -3460,6 +3462,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6123",
 		.num_databases = 4096,
 		.num_ports = 3,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 	},
 
@@ -3469,6 +3472,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6131",
 		.num_databases = 256,
 		.num_ports = 8,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 	},
 
@@ -3478,6 +3482,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6161",
 		.num_databases = 4096,
 		.num_ports = 6,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 	},
 
@@ -3487,6 +3492,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6165",
 		.num_databases = 4096,
 		.num_ports = 6,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 	},
 
@@ -3496,6 +3502,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6171",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	},
 
@@ -3505,6 +3512,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6172",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	},
 
@@ -3514,6 +3522,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6175",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	},
 
@@ -3523,6 +3532,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6176",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	},
 
@@ -3532,6 +3542,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6185",
 		.num_databases = 256,
 		.num_ports = 10,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 	},
 
@@ -3541,6 +3552,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6240",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	},
 
@@ -3550,6 +3562,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6320",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 	},
 
@@ -3559,6 +3572,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6321",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 	},
 
@@ -3568,6 +3582,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6350",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	},
 
@@ -3577,6 +3592,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6351",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	},
 
@@ -3586,6 +3602,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.name = "Marvell 88E6352",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.port_base_addr = 0x10,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	},
 };
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 8221c3c..613cfa1 100644
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
2.8.3
