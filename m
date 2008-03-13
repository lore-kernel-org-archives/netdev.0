From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [net-2.6 PATCH] [IPV6] KCONFIG: Fix description about IPV6_TUNNEL.
Date: Thu, 13 Mar 2008 17:56:37 -0400 (EDT)
Message-ID: <20080313.175637.83195061.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org, colins@sjtu.edu.cn
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54041 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754090AbYCMVz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 17:55:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on notice from "Colin" <colins@sjtu.edu.cn>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--- 
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 58219df..47263e4 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -179,11 +179,12 @@ config IPV6_SIT
 	  Saying M here will produce a module called sit.ko. If unsure, say Y.
 
 config IPV6_TUNNEL
-	tristate "IPv6: IPv6-in-IPv6 tunnel"
+	tristate "IPv6: IP-in-IPv6 tunnel (RFC2473)"
 	select INET6_TUNNEL
 	depends on IPV6
 	---help---
-	  Support for IPv6-in-IPv6 tunnels described in RFC 2473.
+	  Support for IPv6-in-IPv6 and IPv4-in-IPv6 tunnels described in
+	  RFC 2473.
 
 	  If unsure, say N.
 

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
