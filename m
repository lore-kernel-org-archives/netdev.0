From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/ipv4/inetpeer.c: make a struct static
Date: Tue, 15 Mar 2005 15:44:08 +0100
Message-ID: <20050315144408.GL3189@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch makes a needlessly global struct static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.11-mm3-full/net/ipv4/inetpeer.c.old	2005-03-15 13:29:32.000000000 +0100
+++ linux-2.6.11-mm3-full/net/ipv4/inetpeer.c	2005-03-15 13:30:13.000000000 +0100
@@ -92,9 +92,9 @@
 int inet_peer_minttl = 120 * HZ;	/* TTL under high load: 120 sec */
 int inet_peer_maxttl = 10 * 60 * HZ;	/* usual time to live: 10 min */
 
+static struct inet_peer *inet_peer_unused_head;
 /* Exported for inet_putpeer inline function.  */
-struct inet_peer *inet_peer_unused_head,
-		**inet_peer_unused_tailp = &inet_peer_unused_head;
+struct inet_peer **inet_peer_unused_tailp = &inet_peer_unused_head;
 DEFINE_SPINLOCK(inet_peer_unused_lock);
 #define PEER_MAX_CLEANUP_WORK 30
 
