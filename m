From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 1/3] net: Fix indentation in dev_hard_start_xmit()
Date: Fri, 10 Jan 2014 22:16:30 +0000
Message-ID: <1389392190.2025.124.camel@bwh-desktop.uk.level5networks.com>
References: <1389392139.2025.123.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:23254 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbaAJWQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 17:16:33 -0500
In-Reply-To: <1389392139.2025.123.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/core/dev.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index daa153738b40..41bb08f1ec99 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2596,8 +2596,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			dev_queue_xmit_nit(skb, dev);
 
 		skb_len = skb->len;
-			rc = ops->ndo_start_xmit(skb, dev);
-
+		rc = ops->ndo_start_xmit(skb, dev);
 		trace_net_dev_xmit(skb, rc, dev, skb_len);
 		if (rc == NETDEV_TX_OK)
 			txq_trans_update(txq);


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
