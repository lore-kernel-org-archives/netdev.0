From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] TCP: inline message
Date: Mon, 05 Jul 2004 17:00:50 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705.170050.44266970.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

D: [TCP] Diet using "unknown time value" message in net/ipv4/tcp_timer.c.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Thanks.

===== include/net/tcp.h 1.78 vs edited =====
--- 1.78/include/net/tcp.h	2004-06-24 14:01:03 +09:00
+++ edited/include/net/tcp.h	2004-07-05 16:39:04 +09:00
@@ -1036,7 +1036,7 @@
 		break;
 
 	default:
-		printk(KERN_DEBUG "bug: unknown timer value\n");
+		printk(timer_bug_msg);
 	};
 }
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
