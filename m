From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH 1/1] dma-mapping: mark DMA_nBITS_MASK as deprecated fix
Date: Sun, 10 May 2009 09:04:26 +0200
Message-ID: <1241939066-10178-1-git-send-email-jirislaby@gmail.com>
References: <20090510085618D.fujita.tomonori@lab.ntt.co.jp>
Cc: yanghy@cn.fujitsu.com, akpm@linux-foundation.org,
	fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.wellnetcz.com ([212.24.148.102]:36945 "EHLO
	smtp.wellnetcz.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297AbZEJHF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2009 03:05:58 -0400
In-Reply-To: <20090510085618D.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew, please fold into
dma-mapping: mark DMA_nBITS_MASK as deprecated
--

As Fujita correctly demurs, use more meaningful typedef name, so that we
now see:
warning: DMA_nnBIT_MASK is deprecated
instead of
warning: DMA_DEPRECATED is deprecated

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Cc: Yang Hongyang <yanghy@cn.fujitsu.com>
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: Ingo Molnar <mingo@elte.hu>
---
 include/linux/dma-mapping.h |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 6bf3339..38f5608 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -63,7 +63,7 @@ struct dma_map_ops {
 
 #define DMA_BIT_MASK(n)	(((n) == 64) ? ~0ULL : ((1ULL<<(n))-1))
 
-typedef u64 DMA_DEPRECATED __deprecated;
+typedef u64 DMA_nnBIT_MASK __deprecated;
 
 /*
  * NOTE: do not use the below macros in new code and do not add new definitions
@@ -71,18 +71,18 @@ typedef u64 DMA_DEPRECATED __deprecated;
  *
  * Instead, just open-code DMA_BIT_MASK(n) within your driver
  */
-#define DMA_64BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(64)
-#define DMA_48BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(48)
-#define DMA_47BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(47)
-#define DMA_40BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(40)
-#define DMA_39BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(39)
-#define DMA_35BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(35)
-#define DMA_32BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(32)
-#define DMA_31BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(31)
-#define DMA_30BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(30)
-#define DMA_29BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(29)
-#define DMA_28BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(28)
-#define DMA_24BIT_MASK	(DMA_DEPRECATED)DMA_BIT_MASK(24)
+#define DMA_64BIT_MASK	(DMA_nnBIT_MASK)DMA_BIT_MASK(64)
+#define DMA_48BIT_MASK	(DMA_nnBIT_MASK)DMA_BIT_MASK(48)
+#define DMA_47BIT_MASK	(DMA_nnBIT_MASK)DMA_BIT_MASK(47)
+#define DMA_40BIT_MASK	(DMA_nnBIT_MASK)DMA_BIT_MASK(40)
+#define DMA_39BIT_MASK	(DMA_nnBIT_MASK)DMA_BIT_MASK(39)
+#define DMA_35BIT_MASK	(DMA_nnBIT_MASK)DMA_BIT_MASK(35)
+#define DMA_32BIT_MASK	(DMA_nnBIT_MASK)DMA_BIT_MASK(32)
+#define DMA_31BIT_MASK	(DMA_nnBIT_MASK)DMA_BIT_MASK(31)
+#define DMA_30BIT_MASK	(DMA_nnBIT_MASK)DMA_BIT_MASK(30)
+#define DMA_29BIT_MASK	(DMA_nnBIT_MASK)DMA_BIT_MASK(29)
+#define DMA_28BIT_MASK	(DMA_nnBIT_MASK)DMA_BIT_MASK(28)
+#define DMA_24BIT_MASK	(DMA_nnBIT_MASK)DMA_BIT_MASK(24)
 
 #define DMA_MASK_NONE	0x0ULL
 
-- 
1.6.2.4

