From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/53] netfilter: ipvs: Replace kzalloc with kcalloc.
Date: Mon,  1 May 2017 12:46:29 +0200
Message-ID: <1493635640-24325-3-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Varsha Rao <rvarsha016@gmail.com>

Replace kzalloc with kcalloc. As kcalloc is preferred for allocating an
array instead of kzalloc. This patch fixes the checkpatch issue.

Signed-off-by: Varsha Rao <rvarsha016@gmail.com>
---
 net/netfilter/ipvs/ip_vs_sync.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index b03c28084f81..30d6b2cc00a0 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1849,7 +1849,7 @@ int start_sync_thread(struct netns_ipvs *ipvs, struct ipvs_sync_daemon_cfg *c,
 	if (state == IP_VS_STATE_MASTER) {
 		struct ipvs_master_sync_state *ms;
 
-		ipvs->ms = kzalloc(count * sizeof(ipvs->ms[0]), GFP_KERNEL);
+		ipvs->ms = kcalloc(count, sizeof(ipvs->ms[0]), GFP_KERNEL);
 		if (!ipvs->ms)
 			goto out;
 		ms = ipvs->ms;
@@ -1862,7 +1862,7 @@ int start_sync_thread(struct netns_ipvs *ipvs, struct ipvs_sync_daemon_cfg *c,
 			ms->ipvs = ipvs;
 		}
 	} else {
-		array = kzalloc(count * sizeof(struct task_struct *),
+		array = kcalloc(count, sizeof(struct task_struct *),
 				GFP_KERNEL);
 		if (!array)
 			goto out;
-- 
2.1.4

