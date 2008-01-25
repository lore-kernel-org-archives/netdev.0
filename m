From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH 09/14] [usbnet] add driver_priv pointer to 'struct usbnet'
Date: Sat, 26 Jan 2008 00:51:23 +0200
Message-ID: <20080125225123.11716.92165.stgit@fate.lan>
References: <20080125225032.11716.77713.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bjd@jooz.net, david-b@pacbell.net
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn2.hy.skanova.net ([81.228.8.154]:53569 "EHLO
	pne-smtpout4-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755996AbYAYWvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 17:51:31 -0500
In-Reply-To: <20080125225032.11716.77713.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a private data pointer to usbnet for rndis_wlan module to use.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 drivers/net/usb/usbnet.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.h b/drivers/net/usb/usbnet.h
index 29ab92e..0b4bf09 100644
--- a/drivers/net/usb/usbnet.h
+++ b/drivers/net/usb/usbnet.h
@@ -31,6 +31,7 @@ struct usbnet {
 	struct usb_interface	*intf;
 	struct driver_info	*driver_info;
 	const char		*driver_name;
+	void			*driver_priv;
 	wait_queue_head_t	*wait;
 	struct mutex		phy_mutex;
 	unsigned char		suspend_count;

