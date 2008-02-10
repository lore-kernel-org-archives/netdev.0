From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] New device for DM9601 usb net driver
Date: Sun, 10 Feb 2008 20:36:24 +0100
Message-ID: <874pcgy56v.fsf@macbook.be.48ers.dk>
References: <Pine.LNX.4.64.0802071046540.24824@castor.opentrend.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Robert Brockway <robert@timetraveller.org>, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:61836 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515AbYBJTgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 14:36:35 -0500
Received: by fk-out-0910.google.com with SMTP id z23so4198914fkz.5
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2008 11:36:32 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0802071046540.24824@castor.opentrend.net> (Robert Brockway's message of "Thu\, 7 Feb 2008 11\:00\:33 -0500 \(EST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Robert" == Robert Brockway <robert@timetraveller.org> writes:

 Robert> Hi Peter.  I've verified that the Hirose USB-100 (0x0a47,
 Robert> 0x9601) is a clone of the DAVICOM DM9601.  I patched dm9601.c
 Robert> to identify this device and now have these in production.
 Robert> Unified diff against 2.6.24 attached.

Thanks!

Acked-by: Peter Korsgaard <jacmet@sunsite.dk>

 Robert> Cheers,

 Robert> Rob

 Robert> -- 
 Robert> "With sufficient thrust, pigs fly just fine..."
 Robert> 	-- RFC 1925 "The Twelve Networking Truths"

 Robert> --- drivers/net/usb/dm9601.c.old	2008-01-27 00:51:50.000000000 -0500
 Robert> +++ drivers/net/usb/dm9601.c	2008-02-07 10:27:40.000000000 -0500
 Robert> @@ -590,6 +590,10 @@ static const struct usb_device_id produc
 Robert>  	 USB_DEVICE(0x0a46, 0x8515),	/* ADMtek ADM8515 USB NIC */
 Robert>  	 .driver_info = (unsigned long)&dm9601_info,
 Robert>  	 },
 Robert> +	{
 Robert> +	USB_DEVICE(0x0a47, 0x9601),    /* Hirose USB-100 */
 Robert> +	.driver_info = (unsigned long)&dm9601_info,
 Robert> +	},
 Robert>  	{},			// END
 Robert>  };
 

-- 
Bye, Peter Korsgaard
