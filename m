From: "Sergey V. Lobanov" <sergey@lobanov.in>
Subject: [PATCH iproute2 v2] Fix Linux priority and band for TOS==0x2 (man 8 tc-prio)
Date: Fri,  9 May 2014 23:22:42 +0400
Message-ID: <1399663362-23054-1-git-send-email-sergey@lobanov.in>
Cc: "Sergey V. Lobanov" <sergey@lobanov.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward8.mail.yandex.net ([77.88.61.38]:46847 "EHLO
	forward8.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755271AbaEITaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 15:30:21 -0400
Received: from smtp7.mail.yandex.net (smtp7.mail.yandex.net [77.88.61.55])
	by forward8.mail.yandex.net (Yandex) with ESMTP id A4834F60B15
	for <netdev@vger.kernel.org>; Fri,  9 May 2014 23:23:04 +0400 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to commit 4a2b9c3(in Linux kernel) Linux priority(skb->priority)
changed for TOS==0x2

Signed-off-by: Sergey V. Lobanov <sergey@lobanov.in>
---
 man/man8/tc-prio.8 |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/tc-prio.8 b/man/man8/tc-prio.8
index 1625fcc..78694ea 100644
--- a/man/man8/tc-prio.8
+++ b/man/man8/tc-prio.8
@@ -106,7 +106,7 @@ see in the first column of this table:
 TOS     Bits  Means                    Linux Priority    Band
 ------------------------------------------------------------
 0x0     0     Normal Service           0 Best Effort     1
-0x2     1     Minimize Monetary Cost   1 Filler          2
+0x2     1     Minimize Monetary Cost   0 Best Effort     1
 0x4     2     Maximize Reliability     0 Best Effort     1
 0x6     3     mmc+mr                   0 Best Effort     1
 0x8     4     Maximize Throughput      2 Bulk            2
-- 
1.7.9.5
