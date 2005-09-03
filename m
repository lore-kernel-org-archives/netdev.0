From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/netfilter/nfnetlink*: make functions static
Date: Sat, 3 Sep 2005 03:28:29 +0200
Message-ID: <20050903012829.GF3657@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751357AbVICB2k@vger.kernel.org>
To: coreteam@netfilter.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes needlessly global functions static.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 net/netfilter/nfnetlink.c       |    4 ++--
 net/netfilter/nfnetlink_queue.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

--- linux-2.6.13-mm1-full/net/netfilter/nfnetlink.c.old	2005-09-03 02:26:18.000000000 +0200
+++ linux-2.6.13-mm1-full/net/netfilter/nfnetlink.c	2005-09-03 02:27:21.000000000 +0200
@@ -344,14 +344,14 @@
 	} while(nfnl && nfnl->sk_receive_queue.qlen);
 }
 
-void __exit nfnetlink_exit(void)
+static void __exit nfnetlink_exit(void)
 {
 	printk("Removing netfilter NETLINK layer.\n");
 	sock_release(nfnl->sk_socket);
 	return;
 }
 
-int __init nfnetlink_init(void)
+static int __init nfnetlink_init(void)
 {
 	printk("Netfilter messages via NETLINK v%s.\n", nfversion);
 
--- linux-2.6.13-mm1-full/net/netfilter/nfnetlink_queue.c.old	2005-09-03 02:26:55.000000000 +0200
+++ linux-2.6.13-mm1-full/net/netfilter/nfnetlink_queue.c	2005-09-03 02:27:06.000000000 +0200
@@ -76,7 +76,7 @@
 
 static DEFINE_RWLOCK(instances_lock);
 
-u_int64_t htonll(u_int64_t in)
+static u_int64_t htonll(u_int64_t in)
 {
 	u_int64_t out;
 	int i;
