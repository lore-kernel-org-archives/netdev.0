From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 25/29] netfilter, kbuild: use canonical method to specify objs.
Date: Fri, 30 Jun 2017 00:53:23 +0200
Message-ID: <1498776807-11124-26-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57586 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752451AbdF2WyA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 18:54:00 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 1498FBDF49
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:45 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 05EABD1CAA
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:45 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D86CDDA812
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:42 +0200 (CEST)
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jike Song <jike.song@intel.com>

Should use ":=" instead of "+=".

Signed-off-by: Jike Song <jike.song@intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Makefile | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index c9b78e7b342f..913380919301 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -70,10 +70,9 @@ obj-$(CONFIG_NETFILTER_SYNPROXY) += nf_synproxy_core.o
 obj-$(CONFIG_NF_DUP_NETDEV)	+= nf_dup_netdev.o
 
 # nf_tables
-nf_tables-objs += nf_tables_core.o nf_tables_api.o nf_tables_trace.o
-nf_tables-objs += nft_immediate.o nft_cmp.o nft_range.o
-nf_tables-objs += nft_bitwise.o nft_byteorder.o nft_payload.o
-nf_tables-objs += nft_lookup.o nft_dynset.o
+nf_tables-objs := nf_tables_core.o nf_tables_api.o nf_tables_trace.o \
+		  nft_immediate.o nft_cmp.o nft_range.o nft_bitwise.o \
+		  nft_byteorder.o nft_payload.o nft_lookup.o nft_dynset.o
 
 obj-$(CONFIG_NF_TABLES)		+= nf_tables.o
 obj-$(CONFIG_NF_TABLES_INET)	+= nf_tables_inet.o
-- 
2.1.4
