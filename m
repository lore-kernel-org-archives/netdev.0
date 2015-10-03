From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 12/15] kaweth: remove ifdefed out call to dma_supported
Date: Sat,  3 Oct 2015 17:19:36 +0200
Message-ID: <1443885579-7094-13-git-send-email-hch@lst.de>
References: <1443885579-7094-1-git-send-email-hch@lst.de>
Cc: linux-net-drivers@solarflare.com, dri-devel@lists.freedesktop.org,
	linux-media@vger.kernel.org, netdev@vger.kernel.org,
	linux-parisc@vger.kernel.org, linux-serial@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Don Fry <pcnet32@frontier.com>,
	Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443885579-7094-1-git-send-email-hch@lst.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/net/usb/kaweth.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 1e9cdca..f64b25c 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -1177,12 +1177,6 @@ err_fw:
 	INIT_DELAYED_WORK(&kaweth->lowmem_work, kaweth_resubmit_tl);
 	usb_set_intfdata(intf, kaweth);
 
-#if 0
-// dma_supported() is deeply broken on almost all architectures
-	if (dma_supported (dev, 0xffffffffffffffffULL))
-		kaweth->net->features |= NETIF_F_HIGHDMA;
-#endif
-
 	SET_NETDEV_DEV(netdev, dev);
 	if (register_netdev(netdev) != 0) {
 		dev_err(dev, "Error registering netdev.\n");
-- 
1.9.1
