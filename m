From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [iproute2 2/3] police: improve usage message
Date: Sun, 28 Aug 2016 08:52:41 -0400
Message-ID: <1472388762-18035-2-git-send-email-jhs@emojatatu.com>
References: <1472388762-18035-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Roman Mashak <mrv@mojatatu.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33534 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755261AbcH1M7K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 08:59:10 -0400
Received: by mail-it0-f67.google.com with SMTP id d65so4279258ith.0
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 05:59:10 -0700 (PDT)
In-Reply-To: <1472388762-18035-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Mashak <mrv@mojatatu.com>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_police.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/tc/m_police.c b/tc/m_police.c
index d7fa8f6..226e20e 100644
--- a/tc/m_police.c
+++ b/tc/m_police.c
@@ -36,11 +36,12 @@ static void usage(void)
 {
 	fprintf(stderr, "Usage: ... police rate BPS burst BYTES[/BYTES] [ mtu BYTES[/BYTES] ]\n");
 	fprintf(stderr, "                [ peakrate BPS ] [ avrate BPS ] [ overhead BYTES ]\n");
-	fprintf(stderr, "                [ linklayer TYPE ] [ ACTIONTERM ]\n");
+	fprintf(stderr, "                [ linklayer TYPE ] [ CONTROL ]\n");
 
-	fprintf(stderr, "New Syntax ACTIONTERM := conform-exceed <EXCEEDACT>[/NOTEXCEEDACT]\n");
-	fprintf(stderr, "Where: *EXCEEDACT := pipe | ok | reclassify | drop | continue\n");
-	fprintf(stderr, "Where:  pipe is only valid for new syntax\n");
+	fprintf(stderr, "Where: CONTROL := conform-exceed <EXCEEDACT>[/NOTEXCEEDACT]\n");
+	fprintf(stderr, "                  Define how to handle packets which exceed (<EXCEEDACT>)\n");
+	fprintf(stderr, "                  or conform (<NOTEXCEEDACT>) the configured bandwidth limit.\n");
+	fprintf(stderr, "       EXCEEDACT/NOTEXCEEDACT := { pipe | ok | reclassify | drop | continue }\n");
 	exit(-1);
 }
 
-- 
1.9.1
