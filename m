From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH iproute2 1/1] tc classifiers: Modernize tcindex classifier
Date: Wed, 17 Aug 2016 07:16:53 -0400
Message-ID: <1471432613-13459-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35946 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753619AbcHQLRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 07:17:14 -0400
Received: by mail-io0-f193.google.com with SMTP id y34so9692981ioi.3
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 04:17:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/f_tcindex.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tc/f_tcindex.c b/tc/f_tcindex.c
index 280d1d4..0a73784 100644
--- a/tc/f_tcindex.c
+++ b/tc/f_tcindex.c
@@ -99,7 +99,7 @@ static int tcindex_parse_opt(struct filter_util *qu, char *handle, int argc,
 			continue;
 		} else if (!strcmp(*argv,"action")) {
 			NEXT_ARG();
-			if (parse_police(&argc, &argv, TCA_TCINDEX_ACT, n)) {
+			if (parse_action(&argc, &argv, TCA_TCINDEX_ACT, n)) {
 				fprintf(stderr, "Illegal \"action\"\n");
 				return -1;
 			}
-- 
1.9.1
