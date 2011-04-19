From: kaber@trash.net
Subject: [PATCH 2/3] IPVS: combine consecutive #ifdef CONFIG_PROC_FS blocks
Date: Tue, 19 Apr 2011 16:31:31 +0200
Message-ID: <1303223492-13549-3-git-send-email-kaber@trash.net>
References: <1303223492-13549-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1303223492-13549-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 33733c8..36f4495 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1984,9 +1984,6 @@ static const struct file_operations ip_vs_info_fops = {
 	.release = seq_release_private,
 };
 
-#endif
-
-#ifdef CONFIG_PROC_FS
 static int ip_vs_stats_show(struct seq_file *seq, void *v)
 {
 	struct net *net = seq_file_single_net(seq);
-- 
1.7.4.4

