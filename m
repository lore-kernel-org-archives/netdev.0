From: Michal Kubecek <mkubecek@suse.cz>
Subject: [nf-next] netfilter: fix struct ip6t_frag field description
Date: Tue, 2 Apr 2013 08:12:11 +0200
Message-ID: <20130402062048.832BDC451E@unicorn.suse.cz>
Cc: coreteam@netfilter.org, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 include/uapi/linux/netfilter_ipv6/ip6t_frag.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/netfilter_ipv6/ip6t_frag.h b/include/uapi/linux/netfilter_ipv6/ip6t_frag.h
index b47f61b..dfd8bc2 100644
--- a/include/uapi/linux/netfilter_ipv6/ip6t_frag.h
+++ b/include/uapi/linux/netfilter_ipv6/ip6t_frag.h
@@ -4,9 +4,9 @@
 #include <linux/types.h>
 
 struct ip6t_frag {
-	__u32 ids[2];			/* Security Parameter Index */
+	__u32 ids[2];			/* Identification range */
 	__u32 hdrlen;			/* Header Length */
-	__u8  flags;			/*  */
+	__u8  flags;			/* Flags */
 	__u8  invflags;			/* Inverse flags */
 };
 
-- 
1.7.10.4

