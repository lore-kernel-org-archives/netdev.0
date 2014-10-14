From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] dsa: mv88e6171: Fix tag_protocol check
Date: Tue, 14 Oct 2014 11:21:04 -0700
Message-ID: <1413310864-16830-1-git-send-email-linux@roeck-us.net>
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tag_protocol is now an enum, so drivers have to check against it.

Cc: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6171.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 6365e30..1020a7a 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -206,7 +206,7 @@ static int mv88e6171_setup_port(struct dsa_switch *ds, int p)
 	 */
 	val = 0x0433;
 	if (dsa_is_cpu_port(ds, p)) {
-		if (ds->dst->tag_protocol == htons(ETH_P_EDSA))
+		if (ds->dst->tag_protocol == DSA_TAG_PROTO_EDSA)
 			val |= 0x3300;
 		else
 			val |= 0x0100;
-- 
1.9.1
