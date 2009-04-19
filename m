From: Marcin Slusarz <marcin.slusarz@gmail.com>
Subject: [PATCH] net: fix "compatibility" typos
Date: Sun, 19 Apr 2009 19:24:24 +0200
Message-ID: <49EB5E48.1040506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, trivial@kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:46336 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751154AbZDSRYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Apr 2009 13:24:46 -0400
Received: by fxm2 with SMTP id 2so1603221fxm.37
        for <netdev@vger.kernel.org>; Sun, 19 Apr 2009 10:24:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marcin Slusarz <marcin.slusarz@gmail.com>
---
 drivers/net/Kconfig |    4 ++--
 net/core/dev.c      |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 9e92154..214a92d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -28,9 +28,9 @@ if NETDEVICES
 
 config COMPAT_NET_DEV_OPS
        default y
-       bool "Enable older network device API compatiablity"
+       bool "Enable older network device API compatibility"
        ---help---
-          This option enables kernel compatiability with older network devices
+          This option enables kernel compatibility with older network devices
           that do not use net_device_ops interface.
 
 	  If unsure, say Y.
diff --git a/net/core/dev.c b/net/core/dev.c
index 343883f..9d9516c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4400,7 +4400,7 @@ int register_netdevice(struct net_device *dev)
 	dev->iflink = -1;
 
 #ifdef CONFIG_COMPAT_NET_DEV_OPS
-	/* Netdevice_ops API compatiability support.
+	/* Netdevice_ops API compatibility support.
 	 * This is temporary until all network devices are converted.
 	 */
 	if (dev->netdev_ops) {
@@ -4411,7 +4411,7 @@ int register_netdevice(struct net_device *dev)
 			dev->name, netdev_drivername(dev, drivername, 64));
 
 		/* This works only because net_device_ops and the
-		   compatiablity structure are the same. */
+		   compatibility structure are the same. */
 		dev->netdev_ops = (void *) &(dev->init);
 	}
 #endif
-- 
1.6.0.6

