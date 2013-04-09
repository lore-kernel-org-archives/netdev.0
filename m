From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH 4/7] xen-netfront: frags -> slots in log message
Date: Tue, 9 Apr 2013 12:07:32 +0100
Message-ID: <1365505655-8021-5-git-send-email-wei.liu2@citrix.com>
References: <1365505655-8021-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <david.vrabel@citrix.com>,
	<konrad.wilk@oracle.com>, <annie.li@oracle.com>,
	<wdauchy@gmail.com>, Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:60032 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935765Ab3DILWH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 07:22:07 -0400
In-Reply-To: <1365505655-8021-1-git-send-email-wei.liu2@citrix.com>
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
