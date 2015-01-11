From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: sched: sch_teql: Remove unused function
Date: Sun, 11 Jan 2015 15:08:46 +0100
Message-ID: <1420985326-18201-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:48979 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbbAKOFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2015 09:05:41 -0500
Received: by mail-we0-f175.google.com with SMTP id k11so15077134wes.6
        for <netdev@vger.kernel.org>; Sun, 11 Jan 2015 06:05:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the function teql_neigh_release() that is not used anywhere.

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 net/sched/sch_teql.c |    7 -------
 1 file changed, 7 deletions(-)

diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 6ada423..4899d4a 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -122,13 +122,6 @@ teql_peek(struct Qdisc *sch)
 	return NULL;
 }
 
-static inline void
-teql_neigh_release(struct neighbour *n)
-{
-	if (n)
-		neigh_release(n);
-}
-
 static void
 teql_reset(struct Qdisc *sch)
 {
-- 
1.7.10.4
