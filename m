From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 04/11] dsa: skb_put_zero() used to optimize code
Date: Wed, 14 Jun 2017 22:40:40 +0800
Message-ID: <1497451240-4182-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-18.163.com ([220.181.12.18]:38512 "EHLO m12-18.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751836AbdFNOlI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 10:41:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 net/dsa/tag_trailer.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index 172f131..b09e562 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -43,8 +43,7 @@ static struct sk_buff *trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 	kfree_skb(skb);
 
 	if (padlen) {
-		u8 *pad = skb_put(nskb, padlen);
-		memset(pad, 0, padlen);
+		skb_put_zero(nskb, padlen);
 	}
 
 	trailer = skb_put(nskb, 4);
-- 
2.7.4
