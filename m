From: John Crispin <john@phrozen.org>
Subject: [PATCH 4/4] net-next: dsa: qca8k: remove empty set_addr() stub
Date: Mon, 19 Sep 2016 15:28:03 +0200
Message-ID: <1474291683-44167-5-git-send-email-john@phrozen.org>
References: <1474291683-44167-1-git-send-email-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:51011 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938692AbcISN2S (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 09:28:18 -0400
In-Reply-To: <1474291683-44167-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The set_addr() callback is now optional. Remove the empty stub that qca8k
has.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/dsa/qca8k.c |    8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index 7f3f178..4788a89 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -586,13 +586,6 @@ qca8k_setup(struct dsa_switch *ds)
 }
 
 static int
-qca8k_set_addr(struct dsa_switch *ds, u8 *addr)
-{
-	/* The subsystem always calls this function so add an empty stub */
-	return 0;
-}
-
-static int
 qca8k_phy_read(struct dsa_switch *ds, int phy, int regnum)
 {
 	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
@@ -921,7 +914,6 @@ qca8k_get_tag_protocol(struct dsa_switch *ds)
 static struct dsa_switch_ops qca8k_switch_ops = {
 	.get_tag_protocol	= qca8k_get_tag_protocol,
 	.setup			= qca8k_setup,
-	.set_addr		= qca8k_set_addr,
 	.get_strings		= qca8k_get_strings,
 	.phy_read		= qca8k_phy_read,
 	.phy_write		= qca8k_phy_write,
-- 
1.7.10.4
