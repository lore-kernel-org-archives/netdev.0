From: Alexander Aring <aring@mojatatu.com>
Subject: [PATCH iproute2] tc: m_ife: fix match tcindex parsing
Date: Mon, 30 Oct 2017 12:37:49 -0400
Message-ID: <20171030163749.31291-1-aring@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
        Alexander Aring <aring@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:55233 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751475AbdJ3QiF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 12:38:05 -0400
Received: by mail-io0-f193.google.com with SMTP id e89so28519971ioi.11
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 09:38:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes ife_prio to ife_tcindex which is right variable to
assign in the argument in this case.

Signed-off-by: Alexander Aring <aring@mojatatu.com>
---
Found by inspection the code.

 tc/m_ife.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tc/m_ife.c b/tc/m_ife.c
index 5633ab90..8d0fd31f 100644
--- a/tc/m_ife.c
+++ b/tc/m_ife.c
@@ -93,7 +93,7 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
 			} else if (matches(*argv, "prio") == 0) {
 				ife_prio = IFE_META_PRIO;
 			} else if (matches(*argv, "tcindex") == 0) {
-				ife_prio = IFE_META_TCINDEX;
+				ife_tcindex = IFE_META_TCINDEX;
 			} else {
 				fprintf(stderr, "Illegal meta define <%s>\n",
 					*argv);
-- 
2.11.0
