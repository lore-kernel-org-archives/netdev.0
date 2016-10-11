From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH v2 iproute2 5/9] action gact: list pipe as a valid action
Date: Tue, 11 Oct 2016 07:00:44 -0400
Message-ID: <1476183648-25850-6-git-send-email-jhs@emojatatu.com>
References: <1476183648-25850-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, mrv@mojatatu.com, cdillaba@mojatatu.com,
        lucasb@mojatatu.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33575 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751503AbcJKLOj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 07:14:39 -0400
Received: by mail-it0-f68.google.com with SMTP id m138so1392487itm.0
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 04:14:38 -0700 (PDT)
In-Reply-To: <1476183648-25850-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Dillabaugh <cdillaba@mojatatu.com>

Signed-off-by: Craig Dillabaugh <cdillaba@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_gact.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tc/m_gact.c b/tc/m_gact.c
index 2bfd9a7..dc04b9f 100644
--- a/tc/m_gact.c
+++ b/tc/m_gact.c
@@ -45,7 +45,7 @@ explain(void)
 #ifdef CONFIG_GACT_PROB
 	fprintf(stderr, "Usage: ... gact <ACTION> [RAND] [INDEX]\n");
 	fprintf(stderr,
-		"Where: \tACTION := reclassify | drop | continue | pass\n"
+		"Where: \tACTION := reclassify | drop | continue | pass | pipe\n"
 			"\tRAND := random <RANDTYPE> <ACTION> <VAL>\n"
 			"\tRANDTYPE := netrand | determ\n"
 			"\tVAL : = value not exceeding 10000\n"
@@ -54,7 +54,7 @@ explain(void)
 #else
 	fprintf(stderr, "Usage: ... gact <ACTION> [INDEX]\n");
 	fprintf(stderr,
-		"Where: \tACTION := reclassify | drop | continue | pass\n"
+		"Where: \tACTION := reclassify | drop | continue | pass | pipe\n"
 		"\tINDEX := index value used\n"
 		"\n");
 #endif
-- 
1.9.1
