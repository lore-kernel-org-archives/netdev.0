From: Michel Machado <michel@digirati.com.br>
Subject: [PATCH 1/1] net-next: export skb_splice_bits()
Date: Thu, 23 May 2013 13:09:34 -0400
Message-ID: <1369328974.3123.77.camel@Thor>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

skb_splice_bits() is already available in include/linux/skbuff.h, but
without EXPORT_SYMBOL it can't be used by kernel modules.

Signed-off-by: Michel Machado <michel@digirati.com.br>
CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Pravin B Shelar <pshelar@nicira.com>
---
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index af9185d..0976908 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1854,6 +1854,7 @@ done:
 
 	return ret;
 }
+EXPORT_SYMBOL(skb_splice_bits);
 
 /**
  *	skb_store_bits - store bits from kernel buffer to skb
