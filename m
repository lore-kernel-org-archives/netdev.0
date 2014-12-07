From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 14/20] chelsio: fix misspelling of current function in string
Date: Sun,  7 Dec 2014 20:20:56 +0100
Message-ID: <1417980062-25151-15-git-send-email-Julia.Lawall@lip6.fr>
References: <1417980062-25151-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux@rasmusvillemoes.dk,
	joe@perches.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417980062-25151-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace a misspelled function name by %s and then __func__.

This was done using Coccinelle, including the use of Levenshtein distance,
as proposed by Rasmus Villemoes.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
The semantic patch is difficult to summarize, but is available in the cover
letter of this patch series.

 drivers/net/ethernet/chelsio/cxgb/sge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethernet/chelsio/cxgb/sge.c
index 4c58793..86222a1 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -301,7 +301,7 @@ unsigned int t1_sched_update_parms(struct sge *sge, unsigned int port,
 	struct sched_port *p = &s->p[port];
 	unsigned int max_avail_segs;
 
-	pr_debug("t1_sched_update_params mtu=%d speed=%d\n", mtu, speed);
+	pr_debug("%s mtu=%d speed=%d\n", __func__, mtu, speed);
 	if (speed)
 		p->speed = speed;
 	if (mtu)
