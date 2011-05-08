From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 081/115] sysctl: single subheader path: net/{ipv4|ipv6}/neigh/DEV/
Date: Mon,  9 May 2011 00:39:33 +0200
Message-ID: <1304894407-32201-82-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/core/neighbour.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 799f06e..63677be 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2818,7 +2818,13 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 		{ .procname = "net",	 },
 		{ .procname = "proto",	 },
 		{ .procname = "neigh",	 },
-		{ .procname = "default", },
+		{
+			/* will be set to device name (NEIGH_CTL_PATH_DEV) */
+			.procname = "default",
+			/* skip duplicate name check; we're registering
+			 * just one subheader for this directory */
+			.has_just_one_subheader = 1,
+		},
 		{ },
 	};
 
-- 
1.7.5.134.g1c08b
