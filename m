From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6] vlan: Use vlan_dev_real_dev in
 vlan_hwaccel_do_receive
Date: Tue, 31 Aug 2010 16:58:18 +0200
Message-ID: <20100831145817.GB2795@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3799 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932281Ab0HaO6V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 10:58:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[patch net-next-2.6] vlan: Use vlan_dev_real_dev in vlan_hwaccel_do_receive

Use helper as in other places.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 net/8021q/vlan_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 3438c01..889f4ac 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -40,7 +40,7 @@ void vlan_hwaccel_do_receive(struct sk_buff *skb)
 	struct net_device *dev = skb->dev;
 	struct vlan_rx_stats     *rx_stats;
 
-	skb->dev = vlan_dev_info(dev)->real_dev;
+	skb->dev = vlan_dev_real_dev(dev);
 	netif_nit_deliver(skb);
 
 	skb->dev = dev;
-- 
1.7.2.1

