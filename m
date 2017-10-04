From: Tim Hansen <devtimhansen@gmail.com>
Subject: [PATCH] net/ipv4: Remove unused variable in route.c
Date: Wed, 4 Oct 2017 15:59:49 -0400
Message-ID: <20171004195949.GA39492@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        alexander.levin@one.verizon.com, devtimhansen@gmail.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

int rc is unmodified after initalization in net/ipv4/route.c, this patch simply cleans up that variable and returns 0.

This was found with coccicheck M=net/ipv4/ on linus' tree.

Signed-off-by: Tim Hansen <devtimhansen@gmail.com>
---
 net/ipv4/route.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 94d4cd2..02b6be9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3032,7 +3032,6 @@ struct ip_rt_acct __percpu *ip_rt_acct __read_mostly;
 
 int __init ip_rt_init(void)
 {
-	int rc = 0;
 	int cpu;
 
 	ip_idents = kmalloc(IP_IDENTS_SZ * sizeof(*ip_idents), GFP_KERNEL);
@@ -3089,7 +3088,7 @@ int __init ip_rt_init(void)
 #endif
 	register_pernet_subsys(&rt_genid_ops);
 	register_pernet_subsys(&ipv4_inetpeer_ops);
-	return rc;
+	return 0;
 }
 
 #ifdef CONFIG_SYSCTL
-- 
2.1.4
