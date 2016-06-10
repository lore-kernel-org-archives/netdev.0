From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 5/9] tc: m_xt: Drop unused variable fw in parse_ipt()
Date: Fri, 10 Jun 2016 13:42:04 +0200
Message-ID: <1465558928-19657-6-git-send-email-phil@nwl.cc>
References: <1465558928-19657-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:60544 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751251AbcFJLnM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 07:43:12 -0400
In-Reply-To: <1465558928-19657-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_xt.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/tc/m_xt.c b/tc/m_xt.c
index b3731086c717b..c42f3bda4e8f4 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -120,7 +120,6 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 		     char ***argv_p, int tca_id, struct nlmsghdr *n)
 {
 	struct xtables_target *m = NULL;
-	struct ipt_entry fw;
 	struct rtattr *tail;
 
 	int c;
@@ -189,7 +188,6 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 			break;
 
 		default:
-			memset(&fw, 0, sizeof(fw));
 #if (XTABLES_VERSION_CODE >= 6)
 			if (m != NULL && m->x6_parse != NULL) {
 				xtables_option_tpcall(c, argv, 0, m, NULL);
-- 
2.8.2
