From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/18] netfilter: xt_LOG: add missing string format in nf_log_packet()
Date: Fri, 18 Jul 2014 13:01:08 +0200
Message-ID: <1405681272-4994-15-git-send-email-pablo@netfilter.org>
References: <1405681272-4994-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46639 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761516AbaGRLB2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2014 07:01:28 -0400
In-Reply-To: <1405681272-4994-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   net/netfilter/xt_LOG.c: In function 'log_tg':
>> net/netfilter/xt_LOG.c:43: error: format not a string literal and no format arguments

Fixes: fab4085 ("netfilter: log: nf_log_packet() as real unified interface")
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_LOG.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
index 00eb491..c13b794 100644
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@ -40,7 +40,7 @@ log_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	li.u.log.logflags = loginfo->logflags;
 
 	nf_log_packet(net, par->family, par->hooknum, skb, par->in, par->out,
-		      &li, loginfo->prefix);
+		      &li, "%s", loginfo->prefix);
 	return XT_CONTINUE;
 }
 
-- 
1.7.10.4
