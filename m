From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 37/51] netfilter: fix struct ip6t_frag field description
Date: Sat,  6 Apr 2013 14:17:36 +0200
Message-ID: <1365250670-14993-38-git-send-email-pablo@netfilter.org>
References: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1365250670-14993-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Michal Kube=C4=8Dek <mkubecek@suse.cz>

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter_ipv6/ip6t_frag.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/netfilter_ipv6/ip6t_frag.h b/include/ua=
pi/linux/netfilter_ipv6/ip6t_frag.h
index b47f61b..dfd8bc2 100644
--- a/include/uapi/linux/netfilter_ipv6/ip6t_frag.h
+++ b/include/uapi/linux/netfilter_ipv6/ip6t_frag.h
@@ -4,9 +4,9 @@
 #include <linux/types.h>
=20
 struct ip6t_frag {
-	__u32 ids[2];			/* Security Parameter Index */
+	__u32 ids[2];			/* Identification range */
 	__u32 hdrlen;			/* Header Length */
-	__u8  flags;			/*  */
+	__u8  flags;			/* Flags */
 	__u8  invflags;			/* Inverse flags */
 };
=20
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
