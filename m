From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH] vhost: remove unneeded linux/miscdevice.h include
Date: Mon, 18 Sep 2017 18:58:54 +0200
Message-ID: <20170918165854.23408-1-clabbe.montjoie@gmail.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: mst@redhat.com, jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/vhost/vhost.c does not use any miscdevice, so this patch
remove this unnecessary inclusion.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/vhost/vhost.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 33ac2b186b85..33ab839696f9 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -16,7 +16,6 @@
 #include <linux/uio.h>
 #include <linux/mm.h>
 #include <linux/mmu_context.h>
-#include <linux/miscdevice.h>
 #include <linux/mutex.h>
 #include <linux/poll.h>
 #include <linux/file.h>
-- 
2.13.5
