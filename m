From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 06/18] batman-adv: remove a misleading comment
Date: Thu, 23 Aug 2012 15:10:15 +0200
Message-ID: <1345727427-20805-7-git-send-email-ordex@autistici.org>
References: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Jonathan Corbet <corbet@lwn.net>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:28751 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933161Ab2HWNKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:10:53 -0400
In-Reply-To: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonathan Corbet <corbet@lwn.net>

As much as I'm happy to see LWN links sprinkled through the kernel by the
dozen, this one in particular reflects a very old state of reality; the
associated comment is now incorrect.  So just delete it.

Signed-off-by: Jonathan Corbet <corbet@lwn.net>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/main.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 13c88b2..2a1f243 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -58,9 +58,6 @@ static int __init batadv_init(void)
 
 	batadv_iv_init();
 
-	/* the name should not be longer than 10 chars - see
-	 * http://lwn.net/Articles/23634/
-	 */
 	batadv_event_workqueue = create_singlethread_workqueue("bat_events");
 
 	if (!batadv_event_workqueue)
-- 
1.7.9.4
