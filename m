From: "jing xiang" <everxiang@gmail.com>
Subject: Re: [linux-usb-devel] [PATCH]: cdc-subset to support new vendor/product ID
Date: Sat, 14 Jul 2007 14:09:54 +0800
Message-ID: <1776cf1c0707132309s715a4cdfy53e639f33cecc404@mail.gmail.com>
References: <1776cf1c0707060310m4919b680s7dcc94fbf22fef9@mail.gmail.com>
	 <4693B7FA.60306@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb-devel@lists.sourceforge.net,
	greg@kroah.com, "David Brownell" <david-b@pacbell.net>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:14345 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751488AbXGNGJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 02:09:55 -0400
Received: by wa-out-1112.google.com with SMTP id v27so840873wah
        for <netdev@vger.kernel.org>; Fri, 13 Jul 2007 23:09:55 -0700 (PDT)
In-Reply-To: <4693B7FA.60306@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is for cdc subset to support Mavell vendor/product ID.

Signed-off-by: Jing Xiang <everxiang@gmail.com>

--- linux-2.6.21.5/drivers/usb/net/cdc_subset.c.orig    2007-07-14
13:57:37.543028144 +0800
+++ linux-2.6.21.5/drivers/usb/net/cdc_subset.c 2007-07-14
13:58:30.521974120 +0800

- Hide quoted text -
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
