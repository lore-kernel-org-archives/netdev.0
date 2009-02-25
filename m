From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] can: remove some pointless conditionals before kfree_skb()
Date: Wed, 25 Feb 2009 18:35:44 +0800
Message-ID: <49A51F00.9090401@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49753 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1760678AbZBYKgQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 05:36:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some pointless conditionals before kfree_skb().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/can/af_can.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/can/af_can.c b/net/can/af_can.c
index d90e8dd..547bafc 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -273,8 +273,7 @@ int can_send(struct sk_buff *skb, int loop)
 		err = net_xmit_errno(err);
 
 	if (err) {
-		if (newskb)
-			kfree_skb(newskb);
+		kfree_skb(newskb);
 		return err;
 	}
 
-- 
1.5.3.8




