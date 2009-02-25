From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] decnet: remove some pointless conditionals before kfree_skb()
Date: Wed, 25 Feb 2009 18:39:01 +0800
Message-ID: <49A51FC5.9000600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org
To: Christine Caulfield <christine.caulfield@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54672 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752211AbZBYKjd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 05:39:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some pointless conditionals before kfree_skb().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/decnet/af_decnet.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 12bf7d4..963da86 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -2071,8 +2071,7 @@ static int dn_sendmsg(struct kiocb *iocb, struct socket *sock,
 	}
 out:
 
-	if (skb)
-		kfree_skb(skb);
+	kfree_skb(skb);
 
 	release_sock(sk);
 
-- 
1.5.3.8




