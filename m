From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] add SCTP to xfrm_flowi_{sport,dport}()
Date: Tue, 24 Aug 2004 23:04:09 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824.230409.21312009.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

(I'm not sure if ipsec is fully supported for sctp, but anyway,)
I should not have made regression here.

Thanks.

--yoshfuji

===== include/net/xfrm.h 1.66 vs edited =====
--- 1.66/include/net/xfrm.h	2004-08-22 14:00:07 +09:00
+++ edited/include/net/xfrm.h	2004-08-24 22:55:30 +09:00
@@ -428,6 +428,7 @@
 	switch(fl->proto) {
 	case IPPROTO_TCP:
 	case IPPROTO_UDP:
+	case IPPROTO_SCTP:
 		port = fl->fl_ip_sport;
 		break;
 	case IPPROTO_ICMP:
@@ -447,6 +448,7 @@
 	switch(fl->proto) {
 	case IPPROTO_TCP:
 	case IPPROTO_UDP:
+	case IPPROTO_SCTP:
 		port = fl->fl_ip_dport;
 		break;
 	case IPPROTO_ICMP:

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
