From: Christian Riesch <christian.riesch@omicron.at>
Subject: [PATCH 2/4] asix: Rename asix.c to asix_devices.c
Date: Fri, 6 Jul 2012 13:33:06 +0200
Message-ID: <1341574388-7464-3-git-send-email-christian.riesch@omicron.at>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Grant Grundler <grundler@chromium.org>,
	Ming Lei <tom.leiming@gmail.com>,
	Michael Riesch <michael@riesch.at>,
	Christian Riesch <christian.riesch@omicron.at>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:54477 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933561Ab2GFLqu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 07:46:50 -0400
In-Reply-To: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
---
 drivers/net/usb/Makefile                   |    1 +
 drivers/net/usb/{asix.c => asix_devices.c} |    0
 2 files changed, 1 insertions(+), 0 deletions(-)
 rename drivers/net/usb/{asix.c => asix_devices.c} (100%)

diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index a2e2d72..2c8f7b4 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -8,6 +8,7 @@ obj-$(CONFIG_USB_PEGASUS)	+= pegasus.o
 obj-$(CONFIG_USB_RTL8150)	+= rtl8150.o
 obj-$(CONFIG_USB_HSO)		+= hso.o
 obj-$(CONFIG_USB_NET_AX8817X)	+= asix.o
+asix-y := asix_devices.o
 obj-$(CONFIG_USB_NET_CDCETHER)	+= cdc_ether.o
 obj-$(CONFIG_USB_NET_CDC_EEM)	+= cdc_eem.o
 obj-$(CONFIG_USB_NET_DM9601)	+= dm9601.o
diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix_devices.c
similarity index 100%
rename from drivers/net/usb/asix.c
rename to drivers/net/usb/asix_devices.c
-- 
1.7.0.4
