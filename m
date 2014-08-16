From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH 2/4] IPV6: checkpatch corrections
Date: Sat, 16 Aug 2014 13:04:45 +0100
Message-ID: <1408190687-28941-2-git-send-email-ipm@chirality.org.uk>
References: <1408190687-28941-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:43159 "EHLO
	oak.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751529AbaHPME6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2014 08:04:58 -0400
In-Reply-To: <1408190687-28941-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No changes to logic, just whitespace adjustments to coding style of structure definitions
objdump shows no differences

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/ah6.c        |    5 ++---
 net/ipv6/esp6.c       |    7 +++----
 net/ipv6/ipcomp6.c    |    6 ++----
 net/ipv6/mip6.c       |   10 ++++------
 net/ipv6/reassembly.c |    6 ++----
 5 files changed, 13 insertions(+), 21 deletions(-)

diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index ac71d9e..fcffd4e 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -755,11 +755,10 @@ static int ah6_rcv_cb(struct sk_buff *skb, int err)
 	return 0;
 }
 
-static const struct xfrm_type ah6_type =
-{
+static const struct xfrm_type ah6_type = {
 	.description	= "AH6",
 	.owner		= THIS_MODULE,
-	.proto	     	= IPPROTO_AH,
+	.proto		= IPPROTO_AH,
 	.flags		= XFRM_TYPE_REPLAY_PROT,
 	.init_state	= ah6_init_state,
 	.destructor	= ah6_destroy,
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 7b6e830..83fc3a3 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -621,11 +621,10 @@ static int esp6_rcv_cb(struct sk_buff *skb, int err)
 	return 0;
 }
 
-static const struct xfrm_type esp6_type =
-{
+static const struct xfrm_type esp6_type = {
 	.description	= "ESP6",
-	.owner	     	= THIS_MODULE,
-	.proto	     	= IPPROTO_ESP,
+	.owner		= THIS_MODULE,
+	.proto		= IPPROTO_ESP,
 	.flags		= XFRM_TYPE_REPLAY_PROT,
 	.init_state	= esp6_init_state,
 	.destructor	= esp6_destroy,
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index d1c793c..1b9316e 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -181,8 +181,7 @@ static int ipcomp6_rcv_cb(struct sk_buff *skb, int err)
 	return 0;
 }
 
-static const struct xfrm_type ipcomp6_type =
-{
+static const struct xfrm_type ipcomp6_type = {
 	.description	= "IPCOMP6",
 	.owner		= THIS_MODULE,
 	.proto		= IPPROTO_COMP,
@@ -193,8 +192,7 @@ static const struct xfrm_type ipcomp6_type =
 	.hdr_offset	= xfrm6_find_1stfragopt,
 };
 
-static struct xfrm6_protocol ipcomp6_protocol =
-{
+static struct xfrm6_protocol ipcomp6_protocol = {
 	.handler	= xfrm6_rcv,
 	.cb_handler	= ipcomp6_rcv_cb,
 	.err_handler	= ipcomp6_err,
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index db9b6cb..f61429d 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -336,11 +336,10 @@ static void mip6_destopt_destroy(struct xfrm_state *x)
 {
 }
 
-static const struct xfrm_type mip6_destopt_type =
-{
+static const struct xfrm_type mip6_destopt_type = {
 	.description	= "MIP6DESTOPT",
 	.owner		= THIS_MODULE,
-	.proto	     	= IPPROTO_DSTOPTS,
+	.proto		= IPPROTO_DSTOPTS,
 	.flags		= XFRM_TYPE_NON_FRAGMENT | XFRM_TYPE_LOCAL_COADDR,
 	.init_state	= mip6_destopt_init_state,
 	.destructor	= mip6_destopt_destroy,
@@ -469,11 +468,10 @@ static void mip6_rthdr_destroy(struct xfrm_state *x)
 {
 }
 
-static const struct xfrm_type mip6_rthdr_type =
-{
+static const struct xfrm_type mip6_rthdr_type = {
 	.description	= "MIP6RT",
 	.owner		= THIS_MODULE,
-	.proto	     	= IPPROTO_ROUTING,
+	.proto		= IPPROTO_ROUTING,
 	.flags		= XFRM_TYPE_NON_FRAGMENT | XFRM_TYPE_REMOTE_COADDR,
 	.init_state	= mip6_rthdr_init_state,
 	.destructor	= mip6_rthdr_destroy,
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index fe156d9..1a157ca 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -62,8 +62,7 @@
 
 static const char ip6_frag_cache_name[] = "ip6-frags";
 
-struct ip6frag_skb_cb
-{
+struct ip6frag_skb_cb {
 	struct inet6_skb_parm	h;
 	int			offset;
 };
@@ -575,8 +574,7 @@ fail_hdr:
 	return -1;
 }
 
-static const struct inet6_protocol frag_protocol =
-{
+static const struct inet6_protocol frag_protocol = {
 	.handler	=	ipv6_frag_rcv,
 	.flags		=	INET6_PROTO_NOPOLICY,
 };
-- 
1.7.9.5
