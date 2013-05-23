From: Michel Machado <michel@digirati.com.br>
Subject: [PATCH 1/1] net-next: export dma_skb_copy_datagram_iovec()
Date: Thu, 23 May 2013 13:23:38 -0400
Message-ID: <1369329818.3123.83.camel@Thor>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dma_skb_copy_datagram_iovec() is already available in include/net/netdma.h, but
without EXPORT_SYMBOL it can't be used by kernel modules.

Signed-off-by: Michel Machado <michel@digirati.com.br>
CC: "David S. Miller" <davem@davemloft.net>
---
diff --git a/net/core/user_dma.c b/net/core/user_dma.c
index 1b5fefd..653f516 100644
--- a/net/core/user_dma.c
+++ b/net/core/user_dma.c
@@ -129,3 +129,4 @@ end:
 fault:
 	return -EFAULT;
 }
+EXPORT_SYMBOL(dma_skb_copy_datagram_iovec);
