From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH iproute2 1/3] Update inet_diag.h header to pick up INET_DIAG_MARK
Date: Tue, 20 Sep 2016 22:43:42 -0400
Message-ID: <1474425824-22646-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f172.google.com ([209.85.216.172]:36558 "EHLO
        mail-qt0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754795AbcIUCnr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 22:43:47 -0400
Received: by mail-qt0-f172.google.com with SMTP id l91so16626314qte.3
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 19:43:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To ease the upcoming addition of BBR-related data to inet_diag.h, add
the declaration of INET_DIAG_MARK. That way the BBR-related paches
only contain BBR-related pieces.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 include/linux/inet_diag.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index 07e486c..5dac049 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -116,6 +116,7 @@ enum {
 	INET_DIAG_LOCALS,
 	INET_DIAG_PEERS,
 	INET_DIAG_PAD,
+	INET_DIAG_MARK,
 	__INET_DIAG_MAX,
 };
 
-- 
2.8.0.rc3.226.g39d4020
