From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: Mark MLDv2 Report as known
Date: Fri, 09 Apr 2004 21:05:10 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040409.210510.64268862.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Mark MLDv2 Report as known ICMPv6 type.
(We just ignore MLDv2 Reports on hosts as the spec says.)

Same patch applies linux-2.4.x.

Thanks in advance.

===== net/ipv6/icmp.c 1.47 vs edited =====
--- 1.47/net/ipv6/icmp.c	Tue Feb 24 07:09:00 2004
+++ edited/net/ipv6/icmp.c	Fri Apr  9 20:56:08 2004
@@ -646,6 +646,7 @@
 		break;
 
 	case ICMPV6_MGM_REDUCTION:
+	case ICMPV6_MLD2_REPORT:
 		break;
 
 	default:

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
