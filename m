From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH] hso: add Vendor/Product ID's for new devices
Date: Wed, 1 Apr 2009 09:56:55 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.0904010954190.3360-100000@iolanthe.rowland.org>
References: <20090401085751.GA7869@raptor>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-usb@vger.kernel.org, <netdev@vger.kernel.org>,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	David Miller <davem@davemloft.net>
To: Jan Dumon <j.dumon@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:53707 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932311AbZDAN46 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2009 09:56:58 -0400
In-Reply-To: <20090401085751.GA7869@raptor>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Apr 2009, Jan Dumon wrote:

> From: Jan Dumon <j.dumon@option.com>
> 
> Add Vendor/Product ID's for new devices.
> Removed duplicate product ID 0x7361.
> 
> Signed-off-by: Jan Dumon <j.dumon@option.com>
> ---
> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> index fe98aca..d47c508 100644
> --- a/drivers/net/usb/hso.c
> +++ b/drivers/net/usb/hso.c
> @@ -462,9 +462,16 @@ static const struct usb_device_id hso_ids[] = {
>  	{USB_DEVICE(0x0af0, 0x7701)},
>  	{USB_DEVICE(0x0af0, 0x7801)},
>  	{USB_DEVICE(0x0af0, 0x7901)},
> -	{USB_DEVICE(0x0af0, 0x7361)},
> -	{USB_DEVICE(0x0af0, 0xd057)},
> +	{USB_DEVICE(0x0af0, 0x8200)},
> +	{USB_DEVICE(0x0af0, 0x8201)},
> +	{USB_DEVICE(0x0af0, 0xd035)},
>  	{USB_DEVICE(0x0af0, 0xd055)},
> +	{USB_DEVICE(0x0af0, 0xd155)},
> +	{USB_DEVICE(0x0af0, 0xd255)},
> +	{USB_DEVICE(0x0af0, 0xd057)},
> +	{USB_DEVICE(0x0af0, 0xd157)},
> +	{USB_DEVICE(0x0af0, 0xd257)},
> +	{USB_DEVICE(0x0af0, 0xd357)},
>  	{}
>  };
>  MODULE_DEVICE_TABLE(usb, hso_ids);

Is this list supposed to be kept in numerical order?  The entries for
0xd057 and 0xd157 are in the wrong place.

Alan Stern

