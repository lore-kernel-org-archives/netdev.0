From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v3 14/15] net: dsa/mv88e6352: Add support for reading switch registers
Date: Wed, 29 Oct 2014 10:45:06 -0700
Message-ID: <1414604707-22407-15-git-send-email-linux@roeck-us.net>
References: <1414604707-22407-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414604707-22407-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Report switch register values to ethtool.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
v3:
- No change
v2:
- No change

 drivers/net/dsa/mv88e6352.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 8a956f9..d5bbe49 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -778,6 +778,8 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 #endif
 	.get_eeprom		= mv88e6352_get_eeprom,
 	.set_eeprom		= mv88e6352_set_eeprom,
+	.get_regs_len		= mv88e6xxx_get_regs_len,
+	.get_regs		= mv88e6xxx_get_regs,
 };
 
 MODULE_ALIAS("platform:mv88e6352");
-- 
1.9.1
