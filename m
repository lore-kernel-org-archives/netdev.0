From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH trivial] ndisc: fix a typo in a comment in ndisc_recv_na()
Date: Wed,  7 Nov 2012 16:05:38 +0100
Message-ID: <1352300738-3851-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:54579 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314Ab2KGOyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 09:54:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ndisc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index ae0cf81..a2e50dc 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -906,7 +906,7 @@ static void ndisc_recv_na(struct sk_buff *skb)
 		if (lladdr && !memcmp(lladdr, dev->dev_addr, dev->addr_len) &&
 		    net->ipv6.devconf_all->forwarding && net->ipv6.devconf_all->proxy_ndp &&
 		    pneigh_lookup(&nd_tbl, net, &msg->target, dev, 0)) {
-			/* XXX: idev->cnf.prixy_ndp */
+			/* XXX: idev->cnf.proxy_ndp */
 			goto out;
 		}
 
-- 
1.7.12
