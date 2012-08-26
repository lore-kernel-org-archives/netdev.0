From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] vhost: remove duplicated include from tcm_vhost.c
Date: Sun, 26 Aug 2012 09:42:08 +0800
Message-ID: <CAPgLHd-GRu8Dc3bxLL4ogjsE6gY=OS7n0H-5JFyMi_dy2OXP9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:42285 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416Ab2HZBmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2012 21:42:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove duplicated include.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/vhost/tcm_vhost.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/vhost/tcm_vhost.c b/drivers/vhost/tcm_vhost.c
index fb36654..587ca7e 100644
--- a/drivers/vhost/tcm_vhost.c
+++ b/drivers/vhost/tcm_vhost.c
@@ -45,7 +45,6 @@
 #include <target/target_core_fabric_configfs.h>
 #include <target/target_core_configfs.h>
 #include <target/configfs_macros.h>
-#include <linux/vhost.h>
 #include <linux/virtio_net.h> /* TODO vhost.h currently depends on this */
 #include <linux/virtio_scsi.h>
 
