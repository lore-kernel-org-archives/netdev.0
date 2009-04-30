From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCH] xt_socket: checks for the state of nf_conntrack
Date: Thu, 30 Apr 2009 17:35:55 +0200
Message-ID: <1241105755-10017-1-git-send-email-panther@balabit.hu>
Cc: mingo@elte.hu, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, hidden@sch.bme.hu,
	linux-kernel@vger.kernel.org,
	Laszlo Attila Toth <panther@balabit.hu>
To: davem@davemloft.net, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:35113 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932145AbZD3PgA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2009 11:36:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xt_socket can use connection tracking, and checks whether it is a module.

Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
---
 net/netfilter/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 881203c..cb3ad74 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -837,6 +837,7 @@ config NETFILTER_XT_MATCH_SOCKET
 	depends on NETFILTER_TPROXY
 	depends on NETFILTER_XTABLES
 	depends on NETFILTER_ADVANCED
+	depends on !NF_CONNTRACK || NF_CONNTRACK
 	select NF_DEFRAG_IPV4
 	help
 	  This option adds a `socket' match, which can be used to match
-- 
1.6.2.2.404.ge96f3

