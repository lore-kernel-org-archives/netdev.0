From: Benjamin LaHaise <bcrl@kvack.org>
Subject: remove excess initializer
Date: Thu, 27 Jan 2005 10:28:23 -0500
Message-ID: <20050127152823.GA6420@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

The patch below removes some useless code bloat that is left over from 
who knows when.

		-ben
-- 
"Time is what keeps everything from happening all at once." -- John Wheeler


diff -purN linux-2.6.11-rc2/net/socket.c linux-2.6.11-rc2.bcrl/net/socket.c
--- linux-2.6.11-rc2/net/socket.c	2005-01-24 10:19:24.000000000 -0500
+++ linux-2.6.11-rc2.bcrl/net/socket.c	2005-01-27 10:25:18.296037875 -0500
@@ -2029,13 +2029,6 @@ void __init sock_init(void)
 	int i;
 
 	/*
-	 *	Initialize all address (protocol) families. 
-	 */
-	 
-	for (i = 0; i < NPROTO; i++) 
-		net_families[i] = NULL;
-
-	/*
 	 *	Initialize sock SLAB cache.
 	 */
 	 
