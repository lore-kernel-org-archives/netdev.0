From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH v2 iproute2 1/9] ife action: allow specifying index in hex
Date: Tue, 11 Oct 2016 07:00:40 -0400
Message-ID: <1476183648-25850-2-git-send-email-jhs@emojatatu.com>
References: <1476183648-25850-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, mrv@mojatatu.com, cdillaba@mojatatu.com,
        lucasb@mojatatu.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34139 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752385AbcJKLOf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 07:14:35 -0400
Received: by mail-io0-f194.google.com with SMTP id i202so1362512ioi.1
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 04:14:35 -0700 (PDT)
In-Reply-To: <1476183648-25850-1-git-send-email-jhs@emojatatu.com>
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
