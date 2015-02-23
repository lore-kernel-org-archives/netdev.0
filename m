From: Guenter Roeck <linux@roeck-us.net>
Subject: [RFT/RFC PATCH 8/8] net: dsa: mv88e6352: Add support for hardware bridging
Date: Mon, 23 Feb 2015 11:35:50 -0800
Message-ID: <1424720150-27564-9-git-send-email-linux@roeck-us.net>
References: <1424720150-27564-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424720150-27564-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6352.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index d7053db..7be7b03 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -713,6 +713,9 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.set_eeprom		= mv88e6352_set_eeprom,
 	.get_regs_len		= mv88e6xxx_get_regs_len,
 	.get_regs		= mv88e6xxx_get_regs,
+	.port_join_bridge	= mv88e6xxx_join_bridge,
+	.port_leave_bridge	= mv88e6xxx_leave_bridge,
+	.port_stp_update	= mv88e6xxx_port_stp_update,
 };
 
 MODULE_ALIAS("platform:mv88e6352");
-- 
2.1.0
