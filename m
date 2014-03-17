From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/38] netfilter: nfnetlink_log: remove unused code
Date: Mon, 17 Mar 2014 13:42:28 +0100
Message-ID: <1395060178-11833-9-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c |    8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index a155d19..d292c8d 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -28,8 +28,6 @@
 #include <linux/proc_fs.h>
 #include <linux/security.h>
 #include <linux/list.h>
-#include <linux/jhash.h>
-#include <linux/random.h>
 #include <linux/slab.h>
 #include <net/sock.h>
 #include <net/netfilter/nf_log.h>
@@ -75,7 +73,6 @@ struct nfulnl_instance {
 };
 
 #define INSTANCE_BUCKETS	16
-static unsigned int hash_init;
 
 static int nfnl_log_net_id __read_mostly;
 
@@ -1067,11 +1064,6 @@ static int __init nfnetlink_log_init(void)
 {
 	int status = -ENOMEM;
 
-	/* it's not really all that important to have a random value, so
-	 * we can do this from the init function, even if there hasn't
-	 * been that much entropy yet */
-	get_random_bytes(&hash_init, sizeof(hash_init));
-
 	netlink_register_notifier(&nfulnl_rtnl_notifier);
 	status = nfnetlink_subsys_register(&nfulnl_subsys);
 	if (status < 0) {
-- 
1.7.10.4

