From: Sjur Braendeland <sjur.brandeland@stericsson.com>
Subject: [PATCH net-2.6] CAIF: Fix U5500 compile error for shared memory driver
Date: Thu, 18 Nov 2010 11:42:16 +0100
Message-ID: <1290076936-1946-1-git-send-email-sjur.brandeland@stericsson.com>
Cc: Kim Lilliestierna XX <kim.xx.lilliestierna@stericsson.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:43820 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756285Ab0KRKmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 05:42:23 -0500
Received: by eye27 with SMTP id 27so1823172eye.19
        for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 02:42:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kim Lilliestierna XX <kim.xx.lilliestierna@stericsson.com>

Rearrange pr_fmt as __func__ is a variable and not a constant
---
 drivers/net/caif/caif_shm_u5500.c |    2 +-
 drivers/net/caif/caif_shmcore.c   |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/caif/caif_shm_u5500.c b/drivers/net/caif/caif_shm_u5500.c
index 1cd90da..7c1f7b9 100644
--- a/drivers/net/caif/caif_shm_u5500.c
+++ b/drivers/net/caif/caif_shm_u5500.c
@@ -5,7 +5,7 @@
  * License terms: GNU General Public License (GPL) version 2
  */
 
-#define pr_fmt(fmt) KBUILD_MODNAME ":" __func__ "():" fmt
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
 
 #include <linux/version.h>
 #include <linux/init.h>
diff --git a/drivers/net/caif/caif_shmcore.c b/drivers/net/caif/caif_shmcore.c
index 19f9c06..e4ee8c2 100644
--- a/drivers/net/caif/caif_shmcore.c
+++ b/drivers/net/caif/caif_shmcore.c
@@ -6,7 +6,7 @@
  * License terms: GNU General Public License (GPL) version 2
  */
 
-#define pr_fmt(fmt) KBUILD_MODNAME ":" __func__ "():" fmt
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
 
 #include <linux/spinlock.h>
 #include <linux/sched.h>
-- 
1.7.0.4

