From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 1/1] tc: improved usage help for fw classifier.
Date: Thu, 10 Nov 2016 11:02:57 -0500
Message-ID: <1478793777-8979-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
        Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33006 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933663AbcKJQDc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 11:03:32 -0500
Received: by mail-it0-f67.google.com with SMTP id e187so4324312itc.0
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 08:03:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/f_fw.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/tc/f_fw.c b/tc/f_fw.c
index 29c9854..790bef9 100644
--- a/tc/f_fw.c
+++ b/tc/f_fw.c
@@ -25,10 +25,19 @@
 
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... fw [ classid CLASSID ] [ action ACTION_SPEC ]\n");
-	fprintf(stderr, "       ACTION_SPEC := ... look at individual actions\n");
-	fprintf(stderr, "       CLASSID := X:Y\n");
-	fprintf(stderr, "\nNOTE: CLASSID is parsed as hexadecimal input.\n");
+	fprintf(stderr,
+		"Usage: ... fw [ classid CLASSID ] [ indev DEV ] [ action ACTION_SPEC ]\n");
+	fprintf(stderr,
+		"       CLASSID := Push matching packets to the class identified by CLASSID with format X:Y\n");
+	fprintf(stderr,
+		"                  CLASSID is parsed as hexadecimal input.\n");
+	fprintf(stderr,
+		"       DEV := specify device for incoming device classification.\n");
+	fprintf(stderr,
+		"       ACTION_SPEC := Apply an action on matching packets.\n");
+	fprintf(stderr,
+		"       NOTE: handle is represented as HANDLE[/FWMASK].\n");
+	fprintf(stderr, "             FWMASK is 0xffffffff by default.\n");
 }
 
 static int fw_parse_opt(struct filter_util *qu, char *handle, int argc, char **argv, struct nlmsghdr *n)
-- 
1.9.1
