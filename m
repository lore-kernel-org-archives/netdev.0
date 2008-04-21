From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] unexport security_sock_rcv_skb
Date: Mon, 21 Apr 2008 11:48:10 +0300
Message-ID: <20080421084810.GM26897@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:41009 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756616AbYDUIsj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 04:48:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the no longer used export of security_sock_rcv_skb.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
91bb216975ccfd8244625aa816e63802d51b56bd diff --git a/security/security.c b/security/security.c
index 2e250c7..3983324 100644
--- a/security/security.c
+++ b/security/security.c
@@ -990,7 +990,6 @@ int security_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	return security_ops->socket_sock_rcv_skb(sk, skb);
 }
-EXPORT_SYMBOL(security_sock_rcv_skb);
 
 int security_socket_getpeersec_stream(struct socket *sock, char __user *optval,
 				      int __user *optlen, unsigned len)

