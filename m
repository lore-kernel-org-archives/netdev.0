From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/19] netfilter: xt_addrtype: fix trivial typo
Date: Tue, 20 Aug 2013 12:54:33 +0200
Message-ID: <1376996091-3964-2-git-send-email-pablo@netfilter.org>
References: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60057 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750907Ab3HTKzF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 06:55:05 -0400
In-Reply-To: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Oester <kernel@linuxace.com>

Fix typo in error message.

Signed-off-by: Phil Oester <kernel@linuxace.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_addrtype.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/xt_addrtype.c b/net/netfilter/xt_addrtype.c
index 68ff29f..fab6eea 100644
--- a/net/netfilter/xt_addrtype.c
+++ b/net/netfilter/xt_addrtype.c
@@ -202,7 +202,7 @@ static int addrtype_mt_checkentry_v1(const struct xt_mtchk_param *par)
 			return -EINVAL;
 		}
 		if ((info->source | info->dest) >= XT_ADDRTYPE_PROHIBIT) {
-			pr_err("ipv6 PROHIBT (THROW, NAT ..) matching not supported\n");
+			pr_err("ipv6 PROHIBIT (THROW, NAT ..) matching not supported\n");
 			return -EINVAL;
 		}
 		if ((info->source | info->dest) & XT_ADDRTYPE_BROADCAST) {
-- 
1.7.10.4
