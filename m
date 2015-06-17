From: Zhaowei Yuan <zhaowei.yuan@samsung.com>
Subject: [PATCH] net: Update out-of-date comment
Date: Wed, 17 Jun 2015 17:56:27 +0800
Message-ID: <1434534987-17513-1-git-send-email-zhaowei.yuan@samsung.com>
Cc: zhaowei.yuan.cn@gmail.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Struct inet_proto no longer exists, so update the
comment which is out of date.

Signed-off-by: Zhaowei Yuan <zhaowei.yuan@samsung.com>
---
 include/net/sock.h |    1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 3a4898e..356fd91 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -924,7 +924,6 @@ static inline void sk_prot_clear_nulls(struct sock *sk, int size)

 /* Networking protocol blocks we attach to sockets.
  * socket layer -> transport layer interface
- * transport -> network interface is defined by struct inet_proto
  */
 struct proto {
 	void			(*close)(struct sock *sk,
--
1.7.9.5
