From: Amos Kong <akong@redhat.com>
Subject: [PATCH] ethtool: fix a typo in displaying channel parameters
Date: Fri, 18 Apr 2014 09:39:59 +0800
Message-ID: <1397785199-1470-1-git-send-email-akong@redhat.com>
Cc: bwh@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44993 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750970AbaDRCSn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Apr 2014 22:18:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 # ethtool -L eth0 combined 1
 combined unmodified, ignoring
 no channel parameters changed, aborting
 current values: tx 0 rx 0 other 0combined 1
                                ^^^^

Signed-off-by: Amos Kong <akong@redhat.com>
---
 ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ethtool.c b/ethtool.c
index acb4397..4c75653 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1764,7 +1764,7 @@ static int do_schannels(struct cmd_context *ctx)
 	if (!changed) {
 		fprintf(stderr, "no channel parameters changed, aborting\n");
 		fprintf(stderr, "current values: tx %u rx %u other %u"
-			"combined %u\n", echannels.rx_count,
+			" combined %u\n", echannels.rx_count,
 			echannels.tx_count, echannels.other_count,
 			echannels.combined_count);
 		return 1;
-- 
1.9.0
