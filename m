From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/4] netfilter: default CONFIG_NETFILTER_INGRESS to y
Date: Fri, 29 May 2015 01:44:53 +0200
Message-ID: <1432856695-23831-3-git-send-email-pablo@netfilter.org>
References: <1432856695-23831-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40650 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932422AbbE1XkA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 19:40:00 -0400
In-Reply-To: <1432856695-23831-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Useful to compile-test all options.

Suggested-by: Alexei Stavoroitov <ast@plumgrid.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index db1c674..9a89e7c 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -3,6 +3,7 @@ menu "Core Netfilter Configuration"
 
 config NETFILTER_INGRESS
 	bool "Netfilter ingress support"
+	default y
 	select NET_INGRESS
 	help
 	  This allows you to classify packets from ingress using the Netfilter
-- 
1.7.10.4
