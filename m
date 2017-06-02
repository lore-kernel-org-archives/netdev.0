From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 5/5] net: dsa: mv88e6xxx: move the Global 2 macros
Date: Fri,  2 Jun 2017 17:06:19 -0400
Message-ID: <20170602210619.26837-6-vivien.didelot@savoirfairelinux.com>
References: <20170602210619.26837-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48052 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751279AbdFBVIb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 17:08:31 -0400
In-Reply-To: <20170602210619.26837-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the GLOBAL2_* macros where they belong, in the related global2.h
header.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.h    | 101 -----------------------------------
 drivers/net/dsa/mv88e6xxx/global2.c |   2 -
 drivers/net/dsa/mv88e6xxx/global2.h | 103 ++++++++++++++++++++++++++++++++++++
 3 files changed, 103 insertions(+), 103 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index 7e558e9ba35d..98c24af977fd 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -33,107 +33,6 @@
 #define SMI_CMD_OP_45_READ_DATA_INC	((3 << 10) | SMI_CMD_BUSY)
 #define SMI_DATA		0x01
 
-#define GLOBAL2_INT_SOURCE	0x00
-#define GLOBAL2_INT_SOURCE_WATCHDOG	15
-#define GLOBAL2_INT_MASK	0x01
-#define GLOBAL2_MGMT_EN_2X	0x02
-#define GLOBAL2_MGMT_EN_0X	0x03
-#define GLOBAL2_FLOW_CONTROL	0x04
-#define GLOBAL2_SWITCH_MGMT	0x05
-#define GLOBAL2_SWITCH_MGMT_USE_DOUBLE_TAG_DATA	BIT(15)
-#define GLOBAL2_SWITCH_MGMT_PREVENT_LOOPS	BIT(14)
-#define GLOBAL2_SWITCH_MGMT_FLOW_CONTROL_MSG	BIT(13)
-#define GLOBAL2_SWITCH_MGMT_FORCE_FLOW_CTRL_PRI	BIT(7)
-#define GLOBAL2_SWITCH_MGMT_RSVD2CPU		BIT(3)
-#define GLOBAL2_DEVICE_MAPPING	0x06
-#define GLOBAL2_DEVICE_MAPPING_UPDATE		BIT(15)
-#define GLOBAL2_DEVICE_MAPPING_TARGET_SHIFT	8
-#define GLOBAL2_DEVICE_MAPPING_PORT_MASK	0x0f
-#define GLOBAL2_TRUNK_MASK	0x07
-#define GLOBAL2_TRUNK_MASK_UPDATE		BIT(15)
-#define GLOBAL2_TRUNK_MASK_NUM_SHIFT		12
-#define GLOBAL2_TRUNK_MASK_HASK			BIT(11)
-#define GLOBAL2_TRUNK_MAPPING	0x08
-#define GLOBAL2_TRUNK_MAPPING_UPDATE		BIT(15)
-#define GLOBAL2_TRUNK_MAPPING_ID_SHIFT		11
-#define GLOBAL2_IRL_CMD		0x09
-#define GLOBAL2_IRL_CMD_BUSY	BIT(15)
-#define GLOBAL2_IRL_CMD_OP_INIT_ALL	((0x001 << 12) | GLOBAL2_IRL_CMD_BUSY)
-#define GLOBAL2_IRL_CMD_OP_INIT_SEL	((0x010 << 12) | GLOBAL2_IRL_CMD_BUSY)
-#define GLOBAL2_IRL_CMD_OP_WRITE_SEL	((0x011 << 12) | GLOBAL2_IRL_CMD_BUSY)
-#define GLOBAL2_IRL_CMD_OP_READ_SEL	((0x100 << 12) | GLOBAL2_IRL_CMD_BUSY)
-#define GLOBAL2_IRL_DATA	0x0a
-#define GLOBAL2_PVT_ADDR	0x0b
-#define GLOBAL2_PVT_ADDR_BUSY	BIT(15)
-#define GLOBAL2_PVT_ADDR_OP_INIT_ONES	((0x01 << 12) | GLOBAL2_PVT_ADDR_BUSY)
-#define GLOBAL2_PVT_ADDR_OP_WRITE_PVLAN	((0x03 << 12) | GLOBAL2_PVT_ADDR_BUSY)
-#define GLOBAL2_PVT_ADDR_OP_READ	((0x04 << 12) | GLOBAL2_PVT_ADDR_BUSY)
-#define GLOBAL2_PVT_DATA	0x0c
-#define GLOBAL2_SWITCH_MAC	0x0d
-#define GLOBAL2_ATU_STATS	0x0e
-#define GLOBAL2_PRIO_OVERRIDE	0x0f
-#define GLOBAL2_PRIO_OVERRIDE_FORCE_SNOOP	BIT(7)
-#define GLOBAL2_PRIO_OVERRIDE_SNOOP_SHIFT	4
-#define GLOBAL2_PRIO_OVERRIDE_FORCE_ARP		BIT(3)
-#define GLOBAL2_PRIO_OVERRIDE_ARP_SHIFT		0
-#define GLOBAL2_EEPROM_CMD		0x14
-#define GLOBAL2_EEPROM_CMD_BUSY		BIT(15)
-#define GLOBAL2_EEPROM_CMD_OP_WRITE	((0x3 << 12) | GLOBAL2_EEPROM_CMD_BUSY)
-#define GLOBAL2_EEPROM_CMD_OP_READ	((0x4 << 12) | GLOBAL2_EEPROM_CMD_BUSY)
-#define GLOBAL2_EEPROM_CMD_OP_LOAD	((0x6 << 12) | GLOBAL2_EEPROM_CMD_BUSY)
-#define GLOBAL2_EEPROM_CMD_RUNNING	BIT(11)
-#define GLOBAL2_EEPROM_CMD_WRITE_EN	BIT(10)
-#define GLOBAL2_EEPROM_CMD_ADDR_MASK	0xff
-#define GLOBAL2_EEPROM_DATA	0x15
-#define GLOBAL2_EEPROM_ADDR	0x15 /* 6390, 6341 */
-#define GLOBAL2_PTP_AVB_OP	0x16
-#define GLOBAL2_PTP_AVB_DATA	0x17
-#define GLOBAL2_SMI_PHY_CMD			0x18
-#define GLOBAL2_SMI_PHY_CMD_BUSY		BIT(15)
-#define GLOBAL2_SMI_PHY_CMD_EXTERNAL		BIT(13)
-#define GLOBAL2_SMI_PHY_CMD_MODE_22		BIT(12)
-#define GLOBAL2_SMI_PHY_CMD_OP_22_WRITE_DATA	((0x1 << 10) | \
-						 GLOBAL2_SMI_PHY_CMD_MODE_22 | \
-						 GLOBAL2_SMI_PHY_CMD_BUSY)
-#define GLOBAL2_SMI_PHY_CMD_OP_22_READ_DATA	((0x2 << 10) | \
-						 GLOBAL2_SMI_PHY_CMD_MODE_22 | \
-						 GLOBAL2_SMI_PHY_CMD_BUSY)
-#define GLOBAL2_SMI_PHY_CMD_OP_45_WRITE_ADDR	((0x0 << 10) | \
-						 GLOBAL2_SMI_PHY_CMD_BUSY)
-#define GLOBAL2_SMI_PHY_CMD_OP_45_WRITE_DATA	((0x1 << 10) | \
-						 GLOBAL2_SMI_PHY_CMD_BUSY)
-#define GLOBAL2_SMI_PHY_CMD_OP_45_READ_DATA	((0x3 << 10) | \
-						 GLOBAL2_SMI_PHY_CMD_BUSY)
-
-#define GLOBAL2_SMI_PHY_DATA			0x19
-#define GLOBAL2_SCRATCH_MISC	0x1a
-#define GLOBAL2_SCRATCH_BUSY		BIT(15)
-#define GLOBAL2_SCRATCH_REGISTER_SHIFT	8
-#define GLOBAL2_SCRATCH_VALUE_MASK	0xff
-#define GLOBAL2_WDOG_CONTROL	0x1b
-#define GLOBAL2_WDOG_CONTROL_EGRESS_EVENT	BIT(7)
-#define GLOBAL2_WDOG_CONTROL_RMU_TIMEOUT	BIT(6)
-#define GLOBAL2_WDOG_CONTROL_QC_ENABLE		BIT(5)
-#define GLOBAL2_WDOG_CONTROL_EGRESS_HISTORY	BIT(4)
-#define GLOBAL2_WDOG_CONTROL_EGRESS_ENABLE	BIT(3)
-#define GLOBAL2_WDOG_CONTROL_FORCE_IRQ		BIT(2)
-#define GLOBAL2_WDOG_CONTROL_HISTORY		BIT(1)
-#define GLOBAL2_WDOG_CONTROL_SWRESET		BIT(0)
-#define GLOBAL2_WDOG_UPDATE			BIT(15)
-#define GLOBAL2_WDOG_INT_SOURCE			(0x00 << 8)
-#define GLOBAL2_WDOG_INT_STATUS			(0x10 << 8)
-#define GLOBAL2_WDOG_INT_ENABLE			(0x11 << 8)
-#define GLOBAL2_WDOG_EVENT			(0x12 << 8)
-#define GLOBAL2_WDOG_HISTORY			(0x13 << 8)
-#define GLOBAL2_WDOG_DATA_MASK			0xff
-#define GLOBAL2_WDOG_CUT_THROUGH		BIT(3)
-#define GLOBAL2_WDOG_QUEUE_CONTROLLER		BIT(2)
-#define GLOBAL2_WDOG_EGRESS			BIT(1)
-#define GLOBAL2_WDOG_FORCE_IRQ			BIT(0)
-#define GLOBAL2_QOS_WEIGHT	0x1c
-#define GLOBAL2_MISC		0x1d
-#define GLOBAL2_MISC_5_BIT_PORT	BIT(14)
-
 #define MV88E6XXX_N_FID		4096
 
 /* PVT limits for 4-bit port and 5-bit switch */
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index 538a8a27d912..d63af31e7840 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -20,8 +20,6 @@
 #include "global1.h" /* for GLOBAL_STATUS_IRQ_DEVICE */
 #include "global2.h"
 
