From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH] netfilter: logging copyrights is useless
Date: Wed, 15 Mar 2017 14:17:39 +0100
Message-ID: <20170315131739.16285-1-clabbe.montjoie@gmail.com>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: pablo@netfilter.org, kadlec@blackhole.kfki.hu, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Logging copyrights does not add any useful information in logs.
This patch remove such logging

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 net/ipv4/netfilter/arp_tables.c | 1 -
 net/ipv4/netfilter/ip_tables.c  | 1 -
 net/ipv6/netfilter/ip6_tables.c | 1 -
 net/netfilter/nf_tables_api.c   | 1 -
 net/netfilter/nft_compat.c      | 2 --
 5 files changed, 6 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index f17dab1..a89211f 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -1647,7 +1647,6 @@ static int __init arp_tables_init(void)
 	if (ret < 0)
 		goto err4;
 
-	pr_info("arp_tables: (C) 2002 David S. Miller\n");
 	return 0;
 
 err4:
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 384b857..27a4fea 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1933,7 +1933,6 @@ static int __init ip_tables_init(void)
 	if (ret < 0)
 		goto err5;
 
-	pr_info("(C) 2000-2006 Netfilter Core Team\n");
 	return 0;
 
 err5:
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 1e15c54..979acef 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1955,7 +1955,6 @@ static int __init ip6_tables_init(void)
 	if (ret < 0)
 		goto err5;
 
-	pr_info("(C) 2000-2006 Netfilter Core Team\n");
 	return 0;
 
 err5:
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 4559f5d..f53d46e 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -5608,7 +5608,6 @@ static int __init nf_tables_module_init(void)
 	if (err < 0)
 		goto err3;
 
-	pr_info("nf_tables: (c) 2007-2009 Patrick McHardy <kaber@trash.net>\n");
 	return register_pernet_subsys(&nf_tables_net_ops);
 err3:
 	nf_tables_core_module_exit();
diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index fab6bf3..841c5ae 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -810,8 +810,6 @@ static int __init nft_compat_module_init(void)
 		goto err_target;
 	}
 
-	pr_info("nf_tables_compat: (c) 2012 Pablo Neira Ayuso <pablo@netfilter.org>\n");
-
 	return ret;
 
 err_target:
-- 
2.10.2
