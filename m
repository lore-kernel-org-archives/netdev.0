From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 17/20] drivers/net/wireless/rt2x00: remove depends on CONFIG_EXPERIMENTAL
Date: Tue, 22 Jan 2013 10:30:41 -0800
Message-ID: <1358879444-25834-18-git-send-email-keescook@chromium.org>
References: <1358879444-25834-1-git-send-email-keescook@chromium.org>
Cc: netdev@vger.kernel.org, Kees Cook <keescook@chromium.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Ivo van Doorn <IvDoorn@gmail.com>,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358879444-25834-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CONFIG_EXPERIMENTAL config item has not carried much meaning for a
while now and is almost always enabled by default. As agreed during the
Linux kernel summit, remove it from any "depends on" lines in Kconfigs.

CC: Ivo van Doorn <IvDoorn@gmail.com>
CC: Gertjan van Wingerde <gwingerde@gmail.com>
CC: Helmut Schaa <helmut.schaa@googlemail.com>
CC: "John W. Linville" <linville@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: NetDev <netdev@vger.kernel.org>
Signed-off-by: Kees Cook <keescook@chromium.org>
Acked-by: Gertjan van Wingerde <gwingerde@gmail.com>
Acked-by: Ivo van Doorn <IvDoorn@gmail.com>
---
 drivers/net/wireless/rt2x00/Kconfig |    5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/Kconfig b/drivers/net/wireless/rt2x00/Kconfig
index c7548da..44d6ead 100644
--- a/drivers/net/wireless/rt2x00/Kconfig
+++ b/drivers/net/wireless/rt2x00/Kconfig
@@ -82,7 +82,6 @@ config RT2800PCI_RT33XX
 
 config RT2800PCI_RT35XX
 	bool "rt2800pci - Include support for rt35xx devices (EXPERIMENTAL)"
-	depends on EXPERIMENTAL
 	default y
 	---help---
 	  This adds support for rt35xx wireless chipset family to the
@@ -92,7 +91,6 @@ config RT2800PCI_RT35XX
 
 config RT2800PCI_RT53XX
        bool "rt2800pci - Include support for rt53xx devices (EXPERIMENTAL)"
-       depends on EXPERIMENTAL
        default y
        ---help---
          This adds support for rt53xx wireless chipset family to the
@@ -101,7 +99,6 @@ config RT2800PCI_RT53XX
 
 config RT2800PCI_RT3290
        bool "rt2800pci - Include support for rt3290 devices (EXPERIMENTAL)"
-       depends on EXPERIMENTAL
        default y
        ---help---
          This adds support for rt3290 wireless chipset family to the
@@ -159,7 +156,6 @@ config RT2800USB_RT33XX
 
 config RT2800USB_RT35XX
 	bool "rt2800usb - Include support for rt35xx devices (EXPERIMENTAL)"
-	depends on EXPERIMENTAL
 	default y
 	---help---
 	  This adds support for rt35xx wireless chipset family to the
@@ -168,7 +164,6 @@ config RT2800USB_RT35XX
 
 config RT2800USB_RT53XX
        bool "rt2800usb - Include support for rt53xx devices (EXPERIMENTAL)"
-       depends on EXPERIMENTAL
        ---help---
          This adds support for rt53xx wireless chipset family to the
          rt2800usb driver.
-- 
1.7.9.5
