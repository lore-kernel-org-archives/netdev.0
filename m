From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 086/115] sysctl: single subheader path: net/decnet/conf/DEVNAME
Date: Mon,  9 May 2011 00:39:38 +0200
Message-ID: <1304894407-32201-87-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:64326 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932626Ab1EHWmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:42:10 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch was not tested!

I assume the DN_CTL_PATH_DEV .procname names are unique. If they are
not this patch is invalid.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/decnet/dn_dev.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 0dcaa90..d83d561 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -216,7 +216,13 @@ static void dn_dev_sysctl_register(struct net_device *dev, struct dn_dev_parms *
 		{ .procname = "net",  },
 		{ .procname = "decnet",  },
 		{ .procname = "conf",  },
-		{ /* to be set */ },
+		{
+			/* to be set bellow (DN_CTL_PATH_DEV) */
+			.procname = NULL,
+			/* skip duplicate name check; we're registering
+			 * just one subheader for this directory */
+			.has_just_one_subheader = 1,
+		},
 		{ },
 	};
 
-- 
1.7.5.134.g1c08b

