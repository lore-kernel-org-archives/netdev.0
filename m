From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (10/25) sk98: remove more unused device private fields
Date: Mon, 15 Nov 2004 15:27:19 -0800
Message-ID: <20041115152719.225cf0b4@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <demon@pro-linux.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Get rid of more elements in the per-board structure that are never used.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/h/skdrv2nd.h b/drivers/net/sk98lin/h/skdrv2nd.h
--- a/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-15 11:31:35 -08:00
+++ b/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-15 11:31:35 -08:00
@@ -368,8 +368,6 @@
 	SK_TIMER        ModTimer; /* just some timer */
 };
 
-typedef struct s_PerStrm	PER_STRM;
-
 #define SK_ALLOC_IRQ	0x00000001
 
 #ifdef SK_DIAG_SUPPORT
@@ -414,16 +412,6 @@
 	int		Index;		/* internal board index number */
 
 	/* adapter RAM sizes for queues of active port */
-	int		RxQueueSize;	/* memory used for receive queue */
-	int		TxSQueueSize;	/* memory used for sync. tx queue */
-	int		TxAQueueSize;	/* memory used for async. tx queue */
-
-	int		PromiscCount;	/* promiscuous mode counter  */
-	int		AllMultiCount;  /* allmulticast mode counter */
-	int		MulticCount;	/* number of different MC    */
-					/*  addresses for this board */
-					/*  (may be more than HW can)*/
-
 	int		HWRevision;	/* Hardware revision */
 	int		ActivePort;	/* the active XMAC port */
 	int		MaxPorts;		/* number of activated ports */
@@ -446,7 +434,6 @@
 	DIM_INFO        DynIrqModInfo;  /* all data related to DIM */
 
 	/* Only for tests */
-	int		PortUp;
 	int		PortDown;
 	int		ChipsetType;	/*  Chipset family type 
 					 *  0 == Genesis family support
