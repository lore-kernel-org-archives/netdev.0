From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] netlink: add minlen validation for the new signed types
Date: Sun, 26 Aug 2012 11:47:57 +0300
Message-ID: <1345970877-4408-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:38233 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751648Ab2HZIqF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Aug 2012 04:46:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 lib/nlattr.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/nlattr.c b/lib/nlattr.c
index 4226dfe..18eca78 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -22,6 +22,10 @@ static const u16 nla_attr_minlen[NLA_TYPE_MAX+1] = {
 	[NLA_U64]	= sizeof(u64),
 	[NLA_MSECS]	= sizeof(u64),
 	[NLA_NESTED]	= NLA_HDRLEN,
+	[NLA_S8]	= sizeof(s8),
+	[NLA_S16]	= sizeof(s16),
+	[NLA_S32]	= sizeof(s32),
+	[NLA_S64]	= sizeof(s64),
 };
 
 static int validate_nla(const struct nlattr *nla, int maxtype,
-- 
1.7.3.4
