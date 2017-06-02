From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/5] net: dsa: mv88e6xxx: rename chip header
Date: Fri,  2 Jun 2017 17:06:15 -0400
Message-ID: <20170602210619.26837-2-vivien.didelot@savoirfairelinux.com>
References: <20170602210619.26837-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170602210619.26837-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The mv88e6xxx.h is meant to contains the chip structures and data.
Rename it to chip.h, as for other source/header pairs of the driver.

At the same time, ensure that relative header inclusions are separated
by a newline and sorted alphabetically.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c                  | 2 +-
 drivers/net/dsa/mv88e6xxx/{mv88e6xxx.h => chip.h} | 9 +++++----
 drivers/net/dsa/mv88e6xxx/global1.c               | 2 +-
 drivers/net/dsa/mv88e6xxx/global1.h               | 2 +-
 drivers/net/dsa/mv88e6xxx/global1_atu.c           | 2 +-
 drivers/net/dsa/mv88e6xxx/global1_vtu.c           | 2 +-
 drivers/net/dsa/mv88e6xxx/global2.c               | 3 ++-
 drivers/net/dsa/mv88e6xxx/global2.h               | 2 +-
 drivers/net/dsa/mv88e6xxx/phy.c                   | 2 +-
 drivers/net/dsa/mv88e6xxx/port.c                  | 3 ++-
 drivers/net/dsa/mv88e6xxx/port.h                  | 2 +-
 drivers/net/dsa/mv88e6xxx/serdes.c                | 2 +-
 drivers/net/dsa/mv88e6xxx/serdes.h                | 2 +-
 13 files changed, 19 insertions(+), 16 deletions(-)
 rename drivers/net/dsa/mv88e6xxx/{mv88e6xxx.h => chip.h} (99%)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 7cf470c3e662..0176254cb3c7 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -33,7 +33,7 @@
 #include <linux/phy.h>
 #include <net/dsa.h>
 
-#include "mv88e6xxx.h"
+#include "chip.h"
 #include "global1.h"
 #include "global2.h"
 #include "phy.h"
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/chip.h
similarity index 99%
rename from drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
rename to drivers/net/dsa/mv88e6xxx/chip.h
index 9087cb009cc3..ae7aed533aa5 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -1,5 +1,5 @@
 /*
- * Marvell 88e6xxx common definitions
+ * Marvell 88E6xxx Ethernet switch single-chip definition
  *
  * Copyright (c) 2008 Marvell Semiconductor
  *
@@ -9,8 +9,8 @@
  * (at your option) any later version.
  */
 
-#ifndef __MV88E6XXX_H
-#define __MV88E6XXX_H
+#ifndef _MV88E6XXX_CHIP_H
+#define _MV88E6XXX_CHIP_H
 
 #include <linux/if_vlan.h>
 #include <linux/irq.h>
@@ -924,4 +924,5 @@ int mv88e6xxx_update(struct mv88e6xxx_chip *chip, int addr, int reg,
 		     u16 update);
 int mv88e6xxx_wait(struct mv88e6xxx_chip *chip, int addr, int reg, u16 mask);
 struct mii_bus *mv88e6xxx_default_mdio_bus(struct mv88e6xxx_chip *chip);
-#endif
+
+#endif /* _MV88E6XXX_CHIP_H */
diff --git a/drivers/net/dsa/mv88e6xxx/global1.c b/drivers/net/dsa/mv88e6xxx/global1.c
index 39825837a1c9..4081ff0d38a0 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.c
+++ b/drivers/net/dsa/mv88e6xxx/global1.c
@@ -12,7 +12,7 @@
  * (at your option) any later version.
  */
 
-#include "mv88e6xxx.h"
+#include "chip.h"
 #include "global1.h"
 
 int mv88e6xxx_g1_read(struct mv88e6xxx_chip *chip, int reg, u16 *val)
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 46a4ea0f8c47..3b8f356b348c 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -15,7 +15,7 @@
 #ifndef _MV88E6XXX_GLOBAL1_H
 #define _MV88E6XXX_GLOBAL1_H
 
-#include "mv88e6xxx.h"
+#include "chip.h"
 
 int mv88e6xxx_g1_read(struct mv88e6xxx_chip *chip, int reg, u16 *val);
 int mv88e6xxx_g1_write(struct mv88e6xxx_chip *chip, int reg, u16 val);
diff --git a/drivers/net/dsa/mv88e6xxx/global1_atu.c b/drivers/net/dsa/mv88e6xxx/global1_atu.c
index fa7e7db5171b..6b0cf44dc07d 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_atu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_atu.c
@@ -10,7 +10,7 @@
  * (at your option) any later version.
  */
 
