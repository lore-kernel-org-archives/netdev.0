From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 10/20] tg3: Extend loopback test timeout
Date: Mon, 2 Nov 2009 16:27:34 -0800
Message-ID: <1257212000.22010@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1512 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757595AbZKCBd0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 20:33:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch extends the loopback test timeout from 250 usec to 350 usec.
When the 5785 is paired against an AC131 phy, the older timeout is
just a little too close to the expected performance based on timings.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d726da8..7bebb47 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10424,8 +10424,8 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 
 	udelay(10);
 
-	/* 250 usec to allow enough time on some 10/100 Mbps devices.  */
-	for (i = 0; i < 25; i++) {
+	/* 350 usec to allow enough time on some 10/100 Mbps devices.  */
+	for (i = 0; i < 35; i++) {
 		tw32_f(HOSTCC_MODE, tp->coalesce_mode | HOSTCC_MODE_ENABLE |
 		       coal_now);
 
-- 
1.6.4.4


