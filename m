From: adobriyan@gmail.com
Subject: [PATCH 30/38] netns ct: H323 conntracking in netns
Date: Fri, 22 Aug 2008 02:08:49 +0400
Message-ID: <20080821220849.GD31136@x200.localdomain>
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

 net/netfilter/nf_conntrack_h323_main.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -1218,7 +1218,7 @@ static struct nf_conntrack_expect *find_expect(struct nf_conn *ct,
 	tuple.dst.u.tcp.port = port;
 	tuple.dst.protonum = IPPROTO_TCP;
 
-	exp = __nf_ct_expect_find(&init_net, &tuple);
+	exp = __nf_ct_expect_find(nf_ct_net(ct), &tuple);
 	if (exp && exp->master == ct)
 		return exp;
 	return NULL;
-- 
1.5.6.3


