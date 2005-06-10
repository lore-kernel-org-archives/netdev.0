From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.12-rc6] 3c59x: remove superfluous vortex_debug test from boomerang_start_xmit
Date: Fri, 10 Jun 2005 10:27:02 -0400
Message-ID: <20050610142702.GC10449@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261570AbVFJO1S@vger.kernel.org>
To: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the superfluous test of "if (vortex_debug > 3)" inside the
"if (vortex_debug > 6)" clause early in boomerang_start_xmit.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
I stumbled across this while looking at something else...

 drivers/net/3c59x.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -2202,9 +2202,8 @@ boomerang_start_xmit(struct sk_buff *skb
 
 	if (vortex_debug > 6) {
 		printk(KERN_DEBUG "boomerang_start_xmit()\n");
-		if (vortex_debug > 3)
-			printk(KERN_DEBUG "%s: Trying to send a packet, Tx index %d.\n",
-				   dev->name, vp->cur_tx);
+		printk(KERN_DEBUG "%s: Trying to send a packet, Tx index %d.\n",
+			   dev->name, vp->cur_tx);
 	}
 
 	if (vp->cur_tx - vp->dirty_tx >= TX_RING_SIZE) {
-- 
John W. Linville
linville@tuxdriver.com
