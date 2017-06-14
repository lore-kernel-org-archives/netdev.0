From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 06/11] openvswitch: skb_put_zero() used to optimize code
Date: Wed, 14 Jun 2017 22:47:01 +0800
Message-ID: <1497451621-4479-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:58002 "EHLO m12-13.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752315AbdFNOrk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 10:47:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 net/openvswitch/datapath.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 9ddc9f8..d772e9a 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -413,7 +413,7 @@ static void pad_packet(struct datapath *dp, struct sk_buff *skb)
 		size_t plen = NLA_ALIGN(skb->len) - skb->len;
 
 		if (plen > 0)
-			memset(skb_put(skb, plen), 0, plen);
+			skb_put_zero(skb, plen);
 	}
 }
 
-- 
2.7.4
