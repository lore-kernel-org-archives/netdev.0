From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 16/16] net: dsa: mv88e6171: Add support for hardware bridging
Date: Thu, 26 Mar 2015 18:36:43 -0700
Message-ID: <1427420203-27685-17-git-send-email-linux@roeck-us.net>
References: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew@lunn.ch>

Wire up the common code for setting up hardware bridging
and access to the forwarding database.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6171.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index e1700cd8badc..18cfead83dc9 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -431,6 +431,12 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 #endif
 	.get_regs_len		= mv88e6xxx_get_regs_len,
 	.get_regs		= mv88e6xxx_get_regs,
+	.port_join_bridge       = mv88e6xxx_join_bridge,
+	.port_leave_bridge      = mv88e6xxx_leave_bridge,
+	.port_stp_update        = mv88e6xxx_port_stp_update,
+	.fdb_add		= mv88e6xxx_port_fdb_add,
+	.fdb_del		= mv88e6xxx_port_fdb_del,
+	.fdb_getnext		= mv88e6xxx_port_fdb_getnext,
 };
 
 MODULE_ALIAS("platform:mv88e6171");
-- 
2.1.0
