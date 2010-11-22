From: Tracey Dent <tdent48227@gmail.com>
Subject: [PATCH 08/17] Net: ipv6: netfiliter: Makefile: Remove deprecated kbuild goal definitions
Date: Sun, 21 Nov 2010 20:03:19 -0500
Message-ID: <1290387808-2239-9-git-send-email-tdent48227@gmail.com>
References: <1290387808-2239-1-git-send-email-tdent48227@gmail.com>
Cc: marcel@holtmann.org, padovan@profusion.mobi,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	sjur.brandeland@stericsson.com, socketcan@hartkopp.net,
	urs.thuermann@volkswagen.de, socketcan-core@lists.berlios.de,
	sage@newdream.net, ceph-devel@vger.kernel.org,
	wang840925@gmail.com, jlayton@redhat.com, kaber@trash.net,
	pekkas@netcore.fi, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	samuel@sortiz.org, Tracey Dent <tdent48227@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290387808-2239-1-git-send-email-tdent48227@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changed Makefile to use <modules>-y instead of <modules>-objs
because -objs is deprecated and not mentioned in
Documentation/kbuild/makefiles.txt.

Signed-off-by: Tracey Dent <tdent48227@gmail.com>
---
 net/ipv6/netfilter/Makefile |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index 0a432c9..abfee91 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -11,13 +11,13 @@ obj-$(CONFIG_IP6_NF_RAW) += ip6table_raw.o
 obj-$(CONFIG_IP6_NF_SECURITY) += ip6table_security.o
 
 # objects for l3 independent conntrack
-nf_conntrack_ipv6-objs  :=  nf_conntrack_l3proto_ipv6.o nf_conntrack_proto_icmpv6.o
+nf_conntrack_ipv6-y  :=  nf_conntrack_l3proto_ipv6.o nf_conntrack_proto_icmpv6.o
 
 # l3 independent conntrack
 obj-$(CONFIG_NF_CONNTRACK_IPV6) += nf_conntrack_ipv6.o nf_defrag_ipv6.o
 
 # defrag
-nf_defrag_ipv6-objs := nf_defrag_ipv6_hooks.o nf_conntrack_reasm.o
+nf_defrag_ipv6-y := nf_defrag_ipv6_hooks.o nf_conntrack_reasm.o
 obj-$(CONFIG_NF_DEFRAG_IPV6) += nf_defrag_ipv6.o
 
 # matches
-- 
1.7.3.2.245.g03276
