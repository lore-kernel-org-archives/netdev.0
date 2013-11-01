From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 02/24] net: cdc_ncm: add include protection to cdc_ncm.h
Date: Fri,  1 Nov 2013 11:16:39 +0100
Message-ID: <1383301021-16613-3-git-send-email-bjorn@mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49992 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755948Ab3KAKRZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 06:17:25 -0400
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes it a lot easier to test modified versions

Cc: Alexey Orishko <alexey.orishko@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 include/linux/usb/cdc_ncm.h |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index cc25b70..89f0bbc 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -36,6 +36,9 @@
  * SUCH DAMAGE.
  */
=20
+#ifndef __LINUX_USB_CDC_NCM_H
+#define __LINUX_USB_CDC_NCM_H
+
 #define CDC_NCM_COMM_ALTSETTING_NCM		0
 #define CDC_NCM_COMM_ALTSETTING_MBIM		1
=20
@@ -133,3 +136,5 @@ extern void cdc_ncm_unbind(struct usbnet *dev, stru=
ct usb_interface *intf);
 extern struct sk_buff *cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, =
struct sk_buff *skb, __le32 sign);
 extern int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_=
buff *skb_in);
 extern int cdc_ncm_rx_verify_ndp16(struct sk_buff *skb_in, int ndpoffs=
et);
+
+#endif /* __LINUX_USB_CDC_NCM_H */
--=20
1.7.10.4
