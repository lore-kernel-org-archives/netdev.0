From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 13/14] net: dsa/mv88e6352: Add support for reading switch registers
Date: Wed, 22 Oct 2014 21:03:21 -0700
Message-ID: <1414037002-25528-14-git-send-email-linux@roeck-us.net>
References: <1414037002-25528-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:49497 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbaJWEEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 00:04:00 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1Xh9d2-002c7f-Bv
	for netdev@vger.kernel.org; Thu, 23 Oct 2014 04:04:00 +0000
In-Reply-To: <1414037002-25528-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Report switch register values to ethtool.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6352.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 9dddcba..2f31e28 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -779,6 +779,8 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.get_eeprom_len		= mv88e6352_get_eeprom_len,
 	.get_eeprom		= mv88e6352_get_eeprom,
 	.set_eeprom		= mv88e6352_set_eeprom,
+	.get_regs_len		= mv88e6xxx_get_regs_len,
+	.get_regs		= mv88e6xxx_get_regs,
 };
 
 MODULE_ALIAS("platform:mv88e6352");
-- 
1.9.1
