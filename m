From: kaber@trash.net
Subject: [PATCH 12/72] netfilter: ctnetlink: missing validation of CTA_EXPECT_ZONE attribute
Date: Thu, 21 Oct 2010 17:18:59 +0200
Message-ID: <1287674399-31455-13-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch adds the missing validation of the CTA_EXPECT_ZONE
attribute in the ctnetlink code.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_netlink.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 5bae1cd..37533a3 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1733,6 +1733,7 @@ static const struct nla_policy exp_nla_policy[CTA_EXPECT_MAX+1] = {
 	[CTA_EXPECT_TIMEOUT]	= { .type = NLA_U32 },
 	[CTA_EXPECT_ID]		= { .type = NLA_U32 },
 	[CTA_EXPECT_HELP_NAME]	= { .type = NLA_NUL_STRING },
+	[CTA_EXPECT_ZONE]	= { .type = NLA_U16 },
 };
 
 static int
-- 
1.7.1

