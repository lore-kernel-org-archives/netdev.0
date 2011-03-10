From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ip6ip6: autoload ip6 tunnel
Date: Thu, 10 Mar 2011 13:43:19 -0800
Message-ID: <20110310134319.25b1b901@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vasiliy Kulikov <segoon@openwall.com>,
	Michael Tokarev <mjt@tls.msk.ru>,
	Kees Cook <kees.cook@canonical.com>,
	James Morris <jmorris@namei.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55436 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752131Ab1CJV4n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2011 16:56:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add necessary alias to autoload ip6ip6 tunnel module.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch is against 2.6.38-rc7 (not net-next).

--- a/net/ipv6/ip6_tunnel.c	2011-03-10 13:33:16.613345613 -0800
+++ b/net/ipv6/ip6_tunnel.c	2011-03-10 13:37:32.372100323 -0800
@@ -57,6 +57,7 @@
 MODULE_AUTHOR("Ville Nuorvala");
 MODULE_DESCRIPTION("IPv6 tunneling device");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_NETDEV("ip6tnl0");
 
 #ifdef IP6_TNL_DEBUG
 #define IP6_TNL_TRACE(x...) printk(KERN_DEBUG "%s:" x "\n", __func__)
