From: Joe Perches <joe@perches.com>
Subject: [PATCH 07/10] ti: Remove extern from function prototypes
Date: Tue, 24 Sep 2013 14:10:01 -0700
Message-ID: <95f7f1519d5b1ad7c51b3ac561a0903462202d36.1380056108.git.joe@perches.com>
References: <cover.1380056108.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1380056108.git.joe@perches.com>
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
 drivers/net/ethernet/ti/cpts.h | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
index fe993cd..1a581ef 100644
--- a/drivers/net/ethernet/ti/cpts.h
+++ b/drivers/net/ethernet/ti/cpts.h
@@ -127,8 +127,8 @@ struct cpts {
 };
 
 #ifdef CONFIG_TI_CPTS
-extern void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb);
-extern void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb);
+void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb);
+void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb);
 #else
 static inline void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb)
 {
@@ -138,8 +138,7 @@ static inline void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb)
 }
 #endif
 
-extern int cpts_register(struct device *dev, struct cpts *cpts,
-			 u32 mult, u32 shift);
-extern void cpts_unregister(struct cpts *cpts);
+int cpts_register(struct device *dev, struct cpts *cpts, u32 mult, u32 shift);
+void cpts_unregister(struct cpts *cpts);
 
 #endif
-- 
1.8.1.2.459.gbcd45b4.dirty
