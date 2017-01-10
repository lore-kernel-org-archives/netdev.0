From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/7] vxlan: remove unused variable
Date: Tue, 10 Jan 2017 10:18:11 -0800
Message-ID: <20170110181816.18991-3-sthemmin@microsoft.com>
References: <20170110181816.18991-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:32880 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939970AbdAJSS2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 13:18:28 -0500
Received: by mail-pf0-f171.google.com with SMTP id y143so29963503pfb.0
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 10:18:27 -0800 (PST)
In-Reply-To: <20170110181816.18991-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix drivers/net/vxlan.c: In function ‘neigh_reduce’:
warning: variable ‘saddr’ set but not used [-Wunused-but-set-variable]

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/vxlan.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index bb70dd5723b5..4147fd6a4837 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1553,7 +1553,7 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb)
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct nd_msg *msg;
 	const struct ipv6hdr *iphdr;
-	const struct in6_addr *saddr, *daddr;
+	const struct in6_addr *daddr;
 	struct neighbour *n;
 	struct inet6_dev *in6_dev;
 
@@ -1562,7 +1562,6 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb)
 		goto out;
 
 	iphdr = ipv6_hdr(skb);
-	saddr = &iphdr->saddr;
 	daddr = &iphdr->daddr;
 
 	msg = (struct nd_msg *)skb_transport_header(skb);
-- 
2.11.0
