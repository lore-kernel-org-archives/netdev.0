From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next] xfrm: Make function xfrm_dev_register static
Date: Thu, 18 May 2017 15:51:38 +0000
Message-ID: <20170518155138.19962-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33747 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933310AbdERPv4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 11:51:56 -0400
Received: by mail-pg0-f65.google.com with SMTP id s62so6447375pgc.0
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 08:51:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fixes the following sparse warning:

net/xfrm/xfrm_device.c:141:5: warning:
 symbol 'xfrm_dev_register' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
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
