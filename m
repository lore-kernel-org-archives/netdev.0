From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [linux-usb-devel] [PATCH]: cdc-subset to support new vendor/product
 ID
Date: Tue, 10 Jul 2007 12:46:50 -0400
Message-ID: <4693B7FA.60306@garzik.org>
References: <1776cf1c0707060310m4919b680s7dcc94fbf22fef9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb-devel@lists.sourceforge.net,
	greg@kroah.com, David Brownell <david-b@pacbell.net>
To: jing xiang <everxiang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60261 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754303AbXGJQqw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 12:46:52 -0400
In-Reply-To: <1776cf1c0707060310m4919b680s7dcc94fbf22fef9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jing xiang wrote:
> Hi,
> 
> This patch is for cdc subset to support Mavell vendor/product ID.
> 
> Jing Xiang
> 
> Signed-off-by: Jing Xiang<everxiang@gmail.com>
> 
> diff -uNpr linux-2.6.21.5/driver/usb/net/cdc_subset.c
> linux-2.6.21.5.t/driver/usb/net/cdc_subset.c
> --- linux-2.6.21.5/driver/usb/net/cdc_subset.c  2007-06-14
> 18:34:05.000000000 +0800
> +++ linux-2.6.21.5.t/driver/usb/net/cdc_subset.c        2007-06-28
> 15:55:56.290598304 +0800
> 
> @@ -305,6 +305,9 @@ static const struct usb_device_id   produc
>       USB_DEVICE (0x8086, 0x07d3),    // "blob" bootloader
>       .driver_info =  (unsigned long) &blob_info,
> }, {
> +       USB_DEVICE (0x1286, 0x8001),    // "blob" bootloader
> +       .driver_info =  (unsigned long) &blob_info,
> +}, {
>       // Linux Ethernet/RNDIS gadget on pxa210/25x/26x, second config
>       // e.g. Gumstix, current OpenZaurus, ...
>       USB_DEVICE_VER (0x0525, 0xa4a2, 0x0203, 0x0203),

patch failed to apply.  Also, please move extra comments like "Hi," and 
"Jing Xiang" after a "---" separator as described in 
Documentation/SubmittingPatches, so that they are not copied verbatim 
into the permanent kernel changelog.


