From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH RESEND net-next 2/3] net: huawei_cdc_ncm: Introduce the
Date: Tue, 20 Aug 2013 16:50:54 +0200
Message-ID: <1377010256-19063-3-git-send-email-mrkiko.rs@gmail.com>
References: <mrkiko.rs@gmail.com>
 <1377010256-19063-1-git-send-email-mrkiko.rs@gmail.com>
Cc: Enrico Mioso <mrkiko.rs@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:47045 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320Ab3HTOvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 10:51:45 -0400
Received: by mail-wg0-f46.google.com with SMTP id k13so464908wgh.25
        for <netdev@vger.kernel.org>; Tue, 20 Aug 2013 07:51:44 -0700 (PDT)
In-Reply-To: <1377010256-19063-1-git-send-email-mrkiko.rs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

huawei_cdc_ncm driver

This driver supports devices using the NCM protocol as an encapsulation layer
for other protocols, like the E3131 Huawei 3G modem. This driver was heavily inspired by the qmi_wwan approach & code model.

Suggested-by: Bjorn Mork <bjorn@mork.no>
Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
---
 drivers/net/usb/Kconfig  |   11 +++++++++++
 drivers/net/usb/Makefile |    1 +
 2 files changed, 12 insertions(+)

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index d84bfd4..6e56751 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -242,6 +242,17 @@ config USB_NET_CDC_NCM
 	    * ST-Ericsson M343 HSPA Mobile Broadband Modem (reference design)
 	    * Ericsson F5521gw Mobile Broadband Module
 
+config USB_NET_HUAWEI_CDC_NCM
+	tristate "Huawei-style CDC NCM support"
+	depends on USB_USBNET
+	select USB_WDM
+	select USB_NET_CDC_NCM
+	help
+		This driver aims to support huawei-style NCM devices, that use ncm as a
+		transport for other protocols.
+		To compile this driver as a module, choose M here: the module will be
+		called huawei_cdc_ncm.
+
 config USB_NET_CDC_MBIM
 	tristate "CDC MBIM support"
 	depends on USB_USBNET
diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index e817178..fd0e6a7 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -31,6 +31,7 @@ obj-$(CONFIG_USB_IPHETH)	+= ipheth.o
 obj-$(CONFIG_USB_SIERRA_NET)	+= sierra_net.o
 obj-$(CONFIG_USB_NET_CX82310_ETH)	+= cx82310_eth.o
 obj-$(CONFIG_USB_NET_CDC_NCM)	+= cdc_ncm.o
+obj-$(CONFIG_USB_NET_HUAWEI_CDC_NCM)	+= huawei_cdc_ncm.o
 obj-$(CONFIG_USB_VL600)		+= lg-vl600.o
 obj-$(CONFIG_USB_NET_QMI_WWAN)	+= qmi_wwan.o
 obj-$(CONFIG_USB_NET_CDC_MBIM)	+= cdc_mbim.o
-- 
1.7.10.4
