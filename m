From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] usb: serial: option: blacklist Olivetti Olicard200
Date: Tue, 15 Oct 2013 09:47:18 -0500
Message-ID: <1381848438.25397.1.camel@dcbw.foobar.com>
References: <1381842408-10800-1-git-send-email-mrkiko.rs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, davem@davemloft.net, bjorn@mork.no,
	christian.schmiedl@gemalto.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Antonella Pellizzari <anto.pellizzari83@gmail.com>
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381842408-10800-1-git-send-email-mrkiko.rs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-10-15 at 15:06 +0200, Enrico Mioso wrote:
> Interface 6 of this device speaks QMI as per tests done by us.
> Credits go to Antonella for providing the hardware.
> 
> Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
> Signed-off-by: Antonella Pellizzari <anto.pellizzari83@gmail.com>

Tested-by: Dan Williams <dcbw@redhat.com>

> diff --git a/drivers/usb/serial/option.c b/drivers/usb/serial/option.c
> index 80a7104..d7c10d6 100644
> --- a/drivers/usb/serial/option.c
> +++ b/drivers/usb/serial/option.c
> @@ -1257,7 +1257,9 @@ static const struct usb_device_id option_ids[] = {
>  
>  	{ USB_DEVICE(OLIVETTI_VENDOR_ID, OLIVETTI_PRODUCT_OLICARD100) },
>  	{ USB_DEVICE(OLIVETTI_VENDOR_ID, OLIVETTI_PRODUCT_OLICARD145) },
> -	{ USB_DEVICE(OLIVETTI_VENDOR_ID, OLIVETTI_PRODUCT_OLICARD200) },
> +	{ USB_DEVICE(OLIVETTI_VENDOR_ID, OLIVETTI_PRODUCT_OLICARD200),
> +		.driver_info = (kernel_ulong_t)&net_intf6_blacklist
> +	},
>  	{ USB_DEVICE(CELOT_VENDOR_ID, CELOT_PRODUCT_CT680M) }, /* CT-650 CDMA 450 1xEVDO modem */
>  	{ USB_DEVICE_AND_INTERFACE_INFO(SAMSUNG_VENDOR_ID, SAMSUNG_PRODUCT_GT_B3730, USB_CLASS_CDC_DATA, 0x00, 0x00) }, /* Samsung GT-B3730 LTE USB modem.*/
>  	{ USB_DEVICE(YUGA_VENDOR_ID, YUGA_PRODUCT_CEM600) },