-#include "mv88e6xxx.h"
+#include "chip.h"
 #include "global1.h"
 
 /* Offset 0x01: ATU FID Register */
diff --git a/drivers/net/dsa/mv88e6xxx/global1_vtu.c b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
index 9aea22d4c9e2..bf593c7aaa9b 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_vtu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
@@ -11,7 +11,7 @@
  * (at your option) any later version.
  */
 
-#include "mv88e6xxx.h"
+#include "chip.h"
 #include "global1.h"
 
 /* Offset 0x02: VTU FID Register */
diff --git a/drivers/net/dsa/mv88e6xxx/global2.c b/drivers/net/dsa/mv88e6xxx/global2.c
index b3fea55071e3..0defce71e381 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.c
+++ b/drivers/net/dsa/mv88e6xxx/global2.c
@@ -15,7 +15,8 @@
 
 #include <linux/interrupt.h>
 #include <linux/irqdomain.h>
-#include "mv88e6xxx.h"
+
+#include "chip.h"
 #include "global2.h"
 
 #define ADDR_GLOBAL2	0x1c
diff --git a/drivers/net/dsa/mv88e6xxx/global2.h b/drivers/net/dsa/mv88e6xxx/global2.h
index 96046bb12ca1..b5cfe041ee59 100644
--- a/drivers/net/dsa/mv88e6xxx/global2.h
+++ b/drivers/net/dsa/mv88e6xxx/global2.h
@@ -15,7 +15,7 @@
 #ifndef _MV88E6XXX_GLOBAL2_H
 #define _MV88E6XXX_GLOBAL2_H
 
-#include "mv88e6xxx.h"
+#include "chip.h"
 
 #ifdef CONFIG_NET_DSA_MV88E6XXX_GLOBAL2
 
diff --git a/drivers/net/dsa/mv88e6xxx/phy.c b/drivers/net/dsa/mv88e6xxx/phy.c
index d47a6e08d88c..0db624f0993c 100644
--- a/drivers/net/dsa/mv88e6xxx/phy.c
+++ b/drivers/net/dsa/mv88e6xxx/phy.c
@@ -15,7 +15,7 @@
 #include <linux/module.h>
 #include <net/dsa.h>
 
-#include "mv88e6xxx.h"
+#include "chip.h"
 #include "phy.h"
 
 int mv88e6165_phy_read(struct mv88e6xxx_chip *chip, struct mii_bus *bus,
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 548a956637ee..360c77854f2a 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -13,7 +13,8 @@
  */
 
 #include <linux/phy.h>
-#include "mv88e6xxx.h"
+
+#include "chip.h"
 #include "port.h"
 
 int mv88e6xxx_port_read(struct mv88e6xxx_chip *chip, int port, int reg,
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 86f40887b6d2..497a6911b2bd 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -15,7 +15,7 @@
 #ifndef _MV88E6XXX_PORT_H
 #define _MV88E6XXX_PORT_H
 
-#include "mv88e6xxx.h"
+#include "chip.h"
 
 int mv88e6xxx_port_read(struct mv88e6xxx_chip *chip, int port, int reg,
 			u16 *val);
diff --git a/drivers/net/dsa/mv88e6xxx/serdes.c b/drivers/net/dsa/mv88e6xxx/serdes.c
index 53795676bd70..78f5b1eb44ea 100644
--- a/drivers/net/dsa/mv88e6xxx/serdes.c
+++ b/drivers/net/dsa/mv88e6xxx/serdes.c
@@ -13,8 +13,8 @@
 
 #include <linux/mii.h>
 
+#include "chip.h"
 #include "global2.h"
-#include "mv88e6xxx.h"
 #include "phy.h"
 #include "port.h"
 #include "serdes.h"
diff --git a/drivers/net/dsa/mv88e6xxx/serdes.h b/drivers/net/dsa/mv88e6xxx/serdes.h
index eb3ceaef790f..5c1cd6d8e9a5 100644
--- a/drivers/net/dsa/mv88e6xxx/serdes.h
+++ b/drivers/net/dsa/mv88e6xxx/serdes.h
@@ -14,7 +14,7 @@
 #ifndef _MV88E6XXX_SERDES_H
 #define _MV88E6XXX_SERDES_H
 
-#include "mv88e6xxx.h"
+#include "chip.h"
 
 #define MV88E6352_ADDR_SERDES		0x0f
 #define MV88E6352_SERDES_PAGE_FIBER	0x01
-- 
2.13.0
