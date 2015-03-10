From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 2/3] net: dsa: mv6171: Add defines for switch product IDs
Date: Tue, 10 Mar 2015 23:05:58 +0100
Message-ID: <1426025160-13992-3-git-send-email-andrew@lunn.ch>
References: <1426025160-13992-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57223 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752129AbbCJWJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 18:09:34 -0400
In-Reply-To: <1426025160-13992-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the code more readable by using defines for the switch IDs.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6171.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 339484a99bd7..4fa0614e8ff3 100644
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
2.1.4
