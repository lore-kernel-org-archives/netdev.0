From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH 11/12]Remove defines of DMA_XXBIT_MASK micro
Date: Thu, 19 Feb 2009 14:54:25 +0800
Message-ID: <499D0221.9090407@cn.fujitsu.com>
References: <499CFDC8.1070600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Borislav Petkov <petkovbb@googlemail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54346 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751659AbZBSGw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 01:52:58 -0500
In-Reply-To: <499CFDC8.1070600@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove defines of DMA_XXBIT_MASK micro

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

---
 include/linux/dma-mapping.h |   20 +-------------------
 1 files changed, 1 insertions(+), 19 deletions(-)

diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index f238c7e..70f9c63 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -13,27 +13,9 @@ enum dma_data_direction {
 	DMA_NONE = 3,
 };
 
+/*use DMA_BIT_MASK(n) within your driver instead of DMA_xxBIT_MASK*/
 #define DMA_BIT_MASK(n)	(((n) == 64) ? ~0ULL : ((1ULL<<(n))-1))
 
-/*
- * NOTE: do not use the below macros in new code and do not add new definitions
- * here.
- *
- * Instead, just open-code DMA_BIT_MASK(n) within your driver
- */
-#define DMA_64BIT_MASK	DMA_BIT_MASK(64)
-#define DMA_48BIT_MASK	DMA_BIT_MASK(48)
-#define DMA_47BIT_MASK	DMA_BIT_MASK(47)
-#define DMA_40BIT_MASK	DMA_BIT_MASK(40)
-#define DMA_39BIT_MASK	DMA_BIT_MASK(39)
-#define DMA_35BIT_MASK	DMA_BIT_MASK(35)
-#define DMA_32BIT_MASK	DMA_BIT_MASK(32)
-#define DMA_31BIT_MASK	DMA_BIT_MASK(31)
-#define DMA_30BIT_MASK	DMA_BIT_MASK(30)
-#define DMA_29BIT_MASK	DMA_BIT_MASK(29)
-#define DMA_28BIT_MASK	DMA_BIT_MASK(28)
-#define DMA_24BIT_MASK	DMA_BIT_MASK(24)
-
 #define DMA_MASK_NONE	0x0ULL
 
 static inline int valid_dma_direction(int dma_direction)
-- 
1.6.0.3

-- 
Regards
Yang Hongyang
