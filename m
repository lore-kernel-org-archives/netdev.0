From: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [PATCH v1] NFC: Add nfc_dbg() macro
Date: Wed, 22 Mar 2017 21:22:51 +0200
Message-ID: <20170322192251.30261-1-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
        Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
        Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In some cases nfc_dbg() is useful. Add such macro to a header.

Signed-off-by: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
---
 include/net/nfc/nfc.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/nfc/nfc.h b/include/net/nfc/nfc.h
index 1a3de8b34ad2..bbdc73a3239d 100644
--- a/include/net/nfc/nfc.h
+++ b/include/net/nfc/nfc.h
@@ -27,6 +27,7 @@
 #include <linux/device.h>
 #include <linux/skbuff.h>
 
+#define nfc_dbg(dev, fmt, ...) dev_dbg((dev), "NFC: " fmt, ##__VA_ARGS__)
 #define nfc_info(dev, fmt, ...) dev_info((dev), "NFC: " fmt, ##__VA_ARGS__)
 #define nfc_err(dev, fmt, ...) dev_err((dev), "NFC: " fmt, ##__VA_ARGS__)
 
-- 
2.11.0
