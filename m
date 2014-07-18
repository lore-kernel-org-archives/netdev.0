From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/18] ipvs: Remove dead debug code
Date: Fri, 18 Jul 2014 13:01:12 +0200
Message-ID: <1405681272-4994-19-git-send-email-pablo@netfilter.org>
References: <1405681272-4994-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1405681272-4994-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yannick Brosseau <scientist@fb.com>

This code section cannot compile as it refer to non existing variable
It also pre-date git history.

Signed-off-by: Yannick Brosseau <scientist@fb.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |   86 ----------------------------------------
 1 file changed, 86 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c42e83d..335fdb8 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1807,92 +1807,6 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= proc_dointvec,
 	},
 #endif
-#if 0
-	{
-		.procname	= "timeout_established",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_ESTABLISHED],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_synsent",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_SYN_SENT],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_synrecv",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_SYN_RECV],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_finwait",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_FIN_WAIT],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_timewait",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_TIME_WAIT],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_close",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_CLOSE],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_closewait",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_CLOSE_WAIT],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_lastack",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_LAST_ACK],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_listen",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_LISTEN],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_synack",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_SYNACK],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_udp",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_UDP],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "timeout_icmp",
-		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_ICMP],
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-#endif
 	{ }
 };
 
-- 
1.7.10.4

