From: "Benjamin Li" <benli@broadcom.com>
Subject: [UPDATED][NET-NEXT PATCH 1/4] bnx2: In bnx2_set_mac_link()
 return void rather then int
Date: Thu, 18 Sep 2008 09:57:10 -0700
Message-ID: <1221757033-4874-2-git-send-email-benli@broadcom.com>
References: <20080918063933.GA8027@verge.net.au>
 <1221757033-4874-1-git-send-email-benli@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benli@broadcom.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4705 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755115AbYIRQ51 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2008 12:57:27 -0400
In-Reply-To: <1221757033-4874-1-git-send-email-benli@broadcom.com>
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
1.6.0.1


