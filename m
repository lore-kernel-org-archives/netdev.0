From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH RESEND net-next V2 2/3] net: huawei_cdc_ncm: Introduce the  huawei_cdc_ncm driver
Date: Thu, 22 Aug 2013 04:30:40 +0200
Message-ID: <1377138641-2765-3-git-send-email-mrkiko.rs@gmail.com>
References: <mrkiko.rs@gmail.com>
 <1377138641-2765-1-git-send-email-mrkiko.rs@gmail.com>
Cc: Enrico Mioso <mrkiko.rs@gmail.com>
To: gregkh@linuxfoundation.org, oliver@neukum.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377138641-2765-1-git-send-email-mrkiko.rs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
