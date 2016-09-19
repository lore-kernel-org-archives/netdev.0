From: John Crispin <john@phrozen.org>
Subject: [PATCH 3/4] net-next: dsa: b53: remove empty set_addr() stub
Date: Mon, 19 Sep 2016 15:28:02 +0200
Message-ID: <1474291683-44167-4-git-send-email-john@phrozen.org>
References: <1474291683-44167-1-git-send-email-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474291683-44167-1-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The set_addr() callback is now optional. Remove the empty stub that b53
has.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/dsa/b53/b53_common.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 0afc2e5..1a492c0 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -764,11 +764,6 @@ static int b53_get_sset_count(struct dsa_switch *ds)
 	return b53_get_mib_size(dev);
 }
 
-static int b53_set_addr(struct dsa_switch *ds, u8 *addr)
-{
-	return 0;
-}
-
 static int b53_setup(struct dsa_switch *ds)
 {
 	struct b53_device *dev = ds->priv;
@@ -1466,7 +1461,6 @@ static enum dsa_tag_protocol b53_get_tag_protocol(struct dsa_switch *ds)
 static struct dsa_switch_ops b53_switch_ops = {
 	.get_tag_protocol	= b53_get_tag_protocol,
 	.setup			= b53_setup,
-	.set_addr		= b53_set_addr,
 	.get_strings		= b53_get_strings,
 	.get_ethtool_stats	= b53_get_ethtool_stats,
 	.get_sset_count		= b53_get_sset_count,
-- 
1.7.10.4
