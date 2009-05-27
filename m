From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/6]: cpmac: Remove references to BUS_ID_SIZE, use
 MII_BUS_ID_SIZE.
Date: Tue, 26 May 2009 21:39:54 -0700 (PDT)
Message-ID: <20090526.213954.197705917.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kay.sievers@vrfy.org, greg@kroah.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48671
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752543AbZE0Ejz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 00:39:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/cpmac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index af305c0..cfb4198 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -202,7 +202,7 @@ struct cpmac_priv {
 	void __iomem *regs;
 	struct mii_bus *mii_bus;
 	struct phy_device *phy;
-	char phy_name[BUS_ID_SIZE];
+	char phy_name[MII_BUS_ID_SIZE + 3];
 	int oldlink, oldspeed, oldduplex;
 	u32 msg_enable;
 	struct net_device *dev;
-- 
1.6.3

