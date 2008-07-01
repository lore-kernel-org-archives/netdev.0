From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] netlink: Unneeded local variable
Date: Tue, 01 Jul 2008 17:24:05 +0800
Message-ID: <4869F7B5.3080309@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59057 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756205AbYGAJ2h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2008 05:28:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already have a variable, which has the same capability.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 9b97f80..349aba1 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -886,7 +886,7 @@ retry:
 		return netlink_unicast_kernel(sk, skb);
 
 	if (sk_filter(sk, skb)) {
-		int err = skb->len;
+		err = skb->len;
 		kfree_skb(skb);
 		sock_put(sk);
 		return err;


