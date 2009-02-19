From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH 02/12]Replace all DMA_48BIT_MASK micro with DMA_BIT_MASK(48)
Date: Thu, 19 Feb 2009 14:40:14 +0800
Message-ID: <499CFECE.9040500@cn.fujitsu.com>
References: <499CFDC8.1070600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Borislav Petkov <petkovbb@googlemail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59639 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752572AbZBSGir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 01:38:47 -0500
In-Reply-To: <499CFDC8.1070600@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace all DMA_48BIT_MASK micro with DMA_BIT_MASK(48)

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

---
 drivers/net/dl2k.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index c749e9f..4a1b554 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -714,7 +714,7 @@ rio_interrupt (int irq, void *dev_instance)
 
 static inline dma_addr_t desc_to_dma(struct netdev_desc *desc)
 {
-	return le64_to_cpu(desc->fraginfo) & DMA_48BIT_MASK;
+	return le64_to_cpu(desc->fraginfo) & DMA_BIT_MASK(48);
 }
 
 static void
-- 
1.6.0.3


-- 
Regards
Yang Hongyang
