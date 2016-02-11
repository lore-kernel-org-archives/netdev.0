From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 1/2] net: dsa: mv88e6xxx: Add support for Marvell 88E6240
Date: Thu, 11 Feb 2016 11:44:48 +0100
Message-ID: <1455187489-30771-1-git-send-email-s.hauer@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Marvell 88E6240 has been tested successfully without further
changes. Add entry to the table of supported devices.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/dsa/mv88e6352.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index cc6c545..a47f52f 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -25,6 +25,7 @@
 static const struct mv88e6xxx_switch_id mv88e6352_table[] = {
 	{ PORT_SWITCH_ID_6172, "Marvell 88E6172" },
 	{ PORT_SWITCH_ID_6176, "Marvell 88E6176" },
+	{ PORT_SWITCH_ID_6240, "Marvell 88E6240" },
 	{ PORT_SWITCH_ID_6320, "Marvell 88E6320" },
 	{ PORT_SWITCH_ID_6320_A1, "Marvell 88E6320 (A1)" },
 	{ PORT_SWITCH_ID_6320_A2, "Marvell 88e6320 (A2)" },
-- 
2.7.0.rc3
