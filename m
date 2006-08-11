From: Steven Whitehouse <steve@chygwyn.com>
Subject: [DECNET] Fix to multiple tables routing
Date: Fri, 11 Aug 2006 15:27:42 +0100
Message-ID: <20060811142742.GA31748@souterrain.chygwyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick Caulfield <patrick@tykepenguin.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from souterrain.chygwyn.com ([194.39.143.233]:40642 "EHLO
	souterrain.chygwyn.com") by vger.kernel.org with ESMTP
	id S1751149AbWHKOXg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 10:23:36 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here is a fix to Patrick McHardy's increase number of routing tables patch
for DECnet. I did just test this and it appears to be working fine with
this patch.

Cc: Patrick McHardy <kaber@trash.net>
Cc: Patrick Caulfield <patrick@tykepenguin.com>
Signed-off-by: Steven Whitehouse <steve@chygwyn.com>

diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index 878312f..c8d9411 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -116,6 +116,7 @@ static struct nla_policy dn_fib_rule_pol
 	[FRA_SRC]	= { .type = NLA_U16 },
 	[FRA_DST]	= { .type = NLA_U16 },
 	[FRA_FWMARK]	= { .type = NLA_U32 },
+	[FRA_TABLE]     = { .type = NLA_U32 },
 };
 
 static int dn_fib_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
