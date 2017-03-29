From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH] net: ipv6: Removed unnecessary parenthesis
Date: Wed, 29 Mar 2017 15:47:46 +0530
Message-ID: <20170329101746.GA30647@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: outreachy-kernel@googlegroups.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removed parentheses on the right hand side of assignment, as they are
not required. The following coccinelle script was used to fix this
issue:

@@
local idexpression id;
expression e;
@@

id =
-(
e
-)

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index fdde76e8a16a..34dfdc2fb2bc 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -387,9 +387,9 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct sk_buff *prev,  struct net_devic
 		return false;
 
 	/* Unfragmented part is taken from the first segment. */
-	payload_len = ((head->data - skb_network_header(head)) -
+	payload_len = (head->data - skb_network_header(head)) -
 		       sizeof(struct ipv6hdr) + fq->q.len -
-		       sizeof(struct frag_hdr));
+		       sizeof(struct frag_hdr);
 	if (payload_len > IPV6_MAXPLEN) {
 		net_dbg_ratelimited("nf_ct_frag6_reasm: payload len = %d\n",
 				    payload_len);
-- 
2.11.0
