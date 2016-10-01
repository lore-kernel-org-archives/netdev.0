From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH iproute2 1/9] ife action: allow specifying index in hex
Date: Sat,  1 Oct 2016 16:48:29 -0400
Message-ID: <1475354917-7912-2-git-send-email-jhs@emojatatu.com>
References: <1475354917-7912-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Roman Mashak <mrv@mojatatu.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32815 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751764AbcJAUtQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2016 16:49:16 -0400
Received: by mail-pf0-f195.google.com with SMTP id q2so6601751pfj.0
        for <netdev@vger.kernel.org>; Sat, 01 Oct 2016 13:48:49 -0700 (PDT)
In-Reply-To: <1475354917-7912-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Mashak <mrv@mojatatu.com>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_ife.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tc/m_ife.c b/tc/m_ife.c
index 0219760..a5a7516 100644
--- a/tc/m_ife.c
+++ b/tc/m_ife.c
@@ -152,7 +152,7 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
 			NEXT_ARG();
-			if (get_u32(&p.index, *argv, 10)) {
+			if (get_u32(&p.index, *argv, 0)) {
 				fprintf(stderr, "ife: Illegal \"index\"\n");
 				return -1;
 			}
-- 
1.9.1
