From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH 1/4] xen-netfront: frags -> slots in log message
Date: Wed, 17 Apr 2013 18:42:00 +0100
Message-ID: <1366220523-14579-2-git-send-email-wei.liu2@citrix.com>
References: <1366220523-14579-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <ian.campbell@citrix.com>,
	<wdauchy@gmail.com>, <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:62438 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017Ab3DQRrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 13:47:19 -0400
In-Reply-To: <1366220523-14579-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also fix a typo in comment.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Acked-by: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/xen-netfront.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index d9097a7..1bb2e20 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -735,7 +735,7 @@ static int xennet_get_responses(struct netfront_info *np,
 		/*
 		 * This definitely indicates a bug, either in this driver or in
 		 * the backend driver. In future this should flag the bad
-		 * situation to the system controller to reboot the backed.
+		 * situation to the system controller to reboot the backend.
 		 */
 		if (ref == GRANT_INVALID_REF) {
 			if (net_ratelimit())
@@ -771,7 +771,7 @@ next:
 
 	if (unlikely(slots > max)) {
 		if (net_ratelimit())
-			dev_warn(dev, "Too many frags\n");
+			dev_warn(dev, "Too many slots\n");
 		err = -E2BIG;
 	}
 
-- 
1.7.10.4
