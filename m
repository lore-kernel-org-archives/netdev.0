From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/14] netfilter: Fix typo in NF_CONNTRACK Kconfig option description
Date: Thu, 26 Jan 2017 17:37:59 +0100
Message-ID: <1485448687-6072-7-git-send-email-pablo@netfilter.org>
References: <1485448687-6072-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48632 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753586AbdAZQjX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 11:39:23 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id AD36B765C
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 17:38:30 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9DE39FEFC6
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 17:38:30 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7F4B518FDBF
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 17:38:28 +0100 (CET)
In-Reply-To: <1485448687-6072-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Breathitt Gray <vilhelm.gray@gmail.com>

The NF_CONNTRACK Kconfig option description makes an incorrect reference
to the "meta" expression where the "ct" expression would be correct.This
patch fixes the respective typographical error.

Fixes: d497c6352736 ("netfilter: add help information to new nf_tables Kconfig options")
Signed-off-by: William Breathitt Gray <vilhelm.gray@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 63729b489c2c..bbc45f8a7b2d 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -494,7 +494,7 @@ config NFT_CT
 	depends on NF_CONNTRACK
 	tristate "Netfilter nf_tables conntrack module"
 	help
-	  This option adds the "meta" expression that you can use to match
+	  This option adds the "ct" expression that you can use to match
 	  connection tracking information such as the flow state.
 
 config NFT_SET_RBTREE
-- 
2.1.4
