From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 4/8] netns: make nla_policy const
Date: Wed, 31 Aug 2016 15:17:49 -0700
Message-ID: <20160831151749.6e4f5204@xeon-e3>
References: <20160831151445.6c8e4e06@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35806 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751015AbcIAGZL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 02:25:11 -0400
Received: by mail-pf0-f172.google.com with SMTP id x72so27870793pfd.2
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 23:25:11 -0700 (PDT)
In-Reply-To: <20160831151445.6c8e4e06@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/core/net_namespace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 1fe5816..7a77dca 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -533,7 +533,7 @@ static struct pernet_operations __net_initdata net_ns_ops = {
 	.exit = net_ns_net_exit,
 };
 
-static struct nla_policy rtnl_net_policy[NETNSA_MAX + 1] = {
+static const struct nla_policy rtnl_net_policy[NETNSA_MAX + 1] = {
 	[NETNSA_NONE]		= { .type = NLA_UNSPEC },
 	[NETNSA_NSID]		= { .type = NLA_S32 },
 	[NETNSA_PID]		= { .type = NLA_U32 },
-- 
2.9.3
