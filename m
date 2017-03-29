From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH] net: netfilterL: Fix line over 80 characters.
Date: Wed, 29 Mar 2017 15:30:59 +0530
Message-ID: <20170329100059.GA24750@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34035 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754941AbdC2KBF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 06:01:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix the line over 80 characters as reported by checkpatch.pl

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
---
 net/ipv6/netfilter/ip6_tables.c    | 6 ++++--
 net/ipv6/netfilter/ip6t_SYNPROXY.c | 3 ++-
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index ac69ce3bfa1e..b3b94cc80544 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -81,12 +81,14 @@ ip6_packet_match(const struct sk_buff *skb,
 					 &ip6info->dst)))
 		return false;
 
-	ret = ifname_compare_aligned(indev, ip6info->iniface, ip6info->iniface_mask);
+	ret = ifname_compare_aligned(indev, ip6info->iniface,
+				     ip6info->iniface_mask);
 
 	if (NF_INVF(ip6info, IP6T_INV_VIA_IN, ret != 0))
 		return false;
 
-	ret = ifname_compare_aligned(outdev, ip6info->outiface, ip6info->outiface_mask);
+	ret = ifname_compare_aligned(outdev, ip6info->outiface,
+				     ip6info->outiface_mask);
 
 	if (NF_INVF(ip6info, IP6T_INV_VIA_OUT, ret != 0))
 		return false;
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index e0fa78085ad7..6b4d1837891b 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -58,7 +58,8 @@ synproxy_send_tcp(struct net *net,
 	fl6.daddr = niph->daddr;
 	fl6.fl6_sport = nth->source;
 	fl6.fl6_dport = nth->dest;
-	security_skb_classify_flow((struct sk_buff *)skb, flowi6_to_flowi(&fl6));
+	security_skb_classify_flow((struct sk_buff *)skb,
+				   flowi6_to_flowi(&fl6));
 	dst = ip6_route_output(net, NULL, &fl6);
 	if (dst->error) {
 		dst_release(dst);
-- 
2.11.0
