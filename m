From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man ip-link: Fix indentation for 'ip link show' options
Date: Tue,  2 Dec 2014 22:39:11 +0200
Message-ID: <1417552751-3132-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:40606 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932987AbaLBUsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 15:48:54 -0500
Received: by mail-la0-f41.google.com with SMTP id hv19so6796093lab.28
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 12:48:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BEFORE:
              The show command has additional formatting options:

       -s, -stats, -statistics
              output more statistics about packet usage.

       -d, -details
              output more detailed information.

       -h, -human, -human-readble
              output statistics with human readable values number followed by suffix

       -iec   print human readable rates in IEC units (ie. 1K = 1024).
AFTER:
       The show command has additional formatting options:

              -s, -stats, -statistics
                     output more statistics about packet usage.

              -d, -details
                     output more detailed information.

              -h, -human, -human-readble
                     output statistics with human readable values number followed by suffix

              -iec   print human readable rates in IEC units (ie. 1K = 1024).

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ip-link.8.in | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 9d4e3da..cdd0a42 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -688,8 +688,10 @@ only display running interfaces.
 .I DEVICE
 specifies the master device which enslaves devices to show.
 
+.TP
 The show command has additional formatting options:
 
+.RS
 .TP
 .BR "\-s" , " \-stats", " \-statistics"
 output more statistics about packet usage.
@@ -705,6 +707,7 @@ output statistics with human readable values number followed by suffix
 .TP
 .BR "\-iec"
 print human readable rates in IEC units (ie. 1K = 1024).
+.RE
 
 .SS  ip link help - display help
 
-- 
2.1.3
