From: pablo@netfilter.org
Subject: [PATCH 11/12] netfilter: nf_conntrack: add include to fix sparse warning
Date: Mon, 25 Mar 2013 13:15:51 +0100
Message-ID: <1364213752-3934-12-git-send-email-pablo@netfilter.org>
References: <1364213752-3934-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46588 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757312Ab3CYMQX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 08:16:23 -0400
In-Reply-To: <1364213752-3934-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: stephen hemminger <stephen@networkplumber.org>

Include header file to pickup prototype of nf_nat_seq_adjust_hook

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index c8e001a..1068deb 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -48,6 +48,7 @@
 #include <net/netfilter/nf_conntrack_labels.h>
 #include <net/netfilter/nf_nat.h>
 #include <net/netfilter/nf_nat_core.h>
+#include <net/netfilter/nf_nat_helper.h>
 
 #define NF_CONNTRACK_VERSION	"0.5.0"
 
-- 
1.7.10.4
