From: Horms <horms@verge.net.au>
Subject: [patch 1/4] Document the ports option to ip_vs_ftp in kernel-parameters.txt
Date: Fri, 01 Sep 2006 19:10:37 +0900
Message-ID: <20060901101756.111300000@tabatha.lab.ultramonkey.org>
References: <20060901101036.181146000@tabatha.lab.ultramonkey.org>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	Joseph Mack NA3T <jmack@wm7d.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:47280 "EHLO koto.vergenet.net")
	by vger.kernel.org with ESMTP id S1751040AbWIAKgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 06:36:18 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=ip_vs_ftp-doc.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm not sure if documenting this here is appropriate, but
if it is, here is some text to put there.

Signed-Off-By: Simon Horman <horms@verge.net.au>
Index: linux-2.6/Documentation/kernel-parameters.txt
===================================================================
--- linux-2.6.orig/Documentation/kernel-parameters.txt	2006-09-01 17:02:10.000000000 +0900
+++ linux-2.6/Documentation/kernel-parameters.txt	2006-09-01 17:02:49.000000000 +0900
@@ -697,6 +697,12 @@
 	ips=		[HW,SCSI] Adaptec / IBM ServeRAID controller
 			See header of drivers/scsi/ips.c.
 
+	ports=		[IP_VS_FTP] IPVS ftp helper module
+			Default is 21.
+			Up to 8 (IP_VS_APP_MAX_PORTS) ports
+			may be specified.
+			Format: <port>,<port>....
+
 	irqfixup	[HW]
 			When an interrupt is not handled search all handlers
 			for it. Intended to get systems with badly broken

--

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

