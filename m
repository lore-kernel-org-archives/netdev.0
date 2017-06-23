From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/6] xfrm: Make function xfrm_dev_register static
Date: Fri, 23 Jun 2017 10:38:26 +0200
Message-ID: <1498207110-22520-3-git-send-email-steffen.klassert@secunet.com>
References: <1498207110-22520-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:51116 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753457AbdFWIih (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Jun 2017 04:38:37 -0400
In-Reply-To: <1498207110-22520-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fixes the following sparse warning:

net/xfrm/xfrm_device.c:141:5: warning:
 symbol 'xfrm_dev_register' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_device.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_device.c b/net/xfrm/xfrm_device.c
index 8ec8a3f..50ec733 100644
--- a/net/xfrm/xfrm_device.c
+++ b/net/xfrm/xfrm_device.c
@@ -138,7 +138,7 @@ bool xfrm_dev_offload_ok(struct sk_buff *skb, struct xfrm_state *x)
 }
 EXPORT_SYMBOL_GPL(xfrm_dev_offload_ok);
 
-int xfrm_dev_register(struct net_device *dev)
+static int xfrm_dev_register(struct net_device *dev)
 {
 	if ((dev->features & NETIF_F_HW_ESP) && !dev->xfrmdev_ops)
 		return NOTIFY_BAD;
-- 
2.7.4
