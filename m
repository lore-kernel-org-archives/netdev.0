From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/7] bpf: make helper function protos static
Date: Fri,  4 Mar 2016 15:15:04 +0100
Message-ID: <07b6b274e0dff9856b46b223fad14e55e32b941d.1457099834.git.daniel@iogearbox.net>
References: <cover.1457099834.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39192 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752655AbcCDOPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 09:15:32 -0500
In-Reply-To: <cover.1457099834.git.daniel@iogearbox.net>
In-Reply-To: <cover.1457099834.git.daniel@iogearbox.net>
References: <cover.1457099834.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They are only used here, so there's no reason they should not be static.
Only the vlan push/pop protos are used in the test_bpf suite.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index a1fe246..ce4e18d 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1390,7 +1390,7 @@ static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 	return 0;
 }
 
-const struct bpf_func_proto bpf_skb_store_bytes_proto = {
+static const struct bpf_func_proto bpf_skb_store_bytes_proto = {
 	.func		= bpf_skb_store_bytes,
 	.gpl_only	= false,
 	.ret_type	= RET_INTEGER,
@@ -1421,7 +1421,7 @@ static u64 bpf_skb_load_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	return 0;
 }
 
-const struct bpf_func_proto bpf_skb_load_bytes_proto = {
+static const struct bpf_func_proto bpf_skb_load_bytes_proto = {
 	.func		= bpf_skb_load_bytes,
 	.gpl_only	= false,
 	.ret_type	= RET_INTEGER,
@@ -1472,7 +1472,7 @@ static u64 bpf_l3_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 	return 0;
 }
 
-const struct bpf_func_proto bpf_l3_csum_replace_proto = {
+static const struct bpf_func_proto bpf_l3_csum_replace_proto = {
 	.func		= bpf_l3_csum_replace,
 	.gpl_only	= false,
 	.ret_type	= RET_INTEGER,
@@ -1531,7 +1531,7 @@ static u64 bpf_l4_csum_replace(u64 r1, u64 r2, u64 from, u64 to, u64 flags)
 	return 0;
 }
 
-const struct bpf_func_proto bpf_l4_csum_replace_proto = {
+static const struct bpf_func_proto bpf_l4_csum_replace_proto = {
 	.func		= bpf_l4_csum_replace,
 	.gpl_only	= false,
 	.ret_type	= RET_INTEGER,
@@ -1570,7 +1570,7 @@ static u64 bpf_csum_diff(u64 r1, u64 from_size, u64 r3, u64 to_size, u64 seed)
 	return csum_partial(sp->diff, diff_size, seed);
 }
 
-const struct bpf_func_proto bpf_csum_diff_proto = {
+static const struct bpf_func_proto bpf_csum_diff_proto = {
 	.func		= bpf_csum_diff,
 	.gpl_only	= false,
 	.ret_type	= RET_INTEGER,
@@ -1608,7 +1608,7 @@ static u64 bpf_clone_redirect(u64 r1, u64 ifindex, u64 flags, u64 r4, u64 r5)
 	return dev_queue_xmit(skb2);
 }
 
-const struct bpf_func_proto bpf_clone_redirect_proto = {
+static const struct bpf_func_proto bpf_clone_redirect_proto = {
 	.func           = bpf_clone_redirect,
 	.gpl_only       = false,
 	.ret_type       = RET_INTEGER,
@@ -1660,7 +1660,7 @@ int skb_do_redirect(struct sk_buff *skb)
 	return dev_queue_xmit(skb);
 }
 
-const struct bpf_func_proto bpf_redirect_proto = {
+static const struct bpf_func_proto bpf_redirect_proto = {
 	.func           = bpf_redirect,
 	.gpl_only       = false,
 	.ret_type       = RET_INTEGER,
@@ -1799,7 +1799,7 @@ static u64 bpf_skb_get_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 	return 0;
 }
 
-const struct bpf_func_proto bpf_skb_get_tunnel_key_proto = {
+static const struct bpf_func_proto bpf_skb_get_tunnel_key_proto = {
 	.func		= bpf_skb_get_tunnel_key,
 	.gpl_only	= false,
 	.ret_type	= RET_INTEGER,
@@ -1861,7 +1861,7 @@ static u64 bpf_skb_set_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 	return 0;
 }
 
-const struct bpf_func_proto bpf_skb_set_tunnel_key_proto = {
+static const struct bpf_func_proto bpf_skb_set_tunnel_key_proto = {
 	.func		= bpf_skb_set_tunnel_key,
 	.gpl_only	= false,
 	.ret_type	= RET_INTEGER,
-- 
1.9.3
