From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH/RFC] remove include/linux/netflinter_ipv6/ip6t_REJECT.h
Date: Sat, 28 Aug 2004 01:14:51 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040828.011451.79815651.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, laforge@gnumonks.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

There're no users of include/linux/netflinter_ipv6/ip6t_REJECT.h,
which contains wrong, useless definitions.

Yes, I know ip6t_REJECT.c lives in patch-o-matic, but
it (almost) completely replaces ip6t_REJECT.h;
which implies that ip6t_REJECT.h is useless at all.

So, how about removing ip6t_REJECT.h for now?
Of course, introducing appropriate ip6t_REJECT.c and ip6t_REJECT.h is
the alternate option. :-)

Thanks.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

--yoshfuji

ChangeSet@1.1841, 2004-08-28 00:46:02+09:00, yoshfuji@linux-ipv6.org
  [NETFILTER] remove unused file.
  
  Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/linux/netfilter_ipv6/ip6t_REJECT.h b/include/linux/netfilter_ipv6/ip6t_REJECT.h
--- a/include/linux/netfilter_ipv6/ip6t_REJECT.h	2004-08-28 00:47:03 +09:00
+++ /dev/null	Wed Dec 31 16:00:00 196900
@@ -1,16 +0,0 @@
-#ifndef _IP6T_REJECT_H
-#define _IP6T_REJECT_H
-
-enum ip6t_reject_with {
-	IP6T_ICMP_NET_UNREACHABLE,
-	IP6T_ICMP_HOST_UNREACHABLE,
-	IP6T_ICMP_PROT_UNREACHABLE,
-	IP6T_ICMP_PORT_UNREACHABLE,
-	IP6T_ICMP_ECHOREPLY
-};
-
-struct ip6t_reject_info {
-	enum ip6t_reject_with with;      /* reject type */
-};
-
-#endif /*_IPT_REJECT_H*/

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
