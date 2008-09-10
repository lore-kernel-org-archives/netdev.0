From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: hso: remove usb_driver_claim_interface()
Date: Wed, 10 Sep 2008 12:06:29 +0300
Message-ID: <48C78E15.9030603@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050606010906040609040906"
Cc: D.Barow@option.com
To: linux-usb@vger.kernel.org, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-7-68-229.static.zebra.lt ([81.7.68.229]:48902 "EHLO
	teltonika.lt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752926AbYIJJGe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2008 05:06:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050606010906040609040906
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------050606010906040609040906
Content-Type: text/x-patch;
 name="hso-no-claim-interface.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso-no-claim-interface.patch"

No need to reclaim the same USB interface beeing probed.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Cc: Denis Joseph Barrow <D.Barow@option.com>

Index: linux-2.6/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.orig/drivers/net/usb/hso.c
+++ linux-2.6/drivers/net/usb/hso.c
@@ -2487,8 +2487,6 @@ static int hso_probe(struct usb_interfac
 		goto exit;
 	}
 
-	usb_driver_claim_interface(&hso_driver, interface, hso_dev);
-
 	/* save our data pointer in this device */
 	usb_set_intfdata(interface, hso_dev);
 

--------------050606010906040609040906--
