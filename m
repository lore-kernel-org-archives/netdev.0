From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/core/pktgen.c: make a function static
Date: Tue, 15 Mar 2005 15:49:07 +0100
Message-ID: <20050315144907.GN3189@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
To: Robert Olsson <robert.olsson@its.uu.se>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

pktgen_xmit is already inline but not static.

This doesn't make much sense - especially since there's no external user 
of this function.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.11-mm3-full/net/core/pktgen.c.old	2005-03-15 13:25:04.000000000 +0100
+++ linux-2.6.11-mm3-full/net/core/pktgen.c	2005-03-15 13:25:20.000000000 +0100
@@ -2587,7 +2587,7 @@
         thread_unlock();
 }
 
-__inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
+static inline void pktgen_xmit(struct pktgen_dev *pkt_dev)
 {
 	struct net_device *odev = NULL;
 	__u64 idle_start = 0;
