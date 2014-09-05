From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH] rose: use %*ph specifier
Date: Fri,  5 Sep 2014 18:01:51 +0300
Message-ID: <1409929311-3225-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: "David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of dereference each byte let's use %*ph specifier in the printk()
calls.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 net/rose/rose_link.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rose/rose_link.c b/net/rose/rose_link.c
index bc55142..ce60771 100644
--- a/net/rose/rose_link.c
+++ b/net/rose/rose_link.c
@@ -160,7 +160,7 @@ void rose_link_rx_restart(struct sk_buff *skb, struct rose_neigh *neigh, unsigne
 		break;
 
 	case ROSE_DIAGNOSTIC:
-		printk(KERN_WARNING "ROSE: received diagnostic #%d - %02X %02X %02X\n", skb->data[3], skb->data[4], skb->data[5], skb->data[6]);
+		pr_warn("ROSE: received diagnostic #%d - %4ph\n", skb->data + 3);
 		break;
 
 	default:
-- 
2.1.0

