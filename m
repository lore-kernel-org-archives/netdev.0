From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] packet: remove some pointless conditionals before kfree_skb()
Date: Wed, 25 Feb 2009 18:36:42 +0800
Message-ID: <49A51F3A.3010907@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52478 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753328AbZBYKhO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 05:37:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some pointless conditionals before kfree_skb().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/packet/af_packet.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 1fc4a78..d8cc006 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -756,8 +756,7 @@ ring_is_full:
 	spin_unlock(&sk->sk_receive_queue.lock);
 
 	sk->sk_data_ready(sk, 0);
-	if (copy_skb)
-		kfree_skb(copy_skb);
+	kfree_skb(copy_skb);
 	goto drop_n_restore;
 }
 
-- 
1.5.3.8




