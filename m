From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 14/15] net: dsa/mv88e6352: Add support for reading switch registers
Date: Sun, 26 Oct 2014 09:52:44 -0700
Message-ID: <1414342365-27191-15-git-send-email-linux@roeck-us.net>
References: <1414342365-27191-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:45431 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115AbaJZQx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2014 12:53:28 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1XiR4J-002rVA-Ku
	for netdev@vger.kernel.org; Sun, 26 Oct 2014 16:53:27 +0000
In-Reply-To: <1414342365-27191-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Report switch register values to ethtool.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
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
