From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] pc300 - get rid of MOD_INC/MOD_DEC
Date: Mon, 24 Nov 2003 15:51:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031124155100.17b7a4ca.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Remove old style mod inc/dec from this WAN driver.

diff -Nru a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
--- a/drivers/net/wan/pc300_drv.c	Mon Nov 24 15:36:51 2003
+++ b/drivers/net/wan/pc300_drv.c	Mon Nov 24 15:36:51 2003
@@ -3165,7 +3165,6 @@
 		return result;
 	}
 
-	MOD_INC_USE_COUNT;
 	sprintf(ifr.ifr_name, "%s", dev->name);
 	cpc_opench(d);
 	netif_start_queue(dev);
@@ -3201,7 +3200,6 @@
 	}
 #endif
 
-	MOD_DEC_USE_COUNT;
 	return 0;
 }
 
