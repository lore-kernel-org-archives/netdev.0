From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH] cris: fix eth_v10.c build error
Date: Fri, 03 Aug 2012 17:38:07 -0700
Message-ID: <501C6EEF.3030100@xenotime.net>
References: <1344002771-21072-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Mikael Starvik <starvik@axis.com>,
	Jesper Nilsson <jesper.nilsson@axis.com>,
	linux-cris-kernel@axis.com, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344002771-21072-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Fix build error on cris (not tested, no toolchain here):

drivers/net/cris/eth_v10.c: error: too many arguments to function 'e100rxtx_interrupt'

Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
Cc:	Mikael Starvik <starvik@axis.com>
Cc:	Jesper Nilsson <jesper.nilsson@axis.com>
Cc:	linux-cris-kernel@axis.com
---
 drivers/net/cris/eth_v10.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- lnx-36-rc1.orig/drivers/net/cris/eth_v10.c
+++ lnx-36-rc1/drivers/net/cris/eth_v10.c
@@ -1712,7 +1712,7 @@ e100_set_network_leds(int active)
 static void
 e100_netpoll(struct net_device* netdev)
 {
-	e100rxtx_interrupt(NETWORK_DMA_TX_IRQ_NBR, netdev, NULL);
+	e100rxtx_interrupt(NETWORK_DMA_TX_IRQ_NBR, netdev);
 }
 #endif
 
