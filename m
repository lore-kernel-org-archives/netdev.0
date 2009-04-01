From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: [PATCH] hso: add Vendor/Product ID's for new devices
Date: Wed, 01 Apr 2009 10:33:59 +0300
Message-ID: <49D318E7.4050404@teltonika.lt>
References: <20090331115652.GA22106@raptor>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Jan Dumon <j.dumon@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-7-68-229.static.zebra.lt ([81.7.68.229]:47009 "EHLO
	teltonika.lt" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759191AbZDAHeJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2009 03:34:09 -0400
In-Reply-To: <20090331115652.GA22106@raptor>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Dumon wrote:
> From: Jan Dumon <j.dumon@option.com>
> 
> Add Vendor/Product ID's for new devices.
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

Please add comment in description why you are removing these IDs.

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
