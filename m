From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH 1/1] Remove unnecessary debug statement
Date: Sat, 24 May 2014 07:46:08 -0400
Message-ID: <1400931968-7862-1-git-send-email-jhs@emojatatu.com>
Cc: seann@herdejurgen.com, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:33842 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbaEXLqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 07:46:21 -0400
Received: by mail-ig0-f178.google.com with SMTP id hl10so1637439igb.17
        for <netdev@vger.kernel.org>; Sat, 24 May 2014 04:46:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Reported-by: Seann Herdejurgen <seann@herdejurgen.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_police.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/tc/m_police.c b/tc/m_police.c
index df295e0..915f1a5 100644
--- a/tc/m_police.c
+++ b/tc/m_police.c
@@ -149,7 +149,6 @@ int act_parse_police(struct action_util *a,int *argc_p, char ***argv_p, int tca_
 
 	while (argc > 0) {
 
-		fprintf(stderr,"police argc %d argv %s\n", argc, *argv);
 		if (matches(*argv, "index") == 0) {
 			NEXT_ARG();
 			if (get_u32(&p.index, *argv, 10)) {
-- 
1.7.9.5
