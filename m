From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH v2 iproute2 2/9] ife: print prio, mark and hash as unsigned
Date: Tue, 11 Oct 2016 07:00:41 -0400
Message-ID: <1476183648-25850-3-git-send-email-jhs@emojatatu.com>
References: <1476183648-25850-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, mrv@mojatatu.com, cdillaba@mojatatu.com,
        lucasb@mojatatu.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36453 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751953AbcJKMFT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 08:05:19 -0400
Received: by mail-it0-f65.google.com with SMTP id o19so1453902ito.3
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 05:05:19 -0700 (PDT)
In-Reply-To: <1476183648-25850-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Mashak <mrv@mojatatu.com>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_ife.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/tc/m_ife.c b/tc/m_ife.c
index a5a7516..588bad7 100644
--- a/tc/m_ife.c
+++ b/tc/m_ife.c
@@ -252,7 +252,7 @@ static int print_ife(struct action_util *au, FILE *f, struct rtattr *arg)
 			len = RTA_PAYLOAD(metalist[IFE_META_SKBMARK]);
 			if (len) {
 				mmark = rta_getattr_u32(metalist[IFE_META_SKBMARK]);
-				fprintf(f, "use mark %d ", mmark);
+				fprintf(f, "use mark %u ", mmark);
 			} else
 				fprintf(f, "allow mark ");
 		}
@@ -261,7 +261,7 @@ static int print_ife(struct action_util *au, FILE *f, struct rtattr *arg)
 			len = RTA_PAYLOAD(metalist[IFE_META_HASHID]);
 			if (len) {
 				mhash = rta_getattr_u32(metalist[IFE_META_HASHID]);
-				fprintf(f, "use hash %d ", mhash);
+				fprintf(f, "use hash %u ", mhash);
 			} else
 				fprintf(f, "allow hash ");
 		}
@@ -270,7 +270,7 @@ static int print_ife(struct action_util *au, FILE *f, struct rtattr *arg)
 			len = RTA_PAYLOAD(metalist[IFE_META_PRIO]);
 			if (len) {
 				mprio = rta_getattr_u32(metalist[IFE_META_PRIO]);
-				fprintf(f, "use prio %d ", mprio);
+				fprintf(f, "use prio %u ", mprio);
 			} else
 				fprintf(f, "allow prio ");
 		}
-- 
1.9.1
