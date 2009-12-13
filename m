From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] can: CAN_MCP251X should depend on HAS_DMA
Date: Sun, 13 Dec 2009 20:11:06 +0100 (CET)
Message-ID: <alpine.DEB.2.00.0912132008100.21225@ayla.of.borg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Linux Kernel Development <linux-kernel@vger.kernel.org>
To: Christian Pellegrin <chripell@fsfe.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	"David S. Miller" <davem@davemloft.net>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkop
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753955AbZLMTLO@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When building for Sun 3:

drivers/net/can/mcp251x.c:1074: undefined reference to `dma_free_coherent'
drivers/net/can/mcp251x.c:976: undefined reference to `dma_alloc_coherent'
drivers/net/can/mcp251x.c:1050: undefined reference to `dma_free_coherent'

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/can/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index 8c485aa..05b7517 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -50,7 +50,7 @@ config CAN_TI_HECC
 
 config CAN_MCP251X
 	tristate "Microchip MCP251x SPI CAN controllers"
-	depends on CAN_DEV && SPI
+	depends on CAN_DEV && SPI && HAS_DMA
 	---help---
 	  Driver for the Microchip MCP251x SPI CAN controllers.
 
-- 
1.6.0.4

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
