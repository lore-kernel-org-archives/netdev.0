From: sjur.brandeland@stericsson.com
Subject: [PATCH net-2.6] CAIF: Fix U5500 compile error for shared memory driver
Date: Tue, 30 Nov 2010 20:11:22 +0100
Message-ID: <1291144282-2908-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Kim Lilliestierna XX <kim.xx.lilliestierna@stericsson.com>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:41107 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756256Ab0K3TLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 14:11:35 -0500
Received: from terra-smin.broadpark.no ([80.202.8.13])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LCP00HAWPB0B000@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Tue, 30 Nov 2010 20:11:24 +0100 (CET)
Received: from localhost.localdomain ([80.203.137.56])
 by terra-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LCP004N4PAZSNB0@terra-smin.broadpark.no> for
 netdev@vger.kernel.org; Tue, 30 Nov 2010 20:11:24 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kim Lilliestierna XX <kim.xx.lilliestierna@stericsson.com>

Rearrange pr_fmt so it compiles.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_shm_u5500.c |    2 +-
 drivers/net/caif/caif_shmcore.c   |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/caif/caif_shm_u5500.c b/drivers/net/caif/caif_shm_u5500.c
index 1cd90da..32b1c6f 100644
--- a/drivers/net/caif/caif_shm_u5500.c
+++ b/drivers/net/caif/caif_shm_u5500.c
@@ -5,7 +5,7 @@
  * License terms: GNU General Public License (GPL) version 2
  */
 
-#define pr_fmt(fmt) KBUILD_MODNAME ":" __func__ "():" fmt
+#define pr_fmt(fmt) KBUILD_MODNAME ":" fmt
 
 #include <linux/version.h>
 #include <linux/init.h>
diff --git a/drivers/net/caif/caif_shmcore.c b/drivers/net/caif/caif_shmcore.c
index 19f9c06..8051116 100644
--- a/drivers/net/caif/caif_shmcore.c
+++ b/drivers/net/caif/caif_shmcore.c
@@ -6,7 +6,7 @@
  * License terms: GNU General Public License (GPL) version 2
  */
 
-#define pr_fmt(fmt) KBUILD_MODNAME ":" __func__ "():" fmt
+#define pr_fmt(fmt) KBUILD_MODNAME ":" fmt
 
 #include <linux/spinlock.h>
 #include <linux/sched.h>
-- 
1.6.3.3

