From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 04/12] net: dsa: mv88e6xxx: remove unused capabilities
Date: Tue,  4 Jul 2017 19:41:47 -0400
Message-ID: <20170704234155.24360-5-vivien.didelot@savoirfairelinux.com>
References: <20170704234155.24360-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170704234155.24360-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the forgotten capabilities and related flags from previous
cleanups.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.h | 29 +++--------------------------
 1 file changed, 3 insertions(+), 26 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index 086444016352..9ccf5d03346a 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -109,11 +109,6 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_CAP_SMI_CMD,		/* (0x00) SMI Command */
 	MV88E6XXX_CAP_SMI_DATA,		/* (0x01) SMI Data */
 
-	/* Switch Global (1) Registers.
-	 */
-	MV88E6XXX_CAP_G1_ATU_FID,	/* (0x01) ATU FID Register */
-	MV88E6XXX_CAP_G1_VTU_FID,	/* (0x02) VTU FID Register */
-
 	/* Switch Global 2 Registers.
 	 * The device contains a second set of global 16-bit registers.
 	 */
@@ -122,17 +117,6 @@ enum mv88e6xxx_cap {
 	MV88E6XXX_CAP_G2_MGMT_EN_2X,	/* (0x02) MGMT Enable Register 2x */
 	MV88E6XXX_CAP_G2_MGMT_EN_0X,	/* (0x03) MGMT Enable Register 0x */
 	MV88E6XXX_CAP_G2_POT,		/* (0x0f) Priority Override Table */
-
-	/* Per VLAN Spanning Tree Unit (STU).
-	 * The Port State database, if present, is accessed through VTU
-	 * operations and dedicated SID registers. See MV88E6352_G1_VTU_SID.
-	 */
-	MV88E6XXX_CAP_STU,
-
-	/* VLAN Table Unit.
-	 * The VTU is used to program 802.1Q VLANs. See MV88E6XXX_G1_VTU_OP.
-	 */
-	MV88E6XXX_CAP_VTU,
 };
 
 /* Bitmask of capabilities */
@@ -141,8 +125,6 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_SMI_CMD		BIT_ULL(MV88E6XXX_CAP_SMI_CMD)
 #define MV88E6XXX_FLAG_SMI_DATA		BIT_ULL(MV88E6XXX_CAP_SMI_DATA)
 
-#define MV88E6XXX_FLAG_G1_VTU_FID	BIT_ULL(MV88E6XXX_CAP_G1_VTU_FID)
-
 #define MV88E6XXX_FLAG_GLOBAL2		BIT_ULL(MV88E6XXX_CAP_GLOBAL2)
 #define MV88E6XXX_FLAG_G2_INT		BIT_ULL(MV88E6XXX_CAP_G2_INT)
 #define MV88E6XXX_FLAG_G2_MGMT_EN_2X	BIT_ULL(MV88E6XXX_CAP_G2_MGMT_EN_2X)
@@ -160,8 +142,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6097	\
-	(MV88E6XXX_FLAG_G1_VTU_FID |	\
-	 MV88E6XXX_FLAG_GLOBAL2 |	\
+	(MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_INT |        \
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
@@ -169,8 +150,7 @@ enum mv88e6xxx_cap {
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6165	\
-	(MV88E6XXX_FLAG_G1_VTU_FID |	\
-	 MV88E6XXX_FLAG_GLOBAL2 |	\
+	(MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
@@ -193,15 +173,13 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6341	\
 	(MV88E6XXX_FLAG_EEE |		\
-	 MV88E6XXX_FLAG_G1_VTU_FID |	\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_POT |	\
 	 MV88E6XXX_FLAGS_MULTI_CHIP)
 
 #define MV88E6XXX_FLAGS_FAMILY_6351	\
-	(MV88E6XXX_FLAG_G1_VTU_FID |	\
-	 MV88E6XXX_FLAG_GLOBAL2 |	\
+	(MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_0X |	\
@@ -210,7 +188,6 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6352	\
 	(MV88E6XXX_FLAG_EEE |		\
-	 MV88E6XXX_FLAG_G1_VTU_FID |	\
 	 MV88E6XXX_FLAG_GLOBAL2 |	\
 	 MV88E6XXX_FLAG_G2_INT |	\
 	 MV88E6XXX_FLAG_G2_MGMT_EN_2X |	\
-- 
2.13.2
