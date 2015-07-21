From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man ss: Fix explanation when no options specified
Date: Tue, 21 Jul 2015 16:46:28 +0300
Message-ID: <1437486388-5131-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:33534 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbbGUNsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 09:48:43 -0400
Received: by wicmv11 with SMTP id mv11so42234592wic.0
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 06:48:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Really by default ss dumps not only TCP sockets but any kind of socket
which is in ESTABLISHED state (TCP/UDP/UNIX).

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
Reported-by: Miha Marolt <miham@beyondsemi.com>
---
 man/man8/ss.8 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/ss.8 b/man/man8/ss.8
index b7fbaef..6afbabb 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -13,7 +13,7 @@ It can display more TCP and state informations than other tools.
 
 .SH OPTIONS
 When no option is used ss displays a list of 
-open non-listening TCP sockets that have established connection.
+open non-listening sockets (e.g. TCP/UNIX/UDP) that have established connection.
 .TP
 .B \-h, \-\-help
 Show summary of options.
-- 
2.4.2
