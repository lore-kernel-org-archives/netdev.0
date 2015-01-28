From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch iproute2] skbedit: print action too
Date: Wed, 28 Jan 2015 14:52:42 -0800
Message-ID: <1422485562-15572-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:65125 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbbA2Baw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 20:30:52 -0500
Received: by mail-pa0-f48.google.com with SMTP id ey11so32210983pad.7
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 17:30:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 tc/m_skbedit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tc/m_skbedit.c b/tc/m_skbedit.c
index 36323a9..c5deee0 100644
--- a/tc/m_skbedit.c
+++ b/tc/m_skbedit.c
@@ -193,7 +193,7 @@ static int print_skbedit(struct action_util *au, FILE *f, struct rtattr *arg)
 		fprintf(f, " mark %d", *mark);
 	}
 
-	fprintf(f, "\n\t index %d ref %d bind %d", p->index, p->refcnt, p->bindcnt);
+	fprintf(f, " %s\n\t index %d ref %d bind %d", action_n2a(p->action, b1, sizeof (b1)), p->index, p->refcnt, p->bindcnt);
 
 	if (show_stats) {
 		if (tb[TCA_SKBEDIT_TM]) {
-- 
1.8.3.1
