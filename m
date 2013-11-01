From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 4/5] net: cdc_mbim: no need to check for resume if suspend exists
Date: Fri,  1 Nov 2013 14:18:55 +0100
Message-ID: <1383311936-20954-5-git-send-email-bjorn@mork.no>
References: <1383311936-20954-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	linux-usb@vger.kernel.org, Oliver Neukum <oneukum@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:52423 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752523Ab3KANTR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 09:19:17 -0400
In-Reply-To: <1383311936-20954-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Oliver Neukum <oneukum@suse.de>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_mbim.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 172059e..862d137 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -352,7 +352,7 @@ static int cdc_mbim_resume(struct usb_interface *in=
tf)
 	if (ret < 0)
 		goto err;
 	ret =3D usbnet_resume(intf);
-	if (ret < 0 && callsub && info->subdriver->suspend)
+	if (ret < 0 && callsub)
 		info->subdriver->suspend(intf, PMSG_SUSPEND);
 err:
 	return ret;
--=20
1.7.10.4
