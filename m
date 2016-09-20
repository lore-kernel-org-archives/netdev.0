From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv3 net-next 2/2] net: dsa: mv88e6xxx: Convert flag bits to unsigned long long
Date: Wed, 21 Sep 2016 01:40:32 +0200
Message-ID: <1474414832-1638-3-git-send-email-andrew@lunn.ch>
References: <1474414832-1638-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57147 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753230AbcITXkx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 19:40:53 -0400
In-Reply-To: <1474414832-1638-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are soon going to run out of flag bits on 32bit systems. Convert to
unsigned long long.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 62 +++++++++++++++++------------------
 1 file changed, 31 insertions(+), 31 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index e349d0d64645..827988397fd8 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -452,36 +452,36 @@ enum mv88e6xxx_cap {
 };
 
 /* Bitmask of capabilities */
-#define MV88E6XXX_FLAG_EDSA		BIT(MV88E6XXX_CAP_EDSA)
-#define MV88E6XXX_FLAG_EEE		BIT(MV88E6XXX_CAP_EEE)
-
-#define MV88E6XXX_FLAG_SMI_CMD		BIT(MV88E6XXX_CAP_SMI_CMD)
-#define MV88E6XXX_FLAG_SMI_DATA		BIT(MV88E6XXX_CAP_SMI_DATA)
-
-#define MV88E6XXX_FLAG_PHY_PAGE		BIT(MV88E6XXX_CAP_PHY_PAGE)
-
-#define MV88E6XXX_FLAG_SERDES		BIT(MV88E6XXX_CAP_SERDES)
-
-#define MV88E6XXX_FLAG_GLOBAL2		BIT(MV88E6XXX_CAP_GLOBAL2)
-#define MV88E6XXX_FLAG_G2_MGMT_EN_2X	BIT(MV88E6XXX_CAP_G2_MGMT_EN_2X)
-#define MV88E6XXX_FLAG_G2_MGMT_EN_0X	BIT(MV88E6XXX_CAP_G2_MGMT_EN_0X)
-#define MV88E6XXX_FLAG_G2_IRL_CMD	BIT(MV88E6XXX_CAP_G2_IRL_CMD)
-#define MV88E6XXX_FLAG_G2_IRL_DATA	BIT(MV88E6XXX_CAP_G2_IRL_DATA)
-#define MV88E6XXX_FLAG_G2_PVT_ADDR	BIT(MV88E6XXX_CAP_G2_PVT_ADDR)
-#define MV88E6XXX_FLAG_G2_PVT_DATA	BIT(MV88E6XXX_CAP_G2_PVT_DATA)
-#define MV88E6XXX_FLAG_G2_SWITCH_MAC	BIT(MV88E6XXX_CAP_G2_SWITCH_MAC)
-#define MV88E6XXX_FLAG_G2_POT		BIT(MV88E6XXX_CAP_G2_POT)
-#define MV88E6XXX_FLAG_G2_EEPROM_CMD	BIT(MV88E6XXX_CAP_G2_EEPROM_CMD)
-#define MV88E6XXX_FLAG_G2_EEPROM_DATA	BIT(MV88E6XXX_CAP_G2_EEPROM_DATA)
-#define MV88E6XXX_FLAG_G2_SMI_PHY_CMD	BIT(MV88E6XXX_CAP_G2_SMI_PHY_CMD)
-#define MV88E6XXX_FLAG_G2_SMI_PHY_DATA	BIT(MV88E6XXX_CAP_G2_SMI_PHY_DATA)
-
-#define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
-#define MV88E6XXX_FLAG_PPU_ACTIVE	BIT(MV88E6XXX_CAP_PPU_ACTIVE)
-#define MV88E6XXX_FLAG_STU		BIT(MV88E6XXX_CAP_STU)
-#define MV88E6XXX_FLAG_TEMP		BIT(MV88E6XXX_CAP_TEMP)
-#define MV88E6XXX_FLAG_TEMP_LIMIT	BIT(MV88E6XXX_CAP_TEMP_LIMIT)
-#define MV88E6XXX_FLAG_VTU		BIT(MV88E6XXX_CAP_VTU)
+#define MV88E6XXX_FLAG_EDSA		BIT_ULL(MV88E6XXX_CAP_EDSA)
+#define MV88E6XXX_FLAG_EEE		BIT_ULL(MV88E6XXX_CAP_EEE)
+
+#define MV88E6XXX_FLAG_SMI_CMD		BIT_ULL(MV88E6XXX_CAP_SMI_CMD)
+#define MV88E6XXX_FLAG_SMI_DATA		BIT_ULL(MV88E6XXX_CAP_SMI_DATA)
+
+#define MV88E6XXX_FLAG_PHY_PAGE		BIT_ULL(MV88E6XXX_CAP_PHY_PAGE)
+
+#define MV88E6XXX_FLAG_SERDES		BIT_ULL(MV88E6XXX_CAP_SERDES)
+
+#define MV88E6XXX_FLAG_GLOBAL2		BIT_ULL(MV88E6XXX_CAP_GLOBAL2)
+#define MV88E6XXX_FLAG_G2_MGMT_EN_2X	BIT_ULL(MV88E6XXX_CAP_G2_MGMT_EN_2X)
+#define MV88E6XXX_FLAG_G2_MGMT_EN_0X	BIT_ULL(MV88E6XXX_CAP_G2_MGMT_EN_0X)
+#define MV88E6XXX_FLAG_G2_IRL_CMD	BIT_ULL(MV88E6XXX_CAP_G2_IRL_CMD)
+#define MV88E6XXX_FLAG_G2_IRL_DATA	BIT_ULL(MV88E6XXX_CAP_G2_IRL_DATA)
+#define MV88E6XXX_FLAG_G2_PVT_ADDR	BIT_ULL(MV88E6XXX_CAP_G2_PVT_ADDR)
+#define MV88E6XXX_FLAG_G2_PVT_DATA	BIT_ULL(MV88E6XXX_CAP_G2_PVT_DATA)
+#define MV88E6XXX_FLAG_G2_SWITCH_MAC	BIT_ULL(MV88E6XXX_CAP_G2_SWITCH_MAC)
+#define MV88E6XXX_FLAG_G2_POT		BIT_ULL(MV88E6XXX_CAP_G2_POT)
+#define MV88E6XXX_FLAG_G2_EEPROM_CMD	BIT_ULL(MV88E6XXX_CAP_G2_EEPROM_CMD)
+#define MV88E6XXX_FLAG_G2_EEPROM_DATA	BIT_ULL(MV88E6XXX_CAP_G2_EEPROM_DATA)
+#define MV88E6XXX_FLAG_G2_SMI_PHY_CMD	BIT_ULL(MV88E6XXX_CAP_G2_SMI_PHY_CMD)
+#define MV88E6XXX_FLAG_G2_SMI_PHY_DATA	BIT_ULL(MV88E6XXX_CAP_G2_SMI_PHY_DATA)
+
+#define MV88E6XXX_FLAG_PPU		BIT_ULL(MV88E6XXX_CAP_PPU)
+#define MV88E6XXX_FLAG_PPU_ACTIVE	BIT_ULL(MV88E6XXX_CAP_PPU_ACTIVE)
+#define MV88E6XXX_FLAG_STU		BIT_ULL(MV88E6XXX_CAP_STU)
+#define MV88E6XXX_FLAG_TEMP		BIT_ULL(MV88E6XXX_CAP_TEMP)
+#define MV88E6XXX_FLAG_TEMP_LIMIT	BIT_ULL(MV88E6XXX_CAP_TEMP_LIMIT)
+#define MV88E6XXX_FLAG_VTU		BIT_ULL(MV88E6XXX_CAP_VTU)
 
 /* EEPROM Programming via Global2 with 16-bit data */
 #define MV88E6XXX_FLAGS_EEPROM16	\
@@ -614,7 +614,7 @@ struct mv88e6xxx_info {
 	unsigned int num_ports;
 	unsigned int port_base_addr;
 	unsigned int age_time_coeff;
-	unsigned long flags;
+	unsigned long long flags;
 };
 
 struct mv88e6xxx_atu_entry {
-- 
2.9.3
