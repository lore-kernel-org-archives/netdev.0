From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/50] netfilter: nfnetlink_log: add "nf-logger-5-1" module alias name
Date: Wed,  7 Dec 2016 22:52:14 +0100
Message-ID: <1481147576-5690-9-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60084 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933163AbcLGVxP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:15 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 10C11C51AD
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:14 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 01388DA862
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:14 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DABD0DA872
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:11 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

So we can autoload nfnetlink_log.ko when the user adding nft log
group X rule in netdev family.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 763cb4d54e8d..200922bb2036 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -1152,6 +1152,7 @@ MODULE_ALIAS_NF_LOGGER(AF_INET, 1);
 MODULE_ALIAS_NF_LOGGER(AF_INET6, 1);
 MODULE_ALIAS_NF_LOGGER(AF_BRIDGE, 1);
 MODULE_ALIAS_NF_LOGGER(3, 1); /* NFPROTO_ARP */
+MODULE_ALIAS_NF_LOGGER(5, 1); /* NFPROTO_NETDEV */
 
 module_init(nfnetlink_log_init);
 module_exit(nfnetlink_log_fini);
-- 
2.1.4
