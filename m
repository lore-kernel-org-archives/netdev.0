From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IPV6]: Fix check if we're router.
Date: Wed, 08 Dec 2004 10:44:56 +0100 (CET)
Message-ID: <20041208.104456.103795781.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Fix the check if we're router. against 2.6.10-rc3, for 2.6.10 queue.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv6/ndisc.c 1.105 vs edited =====
--- 1.105/net/ipv6/ndisc.c	2004-11-10 15:57:03 +09:00
+++ edited/net/ipv6/ndisc.c	2004-12-08 18:34:45 +09:00
@@ -943,7 +943,7 @@
 	}
 
 	/* Don't accept RS if we're not in router mode */
-	if (!idev->cnf.forwarding || idev->cnf.accept_ra)
+	if (!idev->cnf.forwarding)
 		goto out;
 
 	/*

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
