From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] ns83820: remove some pointless conditionals before kfree_skb()
Date: Wed, 25 Feb 2009 18:47:26 +0800
Message-ID: <49A521BE.4050301@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49576 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752211AbZBYKr6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 05:47:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some pointless conditionals before kfree_skb().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 drivers/net/ns83820.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index 9266502..221b0c4 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -822,8 +822,7 @@ static void ns83820_cleanup_rx(struct ns83820 *dev)
 		struct sk_buff *skb = dev->rx_info.skbs[i];
 		dev->rx_info.skbs[i] = NULL;
 		clear_rx_desc(dev, i);
-		if (skb)
-			kfree_skb(skb);
+		kfree_skb(skb);
 	}
 }
 
-- 
1.5.3.8




