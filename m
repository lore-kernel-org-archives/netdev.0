From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/6] netfilter: nfnetlink_log: add "nf-logger-3-1" module alias name
Date: Thu, 18 Aug 2016 19:29:04 +0200
Message-ID: <1471541348-1538-3-git-send-email-pablo@netfilter.org>
References: <1471541348-1538-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1471541348-1538-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <liping.zhang@spreadtrum.com>

Otherwise, if nfnetlink_log.ko is not loaded, we cannot add rules
to log packets to the userspace when we specify it with arp family,
such as:

  # nft add rule arp filter input log group 0
  <cmdline>:1:1-37: Error: Could not process rule: No such file or
  directory
  add rule arp filter input log group 0
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index cbcfdfb..6577db5 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -1147,6 +1147,7 @@ MODULE_ALIAS_NFNL_SUBSYS(NFNL_SUBSYS_ULOG);
 MODULE_ALIAS_NF_LOGGER(AF_INET, 1);
 MODULE_ALIAS_NF_LOGGER(AF_INET6, 1);
 MODULE_ALIAS_NF_LOGGER(AF_BRIDGE, 1);
+MODULE_ALIAS_NF_LOGGER(3, 1); /* NFPROTO_ARP */
 
 module_init(nfnetlink_log_init);
 module_exit(nfnetlink_log_fini);
-- 
2.1.4

