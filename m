From: Lars Melin <larsm17@gmail.com>
Subject: Re: [PATCH] net: qmi_wwan: Add ID for Telewell TW-LTE 4G v2
Date: Wed, 02 Jul 2014 12:19:46 +0700
Message-ID: <53B39672.7050301@gmail.com>
References: <87vbrgewei.fsf@bwachter.lart.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bernd Wachter <bernd.wachter@jolla.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87vbrgewei.fsf@bwachter.lart.info>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014-07-02 02:01, Bernd Wachter wrote:
> There's a new version of the Telewell 4G modem working with, but not
> recognized by this driver.
>
> Signed-off-by: Bernd Wachter <bernd.wachter@jolla.com>
> ---
> --- linux-3.15.3/drivers/net/usb/qmi_wwan.c.orig	2014-07-01 21:31:07.000000000 +0300
> +++ linux-3.15.3/drivers/net/usb/qmi_wwan.c	2014-07-01 20:39:30.000000000 +0300
> @@ -741,6 +741,7 @@ static const struct usb_device_id produc
>   	{QMI_FIXED_INTF(0x19d2, 0x1424, 2)},
>   	{QMI_FIXED_INTF(0x19d2, 0x1425, 2)},
>   	{QMI_FIXED_INTF(0x19d2, 0x1426, 2)},	/* ZTE MF91 */
> +	{QMI_FIXED_INTF(0x19d2, 0x1428, 2)},	/* Telewell TW-LTE 4G v2 */
>   	{QMI_FIXED_INTF(0x19d2, 0x2002, 4)},	/* ZTE (Vodafone) K3765-Z */
>   	{QMI_FIXED_INTF(0x0f3d, 0x68a2, 8)},    /* Sierra Wireless MC7700 */
>   	{QMI_FIXED_INTF(0x114f, 0x68a2, 8)},    /* Sierra Wireless MC7750 */
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-usb" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
For completeness (full device support) please create a patch for the 
serial interfaces in the option driver, see the entry for ZTE pid 1426 
in option.c as example.
