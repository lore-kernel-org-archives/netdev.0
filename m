From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 084/115] sysctl: single subheader path: net/ax25/DEVICE
Date: Mon,  9 May 2011 00:39:36 +0200
Message-ID: <1304894407-32201-85-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53450 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932628Ab1EHWmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:42:08 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/ax25/sysctl_net_ax25.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/net/ax25/sysctl_net_ax25.c b/net/ax25/sysctl_net_ax25.c
index b1181bc..9bd49c0 100644
--- a/net/ax25/sysctl_net_ax25.c
+++ b/net/ax25/sysctl_net_ax25.c
@@ -160,7 +160,13 @@ void ax25_register_sysctl(struct ax25_dev *ax25_dev)
 	struct ctl_path ax25_path[] = {
 		{ .procname = "net" },
 		{ .procname = "ax25" },
-		{ .procname = ax25_dev->dev->name },
+		{
+			.procname = ax25_dev->dev->name,
+			/* skip duplicate name check; we're registering
+			 * just one subheader for this directory */
+			.has_just_one_subheader = 1,
+
+		},
 		{ }
 	};
 
-- 
1.7.5.134.g1c08b

