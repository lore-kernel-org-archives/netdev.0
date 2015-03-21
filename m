From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 09/18] net: dsa: mv88e6352: Add support for hardware bridging
Date: Sat, 21 Mar 2015 08:46:46 -0700
Message-ID: <1426952815-4642-10-git-send-email-linux@roeck-us.net>
References: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:40301 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748AbbCUPrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 11:47:49 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YZLcq-0001aD-Bm
	for netdev@vger.kernel.org; Sat, 21 Mar 2015 15:47:48 +0000
In-Reply-To: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6352.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index f7e7c0f..51acd16 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -708,6 +708,9 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
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
