From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 12/18] net: dsa: mv88e6352: Add support for ndo_fdb functions
Date: Sat, 21 Mar 2015 08:46:49 -0700
Message-ID: <1426952815-4642-13-git-send-email-linux@roeck-us.net>
References: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for manipulating switch fdb entries by pointing to the
ndo_fdb functions implemented for mv88e6xxxx.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6352.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 51acd16..7285bd0 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -711,6 +711,9 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.port_join_bridge	= mv88e6xxx_join_bridge,
 	.port_leave_bridge	= mv88e6xxx_leave_bridge,
 	.port_stp_update	= mv88e6xxx_port_stp_update,
+	.fdb_add		= mv88e6xxx_port_fdb_add,
+	.fdb_del		= mv88e6xxx_port_fdb_del,
+	.fdb_getnext		= mv88e6xxx_port_fdb_getnext,
 };
 
 MODULE_ALIAS("platform:mv88e6352");
-- 
2.1.0
