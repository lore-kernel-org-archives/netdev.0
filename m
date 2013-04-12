From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH V4 4/7] xen-netfront: frags -> slots in log message
Date: Fri, 12 Apr 2013 15:24:03 +0100
Message-ID: <1365776646-10796-5-git-send-email-wei.liu2@citrix.com>
References: <1365776646-10796-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <annie.li@oracle.com>, <konrad.wilk@oracle.com>,
	<jbeulich@suse.com>, <ian.campbell@citrix.com>,
	<wdauchy@gmail.com>, <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:6348 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752180Ab3DLOYZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Apr 2013 10:24:25 -0400
In-Reply-To: <1365776646-10796-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also fix a typo in comment.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
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
