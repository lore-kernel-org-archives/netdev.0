From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 5/5 v2] netfilter: Fix format string of nfnetlink_log proc file
Date: Thu,  9 Apr 2015 23:57:17 +0200
Message-ID: <1428616637-21690-5-git-send-email-richard@nod.at>
References: <1428616637-21690-1-git-send-email-richard@nod.at>
Cc: linux-wireless@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	sameo@linux.intel.com, aloisio.almeida@openbossa.org,
	lauro.venancio@openbossa.org, davem@davemloft.net,
	kadlec@blackhole.kfki.hu, kaber@trash.net, pablo@netfilter.org,
	Richard Weinberger <richard@nod.at>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428616637-21690-1-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The printed values are all of type unsigned integer, therefore use
%u instead of %d. Otherwise an user can face negative values.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 net/netfilter/nfnetlink_log.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 7150d11..313c26c 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -998,7 +998,7 @@ static int seq_show(struct seq_file *s, void *v)
 {
 	const struct nfulnl_instance *inst = v;
 
-	return seq_printf(s, "%5d %6d %5d %1d %5d %6d %2d\n",
+	return seq_printf(s, "%5u %6u %5u %1u %5u %6u %2u\n",
 			  inst->group_num,
 			  inst->peer_portid, inst->qlen,
 			  inst->copy_mode, inst->copy_range,
-- 
1.8.4.5
