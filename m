From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net: qmi_wwan: Add ID for Telewell TW-LTE 4G v2
Date: Wed, 02 Jul 2014 09:04:10 +0200
Message-ID: <87wqbw1bth.fsf@nemi.mork.no>
References: <87vbrgewei.fsf@bwachter.lart.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bernd Wachter <bernd.wachter@jolla.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87vbrgewei.fsf@bwachter.lart.info> (Bernd Wachter's message of
	"Tue, 01 Jul 2014 22:01:09 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bernd Wachter <bernd.wachter@jolla.com> writes:

> There's a new version of the Telewell 4G modem working with, but not
> recognized by this driver.=20
>
> Signed-off-by: Bernd Wachter <bernd.wachter@jolla.com>
> ---
> --- linux-3.15.3/drivers/net/usb/qmi_wwan.c.orig	2014-07-01 21:31:07.=
000000000 +0300
> +++ linux-3.15.3/drivers/net/usb/qmi_wwan.c	2014-07-01 20:39:30.00000=
0000 +0300
> @@ -741,6 +741,7 @@ static const struct usb_device_id produc
>  	{QMI_FIXED_INTF(0x19d2, 0x1424, 2)},
>  	{QMI_FIXED_INTF(0x19d2, 0x1425, 2)},
>  	{QMI_FIXED_INTF(0x19d2, 0x1426, 2)},	/* ZTE MF91 */
> +	{QMI_FIXED_INTF(0x19d2, 0x1428, 2)},	/* Telewell TW-LTE 4G v2 */
>  	{QMI_FIXED_INTF(0x19d2, 0x2002, 4)},	/* ZTE (Vodafone) K3765-Z */
>  	{QMI_FIXED_INTF(0x0f3d, 0x68a2, 8)},    /* Sierra Wireless MC7700 *=
/
>  	{QMI_FIXED_INTF(0x114f, 0x68a2, 8)},    /* Sierra Wireless MC7750 *=
/

Acked-by: Bj=C3=B8rn Mork <bjorn@mork.no>

Please queue this for stable as well.  Thanks.


Bj=C3=B8rn
