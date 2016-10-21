From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/13] netfilter: xt_ipcomp: add "ip[6]t_ipcomp" module alias name
Date: Fri, 21 Oct 2016 12:12:15 +0200
Message-ID: <1477044743-18948-6-git-send-email-pablo@netfilter.org>
References: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36298 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754960AbcJUKMt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Oct 2016 06:12:49 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id F3B6026E0A
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 12:12:47 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DFB04DA7F7
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 12:12:47 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 0B34EBAC3C
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 12:12:39 +0200 (CEST)
In-Reply-To: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

Otherwise, user cannot add related rules if xt_ipcomp.ko is not loaded:
  # iptables -A OUTPUT -p 108 -m ipcomp --ipcompspi 1
  iptables: No chain/target/match by that name.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_ipcomp.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/xt_ipcomp.c b/net/netfilter/xt_ipcomp.c
index 89d53104c6b3..000e70377f85 100644
--- a/net/netfilter/xt_ipcomp.c
+++ b/net/netfilter/xt_ipcomp.c
@@ -26,6 +26,8 @@
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Fan Du <fan.du@windriver.com>");
 MODULE_DESCRIPTION("Xtables: IPv4/6 IPsec-IPComp SPI match");
+MODULE_ALIAS("ipt_ipcomp");
+MODULE_ALIAS("ip6t_ipcomp");
 
 /* Returns 1 if the spi is matched by the range, 0 otherwise */
 static inline bool
-- 
2.1.4
