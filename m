From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: ip6_tables warning
Date: Thu, 17 Jun 2004 19:13:56 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617.191356.62693754.yoshfuji@linux-ipv6.org>
References: <20040616183343.GA9940@logos.cnet>
	<Pine.GSO.4.58.0406171139020.22919@waterleaf.sonytel.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcelo.tosatti@cyclades.com, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: geert@linux-m68k.org, davem@redhat.com
In-Reply-To: <Pine.GSO.4.58.0406171139020.22919@waterleaf.sonytel.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.GSO.4.58.0406171139020.22919@waterleaf.sonytel.be> (at Thu, 17 Jun 2004 12:06:17 +0200 (MEST)), Geert Uytterhoeven <geert@linux-m68k.org> says:

> This is not a new problem, but I never bothered to report it before:
> 
> | ip6_tables.c: In function `tcp_match':
> | ip6_tables.c:1596: warning: implicit declaration of function `ipv6_skip_exthdr'
> It needs to include <net/ipv6.h> to kill the warning.

Here it is.

===== net/ipv6/netfilter/ip6_tables.c 1.17 vs edited =====
--- 1.17/net/ipv6/netfilter/ip6_tables.c	2004-06-07 12:13:18 +09:00
+++ edited/net/ipv6/netfilter/ip6_tables.c	2004-06-17 19:11:08 +09:00
@@ -20,6 +20,7 @@
 #include <linux/udp.h>
 #include <linux/icmpv6.h>
 #include <net/ip.h>
+#include <net/ipv6.h>
 #include <asm/uaccess.h>
 #include <asm/semaphore.h>
 #include <linux/proc_fs.h>

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
