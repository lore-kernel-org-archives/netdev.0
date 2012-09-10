From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] [PATCH] net: qmi_wwan: fix Gobi device probing for
 un2430
Date: Mon, 10 Sep 2012 16:43:14 -0400 (EDT)
Message-ID: <20120910.164314.1674016370550788813.davem@davemloft.net>
References: <1347296579-15692-1-git-send-email-pierre.sauter@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org, bjorn@mork.no
To: pierre.sauter@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932152Ab2IJUnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 16:43:16 -0400
In-Reply-To: <1347296579-15692-1-git-send-email-pierre.sauter@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pierre.sauter@gmail.com
Date: Mon, 10 Sep 2012 19:02:59 +0200

> From: Pierre Sauter <pierre.sauter@gmail.com>
> 
> HP un2430 is a Gobi 3000 device. It was mistakenly treated as Gobi 1000
> in patch b9f90eb2740203ff2592efe640409ad48335d1c2.
> 
> I own this device and qmi_wwan works again with this fix.
> 
> Signed-off-by: Pierre Sauter <pierre.sauter@gmail.com>

Bjorn, ACK/NACK?

> ---
>  drivers/net/usb/qmi_wwan.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
> index adfab3f..17b8f3e 100644
> --- a/drivers/net/usb/qmi_wwan.c
> +++ b/drivers/net/usb/qmi_wwan.c
> @@ -398,7 +398,6 @@ static const struct usb_device_id products[] = {
>  	/* 4. Gobi 1000 devices */
>  	{QMI_GOBI1K_DEVICE(0x05c6, 0x9212)},	/* Acer Gobi Modem Device */
>  	{QMI_GOBI1K_DEVICE(0x03f0, 0x1f1d)},	/* HP un2400 Gobi Modem Device */
> -	{QMI_GOBI1K_DEVICE(0x03f0, 0x371d)},	/* HP un2430 Mobile Broadband Module */
>  	{QMI_GOBI1K_DEVICE(0x04da, 0x250d)},	/* Panasonic Gobi Modem device */
>  	{QMI_GOBI1K_DEVICE(0x413c, 0x8172)},	/* Dell Gobi Modem device */
>  	{QMI_GOBI1K_DEVICE(0x1410, 0xa001)},	/* Novatel Gobi Modem device */
> @@ -440,6 +439,7 @@ static const struct usb_device_id products[] = {
>  	{QMI_GOBI_DEVICE(0x16d8, 0x8002)},	/* CMDTech Gobi 2000 Modem device (VU922) */
>  	{QMI_GOBI_DEVICE(0x05c6, 0x9205)},	/* Gobi 2000 Modem device */
>  	{QMI_GOBI_DEVICE(0x1199, 0x9013)},	/* Sierra Wireless Gobi 3000 Modem device (MC8355) */
> +	{QMI_GOBI_DEVICE(0x03f0, 0x371d)},	/* HP un2430 Mobile Broadband Module */
>  	{QMI_GOBI_DEVICE(0x1199, 0x9015)},	/* Sierra Wireless Gobi 3000 Modem device */
>  	{QMI_GOBI_DEVICE(0x1199, 0x9019)},	/* Sierra Wireless Gobi 3000 Modem device */
>  	{QMI_GOBI_DEVICE(0x1199, 0x901b)},	/* Sierra Wireless MC7770 */
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
