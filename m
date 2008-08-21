From: adobriyan@gmail.com
Subject: [PATCH 29/38] netns ct: SIP conntracking in netns
Date: Fri, 22 Aug 2008 02:08:31 +0400
Message-ID: <20080821220831.GC31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/netfilter/nf_conntrack_sip.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -775,7 +775,7 @@ static int set_expected_rtp_rtcp(struct sk_buff *skb,
 
 	rcu_read_lock();
 	do {
-		exp = __nf_ct_expect_find(&init_net, &tuple);
+		exp = __nf_ct_expect_find(nf_ct_net(ct), &tuple);
 
 		if (!exp || exp->master == ct ||
 		    nfct_help(exp->master)->helper != nfct_help(ct)->helper ||
-- 
1.5.6.3


