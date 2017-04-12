From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] net: xdp: don't export dev_change_xdp_fd()
Date: Wed, 12 Apr 2017 09:32:07 +0200
Message-ID: <20170412073207.27029-1-johannes@sipsolutions.net>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
        Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:33032 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752302AbdDLHcN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 03:32:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Since dev_change_xdp_fd() is only used in rtnetlink, which must
be built-in, there's no reason to export dev_change_xdp_fd().

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/core/dev.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index ef9fe60ee294..5d33e2baab2b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6754,7 +6754,6 @@ int dev_change_xdp_fd(struct net_device *dev, int fd, u32 flags)
 
 	return err;
 }
-EXPORT_SYMBOL(dev_change_xdp_fd);
 
 /**
  *	dev_new_index	-	allocate an ifindex
-- 
2.11.0
