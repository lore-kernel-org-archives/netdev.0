From: Colin Leroy <colin@colino.net>
Subject: [PATCH] Missing hunk in drivers/usb/Makefile
Date: Fri, 18 Mar 2005 11:43:19 +0100
Message-ID: <20050318114319.350a39e9@jack.colino.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: linux-usb-devel@lists.sf.net
Sender: linux-usb-devel-admin@lists.sourceforge.net
Errors-To: linux-usb-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:linux-usb-devel@lists.sourceforge.net>
List-Help: <mailto:linux-usb-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=linux-usb-devel>
List-Id: netdev.vger.kernel.org

Hi,

[re-send so that linux-usb-devel gets it too]

I see there's been a driver for zd1201 added in drivers/usb/net/.
There's a hunk missing in drivers/usb/Makefile, the driver doesn't
get built if nothing else in drivers/usb/net is configured in :

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


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
