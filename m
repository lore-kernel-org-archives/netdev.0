From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Subject: [PATCH] can: ems_usb: removed duplicated code setting local echo support
Date: Mon,  1 Feb 2010 16:02:06 -0200
Message-ID: <1265047326-7493-1-git-send-email-cascardo@holoscopio.com>
Cc: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: trivial@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from liberdade.minaslivre.org ([72.232.254.139]:33116 "EHLO
	liberdade.minaslivre.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754500Ab0BASGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2010 13:06:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
---
 drivers/net/can/usb/ems_usb.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index efbb05c..ee849cf 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -1020,8 +1020,6 @@ static int ems_usb_probe(struct usb_interface *intf,
 	dev->can.do_set_bittiming = ems_usb_set_bittiming;
 	dev->can.do_set_mode = ems_usb_set_mode;
 
-	netdev->flags |= IFF_ECHO; /* we support local echo */
-
 	netdev->netdev_ops = &ems_usb_netdev_ops;
 
 	netdev->flags |= IFF_ECHO; /* we support local echo */
-- 
1.6.6.1

