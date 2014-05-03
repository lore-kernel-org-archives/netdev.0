From: "Sergey V. Lobanov" <sergey@lobanov.in>
Subject: [PATCH iproute2] Fix Linux priority and band for TOS==0x2 (man 8 tc-prio)
Date: Sat,  3 May 2014 18:48:11 +0400
Message-ID: <1399128491-15991-1-git-send-email-sergey@lobanov.in>
Cc: "Sergey V. Lobanov" <sergey@lobanov.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward6l.mail.yandex.net ([84.201.143.139]:55309 "EHLO
	forward6l.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbaECO6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2014 10:58:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to commit 4a2b9c3(in Linux kernel) Linux priority(skb->priority)
changed for TOS==0x2

Signed-off-by: Sergey V. Lobanov <sergey@lobanov.in>
---
 man/man8/tc-prio.8 |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/tc-prio.8 b/man/man8/tc-prio.8
index 1625fcc..33a0164 100644
--- a/man/man8/tc-prio.8
+++ b/man/man8/tc-prio.8
@@ -106,7 +106,7 @@ see in the first column of this table:
 TOS     Bits  Means                    Linux Priority    Band
 ------------------------------------------------------------
 0x0     0     Normal Service           0 Best Effort     1
-0x2     1     Minimize Monetary Cost   1 Filler          2
+0x2     1     mmc (deprecated)         0 Best Effort     1
 0x4     2     Maximize Reliability     0 Best Effort     1
 0x6     3     mmc+mr                   0 Best Effort     1
 0x8     4     Maximize Throughput      2 Bulk            2
-- 
1.7.9.5
