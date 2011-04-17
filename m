From: Thiago Farina <tfransosi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/1] drivers/net/usb/usbnet.c: Use FIELD_SIZEOF macro in usbnet_init() function.
Date: Sun, 17 Apr 2011 19:46:04 -0300
Message-ID: <3f3e63ecef46abc5d23053c051b3fef52104cbe7.1303080236.git.tfransosi@gmail.com>
Cc: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thiago Farina <tfransosi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thiago Farina <tfransosi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/usbnet.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 069c1cf..7bc9852 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1529,9 +1529,9 @@ EXPORT_SYMBOL_GPL(usbnet_resume);
 
 static int __init usbnet_init(void)
 {
-	/* compiler should optimize this out */
-	BUILD_BUG_ON (sizeof (((struct sk_buff *)0)->cb)
-			< sizeof (struct skb_data));
+	/* Compiler should optimize this out. */
+	BUILD_BUG_ON(
+		FIELD_SIZEOF(struct sk_buff, cb) < sizeof(struct skb_data));
 
 	random_ether_addr(node_id);
 	return 0;
-- 
1.7.5.rc2.4.g4d8b3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
