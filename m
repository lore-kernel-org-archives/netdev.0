From: David Miller <davem@davemloft.net>
Subject: [PATCH 08/26] xfrm: Const'ify pointer args to migrate_tmpl_match
 and xfrm_migrate_check
Date: Wed, 23 Feb 2011 23:13:17 -0800 (PST)
Message-ID: <20110223.231317.115937413.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37469
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932547Ab1BXHMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:12:40 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 6681524C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:13:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_policy.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 5f19ae6..eb76da7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2788,7 +2788,7 @@ static struct xfrm_policy * xfrm_migrate_policy_find(struct xfrm_selector *sel,
 	return ret;
 }
 
-static int migrate_tmpl_match(struct xfrm_migrate *m, struct xfrm_tmpl *t)
+static int migrate_tmpl_match(const struct xfrm_migrate *m, const struct xfrm_tmpl *t)
 {
 	int match = 0;
 
@@ -2858,7 +2858,7 @@ static int xfrm_policy_migrate(struct xfrm_policy *pol,
 	return 0;
 }
 
-static int xfrm_migrate_check(struct xfrm_migrate *m, int num_migrate)
+static int xfrm_migrate_check(const struct xfrm_migrate *m, int num_migrate)
 {
 	int i, j;
 
-- 
1.7.4.1

