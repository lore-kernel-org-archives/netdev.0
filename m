From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/7] netfilter: fix connlimit Kconfig prompt string
Date: Thu, 21 Nov 2013 10:05:22 +0100
Message-ID: <1385024728-4057-2-git-send-email-pablo@netfilter.org>
References: <1385024728-4057-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34566 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751154Ab3KUJGA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Nov 2013 04:06:00 -0500
In-Reply-To: <1385024728-4057-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>

Under Core Netfilter Configuration, connlimit match support has
an extra double quote at the end of it.

Fixes a portion of kernel bugzilla #52671:
  https://bugzilla.kernel.org/show_bug.cgi?id=52671

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Reported-by: lailavrazda1979@gmail.com
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 48acec1..c3398cd 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -909,7 +909,7 @@ config NETFILTER_XT_MATCH_CONNLABEL
 	  connection simultaneously.
 
 config NETFILTER_XT_MATCH_CONNLIMIT
-	tristate '"connlimit" match support"'
+	tristate '"connlimit" match support'
 	depends on NF_CONNTRACK
 	depends on NETFILTER_ADVANCED
 	---help---
-- 
1.7.10.4
