From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPVS: linkage error without CONFIG_IP_VS_PROTO_TCP
Date: Sat, 09 Aug 2003 16:29:52 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030809.162952.114376111.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch fixes linkage error occurs if CONFIG_IP_VS_PROTO_TCP 
is not set.

Thanks.

Index: linux26/net/ipv4/ipvs/ip_vs_core.c
===================================================================
RCS file: /cvsroot/usagi/usagi/kernel/linux26/net/ipv4/ipvs/ip_vs_core.c,v
retrieving revision 1.1.1.1
diff -u -r1.1.1.1 ip_vs_core.c
--- linux26/net/ipv4/ipvs/ip_vs_core.c	15 Jul 2003 07:42:29 -0000	1.1.1.1
+++ linux26/net/ipv4/ipvs/ip_vs_core.c	9 Aug 2003 07:14:55 -0000
@@ -53,7 +53,9 @@
 EXPORT_SYMBOL(ip_vs_conn_new);
 EXPORT_SYMBOL(ip_vs_conn_in_get);
 EXPORT_SYMBOL(ip_vs_conn_out_get);
+#ifdef CONFIG_IP_VS_PROTO_TCP
 EXPORT_SYMBOL(ip_vs_tcp_conn_listen);
+#endif
 EXPORT_SYMBOL(ip_vs_conn_put);
 #ifdef CONFIG_IP_VS_DEBUG
 EXPORT_SYMBOL(ip_vs_get_debug_level);


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
