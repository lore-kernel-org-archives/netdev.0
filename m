From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 1/1] tc: updated tc-u32 man page to reflect skip_sw and skip_hw parameters.
Date: Wed, 21 Jun 2017 11:14:22 -0400
Message-ID: <1498058062-14399-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35966 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752506AbdFUPPB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 11:15:01 -0400
Received: by mail-it0-f65.google.com with SMTP id 185so1039580itv.3
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 08:14:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 man/man8/tc-u32.8 | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/man/man8/tc-u32.8 b/man/man8/tc-u32.8
index 691f53c..e9475a9 100644
--- a/man/man8/tc-u32.8
+++ b/man/man8/tc-u32.8
@@ -29,6 +29,10 @@ u32 \- universal 32bit traffic control filter
 .IR HANDLE " ] [ "
 .B indev
 .IR ifname " ] [ "
+.B skip_hw
+.R  "|"
+.B skip_sw
+.R " ] [ "
 .BR help " ]"
 
 .ti -8
@@ -331,6 +335,13 @@ option.
 Filter on the incoming interface of the packet. Obviously works only for
 forwarded traffic.
 .TP
+.BI skip_sw
+Do not process filter by software. If hardware has no offload support for this
+filter, or TC offload is not enabled for the interface, operation will fail.
+.TP
+.BI skip_hw
+Do not process filter by hardware.
+.TP
 .BI help
 Print a brief help text about possible options.
 .SH SELECTORS
-- 
1.9.1
