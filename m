From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next] doc:networking: Fix default value (icmp_ignore_bogus_error_responses).
Date: Sat,  8 Jun 2013 09:16:19 +0300
Message-ID: <1370672179-2664-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:35680 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041Ab3FHDQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 23:16:43 -0400
Received: by mail-ea0-f177.google.com with SMTP id j14so4001465eak.36
        for <netdev@vger.kernel.org>; Fri, 07 Jun 2013 20:16:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes icmp_ignore_bogus_error_responses default value to be 1 instead 
of FALSE. It is initialized to 1 in icmp_sk_init().

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 Documentation/networking/ip-sysctl.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 398d0fb..9cea5d3 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -729,7 +729,7 @@ icmp_ignore_bogus_error_responses - BOOLEAN
 	frames.  Such violations are normally logged via a kernel warning.
 	If this is set to TRUE, the kernel will not give such warnings, which
 	will avoid log file clutter.
-	Default: FALSE
+	Default: 1
 
 icmp_errors_use_inbound_ifaddr - BOOLEAN
 
-- 
1.8.1.4
