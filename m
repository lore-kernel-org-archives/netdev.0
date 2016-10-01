From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH iproute2 5/9] action gact: list pipe as a valid action
Date: Sat,  1 Oct 2016 16:48:33 -0400
Message-ID: <1475354917-7912-6-git-send-email-jhs@emojatatu.com>
References: <1475354917-7912-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Craig Dillabaugh <cdillaba@mojatatu.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34133 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751959AbcJAUtQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2016 16:49:16 -0400
Received: by mail-pa0-f67.google.com with SMTP id r9so5694474paz.1
        for <netdev@vger.kernel.org>; Sat, 01 Oct 2016 13:48:56 -0700 (PDT)
In-Reply-To: <1475354917-7912-1-git-send-email-jhs@emojatatu.com>
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
