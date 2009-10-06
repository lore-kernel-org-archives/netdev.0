From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH 1/5] rndis_host: support ETHTOOL_GPERMADDR
Date: Tue,  6 Oct 2009 17:05:42 -0400
Message-ID: <1254863142-14698-1-git-send-email-linville@tuxdriver.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42497 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758227AbZJFVQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 17:16:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 drivers/net/usb/rndis_host.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index d032bba..0caa800 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -418,6 +418,7 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 		goto halt_fail_and_release;
 	}
 	memcpy(net->dev_addr, bp, ETH_ALEN);
+	memcpy(net->perm_addr, bp, ETH_ALEN);
 
 	/* set a nonzero filter to enable data transfers */
 	memset(u.set, 0, sizeof *u.set);
-- 
1.6.2.5

