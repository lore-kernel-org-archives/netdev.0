From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 19/33] netfilter: ipset: Kconfig: ipset needs NETFILTER_NETLINK
Date: Fri,  4 Oct 2013 10:33:04 +0200
Message-ID: <1380875598-5250-20-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55580 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754319Ab3JDIeB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Oct 2013 04:34:01 -0400
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/Kconfig b/net/netfilter/ipset/Kconfig
index ba36c28..fd2c14b 100644
--- a/net/netfilter/ipset/Kconfig
+++ b/net/netfilter/ipset/Kconfig
@@ -1,7 +1,7 @@
 menuconfig IP_SET
 	tristate "IP set support"
 	depends on INET && NETFILTER
-	depends on NETFILTER_NETLINK
+	select NETFILTER_NETLINK
 	help
 	  This option adds IP set support to the kernel.
 	  In order to define and use the sets, you need the userspace utility
-- 
1.7.10.4
