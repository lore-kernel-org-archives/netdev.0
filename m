From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: inappropriate static variable in net/ipv6/ndisc.c
Date: Thu, 26 Jun 2003 14:21:09 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030626.142109.76202395.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

It is not appropriate to use static variable here.

--yoshfuji

Index: linux-2.5/net/ipv6/ndisc.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/ndisc.c,v
retrieving revision 1.40
diff -u -p -r1.40 ndisc.c
--- linux-2.5/net/ipv6/ndisc.c	21 Jun 2003 16:21:01 -0000	1.40
+++ linux-2.5/net/ipv6/ndisc.c	26 Jun 2003 03:58:58 -0000
@@ -423,7 +423,7 @@ static void ndisc_send_na(struct net_dev
 		   struct in6_addr *daddr, struct in6_addr *solicited_addr,
 	 	   int router, int solicited, int override, int inc_opt) 
 {
-	static struct in6_addr tmpaddr;
+	struct in6_addr tmpaddr;
 	struct inet6_ifaddr *ifp;
 	struct inet6_dev *idev;
 	struct flowi fl;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
