From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] virtio_net: remove forgotten assignment
Date: Mon, 1 Mar 2010 12:22:55 +0100
Message-ID: <20100301112254.GB2799@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39879 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750729Ab0CALW6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Mar 2010 06:22:58 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is no longer needed. I missed to remove this in
567ec874d15b478c8eda7e9a5d2dcb05f13f1fb5

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/virtio_net.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index e6095f3..25dc77c 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -775,7 +775,6 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	mac_data = (void *)&mac_data->macs[uc_count][0];
 
 	mac_data->entries = mc_count;
-	addr = dev->mc_list;
 	i = 0;
 	netdev_for_each_mc_addr(addr, dev)
 		memcpy(&mac_data->macs[i++][0], addr->da_addr, ETH_ALEN);
-- 
1.6.6

