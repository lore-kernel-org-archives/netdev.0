From: Horms <horms@verge.net.au>
Subject: [patch 2/4] auto-help for ip_vs_ftp
Date: Fri, 01 Sep 2006 19:10:38 +0900
Message-ID: <20060901101756.432994000@tabatha.lab.ultramonkey.org>
References: <20060901101036.181146000@tabatha.lab.ultramonkey.org>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	Joseph Mack NA3T <jmack@wm7d.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:47536 "EHLO koto.vergenet.net")
	by vger.kernel.org with ESMTP id S1751406AbWIAKgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 06:36:18 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=ip_vs_ftp-auto-doc.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fill in a help message for the ports option to ip_vs_ftp

Signed-Off-By: Simon Horman <horms@verge.net.au>
Index: linux-2.6/net/ipv4/ipvs/ip_vs_ftp.c
===================================================================
--- linux-2.6.orig/net/ipv4/ipvs/ip_vs_ftp.c	2006-09-01 19:02:38.000000000 +0900
+++ linux-2.6/net/ipv4/ipvs/ip_vs_ftp.c	2006-09-01 19:06:42.000000000 +0900
@@ -46,6 +46,7 @@
  */
 static int ports[IP_VS_APP_MAX_PORTS] = {21, 0};
 module_param_array(ports, int, NULL, 0);
+MODULE_PARM_DESC(ports, "Ports to monitor for FTP control commands");
 
 /*
  *	Debug level

--

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

