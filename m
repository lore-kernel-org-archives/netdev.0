From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] ax25_route.c: remove an unused function
Date: Fri, 29 Oct 2004 02:20:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029002045.GO29142@stusta.de>
References: <20041028230032.GU3207@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams@vger.kernel.org, davem@davemloft.net, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ralf@linux-mips.org
Content-Disposition: inline
In-Reply-To: <20041028230032.GU3207@stusta.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[ this time without the problems due to a digital signature... ]

The patch below removes an unused function from net/ax25/ax25_route.c


diffstat output:
 net/ax25/ax25_route.c |   16 ----------------
 1 files changed, 16 deletions(-)


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.10-rc1-mm1-full/net/ax25/ax25_route.c.old	2004-10-28 23:50:25.000000000 +0200
+++ linux-2.6.10-rc1-mm1-full/net/ax25/ax25_route.c	2004-10-28 23:50:41.000000000 +0200
@@ -41,22 +41,6 @@
 
 static ax25_route *ax25_get_route(ax25_address *, struct net_device *);
 
-/*
- * small macro to drop non-digipeated digipeaters and reverse path
- */
-static inline void ax25_route_invert(ax25_digi *in, ax25_digi *out)
-{
-	int k;
-
-	for (k = 0; k < in->ndigi; k++)
-		if (!in->repeated[k])
-			break;
-
-	in->ndigi = k;
-
-	ax25_digi_invert(in, out);
-}
-
 void ax25_rt_device_down(struct net_device *dev)
 {
 	ax25_route *s, *t, *ax25_rt;
