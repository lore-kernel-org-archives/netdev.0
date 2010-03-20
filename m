From: Dan Carpenter <error27@gmail.com>
Subject: [patch] bridge: cleanup: remove unused assignment
Date: Sat, 20 Mar 2010 14:20:49 +0300
Message-ID: <20100320112049.GU5331@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Michael Braun <michael-dev@fami-braun.de>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:46422 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305Ab0CTLVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 07:21:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We never actually use iph again so this assignment can be removed.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 6980625..9f0c4f0 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1003,8 +1003,6 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 	if (!pskb_may_pull(skb2, sizeof(*ih)))
 		goto out;
 
-	iph = ip_hdr(skb2);
-
 	switch (skb2->ip_summed) {
 	case CHECKSUM_COMPLETE:
 		if (!csum_fold(skb2->csum))
