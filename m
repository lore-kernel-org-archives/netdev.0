From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH] USB 10/100 RJ45 Ethernet Network Adapter
Date: Tue, 22 Feb 2011 22:18:39 +0300
Message-ID: <4D640C0F.3050703@ru.mvista.com>
References: <20110222140705.GA6055@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter Korsgaard <jacmet@sunsite.dk>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org
To: Shahar Havivi <shaharh@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110222140705.GA6055@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Shahar Havivi wrote:

> The device is very similar to (0x0fe6, 0x8101),
> And works well with dm9601 driver.

   You should sign off your patch in order for it to be merged.

> ---
>  drivers/net/usb/dm9601.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)

> diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
> index 02b622e..2d1c8ae 100644
> --- a/drivers/net/usb/dm9601.c
> +++ b/drivers/net/usb/dm9601.c
> @@ -654,6 +654,11 @@ static const struct usb_device_id products[] = {
>  	 USB_DEVICE(0x0a46, 0x9000),	/* DM9000E */
>  	 .driver_info = (unsigned long)&dm9601_info,
>  	 },
> +	{
> +	 USB_DEVICE(0x0fe6, 0x9700),	/* DM9601 USB to Fast Ethernet Adapter */
> +

    Extra empty line shouldn't be here I guess...

> +	 .driver_info = (unsigned long)&dm9601_info,
> +	 },
>  	{},			// END
>  };

WBR, Sergei
