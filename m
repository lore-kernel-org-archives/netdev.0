From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1] net/sched/cls_bpf.c: remove null test before kfree
Date: Fri, 20 Jun 2014 22:33:27 +0200
Message-ID: <1403296407-5877-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix checkpatch warning:
WARNING: kfree(NULL) is safe this check is probably not required

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/sched/cls_bpf.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 13f64df..715367a 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -212,8 +212,7 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 
 	if (fp_old)
 		sk_unattached_filter_destroy(fp_old);
-	if (bpf_old)
-		kfree(bpf_old);
+	kfree(bpf_old);
 
 	return 0;
 
-- 
1.8.4.5
