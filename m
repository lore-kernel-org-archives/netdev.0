From: akpm@linux-foundation.org
Subject: [patch 01/15] git-net: fix yam.c
Date: Thu, 26 Apr 2007 00:27:21 -0700
Message-ID: <200704260727.l3Q7RLxU023943@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:38345 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933408AbXDZH2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:28:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>

drivers/net/hamradio/yam.c: In function `yam_tx_byte':
drivers/net/hamradio/yam.c:643: warning: passing arg 1 of `skb_copy_from_linear_data_offset' from incompatible pointer type

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/hamradio/yam.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/hamradio/yam.c~git-net-fix-yamc drivers/net/hamradio/yam.c
--- a/drivers/net/hamradio/yam.c~git-net-fix-yamc
+++ a/drivers/net/hamradio/yam.c
@@ -638,7 +638,7 @@ static void yam_tx_byte(struct net_devic
         			dev_kfree_skb_any(skb);
 				break;
 			}
-			skb_copy_from_linear_data_offset(skb->data, 1,
+			skb_copy_from_linear_data_offset(skb, 1,
 							 yp->tx_buf,
 							 yp->tx_len);
 			dev_kfree_skb_any(skb);
_
