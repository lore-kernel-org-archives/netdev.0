From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [2.6,2.4] Don't update MTU by invalid mtu value in RA
Date: Thu, 18 Dec 2003 17:34:08 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031218.173408.17644747.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org,
        Hiroaki Kago
 <kago@jp.fujitsu.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

D: Don't update MTU by invalid mtu value in RA message.
D: Notified by Hiroaki Kago <kago@jp.fujitsu.com>.

Thanks in advance.

===== net/ipv6/ndisc.c 1.58 vs edited =====
--- 1.58/net/ipv6/ndisc.c	Sat Sep 13 09:25:13 2003
+++ edited/net/ipv6/ndisc.c	Thu Dec 18 17:31:27 2003
@@ -1166,9 +1166,7 @@
 				ND_PRINTK0("NDISC: router announcement with mtu = %d\n",
 					   mtu);
 			}
-		}
-
-		if (in6_dev->cnf.mtu6 != mtu) {
+		} else if (in6_dev->cnf.mtu6 != mtu) {
 			in6_dev->cnf.mtu6 = mtu;
 
 			if (rt)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
