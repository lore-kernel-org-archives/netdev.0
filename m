From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (11/25) sk98: correct return value from change mtu
Date: Mon, 15 Nov 2004 15:30:35 -0800
Message-ID: <20041115153035.4026f076@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <demon@pro-linux.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Get rid of bogus comment in change mtu function and return
the correct status.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-15 13:29:11 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-15 13:29:11 -08:00
@@ -2791,20 +2791,7 @@
 	SkEventDispatcher(pAC, pAC->IoBase);
 	spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
 	
-	/*
-	** While testing this driver with latest kernel 2.5 (2.5.70), it 
-	** seems as if upper layers have a problem to handle a successful
-	** return value of '0'. If such a zero is returned, the complete 
-	** system hangs for several minutes (!), which is in acceptable.
-	**
-	** Currently it is not clear, what the exact reason for this problem
-	** is. The implemented workaround for 2.5 is to return the desired 
-	** new MTU size if all needed changes for the new MTU size where 
-	** performed. In kernels 2.2 and 2.4, a zero value is returned,
-	** which indicates the successful change of the mtu-size.
-	*/
-	return NewMtu;
-
+	return 0;
 } /* SkGeChangeMtu */
 
 
