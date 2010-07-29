From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] net: ks8842 depends on DMA_ENGINE
Date: Thu, 29 Jul 2010 10:14:27 -0700
Message-ID: <20100729101427.2aafd6e7.randy.dunlap@oracle.com>
References: <20100729143211.9e7edaed.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100729143211.9e7edaed.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

ks8842 uses dma channel functions, so it should depend on DMA_ENGINE.

ERROR: "__dma_request_channel" [drivers/net/ks8842.ko] undefined!
ERROR: "dma_release_channel" [drivers/net/ks8842.ko] undefined!

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next-20100729.orig/drivers/net/Kconfig
+++ linux-next-20100729/drivers/net/Kconfig
@@ -1751,7 +1751,7 @@ config TLAN
 
 config KS8842
 	tristate "Micrel KSZ8841/42 with generic bus interface"
-	depends on HAS_IOMEM
+	depends on HAS_IOMEM && DMA_ENGINE
 	help
 	 This platform driver is for KSZ8841(1-port) / KS8842(2-port)
 	 ethernet switch chip (managed, VLAN, QoS) from Micrel or
