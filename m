From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IPV6] reability improvement
Date: Sat, 21 Aug 2004 01:34:34 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040821.013434.102361441.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

D: Improve readability.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv6/ip6_flowlabel.c 1.15 vs edited =====
--- 1.15/net/ipv6/ip6_flowlabel.c	2004-07-08 07:49:52 +09:00
+++ edited/net/ipv6/ip6_flowlabel.c	2004-08-21 01:18:30 +09:00
@@ -538,7 +538,8 @@
 
 		/* Do not check for fault */
 		if (!freq.flr_label)
-			copy_to_user(optval + ((u8*)&freq.flr_label - (u8*)&freq), &fl->label, sizeof(fl->label));
+			copy_to_user(&((struct in6_flowlabel_req __user *) optval)->flr_label,
+				     &fl->label, sizeof(fl->label));
 
 		sfl1->fl = fl;
 		sfl1->next = np->ipv6_fl_list;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
