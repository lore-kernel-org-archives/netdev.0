From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 085/115] sysctl: single subheader path: kernel/sched_domain/CPU/DOMAIN/
Date: Mon,  9 May 2011 00:39:37 +0200
Message-ID: <1304894407-32201-86-git-send-email-lucian.grijincu@gmail.com>
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
 kernel/sched.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/kernel/sched.c b/kernel/sched.c
index 6e39b7c..8320365 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -6250,7 +6250,13 @@ static void register_sched_domain_sysctl(void)
 		{ .procname = "kernel" },
 		{ .procname = "sched_domain" },
 		{ /* 'cpu0' */ },
-		{ /* 'domain0' */ },
+		{
+			/* 'domain0' */
+			.procname = NULL,
+			/* skip duplicate name check; we're registering
+			 * just one subheader for this directory */
+			.has_just_one_subheader = 1,
+		},
 		{  },
 	};
 
-- 
1.7.5.134.g1c08b
