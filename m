From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 07/14] net: constify sk_gfp_atomic() sock argument
Date: Tue, 29 Sep 2015 07:42:45 -0700
Message-ID: <1443537772-15305-8-git-send-email-edumazet@google.com>
References: <1443537772-15305-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35185 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756618AbbI2Onx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 10:43:53 -0400
Received: by pacfv12 with SMTP id fv12so8448439pac.2
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 07:43:52 -0700 (PDT)
In-Reply-To: <1443537772-15305-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 94dff7f566f5..dfe2eb8e1132 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -759,7 +759,7 @@ static inline int sk_memalloc_socks(void)
 
 #endif
 
-static inline gfp_t sk_gfp_atomic(struct sock *sk, gfp_t gfp_mask)
+static inline gfp_t sk_gfp_atomic(const struct sock *sk, gfp_t gfp_mask)
 {
 	return GFP_ATOMIC | (sk->sk_allocation & __GFP_MEMALLOC);
 }
-- 
2.6.0.rc2.230.g3dd15c0
