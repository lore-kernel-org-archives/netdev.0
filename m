From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/1] vhost: Remove duplicate inclusion of linux/vhost.h
Date: Mon, 19 Nov 2012 16:58:28 +0530
Message-ID: <1353324508-22083-1-git-send-email-sachin.kamat@linaro.org>
Cc: mst@redhat.com, nab@linux-iscsi.org, sachin.kamat@linaro.org,
	patches@linaro.org
To: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

linux/vhost.h was included twice.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/vhost/tcm_vhost.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/tcm_vhost.c b/drivers/vhost/tcm_vhost.c
index 73bbc46..798792b 100644
--- a/drivers/vhost/tcm_vhost.c
+++ b/drivers/vhost/tcm_vhost.c
@@ -34,7 +34,6 @@
 #include <linux/ctype.h>
 #include <linux/compat.h>
 #include <linux/eventfd.h>
-#include <linux/vhost.h>
 #include <linux/fs.h>
 #include <linux/miscdevice.h>
 #include <asm/unaligned.h>
-- 
1.7.4.1

