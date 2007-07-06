From: David Brownell <david-b@pacbell.net>
Subject: Re: [linux-usb-devel] [PATCH]: cdc-subset to support new vendor/product ID
Date: Fri, 6 Jul 2007 13:43:35 -0700
Message-ID: <200707061343.35969.david-b@pacbell.net>
References: <1776cf1c0707060310m4919b680s7dcc94fbf22fef9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb-devel@lists.sourceforge.net,
	greg@kroah.com
To: "jing xiang" <everxiang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp122.sbc.mail.sp1.yahoo.com ([69.147.64.95]:35198 "HELO
	smtp122.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759177AbXGFUnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 16:43:40 -0400
In-Reply-To: <1776cf1c0707060310m4919b680s7dcc94fbf22fef9@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 06 July 2007, jing xiang wrote:
> Hi,
> 
> This patch is for cdc subset to support Mavell vendor/product ID.
> 
> Jing Xiang
> 
> Signed-off-by: Jing Xiang<everxiang@gmail.com>

Acked-by: David Brownell <dbrownell@users.sourceforge.net>

> 
> diff -uNpr linux-2.6.21.5/driver/usb/net/cdc_subset.c
> linux-2.6.21.5.t/driver/usb/net/cdc_subset.c
> --- linux-2.6.21.5/driver/usb/net/cdc_subset.c  2007-06-14
> 18:34:05.000000000 +0800
> +++ linux-2.6.21.5.t/driver/usb/net/cdc_subset.c        2007-06-28
> 15:55:56.290598304 +0800
> 
> @@ -305,6 +305,9 @@ static const struct usb_device_id   produc
>        USB_DEVICE (0x8086, 0x07d3),    // "blob" bootloader
>        .driver_info =  (unsigned long) &blob_info,
>  }, {
> +       USB_DEVICE (0x1286, 0x8001),    // "blob" bootloader
> +       .driver_info =  (unsigned long) &blob_info,
> +}, {
>        // Linux Ethernet/RNDIS gadget on pxa210/25x/26x, second config
>        // e.g. Gumstix, current OpenZaurus, ...
>        USB_DEVICE_VER (0x0525, 0xa4a2, 0x0203, 0x0203),
> 


