From: Joe Perches <joe@perches.com>
Subject: [PATCH 05/11] esp.h: Remove extern from function prototypes
Date: Fri, 20 Sep 2013 11:23:22 -0700
Message-ID: <8a4f63b62ceebd21866d23ee959be7e6e571b736.1379701322.git.joe@perches.com>
References: <597c1b62607f823af60dc4a99d59373dddfb7837.1379701322.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <597c1b62607f823af60dc4a99d59373dddfb7837.1379701322.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/esp.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/esp.h b/include/net/esp.h
index d584513..1356dda 100644
--- a/include/net/esp.h
+++ b/include/net/esp.h
@@ -13,7 +13,7 @@ struct esp_data {
 	struct crypto_aead *aead;
 };
 
-extern void *pskb_put(struct sk_buff *skb, struct sk_buff *tail, int len);
+void *pskb_put(struct sk_buff *skb, struct sk_buff *tail, int len);
 
 struct ip_esp_hdr;
 
-- 
1.8.1.2.459.gbcd45b4.dirty
