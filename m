From: Richard Stearn <richard@rns-stearn.demon.co.uk>
Subject: [PATCH 5/6]NET:AX25:ROSE Adds the log priority to a printk
Date: Sat, 16 Jul 2016 10:45:59 +0100
Message-ID: <201607160945.u6G9jxXE015213@ux4.g1sog>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: [PATCH 5/6]NET:AX25:ROSE Adds the log priority to a printk
Adds the log priority to a printk.

Signed-off-by: Richard Stearn <richard@rns-stearn.demon.co.uk>
---
 net/rose/rose_route.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rose/rose_route.c b/net/rose/rose_route.c
index 56e53d5..9f256ed 100644
--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -903,7 +903,7 @@ int rose_route_frame(struct sk_buff *skb, ax25_cb *ax25)
 	}
 
 	if (rose_neigh == NULL) {
-		printk("rose_route : unknown neighbour or device %s\n",
+		printk(KERN_ERR "rose_route_frame: unknown neighbour or device %s\n",
 		       ax2asc(buf, &ax25->dest_addr));
 		goto out;
 	}
