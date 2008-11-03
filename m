From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH 2/4] nets: clean up net/ipv4/pararp.c
Date: Mon, 3 Nov 2008 18:41:46 +0800
Message-ID: <20081103104146.GC19058@ubuntu>
References: <20081102074446.GA12140@ubuntu> <490DEAD3.3030202@cosmosbay.com> <20081103082002.GG14553@ubuntu> <20081103.002808.142907024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:60785 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754995AbYKCKlh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 05:41:37 -0500
Content-Disposition: inline
In-Reply-To: <20081103.002808.142907024.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[PATCH 2/4] nets: clean up net/ipv4/pararp.c

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
---
 net/ipv4/arp.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 051a62f..957c87d 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -506,7 +506,7 @@ int arp_bind_neighbour(struct dst_entry *dst)
 	if (dev == NULL)
 		return -EINVAL;
 	if (n == NULL) {
-		__be32 nexthop = ((struct rtable*)dst)->rt_gateway;
+		__be32 nexthop = ((struct rtable *)dst)->rt_gateway;
 		if (dev->flags&(IFF_LOOPBACK|IFF_POINTOPOINT))
 			nexthop = 0;
 		n = __neigh_lookup_errno(
@@ -640,14 +640,14 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 	arp_ptr=(unsigned char *)(arp+1);
 
 	memcpy(arp_ptr, src_hw, dev->addr_len);
-	arp_ptr+=dev->addr_len;
-	memcpy(arp_ptr, &src_ip,4);
-	arp_ptr+=4;
+	arp_ptr += dev->addr_len;
+	memcpy(arp_ptr, &src_ip, 4);
+	arp_ptr += 4;
 	if (target_hw != NULL)
 		memcpy(arp_ptr, target_hw, dev->addr_len);
 	else
 		memset(arp_ptr, 0, dev->addr_len);
-	arp_ptr+=dev->addr_len;
+	arp_ptr += dev->addr_len;
 	memcpy(arp_ptr, &dest_ip, 4);
 
 	return skb;
@@ -823,9 +823,9 @@ static int arp_process(struct sk_buff *skb)
 				int dont_send = 0;
 
 				if (!dont_send)
-					dont_send |= arp_ignore(in_dev,sip,tip);
+					dont_send |= arp_ignore(in_dev, sip, tip);
 				if (!dont_send && IN_DEV_ARPFILTER(in_dev))
-					dont_send |= arp_filter(sip,tip,dev);
+					dont_send |= arp_filter(sip, tip, dev);
 				if (!dont_send)
 					arp_send(ARPOP_REPLY,ETH_P_ARP,sip,dev,tip,sha,dev->dev_addr,sha);
 
-- 
1.5.6.3

