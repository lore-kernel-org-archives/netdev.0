From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch net-next v3 6/7] ipv4: ERROR: code indent should use tabs where possible
Date: Mon, 23 Dec 2013 13:57:25 +0800
Message-ID: <1387778246-15300-7-git-send-email-chenweilong@huawei.com>
References: <1387778246-15300-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	<netfilter@vger.kernel.org>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:62086 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362Ab3LWF6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 00:58:11 -0500
In-Reply-To: <1387778246-15300-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/ipv4/cipso_ipv4.c      | 9 +++------
 net/ipv4/sysctl_net_ipv4.c | 2 +-
 net/ipv4/xfrm4_mode_beet.c | 2 +-
 3 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 4b59b6e..69e77c8 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -1335,8 +1335,7 @@ static int cipso_v4_parsetag_rbm(const struct cipso_v4_doi *doi_def,
 	secattr->flags |= NETLBL_SECATTR_MLS_LVL;
 
 	if (tag_len > 4) {
-		secattr->attr.mls.cat =
-		                       netlbl_secattr_catmap_alloc(GFP_ATOMIC);
+		secattr->attr.mls.cat = netlbl_secattr_catmap_alloc(GFP_ATOMIC);
 		if (secattr->attr.mls.cat == NULL)
 			return -ENOMEM;
 
@@ -1431,8 +1430,7 @@ static int cipso_v4_parsetag_enum(const struct cipso_v4_doi *doi_def,
 	secattr->flags |= NETLBL_SECATTR_MLS_LVL;
 
 	if (tag_len > 4) {
-		secattr->attr.mls.cat =
-			               netlbl_secattr_catmap_alloc(GFP_ATOMIC);
+		secattr->attr.mls.cat = netlbl_secattr_catmap_alloc(GFP_ATOMIC);
 		if (secattr->attr.mls.cat == NULL)
 			return -ENOMEM;
 
@@ -1526,8 +1524,7 @@ static int cipso_v4_parsetag_rng(const struct cipso_v4_doi *doi_def,
 	secattr->flags |= NETLBL_SECATTR_MLS_LVL;
 
 	if (tag_len > 4) {
-		secattr->attr.mls.cat =
-			               netlbl_secattr_catmap_alloc(GFP_ATOMIC);
+		secattr->attr.mls.cat = netlbl_secattr_catmap_alloc(GFP_ATOMIC);
 		if (secattr->attr.mls.cat == NULL)
 			return -ENOMEM;
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index d7b63a6..1d2480a 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -700,7 +700,7 @@ static struct ctl_table ipv4_table[] = {
 		.mode           = 0644,
 		.proc_handler   = proc_dointvec
 	},
-        {
+	{
 		.procname       = "tcp_thin_dupack",
 		.data           = &sysctl_tcp_thin_dupack,
 		.maxlen         = sizeof(int),
diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
index e3db3f9..71acd00 100644
--- a/net/ipv4/xfrm4_mode_beet.c
+++ b/net/ipv4/xfrm4_mode_beet.c
@@ -48,7 +48,7 @@ static int xfrm4_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 		hdrlen += IPV4_BEET_PHMAXLEN - (optlen & 4);
 
 	skb_set_network_header(skb, -x->props.header_len -
-			            hdrlen + (XFRM_MODE_SKB_CB(skb)->ihl - sizeof(*top_iph)));
+				    hdrlen + (XFRM_MODE_SKB_CB(skb)->ihl - sizeof(*top_iph)));
 	if (x->sel.family != AF_INET6)
 		skb->network_header += IPV4_BEET_PHMAXLEN;
 	skb->mac_header = skb->network_header +
-- 
1.7.12
