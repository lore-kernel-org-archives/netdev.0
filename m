From: kaber@trash.net
Subject: [PATCH 56/79] netfilter: xt_comment: drop unneeded unsigned qualifier
Date: Wed, 19 Jan 2011 20:14:56 +0100
Message-ID: <1295464519-21763-57-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51989 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753906Ab1ASTPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:38 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

Since a string is stored, and not something like a MAC address that
would rely on (un)signedness, drop the qualifier.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/xt_comment.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter/xt_comment.h b/include/linux/netfilter/xt_comment.h
index eacfedc..0ea5e79 100644
--- a/include/linux/netfilter/xt_comment.h
+++ b/include/linux/netfilter/xt_comment.h
@@ -4,7 +4,7 @@
 #define XT_MAX_COMMENT_LEN 256
 
 struct xt_comment_info {
-	unsigned char comment[XT_MAX_COMMENT_LEN];
+	char comment[XT_MAX_COMMENT_LEN];
 };
 
 #endif /* XT_COMMENT_H */
-- 
1.7.2.3

