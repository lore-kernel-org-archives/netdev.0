From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 080/115] sysctl: single subheader path: net/ipv4/conf/DEVICE-NAME/
Date: Mon,  9 May 2011 00:39:32 +0200
Message-ID: <1304894407-32201-81-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51704 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932620Ab1EHWmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:42:03 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/ipv4/devinet.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index cd9ca08..e672107 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1631,7 +1631,13 @@ static int __devinet_sysctl_register(struct net *net, char *dev_name,
 		{ .procname = "net",  },
 		{ .procname = "ipv4", },
 		{ .procname = "conf", },
-		{ /* to be set */ },
+		{
+			/* to be set bellow (DEVINET_CTL_PATH_DEV) */
+			.procname = NULL,
+			/* skip duplicate name check; we're registering
+			 * just one subheader for this directory */
+			.has_just_one_subheader = 1,
+		},
 		{ },
 	};
 
-- 
1.7.5.134.g1c08b

