From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH iproute2 7/9] man pages: update ife action to include tcindex
Date: Sat,  1 Oct 2016 16:48:35 -0400
Message-ID: <1475354917-7912-8-git-send-email-jhs@emojatatu.com>
References: <1475354917-7912-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Lucas Bates <lucasb@mojatatu.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33476 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752051AbcJAUtQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2016 16:49:16 -0400
Received: by mail-pa0-f68.google.com with SMTP id oz2so6347084pac.0
        for <netdev@vger.kernel.org>; Sat, 01 Oct 2016 13:48:59 -0700 (PDT)
In-Reply-To: <1475354917-7912-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Bates <lucasb@mojatatu.com>

Signed-off-by: Lucas Bates <lucasb@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 man/man8/tc-ife.8 | 29 ++++++++++++++++++++++++++---
 1 file changed, 26 insertions(+), 3 deletions(-)

diff --git a/man/man8/tc-ife.8 b/man/man8/tc-ife.8
index 7b3601e..aaf0f97 100644
--- a/man/man8/tc-ife.8
+++ b/man/man8/tc-ife.8
@@ -5,8 +5,8 @@ IFE - encapsulate/decapsulate metadata
 .SH SYNOPSIS
 .in +8
 .ti -8
-.BR tc " ... " action ife"
-.I DIRECTION ACTION
+.BR tc " ... " " action ife"
+.IR DIRECTION " [ " ACTION " ] "
 .RB "[ " dst
 .IR DMAC " ] "
 .RB "[ " src
@@ -24,7 +24,13 @@ IFE - encapsulate/decapsulate metadata
 
 .ti -8
 .IR ACTION " := { "
-.BR allow " | " use " }"
+.BI allow " ATTR"
+.RB "| " use
+.IR "ATTR value" " }"
+
+.ti -8
+.IR ATTR " := { "
+.BR mark " | " prio " | " tcindex " }"
 
 .ti -8
 .IR CONTROL " := { "
@@ -50,6 +56,23 @@ Encode direction only. Allows encoding specified metadata.
 .B use
 Encode direction only. Enforce static encoding of specified metadata.
 .TP
+.BR mark " [ "
+.IR u32_value " ]"
+The value to set for the skb mark. The u32 value is required only when
+.BR use " is specified."
+.TP
+.BR prio " [ "
+.IR u32_value " ]"
+The value to set for priority in the skb structure. The u32 value is required
+only when
+.BR use " is specified."
+.TP
+.BR tcindex " ["
+.IR u16_value " ]"
+Value to set for the traffic control index in the skb structure. The u16 value
+is required only when
+.BR use " is specified."
+.TP
 .BI dmac " DMAC"
 .TQ
 .BI smac " SMAC"
-- 
1.9.1
