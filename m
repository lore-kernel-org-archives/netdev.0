From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] XFRM: typo
Date: Sun, 29 Jun 2003 22:35:00 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030629.223500.58352746.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This fixes a typo.

Index: linux-2.5/net/xfrm/xfrm_input.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/xfrm/xfrm_input.c,v
retrieving revision 1.4
diff -u -r1.4 xfrm_input.c
--- linux-2.5/net/xfrm/xfrm_input.c	16 May 2003 21:02:52 -0000	1.4
+++ linux-2.5/net/xfrm/xfrm_input.c	29 Jun 2003 12:11:51 -0000
@@ -18,7 +18,7 @@
 	kmem_cache_free(sp->pool, sp);
 }
 
-/* Fetch spi and seq frpm ipsec header */
+/* Fetch spi and seq from ipsec header */
 
 int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, u32 *spi, u32 *seq)
 {

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
