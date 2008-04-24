From: Michael Beasley <youvegotmoxie@gmail.com>
Subject: [PATCH] fix typo in net/ipv6/Kconfig
Date: Thu, 24 Apr 2008 08:40:09 -0400
Message-ID: <20080424084009.61f773a6@snafu.setup>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.240]:59147 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617AbYDXMnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 08:43:13 -0400
Received: by hs-out-0708.google.com with SMTP id 4so2008344hsl.5
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 05:43:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Beasley <youvegotmoxie@gmail.com>

Two is used in the wrong context here, as you are connecting to an IPv6 network
over IPv4; not connecting two IPv6 networks to an IPv4 one.

Signed-off-by: Michael Beasley <youvegotmoxie@gmail.com>
---

diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index eb0b808..56b4d86 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -172,7 +172,7 @@ config IPV6_SIT
 	  Tunneling means encapsulating data of one protocol type within
 	  another protocol and sending it over a channel that understands the
 	  encapsulating protocol. This driver implements encapsulation of IPv6
-	  into IPv4 packets. This is useful if you want to connect two IPv6
+	  into IPv4 packets. This is useful if you want to connect to IPv6
 	  networks over an IPv4-only path.
 
 	  Saying M here will produce a module called sit.ko. If unsure, say Y.

---
