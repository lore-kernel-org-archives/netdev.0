From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] irda: remove some pointless conditionals before kfree_skb()
Date: Wed, 25 Feb 2009 18:14:27 +0800
Message-ID: <49A51A03.1010201@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63656 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754952AbZBYKO7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 05:14:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some pointless conditionals before kfree_skb().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 drivers/net/irda/sir_dev.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/irda/sir_dev.c b/drivers/net/irda/sir_dev.c
index c23d211..803c0be 100644
--- a/drivers/net/irda/sir_dev.c
+++ b/drivers/net/irda/sir_dev.c
@@ -780,8 +780,7 @@ static int sirdev_alloc_buffers(struct sir_dev *dev)
 
 static void sirdev_free_buffers(struct sir_dev *dev)
 {
-	if (dev->rx_buff.skb)
-		kfree_skb(dev->rx_buff.skb);
+	kfree_skb(dev->rx_buff.skb);
 	kfree(dev->tx_buff.head);
 	dev->rx_buff.head = dev->tx_buff.head = NULL;
 	dev->rx_buff.skb = NULL;
-- 
1.5.3.8




