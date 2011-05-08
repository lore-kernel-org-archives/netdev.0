From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 046/115] sysctl: remove .child from pm/ (frv)
Date: Mon,  9 May 2011 00:38:58 +0200
Message-ID: <1304894407-32201-47-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49055 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932427Ab1EHWlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:41:20 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 arch/frv/kernel/pm.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/arch/frv/kernel/pm.c b/arch/frv/kernel/pm.c
index 5fa3889..bcef945 100644
--- a/arch/frv/kernel/pm.c
+++ b/arch/frv/kernel/pm.c
@@ -329,13 +329,9 @@ static struct ctl_table pm_table[] =
 	{ }
 };
 
-static struct ctl_table pm_dir_table[] =
+static const __initdata struct ctl_path pm_path[] =
 {
-	{
-		.procname	= "pm",
-		.mode		= 0555,
-		.child		= pm_table,
-	},
+	{ .procname = "pm" },
 	{ }
 };
 
@@ -344,7 +340,7 @@ static struct ctl_table pm_dir_table[] =
  */
 static int __init pm_init(void)
 {
-	register_sysctl_table(pm_dir_table);
+	register_sysctl_paths(pm_path, pm_table);
 	return 0;
 }
 
-- 
1.7.5.134.g1c08b

