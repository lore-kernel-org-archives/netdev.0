From: "jing xiang" <everxiang@gmail.com>
Subject: Re: [PATCH]: cdc-subset to support new
	vendor/product ID
Date: Sat, 14 Jul 2007 14:13:24 +0800
Message-ID: <1776cf1c0707132313j546ab73av109b1c3264db150f@mail.gmail.com>
References: <1776cf1c0707060310m4919b680s7dcc94fbf22fef9@mail.gmail.com>
	<4693B7FA.60306@garzik.org>
	<1776cf1c0707132309s715a4cdfy53e639f33cecc404@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Brownell <david-b@pacbell.net>, netdev@vger.kernel.org,
	linux-usb-devel@lists.sourceforge.net, greg@kroah.com
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1776cf1c0707132309s715a4cdfy53e639f33cecc404@mail.gmail.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-usb-devel>
List-Post: <mailto:linux-usb-devel@lists.sourceforge.net>
List-Help: <mailto:linux-usb-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux-usb-devel-bounces@lists.sourceforge.net
Errors-To: linux-usb-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This patch is for cdc subset to support Mavell vendor/product ID.

Signed-off-by: Jing Xiang <everxiang@gmail.com>

--- linux-2.6.21.5/drivers/usb/net/cdc_subset.c.orig    2007-07-14
13:57:37.543028144 +0800
+++ linux-2.6.21.5/drivers/usb/net/cdc_subset.c 2007-07-14
13:58:30.521974120 +0800
@@ -305,6 +305,9 @@ static const struct usb_device_id   produc
        USB_DEVICE (0x8086, 0x07d3),    // "blob" bootloader
        .driver_info =  (unsigned long) &blob_info,
 }, {
+       USB_DEVICE (0x1286, 0x8001),    // "blob" bootloader
+       .driver_info =  (unsigned long) &blob_info,
+}, {
        // Linux Ethernet/RNDIS gadget on pxa210/25x/26x, second config
        // e.g. Gumstix, current OpenZaurus, ...
        USB_DEVICE_VER (0x0525, 0xa4a2, 0x0203, 0x0203),

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
