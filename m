From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/5] net: dsa: mv88e6xxx: move PHY macros
Date: Fri,  2 Jun 2017 17:06:16 -0400
Message-ID: <20170602210619.26837-3-vivien.didelot@savoirfairelinux.com>
References: <20170602210619.26837-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48000 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbdFBVIb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 17:08:31 -0400
In-Reply-To: <20170602210619.26837-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the PHY_* macros where they belong, in the related phy.h header.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.h | 4 ----
 drivers/net/dsa/mv88e6xxx/phy.h  | 3 +++
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index ae7aed533aa5..2929132fb52d 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -33,10 +33,6 @@
 #define SMI_CMD_OP_45_READ_DATA_INC	((3 << 10) | SMI_CMD_BUSY)
 #define SMI_DATA		0x01
 
-/* PHY Registers */
-#define PHY_PAGE		0x16
-#define PHY_PAGE_COPPER		0x00
-
 #define PORT_STATUS		0x00
 #define PORT_STATUS_PAUSE_EN	BIT(15)
 #define PORT_STATUS_MY_PAUSE	BIT(14)
diff --git a/drivers/net/dsa/mv88e6xxx/phy.h b/drivers/net/dsa/mv88e6xxx/phy.h
index 91fe3c3e9aea..4131a4e8206a 100644
--- a/drivers/net/dsa/mv88e6xxx/phy.h
+++ b/drivers/net/dsa/mv88e6xxx/phy.h
@@ -14,6 +14,9 @@
 #ifndef _MV88E6XXX_PHY_H
 #define _MV88E6XXX_PHY_H
 
+#define PHY_PAGE		0x16
+#define PHY_PAGE_COPPER		0x00
+
 /* PHY Registers accesses implementations */
 int mv88e6165_phy_read(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
 		       int addr, int reg, u16 *val);
-- 
2.13.0
