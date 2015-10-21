From: kbuild test robot <lkp@intel.com>
Subject: [RFC PATCH] arcnet: com20020: com20020_netdev_open() can be static
Date: Thu, 22 Oct 2015 01:18:53 +0800
Message-ID: <20151021171853.GA82900@lkp-ib04.intel.com>
References: <201510220121.IavQe5iv%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, davem@davemloft.net, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: Michael Grzeschik <m.grzeschik@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:47425 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754016AbbJURQM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2015 13:16:12 -0400
Content-Disposition: inline
In-Reply-To: <1445442332-10625-3-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 com20020.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index 436951b..13d9ad4 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -164,7 +164,7 @@ static int com20020_set_hwaddr(struct net_device *dev, void *addr)
 	return 0;
 }
 
-int com20020_netdev_open(struct net_device *dev)
+static int com20020_netdev_open(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
 	struct arcnet_local *lp = netdev_priv(dev);
@@ -175,7 +175,7 @@ int com20020_netdev_open(struct net_device *dev)
 	return arcnet_open(dev);
 }
 
-int com20020_netdev_close(struct net_device *dev)
+static int com20020_netdev_close(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
 	struct arcnet_local *lp = netdev_priv(dev);
