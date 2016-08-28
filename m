From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [iproute2 1/3] police: add extra space to improve police result printing
Date: Sun, 28 Aug 2016 08:52:40 -0400
Message-ID: <1472388762-18035-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Roman Mashak <mrv@mojatatu.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36614 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755271AbcH1MxT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 08:53:19 -0400
Received: by mail-it0-f65.google.com with SMTP id x131so4250938ite.3
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 05:52:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Mashak <mrv@mojatatu.com>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_police.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tc/m_police.c b/tc/m_police.c
index f0b179f..d7fa8f6 100644
--- a/tc/m_police.c
+++ b/tc/m_police.c
@@ -322,7 +322,7 @@ int print_police(struct action_util *a, FILE *f, struct rtattr *arg)
 	if (tb[TCA_POLICE_RESULT]) {
 		__u32 action = rta_getattr_u32(tb[TCA_POLICE_RESULT]);
 
-		fprintf(f, "/%s", action_n2a(action));
+		fprintf(f, "/%s ", action_n2a(action));
 	} else
 		fprintf(f, " ");
 
-- 
1.9.1
