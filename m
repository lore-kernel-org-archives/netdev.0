From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] depca: remove forgotten needless inicialization
Date: Thu, 18 Feb 2010 09:55:07 +0100
Message-ID: <20100218085506.GB2772@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38841 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753282Ab0BRIzK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2010 03:55:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/depca.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index 64a569b..744c192 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -1272,7 +1272,7 @@ static void set_multicast_list(struct net_device *dev)
 static void SetMulticastFilter(struct net_device *dev)
 {
 	struct depca_private *lp = netdev_priv(dev);
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 	char *addrs;
 	int i, j, bit, byte;
 	u16 hashcode;
-- 
1.6.6

