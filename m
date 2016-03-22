From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 1/4] tc/p_ip.c: Minor coding style cleanup
Date: Tue, 22 Mar 2016 15:16:21 +0100
Message-ID: <1458656184-22154-2-git-send-email-phil@nwl.cc>
References: <1458656184-22154-1-git-send-email-phil@nwl.cc>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:34752 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758612AbcCVOQi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 10:16:38 -0400
In-Reply-To: <1458656184-22154-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Break overlong function definitions and remove one extraneous
whitespace.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/p_ip.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/tc/p_ip.c b/tc/p_ip.c
index 53dfb2693d47e..535151e5d7668 100644
--- a/tc/p_ip.c
+++ b/tc/p_ip.c
@@ -24,7 +24,8 @@
 #include "m_pedit.h"
 
 static int
-parse_ip(int *argc_p, char ***argv_p, struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
+parse_ip(int *argc_p, char ***argv_p,
+	 struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
 {
 	int res = -1;
 	int argc = *argc_p;
@@ -52,7 +53,7 @@ parse_ip(int *argc_p, char ***argv_p, struct tc_pedit_sel *sel, struct tc_pedit_
 	if (strcmp(*argv, "tos") == 0 || matches(*argv, "dsfield") == 0) {
 		NEXT_ARG();
 		tkey->off = 1;
-		res = parse_cmd(&argc, &argv,  1, TU32, RU8, sel, tkey);
+		res = parse_cmd(&argc, &argv, 1, TU32, RU8, sel, tkey);
 		goto done;
 	}
 	if (strcmp(*argv, "ihl") == 0) {
@@ -139,7 +140,8 @@ done:
 }
 
 static int
-parse_ip6(int *argc_p, char ***argv_p, struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
+parse_ip6(int *argc_p, char ***argv_p,
+	  struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
 {
 	int res = -1;
 	return res;
-- 
2.7.2
