From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 3/3] net: dsa: mv88e6171: Add support for reading switch registers
Date: Sat, 15 Nov 2014 22:24:53 +0100
Message-ID: <1416086694-15790-4-git-send-email-andrew@lunn.ch>
References: <1416086694-15790-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, linux@roeck-us.net,
	Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:32994 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754604AbaKOVZW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2014 16:25:22 -0500
In-Reply-To: <1416086694-15790-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The infrastructure can now report switch registers to ethtool.
Add support for it to the mv88e6171 driver.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6171.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index ed4c79778823..aa33d16f2e22 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -423,6 +423,8 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 #ifdef CONFIG_NET_DSA_HWMON
 	.get_temp               = mv88e6xxx_get_temp,
 #endif
+	.get_regs_len		= mv88e6xxx_get_regs_len,
+	.get_regs		= mv88e6xxx_get_regs,
 };
 
 MODULE_ALIAS("platform:mv88e6171");
-- 
2.1.3
