From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Subject: [PATCH 1/3] Add (struct sock*) sk parameter for send_ack()
Date: Tue, 05 Aug 2008 17:22:38 +0800
Message-ID: <48981BDE.70201@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761007AbYHEJ0d@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add (struct sock*) sk parameter for send_ack.

Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
---
 include/net/request_sock.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 8d6e991..cac811e 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -33,7 +33,7 @@ struct request_sock_ops {
 	struct kmem_cache	*slab;
 	int		(*rtx_syn_ack)(struct sock *sk,
 				       struct request_sock *req);
-	void		(*send_ack)(struct sk_buff *skb,
+	void		(*send_ack)(struct sock *sk, struct sk_buff *skb,
 				    struct request_sock *req);
 	void		(*send_reset)(struct sock *sk,
 				      struct sk_buff *skb);
-- 
1.5.3
