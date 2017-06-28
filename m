From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 1/1] tc: updated ife man page.
Date: Wed, 28 Jun 2017 13:05:04 -0400
Message-ID: <1498669504-23676-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34668 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751583AbdF1RFR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 13:05:17 -0400
Received: by mail-it0-f67.google.com with SMTP id o202so3694823itc.1
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 10:05:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Explain when skbmark encoding may fail.

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 man/man8/tc-ife.8 | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/man/man8/tc-ife.8 b/man/man8/tc-ife.8
index a8f1f28..1499a3f 100644
--- a/man/man8/tc-ife.8
+++ b/man/man8/tc-ife.8
@@ -59,7 +59,10 @@ Encode direction only. Enforce static encoding of specified metadata.
 .BR mark " [ "
 .IR u32_value " ]"
 The value to set for the skb mark. The u32 value is required only when
-.BR use " is specified."
+.BR use " is specified. If
+.BR mark " value is zero, it will not be encoded, instead
+"overlimits" statistics increment and
+.BR CONTROL " action is taken.
 .TP
 .BR prio " [ "
 .IR u32_value " ]"
-- 
1.9.1
