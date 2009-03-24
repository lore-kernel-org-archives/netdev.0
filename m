From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/41: remove unneeded goto
Date: Tue, 24 Mar 2009 15:03:09 +0100 (MET)
Message-ID: <20090324140305.31401.99275.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit fecea3a389c89de9afae2eda74fad894d5677229
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Feb 18 16:29:08 2009 +0100

    netfilter: remove unneeded goto
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index a90ac83..5bb3473 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -174,7 +174,6 @@ next_hook:
 			     outdev, &elem, okfn, hook_thresh);
 	if (verdict == NF_ACCEPT || verdict == NF_STOP) {
 		ret = 1;
-		goto unlock;
 	} else if (verdict == NF_DROP) {
 		kfree_skb(skb);
 		ret = -EPERM;
@@ -183,7 +182,6 @@ next_hook:
 			      verdict >> NF_VERDICT_BITS))
 			goto next_hook;
 	}
-unlock:
 	rcu_read_unlock();
 	return ret;
 }
