From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 10/12] caif: CAIF_VIRTIO should depend on HAS_DMA
Date: Thu,  9 May 2013 23:04:52 +0200
Message-ID: <1368133494-22198-10-git-send-email-geert@linux-m68k.org>
References: <1368133494-22198-1-git-send-email-geert@linux-m68k.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from jacques.telenet-ops.be ([195.130.132.50]:34703 "EHLO
	jacques.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754014Ab3EIVFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 17:05:10 -0400
In-Reply-To: <1368133494-22198-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If NO_DMA=y:

drivers/built-in.o: In function `cfv_destroy_genpool':
drivers/net/caif/caif_virtio.c:364: undefined reference to `dma_free_coherent'
drivers/built-in.o: In function `cfv_create_genpool':
drivers/net/caif/caif_virtio.c:397: undefined reference to `dma_alloc_coherent'

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 drivers/net/caif/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/caif/Kconfig b/drivers/net/caif/Kconfig
index 7ffc756..5470980 100644
--- a/drivers/net/caif/Kconfig
+++ b/drivers/net/caif/Kconfig
@@ -43,7 +43,7 @@ config CAIF_HSI
 
 config CAIF_VIRTIO
 	tristate "CAIF virtio transport driver"
-	depends on CAIF
+	depends on CAIF && HAS_DMA
 	select VHOST_RING
 	select VIRTIO
 	select GENERIC_ALLOCATOR
-- 
1.7.0.4
