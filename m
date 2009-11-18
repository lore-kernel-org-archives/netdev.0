From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 8/16] drivers/net/smsc9420.c: remove exceptional & on function
 name
Date: Wed, 18 Nov 2009 19:23:17 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0911181923010.20943@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Steve Glendinning <steve.glendinning@smsc.com>,
	netdev@vger.kernel.org, arnd@arndb.de, joe@perches.com,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932289AbZKRSXT@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

In this file, function names are otherwise used as pointers without &.

A simplified version of the semantic patch that makes this change is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@r@
identifier f;
@@

f(...) { ... }

@@
identifier r.f;
@@

- &f
+ f
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/smsc9420.c              |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index b4909a2..92e2bbe 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -1161,7 +1161,7 @@ static int smsc9420_mii_probe(struct net_device *dev)
 		phydev->phy_id);
 
 	phydev = phy_connect(dev, dev_name(&phydev->dev),
-		&smsc9420_phy_adjust_link, 0, PHY_INTERFACE_MODE_MII);
+		smsc9420_phy_adjust_link, 0, PHY_INTERFACE_MODE_MII);
 
 	if (IS_ERR(phydev)) {
 		pr_err("%s: Could not attach to PHY\n", dev->name);
