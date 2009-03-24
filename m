From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/41: change generic l4 protocol number
Date: Tue, 24 Mar 2009 15:03:08 +0100 (MET)
Message-ID: <20090324140303.31401.96296.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit fe2a7ce4de07472ace0cdf460a41f462a4621687
Author: Christoph Paasch <christoph.paasch@student.uclouvain.be>
Date:   Wed Feb 18 16:28:35 2009 +0100

    netfilter: change generic l4 protocol number
    
    0 is used by Hop-by-hop header and so this may cause confusion.
    255 is stated as 'Reserved' by IANA.
    
    Signed-off-by: Christoph Paasch <christoph.paasch@student.uclouvain.be>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index 4be80d7..829374f 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -92,7 +92,7 @@ static struct ctl_table generic_compat_sysctl_table[] = {
 struct nf_conntrack_l4proto nf_conntrack_l4proto_generic __read_mostly =
 {
 	.l3proto		= PF_UNSPEC,
-	.l4proto		= 0,
+	.l4proto		= 255,
 	.name			= "unknown",
 	.pkt_to_tuple		= generic_pkt_to_tuple,
 	.invert_tuple		= generic_invert_tuple,
