From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/29] netfilter: dup: resolve warnings about missing prototypes
Date: Fri, 30 Jun 2017 00:53:01 +0200
Message-ID: <1498776807-11124-4-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57584 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752094AbdF2Wxl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 18:53:41 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id D5A01BDF5B
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:29 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id C746BDA46C
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:29 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D79EBDA241
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:25 +0200 (CEST)
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: stephen hemminger <stephen@networkplumber.org>

Missing include file causes:

net/netfilter/nf_dup_netdev.c:26:6: warning: no previous prototype for ‘nf_fwd_netdev_egress’ [-Wmissing-prototypes]
net/netfilter/nf_dup_netdev.c:40:6: warning: no previous prototype for ‘nf_dup_netdev_egress’ [-Wmissing-prototypes]

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_dup_netdev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nf_dup_netdev.c b/net/netfilter/nf_dup_netdev.c
index c9d7f95768ab..f4a566e67213 100644
--- a/net/netfilter/nf_dup_netdev.c
+++ b/net/netfilter/nf_dup_netdev.c
@@ -13,6 +13,7 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter/nf_tables.h>
 #include <net/netfilter/nf_tables.h>
+#include <net/netfilter/nf_dup_netdev.h>
 
 static void nf_do_netdev_egress(struct sk_buff *skb, struct net_device *dev)
 {
-- 
2.1.4
