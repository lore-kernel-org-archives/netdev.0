From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/2) wan/hostess_sv11 -- get rid of mod inc/dec
Date: Tue, 25 Nov 2003 11:43:39 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031125114339.36372791.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The explicit inc/dec are no longer needed in 2.6.  
Jeff, please add to net-drivers-2.5-exp

diff -Nru a/drivers/net/wan/hostess_sv11.c b/drivers/net/wan/hostess_sv11.c
--- a/drivers/net/wan/hostess_sv11.c	Mon Nov 24 15:37:26 2003
+++ b/drivers/net/wan/hostess_sv11.c	Mon Nov 24 15:37:26 2003
@@ -122,7 +122,6 @@
 	 */
 
 	netif_start_queue(d);
-	MOD_INC_USE_COUNT;
 	return 0;
 }
 
@@ -154,7 +153,6 @@
 			z8530_sync_txdma_close(d, &sv11->sync.chanA);
 			break;
 	}
-	MOD_DEC_USE_COUNT;
 	return 0;
 }
 
