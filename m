From: Ben Chan <benchan@chromium.org>
Subject: [PATCH v3 1/2] USB: cdc: add MBIM extended functional descriptor structure
Date: Mon, 17 Mar 2014 20:59:04 -0700
Message-ID: <1395115145-31821-1-git-send-email-benchan@chromium.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Greg Suarez <gsuarez@smithmicro.com>
To: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Oliver Neukum <oliver@neukum.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the MBIM extended functional descriptor structure
defined in "Universal Serial Bus Communications Class Subclass
Specification for Mobile Broadband Interface Model, Revision 1.0,
Errata-1" published by USB-IF.

Signed-off-by: Ben Chan <benchan@chromium.org>
---
No changes from patch v1.

 include/uapi/linux/usb/cdc.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/uapi/linux/usb/cdc.h b/include/uapi/linux/usb/cdc.h
index f35aa0a..b6a9cdd 100644
--- a/include/uapi/linux/usb/cdc.h
+++ b/include/uapi/linux/usb/cdc.h
@@ -56,6 +56,7 @@
 #define USB_CDC_OBEX_TYPE		0x15
 #define USB_CDC_NCM_TYPE		0x1a
 #define USB_CDC_MBIM_TYPE		0x1b
+#define USB_CDC_MBIM_EXTENDED_TYPE	0x1c
 
 /* "Header Functional Descriptor" from CDC spec  5.2.3.1 */
 struct usb_cdc_header_desc {
@@ -205,6 +206,17 @@ struct usb_cdc_mbim_desc {
 	__u8    bmNetworkCapabilities;
 } __attribute__ ((packed));
 
+/* "MBIM Extended Functional Descriptor" from CDC MBIM spec 1.0 errata-1 */
+struct usb_cdc_mbim_extended_desc {
+	__u8	bLength;
+	__u8	bDescriptorType;
+	__u8	bDescriptorSubType;
+
+	__le16	bcdMBIMExtendedVersion;
+	__u8	bMaxOutstandingCommandMessages;
+	__le16	wMTU;
+} __attribute__ ((packed));
+
 /*-------------------------------------------------------------------------*/
 
 /*
-- 
1.9.0.279.gdc9e3eb
