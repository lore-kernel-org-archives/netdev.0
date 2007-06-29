From: "Stanley Cai" <stanley.w.cai@gmail.com>
Subject: [linux-usb-devel] USB: cdc-subset.c support for new vendor/product ID
Date: Thu, 28 Jun 2007 21:13:28 -0400
Message-ID: <dd2695e90706281813p3bb8baecx422c7c29793754ae@mail.gmail.com>
References: <1776cf1c0706140502p3f159832u653bd9e53bd5b171@mail.gmail.com>
	 <200706241749.37401.david-b@pacbell.net>
	 <1776cf1c0706260500k55a14c60u974f36bfa2e15235@mail.gmail.com>
	 <200706261017.06524.david-b@pacbell.net>
	 <1776cf1c0706280324k3a56c7e9m4d3af26f6d1dfba3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: everxiang@gmail.com, linux-usb-devel@lists.sourceforge.net,
	"David Brownell" <david-b@pacbell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:52249 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761426AbXF2BN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 21:13:29 -0400
Received: by wx-out-0506.google.com with SMTP id h31so697358wxd
        for <netdev@vger.kernel.org>; Thu, 28 Jun 2007 18:13:28 -0700 (PDT)
In-Reply-To: <1776cf1c0706280324k3a56c7e9m4d3af26f6d1dfba3@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Send to the lists on behalf on Jing, Any comment is welcome. Thanks -stanley

----------------------

hi,

Here's one patch for cdc subset to support new vendor/product ID.
Could you help to check whether it is accaptable or not? Thanks a lot!

Signed-off-by: Jing Xiang<everxiang@gmail.com>

diff -uNpr linux-2.6.21.5/driver/usb/net/cdc_subset.c
linux-2.6.21.5.t/driver/usb/net/cdc_subset.c
--- linux-2.6.21.5/driver/usb/net/cdc_subset.c  2007-06-14
18:34:05.000000000 +0800
+++ linux-2.6.21.5.t/driver/usb/net/cdc_subset.c        2007-06-28
15:55:56.290598304 +0800
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
