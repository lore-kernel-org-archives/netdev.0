From: Joe Perches <joe@perches.com>
Subject: [PATCH v3 3/9] include/net/iw_handler.h: Use SIOCIWFIRST not SIOCSIWCOMMIT in comment
Date: Thu, 18 Mar 2010 18:29:34 -0700
Message-ID: <5a1465ded6e3eae64f2fde0027dd83e6b1264899.1268961559.git.joe@perches.com>
References: <cover.1268961559.git.joe@perches.com>
Cc: Richard Kennedy <richard@rsk.demon.co.uk>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1860 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753431Ab0CSB3p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Mar 2010 21:29:45 -0400
In-Reply-To: <cover.1268961559.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

to match use in IW_IOCTL_IDX macro

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/iw_handler.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/iw_handler.h b/include/net/iw_handler.h
index b2b98f3..3afdb21 100644
--- a/include/net/iw_handler.h
+++ b/include/net/iw_handler.h
@@ -323,7 +323,7 @@ typedef int (*iw_handler)(struct net_device *dev, struct iw_request_info *info,
 struct iw_handler_def {
 
 	/* Array of handlers for standard ioctls
-	 * We will call dev->wireless_handlers->standard[ioctl - SIOCSIWCOMMIT]
+	 * We will call dev->wireless_handlers->standard[ioctl - SIOCIWFIRST]
 	 */
 	const iw_handler *	standard;
 	/* Number of handlers defined (more precisely, index of the
-- 
1.7.0.14.g7e948

