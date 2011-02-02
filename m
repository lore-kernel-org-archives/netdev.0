From: kaber@trash.net
Subject: [PATCH 16/26] netfilter: ctnetlink: fix ctnetlink_parse_tuple() warning
Date: Thu,  3 Feb 2011 00:11:54 +0100
Message-ID: <1296688324-7830-17-git-send-email-kaber@trash.net>
References: <1296688324-7830-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1296688324-7830-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

net/netfilter/nf_conntrack_netlink.c: In function 'ctnetlink_parse_tuple':
net/netfilter/nf_conntrack_netlink.c:832:11: warning: comparison between 'enum ctattr_tuple' and 'enum ctattr_type'

Use ctattr_type for the 'type' parameter since that's the type of all attributes
passed to this function.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_netlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 61c7394..cb1a819 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -803,7 +803,7 @@ static const struct nla_policy tuple_nla_policy[CTA_TUPLE_MAX+1] = {
 static int
 ctnetlink_parse_tuple(const struct nlattr * const cda[],
 		      struct nf_conntrack_tuple *tuple,
-		      enum ctattr_tuple type, u_int8_t l3num)
+		      enum ctattr_type type, u_int8_t l3num)
 {
 	struct nlattr *tb[CTA_TUPLE_MAX+1];
 	int err;
-- 
1.7.2.3

