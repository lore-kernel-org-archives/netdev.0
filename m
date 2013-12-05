From: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: [PATCH 2/7] net: of_mdio: use PHY_MAX_ADDR constant
Date: Thu, 5 Dec 2013 14:52:11 -0800
Message-ID: <1386283936-26104-3-git-send-email-florian@openwrt.org>
References: <1386283936-26104-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <abrodkin-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
	<rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1386283936-26104-1-git-send-email-florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Use the PHY_MAX_ADDR constant for checking if a MDIO bus address is
valid instead of using a plain "32".

Signed-off-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/of/of_mdio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 82485d2..f93ebca 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -107,7 +107,7 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
 		}
 
 		addr = be32_to_cpup(paddr);
-		if (addr >= 32) {
+		if (addr >= PHY_MAX_ADDR) {
 			dev_err(&mdio->dev, "%s PHY address %i is too large\n",
 				child->full_name, addr);
 			continue;
-- 
1.8.3.2

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
