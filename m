From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/6]: sh_eth: Remove references to BUS_ID_SIZE, use
 MII_BUS_ID_SIZE instead.
Date: Tue, 26 May 2009 21:39:56 -0700 (PDT)
Message-ID: <20090526.213956.258493163.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kay.sievers@vrfy.org, greg@kroah.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48675
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752462AbZE0Ej5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 00:39:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/sh_eth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index cdd73b9..0709b75 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -964,7 +964,7 @@ static void sh_eth_adjust_link(struct net_device *ndev)
 static int sh_eth_phy_init(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	char phy_id[BUS_ID_SIZE];
+	char phy_id[MII_BUS_ID_SIZE + 3];
 	struct phy_device *phydev = NULL;
 
 	snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
-- 
1.6.3

