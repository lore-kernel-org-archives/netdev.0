From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [iproute2 3/3] police: bug fix man page
Date: Sun, 28 Aug 2016 08:52:42 -0400
Message-ID: <1472388762-18035-3-git-send-email-jhs@emojatatu.com>
References: <1472388762-18035-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Roman Mashak <mrv@mojatatu.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35475 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932253AbcH1M7M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 08:59:12 -0400
Received: by mail-it0-f65.google.com with SMTP id f128so4272116ith.2
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 05:59:11 -0700 (PDT)
In-Reply-To: <1472388762-18035-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Mashak <mrv@mojatatu.com>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 man/man8/tc-police.8 | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/man/man8/tc-police.8 b/man/man8/tc-police.8
index 5c5a632..620c288 100644
--- a/man/man8/tc-police.8
+++ b/man/man8/tc-police.8
@@ -26,10 +26,10 @@ police - policing action
 
 .ti -8
 .IR CONTROL " :="
-.BI conform-exceed " EXCEEDACT\fR[\fB/\fIEXCEEDACT"
+.BI conform-exceed " EXCEEDACT\fR[\fB/\fINOTEXCEEDACT"
 
 .ti -8
-.IR EXCEEDACT " := { "
+.IR EXCEEDACT/NOTEXCEEDACT " := { "
 .BR pipe " | " ok " | " reclassify " | " drop " | " continue " }"
 .SH DESCRIPTION
 The
@@ -94,11 +94,9 @@ Fine-tune the in-kernel packet rate estimator.
 are time values and control the frequency in which samples are taken and over
 what timespan an average is built.
 .TP
-.BI conform-exceed " EXCEEDACT\fR[\fB/\fIEXCEEDACT\fR]"
-Define how to handle packets which exceed (and, if the second
-.I EXCEEDACT
-is given, also those who don't), the configured bandwidth limit. Possible values
-are:
+.BI conform-exceed " EXCEEDACT\fR[\fB/\fINOTEXCEEDACT\fR]"
+Define how to handle packets which exceed or conform the
+configured bandwidth limit. Possible values are:
 .RS
 .IP continue
 Don't do anything, just continue with the next action in line.
-- 
1.9.1
