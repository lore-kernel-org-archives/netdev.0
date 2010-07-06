From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 01/11] isdn/gigaset: adjust usb_gigaset tty write buffer limit
Date: Tue,  6 Jul 2010 02:18:37 +0200 (CEST)
Message-ID: <20100705-patch-gigaset-01.tilman@imap.cc>
References: <20100705-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100705-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The usb_gigaset driver's write buffer limit was different from those
of the others for no good reason. Set it to the same value, derived
from the Siemens documentation.

Impact: cosmetic
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/usb-gigaset.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigaset/usb-gigaset.c
index 76dbb20..f65cf7d 100644
--- a/drivers/isdn/gigaset/usb-gigaset.c
+++ b/drivers/isdn/gigaset/usb-gigaset.c
@@ -39,7 +39,8 @@ MODULE_PARM_DESC(cidmode, "Call-ID mode");
 #define GIGASET_MODULENAME "usb_gigaset"
 #define GIGASET_DEVNAME    "ttyGU"
 
-#define IF_WRITEBUF 2000	/* arbitrary limit */
+/* length limit according to Siemens 3070usb-protokoll.doc ch. 2.1 */
+#define IF_WRITEBUF 264
 
 /* Values for the Gigaset M105 Data */
 #define USB_M105_VENDOR_ID	0x0681
-- 
1.6.5.3.298.g39add
