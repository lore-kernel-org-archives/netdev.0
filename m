From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 14/16] net: dsa: mv88e6171: Add defines for switch product IDs
Date: Thu, 26 Mar 2015 18:36:41 -0700
Message-ID: <1427420203-27685-15-git-send-email-linux@roeck-us.net>
References: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:39415 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753570AbbC0BhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 21:37:25 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YbJD8-0020pq-OT
	for netdev@vger.kernel.org; Fri, 27 Mar 2015 01:37:23 +0000
In-Reply-To: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>

Make the code more readable by using defines for the switch IDs.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Guenter Roeck <linux@roeck-us.net>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6171.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 6ce6a3ea1b8d..54ebfed1b938 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -17,6 +17,10 @@
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
+/* Switch product IDs */
+#define ID_6171	0x1710
+#define ID_6172	0x1720
+
 static char *mv88e6171_probe(struct device *host_dev, int sw_addr)
 {
 	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
@@ -27,9 +31,9 @@ static char *mv88e6171_probe(struct device *host_dev, int sw_addr)
 
 	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), 0x03);
 	if (ret >= 0) {
-		if ((ret & 0xfff0) == 0x1710)
+		if ((ret & 0xfff0) == ID_6171)
 			return "Marvell 88E6171";
-		if ((ret & 0xfff0) == 0x1720)
+		if ((ret & 0xfff0) == ID_6172)
 			return "Marvell 88E6172";
 	}
 
-- 
2.1.0
