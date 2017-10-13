From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 3/4] net: dsa: dsa_loop: remove .set_addr
Date: Thu, 12 Oct 2017 21:41:12 -0400
Message-ID: <20171013014113.29561-4-vivien.didelot@savoirfairelinux.com>
References: <20171013014113.29561-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171013014113.29561-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The .set_addr function does nothing, remove the dsa_loop implementation
before getting rid of it completely in DSA.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/dsa_loop.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/dsa/dsa_loop.c b/drivers/net/dsa/dsa_loop.c
index d55051abf4ed..3a3f4f7ba364 100644
--- a/drivers/net/dsa/dsa_loop.c
+++ b/drivers/net/dsa/dsa_loop.c
@@ -110,13 +110,6 @@ static void dsa_loop_get_ethtool_stats(struct dsa_switch *ds, int port,
 		data[i] = ps->ports[port].mib[i].val;
 }
 
-static int dsa_loop_set_addr(struct dsa_switch *ds, u8 *addr)
-{
-	dev_dbg(ds->dev, "%s\n", __func__);
-
-	return 0;
-}
-
 static int dsa_loop_phy_read(struct dsa_switch *ds, int port, int regnum)
 {
 	struct dsa_loop_priv *ps = ds->priv;
@@ -263,7 +256,6 @@ static const struct dsa_switch_ops dsa_loop_driver = {
 	.get_strings		= dsa_loop_get_strings,
 	.get_ethtool_stats	= dsa_loop_get_ethtool_stats,
 	.get_sset_count		= dsa_loop_get_sset_count,
-	.set_addr		= dsa_loop_set_addr,
 	.phy_read		= dsa_loop_phy_read,
 	.phy_write		= dsa_loop_phy_write,
 	.port_bridge_join	= dsa_loop_port_bridge_join,
-- 
2.14.2
