From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 15/44] xtensa: remove DMA_ERROR_CODE
Date: Thu,  8 Jun 2017 15:25:40 +0200
Message-ID: <20170608132609.32662-16-hch@lst.de>
References: <20170608132609.32662-1-hch@lst.de>
Cc: linux-kernel@vger.kernel.org
To: x86@kernel.org, linux-arm-kernel@lists.infradead.org,
        xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org,
        linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-mips@linux-mips.org, openrisc@lists.librecores.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org,
        linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org,
        linux-samsung-soc@vger.kernel.org,
        iommu@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:52417 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751776AbdFHN1X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 09:27:23 -0400
In-Reply-To: <20170608132609.32662-1-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xtensa already implements the mapping_error method for its only
dma_map_ops instance.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/xtensa/include/asm/dma-mapping.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/arch/xtensa/include/asm/dma-mapping.h b/arch/xtensa/include/asm/dma-mapping.h
index c6140fa8c0be..269738dc9d1d 100644
--- a/arch/xtensa/include/asm/dma-mapping.h
+++ b/arch/xtensa/include/asm/dma-mapping.h
@@ -16,8 +16,6 @@
 #include <linux/mm.h>
 #include <linux/scatterlist.h>
 
-#define DMA_ERROR_CODE		(~(dma_addr_t)0x0)
-
 extern const struct dma_map_ops xtensa_dma_map_ops;
 
 static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
-- 
2.11.0
