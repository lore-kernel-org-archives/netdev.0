From: akpm@osdl.org
Subject: [patch 01/10] multiple definitions of ip_nat_tftp_hook
Date: Mon, 24 Jan 2005 18:57:07 -0800
Message-ID: <200501250257.j0P2vZl20241@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org,
        benoit.boissinot@ens-lyon.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>

net/ipv4/netfilter/ip_nat_tftp.o(.bss+0x0):net/ipv4/netfilter/ip_nat_tftp.c:44: multiple definition of `ip_nat_tftp_hook'

Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/include/linux/netfilter_ipv4/ip_conntrack_tftp.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff -puN include/linux/netfilter_ipv4/ip_conntrack_tftp.h~ip_nat_tftp_hook-scoping-fix include/linux/netfilter_ipv4/ip_conntrack_tftp.h
--- 25/include/linux/netfilter_ipv4/ip_conntrack_tftp.h~ip_nat_tftp_hook-scoping-fix	2005-01-24 18:55:46.792183344 -0800
+++ 25-akpm/include/linux/netfilter_ipv4/ip_conntrack_tftp.h	2005-01-24 18:55:46.795182888 -0800
@@ -13,8 +13,8 @@ struct tftphdr {
 #define TFTP_OPCODE_ACK		4
 #define TFTP_OPCODE_ERROR	5
 
-unsigned int (*ip_nat_tftp_hook)(struct sk_buff **pskb,
-				 enum ip_conntrack_info ctinfo,
-				 struct ip_conntrack_expect *exp);
+extern unsigned int (*ip_nat_tftp_hook)(struct sk_buff **pskb,
+					enum ip_conntrack_info ctinfo,
+					struct ip_conntrack_expect *exp);
 
 #endif /* _IP_CT_TFTP */
_
