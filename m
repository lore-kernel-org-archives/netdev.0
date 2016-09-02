From: Paul Burton <paul.burton@imgtec.com>
Subject: [PATCH] net: lantiq_etop: Remove unused 'i' variable
Date: Fri, 2 Sep 2016 15:26:54 +0100
Message-ID: <20160902142654.4195-1-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Burton <paul.burton@imgtec.com>,
        <linux-kernel@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>,
        Florian Westphal <fw@strlen.de>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit e7f4dc3536a4 ("mdio: Move allocation of interrupts into core")
removed the only use of the 'i' variable from ltq_etop_mdio_init() but
left the variable declaration behind, leading to the following compiler
warning:

  drivers/net/ethernet/lantiq_etop.c: In function 'ltq_etop_mdio_init':
  drivers/net/ethernet/lantiq_etop.c:414:6: warning: unused variable 'i' [-Wunused-variable]
    int i;
        ^

Fix this by removing the declaration of the 'i' variable.

Signed-off-by: Paul Burton <paul.burton@imgtec.com>

---

 drivers/net/ethernet/lantiq_etop.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index dc82b1b..0d2f8e9 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -411,7 +411,6 @@ static int
 ltq_etop_mdio_init(struct net_device *dev)
 {
 	struct ltq_etop_priv *priv = netdev_priv(dev);
-	int i;
 	int err;
 
 	priv->mii_bus = mdiobus_alloc();
-- 
2.9.3
