From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 7/8] tcp: make nla_policy const
Date: Wed, 31 Aug 2016 15:21:37 -0700
Message-ID: <20160831152137.5228d75c@xeon-e3>
References: <20160831151445.6c8e4e06@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35671 "EHLO
        mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751696AbcIAGZQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 02:25:16 -0400
Received: by mail-pa0-f44.google.com with SMTP id hb8so26511896pac.2
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 23:25:15 -0700 (PDT)
In-Reply-To: <20160831151445.6c8e4e06@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/ipv4/tcp_metrics.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index b617826..bf1f3b2 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -751,7 +751,7 @@ static struct genl_family tcp_metrics_nl_family = {
 	.netnsok	= true,
 };
 
-static struct nla_policy tcp_metrics_nl_policy[TCP_METRICS_ATTR_MAX + 1] = {
+static const struct nla_policy tcp_metrics_nl_policy[TCP_METRICS_ATTR_MAX + 1] = {
 	[TCP_METRICS_ATTR_ADDR_IPV4]	= { .type = NLA_U32, },
 	[TCP_METRICS_ATTR_ADDR_IPV6]	= { .type = NLA_BINARY,
 					    .len = sizeof(struct in6_addr), },
-- 
2.9.3
