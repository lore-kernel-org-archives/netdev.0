From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/vhost: remove depends on CONFIG_EXPERIMENTAL
Date: Fri, 22 Feb 2013 23:33:43 -0800
Message-ID: <20130223073343.GA5021@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Asias He <asias@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.outflux.net ([198.145.64.163]:44206 "EHLO smtp.outflux.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751353Ab3BWHdq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Feb 2013 02:33:46 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The CONFIG_EXPERIMENTAL config item has not carried much meaning for a
while now and is almost always enabled by default. As agreed during the
Linux kernel summit, remove it from any "depends on" lines in Kconfigs.

Signed-off-by: Kees Cook <keescook@chromium.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: Asias He <asias@redhat.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/Kconfig.blk |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/vhost/Kconfig.blk b/drivers/vhost/Kconfig.blk
index 831a121..eeffc8b 100644
--- a/drivers/vhost/Kconfig.blk
+++ b/drivers/vhost/Kconfig.blk
@@ -1,6 +1,6 @@
 config VHOST_BLK
-	tristate "Host kernel accelerator for virtio blk (EXPERIMENTAL)"
-	depends on BLOCK &&  EXPERIMENTAL && EVENTFD && m
+	tristate "Host kernel accelerator for virtio blk"
+	depends on BLOCK && EVENTFD && m
 	---help---
 	  This kernel module can be loaded in host kernel to accelerate
 	  guest block with virtio_blk. Not to be confused with virtio_blk
-- 
1.7.9.5


-- 
Kees Cook
Chrome OS Security
