From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH iproute2 1/2] skbedit to default to pipe
Date: Sat, 21 Dec 2013 16:38:36 -0500
Message-ID: <1387661917-29520-2-git-send-email-jhs@mojatatu.com>
References: <1387661917-29520-1-git-send-email-jhs@mojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org, alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:42727 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756144Ab3LUVjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Dec 2013 16:39:11 -0500
Received: by mail-ie0-f173.google.com with SMTP id to1so4652816ieb.18
        for <netdev@vger.kernel.org>; Sat, 21 Dec 2013 13:39:11 -0800 (PST)
In-Reply-To: <1387661917-29520-1-git-send-email-jhs@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow skbedit to be used as is in an action chain by default
without need to specify pipe

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_skbedit.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/tc/m_skbedit.c b/tc/m_skbedit.c
index cca05ed..6b582f3 100644
--- a/tc/m_skbedit.c
+++ b/tc/m_skbedit.c
@@ -99,6 +99,7 @@ parse_skbedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 		argv++;
 	}
 
+	sel.action = TC_ACT_PIPE;
 	if (argc) {
 		if (matches(*argv, "reclassify") == 0) {
 			sel.action = TC_ACT_RECLASSIFY;
-- 
1.7.9.5
