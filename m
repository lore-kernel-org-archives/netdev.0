From: "Benjamin Li" <benli@broadcom.com>
Subject: NET-NEXT PATCH] bnx2: In bnx2_set_mac_link() return void rather
 then int
Date: Wed, 17 Sep 2008 16:02:18 -0700
Message-ID: <a93511dbe76cb994f3dbd16c3ad820617d4187e9.1219454143.git.benli@broadcom.com>
References: <cover.1219454143.git.benli@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benli@broadcom.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1621 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753721AbYIQXCg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Sep 2008 19:02:36 -0400
Received: from mail-irva-8.broadcom.com (mail-irva-8 [10.11.18.52]) by
 mail-irva-10.broadcom.com (Postfix) with ESMTP id 1653D2B0 for
 <netdev@vger.kernel.org>; Wed, 17 Sep 2008 16:02:24 -0700 (PDT)
In-Reply-To: <cover.1219454143.git.benli@broadcom.com>
In-Reply-To: <cover.1219454143.git.benli@broadcom.com>
References: <cover.1219454143.git.benli@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2_set_mac_link() doesn't need to return any error codes.  And
all the callers don't check the return code. It is safe to 
change the return type to a void.

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 2486a65..192a24e 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1127,7 +1127,7 @@ bnx2_init_all_rx_contexts(struct bnx2 *bp)
 	}
 }
 
-static int
+static void
 bnx2_set_mac_link(struct bnx2 *bp)
 {
 	u32 val;
@@ -1193,8 +1193,6 @@ bnx2_set_mac_link(struct bnx2 *bp)
 
 	if (CHIP_NUM(bp) == CHIP_NUM_5709)
 		bnx2_init_all_rx_contexts(bp);
-
-	return 0;
 }
 
 static void
-- 
1.5.6.4


