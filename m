From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/23] netfilter-bridge: brace placement
Date: Fri, 18 Dec 2015 21:26:31 +0100
Message-ID: <1450470409-31427-6-git-send-email-pablo@netfilter.org>
References: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57984 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965165AbbLRUeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 15:34:05 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 1FC0017F1D0
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:04 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id C4217DA86F
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:03 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id A5C0BDA809
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:33:43 +0100 (CET)
In-Reply-To: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Morris <ipm@chirality.org.uk>

Change brace placement to eliminate checkpatch error.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebt_log.c  | 6 ++----
 net/bridge/netfilter/ebtables.c | 3 +--
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index f22284d..152300d 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -36,14 +36,12 @@ static int ebt_log_tg_check(const struct xt_tgchk_param *par)
 	return 0;
 }
 
-struct tcpudphdr
-{
+struct tcpudphdr {
 	__be16 src;
 	__be16 dst;
 };
 
-struct arppayload
-{
+struct arppayload {
 	unsigned char mac_src[ETH_ALEN];
 	unsigned char ip_src[4];
 	unsigned char mac_dst[ETH_ALEN];
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 62090e2..b13ea69 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -551,8 +551,7 @@ ebt_check_entry_size_and_hooks(const struct ebt_entry *e,
 	return 0;
 }
 
-struct ebt_cl_stack
-{
+struct ebt_cl_stack {
 	struct ebt_chainstack cs;
 	int from;
 	unsigned int hookmask;
-- 
2.1.4
