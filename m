From: Patrick McHardy <kaber@trash.net>
Subject: gre: fix copy and paste error
Date: Fri, 10 Oct 2008 17:54:40 +0200
Message-ID: <48EF7AC0.6080104@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060307050407010200030505"
To: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57636 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758143AbYJJPyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 11:54:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060307050407010200030505
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------060307050407010200030505
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit c7d32967f53c4d3ded69f0e645b7c0848ac8cb1b
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Oct 10 17:53:36 2008 +0200

    gre: fix copy and paste error
    
    The flags are dumped twice, the keys not at all.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 0d5e35b..c0755e9 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1539,8 +1539,8 @@ static int ipgre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	NLA_PUT_U32(skb, IFLA_GRE_LINK, p->link);
 	NLA_PUT_BE16(skb, IFLA_GRE_IFLAGS, p->i_flags);
 	NLA_PUT_BE16(skb, IFLA_GRE_OFLAGS, p->o_flags);
-	NLA_PUT_BE32(skb, IFLA_GRE_IFLAGS, p->i_flags);
-	NLA_PUT_BE32(skb, IFLA_GRE_OFLAGS, p->o_flags);
+	NLA_PUT_BE32(skb, IFLA_GRE_IKEY, p->i_key);
+	NLA_PUT_BE32(skb, IFLA_GRE_OKEY, p->o_key);
 	NLA_PUT(skb, IFLA_GRE_LOCAL, 4, &p->iph.saddr);
 	NLA_PUT(skb, IFLA_GRE_REMOTE, 4, &p->iph.daddr);
 	NLA_PUT_U8(skb, IFLA_GRE_TTL, p->iph.ttl);

--------------060307050407010200030505--
