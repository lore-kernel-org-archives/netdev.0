From: Stefan Metzmacher <metze@samba.org>
Subject: [PATCH] TODO FLAG_POINTTOPOINT => FLAG_WWAN? usbnet/cdc_ncm: mark ncm devices as "mobile broadband devices" with FLAG_WWAN
Date: Wed,  1 Jun 2011 12:08:33 +0200
Message-ID: <1306922913-17803-2-git-send-email-metze@samba.org>
References: <1306922913-17803-1-git-send-email-metze@samba.org>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Metzmacher <metze@samba.org>
To: Oliver Neukum <oliver@neukum.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.182]:26288 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758772Ab1FAKIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 06:08:49 -0400
In-Reply-To: <1306922913-17803-1-git-send-email-metze@samba.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e1e499eef2200c2a7120c9ebf297d48b195cf887 does the same for
cdc_ether (with lets the Ericsson F3507g modem appear as wwanX device).

With this commit also the Ericsson F5521gw modem becomes a wwanX device.

Signed-off-by: Stefan Metzmacher <metze@samba.org>
---
 drivers/net/usb/cdc_ncm.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 3257aaa..21f44ab 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1217,7 +1217,7 @@ static int cdc_ncm_manage_power(struct usbnet *dev, int status)
 
 static const struct driver_info cdc_ncm_info = {
 	.description = "CDC NCM",
-	.flags = FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET,
+	.flags = FLAG_WWAN | FLAG_NO_SETINT | FLAG_MULTI_PACKET,
 	.bind = cdc_ncm_bind,
 	.unbind = cdc_ncm_unbind,
 	.check_connect = cdc_ncm_check_connect,
-- 
1.7.4.1

