From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 8/8] net: dsa: mv88e6xxx: prefix Global Prio and Tag macros
Date: Thu, 15 Jun 2017 12:14:06 -0400
Message-ID: <20170615161406.20546-9-vivien.didelot@savoirfairelinux.com>
References: <20170615161406.20546-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170615161406.20546-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prefix and document the remaining Global IP and IEEE Priority and Core
Tag Type registers and give them a clear 16-bit register representation.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c    | 18 +++++++++---------
 drivers/net/dsa/mv88e6xxx/global1.h | 33 +++++++++++++++++++++++----------
 2 files changed, 32 insertions(+), 19 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 46e8d1871847..19772e3dd67e 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2022,33 +2022,33 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 		return err;
 
 	/* Configure the IP ToS mapping registers. */
-	err = mv88e6xxx_g1_write(chip, GLOBAL_IP_PRI_0, 0x0000);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_IP_PRI_0, 0x0000);
 	if (err)
 		return err;
-	err = mv88e6xxx_g1_write(chip, GLOBAL_IP_PRI_1, 0x0000);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_IP_PRI_1, 0x0000);
 	if (err)
 		return err;
-	err = mv88e6xxx_g1_write(chip, GLOBAL_IP_PRI_2, 0x5555);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_IP_PRI_2, 0x5555);
 	if (err)
 		return err;
-	err = mv88e6xxx_g1_write(chip, GLOBAL_IP_PRI_3, 0x5555);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_IP_PRI_3, 0x5555);
 	if (err)
 		return err;
-	err = mv88e6xxx_g1_write(chip, GLOBAL_IP_PRI_4, 0xaaaa);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_IP_PRI_4, 0xaaaa);
 	if (err)
 		return err;
-	err = mv88e6xxx_g1_write(chip, GLOBAL_IP_PRI_5, 0xaaaa);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_IP_PRI_5, 0xaaaa);
 	if (err)
 		return err;
-	err = mv88e6xxx_g1_write(chip, GLOBAL_IP_PRI_6, 0xffff);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_IP_PRI_6, 0xffff);
 	if (err)
 		return err;
-	err = mv88e6xxx_g1_write(chip, GLOBAL_IP_PRI_7, 0xffff);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_IP_PRI_7, 0xffff);
 	if (err)
 		return err;
 
 	/* Configure the IEEE 802.1p priority mapping register. */
-	err = mv88e6xxx_g1_write(chip, GLOBAL_IEEE_PRI, 0xfa41);
+	err = mv88e6xxx_g1_write(chip, MV88E6XXX_G1_IEEE_PRI, 0xfa41);
 	if (err)
 		return err;
 
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 16c21bd671c5..950b914f9251 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -146,16 +146,29 @@
 #define MV88E6XXX_G1_ATU_MAC23		0x0e
 #define MV88E6XXX_G1_ATU_MAC45		0x0f
 
-#define GLOBAL_IP_PRI_0		0x10
-#define GLOBAL_IP_PRI_1		0x11
-#define GLOBAL_IP_PRI_2		0x12
-#define GLOBAL_IP_PRI_3		0x13
-#define GLOBAL_IP_PRI_4		0x14
-#define GLOBAL_IP_PRI_5		0x15
-#define GLOBAL_IP_PRI_6		0x16
-#define GLOBAL_IP_PRI_7		0x17
-#define GLOBAL_IEEE_PRI		0x18
-#define GLOBAL_CORE_TAG_TYPE	0x19
+/* Offset 0x10: IP-PRI Mapping Register 0
+ * Offset 0x11: IP-PRI Mapping Register 1
+ * Offset 0x12: IP-PRI Mapping Register 2
+ * Offset 0x13: IP-PRI Mapping Register 3
+ * Offset 0x14: IP-PRI Mapping Register 4
+ * Offset 0x15: IP-PRI Mapping Register 5
+ * Offset 0x16: IP-PRI Mapping Register 6
+ * Offset 0x17: IP-PRI Mapping Register 7
+ */
+#define MV88E6XXX_G1_IP_PRI_0	0x10
+#define MV88E6XXX_G1_IP_PRI_1	0x11
+#define MV88E6XXX_G1_IP_PRI_2	0x12
+#define MV88E6XXX_G1_IP_PRI_3	0x13
+#define MV88E6XXX_G1_IP_PRI_4	0x14
+#define MV88E6XXX_G1_IP_PRI_5	0x15
+#define MV88E6XXX_G1_IP_PRI_6	0x16
+#define MV88E6XXX_G1_IP_PRI_7	0x17
+
+/* Offset 0x18: IEEE-PRI Register */
+#define MV88E6XXX_G1_IEEE_PRI	0x18
+
+/* Offset 0x19: Core Tag Type */
+#define MV88E6185_G1_CORE_TAG_TYPE	0x19
 
 /* Offset 0x1A: Monitor Control */
 #define MV88E6185_G1_MONITOR_CTL			0x1a
-- 
2.13.1