-#define ADDR_GLOBAL2	0x1c
-
 static int mv88e6xxx_g2_read(struct mv88e6xxx_chip *chip, int reg, u16 *val)
 {
 	return mv88e6xxx_read(chip, ADDR_GLOBAL2, reg, val);
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index b5cfe041ee59..84a5ea69a4ac 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -17,6 +17,109 @@
 
 #include "chip.h"
 
+#define ADDR_GLOBAL2	0x1c
+
+#define GLOBAL2_INT_SOURCE	0x00
+#define GLOBAL2_INT_SOURCE_WATCHDOG	15
+#define GLOBAL2_INT_MASK	0x01
+#define GLOBAL2_MGMT_EN_2X	0x02
+#define GLOBAL2_MGMT_EN_0X	0x03
+#define GLOBAL2_FLOW_CONTROL	0x04
+#define GLOBAL2_SWITCH_MGMT	0x05
+#define GLOBAL2_SWITCH_MGMT_USE_DOUBLE_TAG_DATA	BIT(15)
+#define GLOBAL2_SWITCH_MGMT_PREVENT_LOOPS	BIT(14)
+#define GLOBAL2_SWITCH_MGMT_FLOW_CONTROL_MSG	BIT(13)
+#define GLOBAL2_SWITCH_MGMT_FORCE_FLOW_CTRL_PRI	BIT(7)
+#define GLOBAL2_SWITCH_MGMT_RSVD2CPU		BIT(3)
+#define GLOBAL2_DEVICE_MAPPING	0x06
+#define GLOBAL2_DEVICE_MAPPING_UPDATE		BIT(15)
+#define GLOBAL2_DEVICE_MAPPING_TARGET_SHIFT	8
+#define GLOBAL2_DEVICE_MAPPING_PORT_MASK	0x0f
+#define GLOBAL2_TRUNK_MASK	0x07
+#define GLOBAL2_TRUNK_MASK_UPDATE		BIT(15)
+#define GLOBAL2_TRUNK_MASK_NUM_SHIFT		12
+#define GLOBAL2_TRUNK_MASK_HASK			BIT(11)
+#define GLOBAL2_TRUNK_MAPPING	0x08
+#define GLOBAL2_TRUNK_MAPPING_UPDATE		BIT(15)
+#define GLOBAL2_TRUNK_MAPPING_ID_SHIFT		11
+#define GLOBAL2_IRL_CMD		0x09
+#define GLOBAL2_IRL_CMD_BUSY	BIT(15)
+#define GLOBAL2_IRL_CMD_OP_INIT_ALL	((0x001 << 12) | GLOBAL2_IRL_CMD_BUSY)
+#define GLOBAL2_IRL_CMD_OP_INIT_SEL	((0x010 << 12) | GLOBAL2_IRL_CMD_BUSY)
+#define GLOBAL2_IRL_CMD_OP_WRITE_SEL	((0x011 << 12) | GLOBAL2_IRL_CMD_BUSY)
+#define GLOBAL2_IRL_CMD_OP_READ_SEL	((0x100 << 12) | GLOBAL2_IRL_CMD_BUSY)
+#define GLOBAL2_IRL_DATA	0x0a
+#define GLOBAL2_PVT_ADDR	0x0b
+#define GLOBAL2_PVT_ADDR_BUSY	BIT(15)
+#define GLOBAL2_PVT_ADDR_OP_INIT_ONES	((0x01 << 12) | GLOBAL2_PVT_ADDR_BUSY)
+#define GLOBAL2_PVT_ADDR_OP_WRITE_PVLAN	((0x03 << 12) | GLOBAL2_PVT_ADDR_BUSY)
+#define GLOBAL2_PVT_ADDR_OP_READ	((0x04 << 12) | GLOBAL2_PVT_ADDR_BUSY)
+#define GLOBAL2_PVT_DATA	0x0c
+#define GLOBAL2_SWITCH_MAC	0x0d
+#define GLOBAL2_ATU_STATS	0x0e
+#define GLOBAL2_PRIO_OVERRIDE	0x0f
+#define GLOBAL2_PRIO_OVERRIDE_FORCE_SNOOP	BIT(7)
+#define GLOBAL2_PRIO_OVERRIDE_SNOOP_SHIFT	4
+#define GLOBAL2_PRIO_OVERRIDE_FORCE_ARP		BIT(3)
+#define GLOBAL2_PRIO_OVERRIDE_ARP_SHIFT		0
+#define GLOBAL2_EEPROM_CMD		0x14
+#define GLOBAL2_EEPROM_CMD_BUSY		BIT(15)
+#define GLOBAL2_EEPROM_CMD_OP_WRITE	((0x3 << 12) | GLOBAL2_EEPROM_CMD_BUSY)
+#define GLOBAL2_EEPROM_CMD_OP_READ	((0x4 << 12) | GLOBAL2_EEPROM_CMD_BUSY)
+#define GLOBAL2_EEPROM_CMD_OP_LOAD	((0x6 << 12) | GLOBAL2_EEPROM_CMD_BUSY)
+#define GLOBAL2_EEPROM_CMD_RUNNING	BIT(11)
+#define GLOBAL2_EEPROM_CMD_WRITE_EN	BIT(10)
+#define GLOBAL2_EEPROM_CMD_ADDR_MASK	0xff
+#define GLOBAL2_EEPROM_DATA	0x15
+#define GLOBAL2_EEPROM_ADDR	0x15 /* 6390, 6341 */
+#define GLOBAL2_PTP_AVB_OP	0x16
+#define GLOBAL2_PTP_AVB_DATA	0x17
+#define GLOBAL2_SMI_PHY_CMD			0x18
+#define GLOBAL2_SMI_PHY_CMD_BUSY		BIT(15)
+#define GLOBAL2_SMI_PHY_CMD_EXTERNAL		BIT(13)
+#define GLOBAL2_SMI_PHY_CMD_MODE_22		BIT(12)
+#define GLOBAL2_SMI_PHY_CMD_OP_22_WRITE_DATA	((0x1 << 10) | \
+						 GLOBAL2_SMI_PHY_CMD_MODE_22 | \
+						 GLOBAL2_SMI_PHY_CMD_BUSY)
+#define GLOBAL2_SMI_PHY_CMD_OP_22_READ_DATA	((0x2 << 10) | \
+						 GLOBAL2_SMI_PHY_CMD_MODE_22 | \
+						 GLOBAL2_SMI_PHY_CMD_BUSY)
+#define GLOBAL2_SMI_PHY_CMD_OP_45_WRITE_ADDR	((0x0 << 10) | \
+						 GLOBAL2_SMI_PHY_CMD_BUSY)
+#define GLOBAL2_SMI_PHY_CMD_OP_45_WRITE_DATA	((0x1 << 10) | \
+						 GLOBAL2_SMI_PHY_CMD_BUSY)
+#define GLOBAL2_SMI_PHY_CMD_OP_45_READ_DATA	((0x3 << 10) | \
+						 GLOBAL2_SMI_PHY_CMD_BUSY)
+
+#define GLOBAL2_SMI_PHY_DATA			0x19
+#define GLOBAL2_SCRATCH_MISC	0x1a
+#define GLOBAL2_SCRATCH_BUSY		BIT(15)
+#define GLOBAL2_SCRATCH_REGISTER_SHIFT	8
+#define GLOBAL2_SCRATCH_VALUE_MASK	0xff
+#define GLOBAL2_WDOG_CONTROL	0x1b
+#define GLOBAL2_WDOG_CONTROL_EGRESS_EVENT	BIT(7)
+#define GLOBAL2_WDOG_CONTROL_RMU_TIMEOUT	BIT(6)
+#define GLOBAL2_WDOG_CONTROL_QC_ENABLE		BIT(5)
+#define GLOBAL2_WDOG_CONTROL_EGRESS_HISTORY	BIT(4)
+#define GLOBAL2_WDOG_CONTROL_EGRESS_ENABLE	BIT(3)
+#define GLOBAL2_WDOG_CONTROL_FORCE_IRQ		BIT(2)
+#define GLOBAL2_WDOG_CONTROL_HISTORY		BIT(1)
+#define GLOBAL2_WDOG_CONTROL_SWRESET		BIT(0)
+#define GLOBAL2_WDOG_UPDATE			BIT(15)
+#define GLOBAL2_WDOG_INT_SOURCE			(0x00 << 8)
+#define GLOBAL2_WDOG_INT_STATUS			(0x10 << 8)
+#define GLOBAL2_WDOG_INT_ENABLE			(0x11 << 8)
+#define GLOBAL2_WDOG_EVENT			(0x12 << 8)
+#define GLOBAL2_WDOG_HISTORY			(0x13 << 8)
+#define GLOBAL2_WDOG_DATA_MASK			0xff
+#define GLOBAL2_WDOG_CUT_THROUGH		BIT(3)
+#define GLOBAL2_WDOG_QUEUE_CONTROLLER		BIT(2)
+#define GLOBAL2_WDOG_EGRESS			BIT(1)
+#define GLOBAL2_WDOG_FORCE_IRQ			BIT(0)
+#define GLOBAL2_QOS_WEIGHT	0x1c
+#define GLOBAL2_MISC		0x1d
+#define GLOBAL2_MISC_5_BIT_PORT	BIT(14)
+
 #ifdef CONFIG_NET_DSA_MV88E6XXX_GLOBAL2
 
 static inline int mv88e6xxx_g2_require(struct mv88e6xxx_chip *chip)
-- 
2.13.0
