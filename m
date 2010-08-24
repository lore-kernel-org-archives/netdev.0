From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH] caif-driver: add HAS_DMA dependency
Date: Tue, 24 Aug 2010 17:14:27 +0200
Message-ID: <20100824151427.GC2160@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heiko Carstens <heiko.carstens@de.ibm.com>

Fix this error on an s390 allyesconfig build:

linux-2.6/drivers/net/caif/caif_spi.c:98:
    undefined reference to `dma_free_coherent'

Cc: Sjur Braendeland <sjur.brandeland@stericsson.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 drivers/net/caif/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/caif/Kconfig
+++ b/drivers/net/caif/Kconfig
@@ -15,7 +15,7 @@ config CAIF_TTY
 
 config CAIF_SPI_SLAVE
 	tristate "CAIF SPI transport driver for slave interface"
-	depends on CAIF
+	depends on CAIF && HAS_DMA
 	default n
 	---help---
 	The CAIF Link layer SPI Protocol driver for Slave SPI interface.
