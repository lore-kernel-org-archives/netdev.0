From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH 10/13] [RFC] [IPV6] Don't export ipv6_get_saddr().
Date: Tue, 17 Oct 2006 03:22:17 +0300
Message-ID: <45342239.9090107@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>, kim.nordlund@nokia.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:11794 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1422976AbWJQAWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 20:22:19 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


To make sure the source address selection is done correctly, don't let
users outside the ipv6 module call ipv6_get_saddr() directly. In stead
have them go through ip6_route_output().

Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
---
 net/ipv6/ipv6_syms.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ipv6_syms.c b/net/ipv6/ipv6_syms.c
index 0e8e067..94a9806 100644
--- a/net/ipv6/ipv6_syms.c
+++ b/net/ipv6/ipv6_syms.c
@@ -25,7 +25,6 @@ EXPORT_SYMBOL(inet6_release);
 EXPORT_SYMBOL(inet6_bind);
 EXPORT_SYMBOL(inet6_getname);
 EXPORT_SYMBOL(inet6_ioctl);
-EXPORT_SYMBOL(ipv6_get_saddr);
 EXPORT_SYMBOL(ipv6_chk_addr);
 EXPORT_SYMBOL(in6_dev_finish_destroy);
 #ifdef CONFIG_XFRM
-- 
1.4.2.3

