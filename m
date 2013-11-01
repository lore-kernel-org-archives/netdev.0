From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 20/24] net: cdc_ncm: drop "extern" from header declarations
Date: Fri,  1 Nov 2013 11:16:57 +0100
Message-ID: <1383301021-16613-21-git-send-email-bjorn@mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Cc: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 include/linux/usb/cdc_ncm.h |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index cad54ad..2300f74 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -119,11 +119,11 @@ struct cdc_ncm_ctx {
 	u16 connected;
 };
=20
-extern u8 cdc_ncm_select_altsetting(struct usbnet *dev, struct usb_int=
erface *intf);
-extern int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interfac=
e *intf, u8 data_altsetting);
-extern void cdc_ncm_unbind(struct usbnet *dev, struct usb_interface *i=
ntf);
-extern struct sk_buff *cdc_ncm_fill_tx_frame(struct usbnet *dev, struc=
t sk_buff *skb, __le32 sign);
-extern int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_=
buff *skb_in);
-extern int cdc_ncm_rx_verify_ndp16(struct sk_buff *skb_in, int ndpoffs=
et);
+u8 cdc_ncm_select_altsetting(struct usbnet *dev, struct usb_interface =
*intf);
+int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf=
, u8 data_altsetting);
+void cdc_ncm_unbind(struct usbnet *dev, struct usb_interface *intf);
+struct sk_buff *cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_bu=
ff *skb, __le32 sign);
+int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_buff *s=
kb_in);
+int cdc_ncm_rx_verify_ndp16(struct sk_buff *skb_in, int ndpoffset);
=20
 #endif /* __LINUX_USB_CDC_NCM_H */
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
