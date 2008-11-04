From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] hso: rfkill type should be WWAN
Date: Tue, 04 Nov 2008 13:32:31 +0200
Message-ID: <20081104113230.3552.69802.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	Denis Joseph Barrow <D.Barow@option.com>
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-7-68-229.static.zebra.lt ([81.7.68.229]:34834 "EHLO
	teltonika.lt" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750860AbYKDLch (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2008 06:32:37 -0500
Received: from 82-135-208-232.static.zebra.lt (HELO Programuotojas.82-135-208-232.ip.zebra.lt) (paulius.zaleckas@[82.135.208.232])
          (envelope-sender <paulius.zaleckas@teltonika.lt>)
          by teltonika.lt (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 4 Nov 2008 11:30:53 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Cc: Denis Joseph Barrow <D.Barow@option.com>
---

 drivers/net/usb/hso.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 1164c52..3f49e83 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2188,7 +2188,7 @@ static void hso_create_rfkill(struct hso_device *hso_dev,
 	char *rfkn;
 
 	hso_net->rfkill = rfkill_allocate(&interface_to_usbdev(interface)->dev,
-				 RFKILL_TYPE_WLAN);
+				 RFKILL_TYPE_WWAN);
 	if (!hso_net->rfkill) {
 		dev_err(dev, "%s - Out of memory", __func__);
 		return;

