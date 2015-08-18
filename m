From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 02/13] ip_tunnels: use u8/u16/u32
Date: Tue, 18 Aug 2015 22:33:11 +0200
Message-ID: <556d360e04809b054d92cf31005a75f433a6b82e.1439929916.git.jbenc@redhat.com>
References: <cover.1439929916.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47616 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751727AbbHRUdo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 16:33:44 -0400
In-Reply-To: <cover.1439929916.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ip_tunnels.h include file uses mixture of __u16 and u16 (etc.) types.
Unify it to the non-underscore variants.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/net/ip_tunnels.h | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 81cf11c931e4..ca173f22f07f 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -32,8 +32,8 @@ struct ip_tunnel_key {
 	__be32			ipv4_src;
 	__be32			ipv4_dst;
 	__be16			tun_flags;
-	__u8			ipv4_tos;
-	__u8			ipv4_ttl;
+	u8			ipv4_tos;
+	u8			ipv4_ttl;
 	__be16			tp_src;
 	__be16			tp_dst;
 };
@@ -64,8 +64,8 @@ struct ip_tunnel_6rd_parm {
 #endif
 
 struct ip_tunnel_encap {
-	__u16			type;
-	__u16			flags;
+	u16			type;
+	u16			flags;
 	__be16			sport;
 	__be16			dport;
 };
@@ -95,8 +95,8 @@ struct ip_tunnel {
 					 * arrived */
 
 	/* These four fields used only by GRE */
-	__u32		i_seqno;	/* The last seen seqno	*/
-	__u32		o_seqno;	/* The last output seqno */
+	u32		i_seqno;	/* The last seen seqno	*/
+	u32		o_seqno;	/* The last output seqno */
 	int		tun_hlen;	/* Precalculated header length */
 	int		mlink;
 
@@ -273,8 +273,8 @@ static inline u8 ip_tunnel_ecn_encap(u8 tos, const struct iphdr *iph,
 
 int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto);
 int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
-		  __be32 src, __be32 dst, __u8 proto,
-		  __u8 tos, __u8 ttl, __be16 df, bool xnet);
+		  __be32 src, __be32 dst, u8 proto,
+		  u8 tos, u8 ttl, __be16 df, bool xnet);
 
 struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb, bool gre_csum,
 					 int gso_type_mask);
-- 
1.8.3.1
