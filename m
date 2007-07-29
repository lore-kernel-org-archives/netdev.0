From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] make nf_ct_ipv6_skip_exthdr() static
Date: Sun, 29 Jul 2007 16:58:46 +0200
Message-ID: <20070729145846.GZ16817@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	linux-kernel@vger.kernel.org
To: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

nf_ct_ipv6_skip_exthdr() can now become static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 include/net/netfilter/ipv6/nf_conntrack_ipv6.h |    3 ---
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    4 ++--
 2 files changed, 2 insertions(+), 5 deletions(-)

--- linux-2.6.23-rc1-mm1/include/net/netfilter/ipv6/nf_conntrack_ipv6.h.old	2007-07-26 20:17:47.000000000 +0200
+++ linux-2.6.23-rc1-mm1/include/net/netfilter/ipv6/nf_conntrack_ipv6.h	2007-07-26 20:17:53.000000000 +0200
@@ -7,9 +7,6 @@
 extern struct nf_conntrack_l4proto nf_conntrack_l4proto_udp6;
 extern struct nf_conntrack_l4proto nf_conntrack_l4proto_icmpv6;
 
-extern int nf_ct_ipv6_skip_exthdr(const struct sk_buff *skb, int start,
-				  u8 *nexthdrp, int len);
-
 extern int nf_ct_frag6_init(void);
 extern void nf_ct_frag6_cleanup(void);
 extern struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb);
--- linux-2.6.23-rc1-mm1/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c.old	2007-07-26 20:18:03.000000000 +0200
+++ linux-2.6.23-rc1-mm1/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c	2007-07-26 20:18:27.000000000 +0200
@@ -86,8 +86,8 @@
  *        - Note also special handling of AUTH header. Thanks to IPsec wizards.
  */
 
-int nf_ct_ipv6_skip_exthdr(const struct sk_buff *skb, int start, u8 *nexthdrp,
-			   int len)
+static int nf_ct_ipv6_skip_exthdr(const struct sk_buff *skb, int start,
+				  u8 *nexthdrp, int len)
 {
 	u8 nexthdr = *nexthdrp;
 
