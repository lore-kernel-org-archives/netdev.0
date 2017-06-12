From: Oliver Neukum <oneukum@suse.com>
Subject: [PATCH] r8152: give the device version
Date: Mon, 12 Jun 2017 13:56:51 +0200
Message-ID: <20170612115651.8015-1-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>
To: davem@davemloft.net, netdev@vger.kernel.org, hayeswang@realtek.co
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33031 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751944AbdFLL6u (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Jun 2017 07:58:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Getting the device version out of the driver really aids debugging.

Signed-off-by: Oliver Neukum <oneukum@suse.com>
---
 drivers/net/usb/r8152.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index ddc62cb69be8..1a419a45e2a2 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -4368,6 +4368,8 @@ static u8 rtl_get_version(struct usb_interface *intf)
 		break;
 	}
 
+	dev_dbg(&intf->dev, "Detected version 0x%04x\n", version);
+
 	return version;
 }
 
-- 
2.12.3
