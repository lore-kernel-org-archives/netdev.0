From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v1 net-next 2/7] dsa: mv88e6xxx: Rename probe function to fit the normal pattern
Date: Tue, 10 May 2016 23:27:20 +0200
Message-ID: <1462915645-24674-3-git-send-email-andrew@lunn.ch>
References: <1462915645-24674-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34996 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751913AbcEJV3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 17:29:16 -0400
In-Reply-To: <1462915645-24674-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All other DSA drivers use _drv_ in there DSA probe function name, thus
allowing for a true linux driver probe function to use the
conventional name. Make mv88e6xxx fit this pattern.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index b2d27bfd53c2..199a8628df2b 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3529,9 +3529,9 @@ mv88e6xxx_lookup_info(unsigned int prod_num, const struct mv88e6xxx_info *table,
 	return NULL;
 }
 
-static const char *mv88e6xxx_probe(struct device *dsa_dev,
-				   struct device *host_dev, int sw_addr,
-				   void **priv)
+static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
+				       struct device *host_dev, int sw_addr,
+				       void **priv)
 {
 	const struct mv88e6xxx_info *info;
 	struct mv88e6xxx_priv_state *ps;
@@ -3576,7 +3576,7 @@ static const char *mv88e6xxx_probe(struct device *dsa_dev,
 
 struct dsa_switch_driver mv88e6xxx_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
-	.probe			= mv88e6xxx_probe,
+	.probe			= mv88e6xxx_drv_probe,
 	.setup			= mv88e6xxx_setup,
 	.set_addr		= mv88e6xxx_set_addr,
 	.phy_read		= mv88e6xxx_phy_read,
-- 
2.8.1
