From: Colin Leroy <colin@colino.net>
Subject: Missing hunk in drivers/usb/Makefile
Date: Fri, 18 Mar 2005 10:28:55 +0100
Message-ID: <20050318102855.5c6e534e@jack.colino.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I see there's been a driver for zd1201 added in drivers/usb/net/.
There's a hunk missing in drivers/usb/Makefile, the driver doesn't
get built in nothing else in drivers/usb/net is configured in :

Signed-off-by: Colin Leroy <colin@colino.net>
--- a/drivers/usb/Makefile	2005-03-18 10:26:38.000000000 +0100
+++ b/drivers/usb/Makefile	2005-03-18 10:27:22.000000000 +0100
@@ -50,6 +50,7 @@
 obj-$(CONFIG_USB_PEGASUS)	+= net/
 obj-$(CONFIG_USB_RTL8150)	+= net/
 obj-$(CONFIG_USB_USBNET)	+= net/
+obj-$(CONFIG_USB_ZD1201)	+= net/
 
 obj-$(CONFIG_USB_HPUSBSCSI)	+= image/
 obj-$(CONFIG_USB_MDC800)	+= image/
