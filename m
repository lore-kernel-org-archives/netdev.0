From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch] 2.6.1-bk1-netdev2 - Realtek 8169 braindamaged
Date: Mon, 12 Jan 2004 23:12:04 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040112231204.B5983@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

  please apply.



$@!#&%{ bug in the r8169 driver.


 drivers/net/r8169.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/r8169.c~r8169-dma-api-rx-buffers-argl drivers/net/r8169.c
--- linux-2.6.1-bk1-netdev2/drivers/net/r8169.c~r8169-dma-api-rx-buffers-argl	2004-01-12 23:01:59.000000000 +0100
+++ linux-2.6.1-bk1-netdev2-fr/drivers/net/r8169.c	2004-01-12 23:01:59.000000000 +0100
@@ -1408,7 +1408,7 @@ rtl8169_rx_interrupt(struct net_device *
 	assert(tp != NULL);
 	assert(ioaddr != NULL);
 
-	cur_rx = tp->cur_rx % RX_BUF_SIZE;
+	cur_rx = tp->cur_rx % NUM_RX_DESC;
 
 	while (!(le32_to_cpu(tp->RxDescArray[cur_rx].status) & OWNbit)) {
 		u32 status = le32_to_cpu(tp->RxDescArray[cur_rx].status);

_
