From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] NET DRIVER: Added support for Cinterion's PLxx WWAN Interface
Date: Mon, 06 May 2013 14:07:10 +0200
Message-ID: <87ehdk71n5.fsf@nemi.mork.no>
References: <239D7A53E5B17B4BB20795A7977613A4A7EE9993A8@CROEXCFWP04.gemalto.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Schemmel Hans-Christoph <Hans-Christoph.Schemmel@gemalto.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <239D7A53E5B17B4BB20795A7977613A4A7EE9993A8@CROEXCFWP04.gemalto.com>
	(Schemmel Hans-Christoph's message of "Mon, 6 May 2013 11:16:46
	+0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Schemmel Hans-Christoph <Hans-Christoph.Schemmel@gemalto.com> writes:

> /drivers/net/usb/qmi_wwan.c: Added support for Cinterion's PLxx WWAN =
Interface by adding QMI_FIXED_INTF with Cinterion's Vendor ID as well a=
s Product ID and WWAN Interface Number.
>
> Signed-off-by: Hans-Christoph Schemmel <hans-christoph.schemmel@gemal=
to.com>
> ---
> patch is against linux-3.9
> --- linux-3.9/drivers/net/usb/qmi_wwan.c.orig	2013-05-06 08:10:11.170=
034451 +0200
> +++ linux-3.9/drivers/net/usb/qmi_wwan.c	2013-05-06 08:58:00.80026417=
9 +0200
> @@ -569,6 +569,7 @@ static const struct usb_device_id produc
>  	{QMI_FIXED_INTF(0x1bbb, 0x011e, 4)},	/* Telekom Speedstick LTE II (=
Alcatel One Touch L100V LTE) */
>  	{QMI_FIXED_INTF(0x2357, 0x0201, 4)},	/* TP-LINK HSUPA Modem MA180 *=
/
>  	{QMI_FIXED_INTF(0x1bc7, 0x1200, 5)},	/* Telit LE920 */
> +	{QMI_FIXED_INTF(0x1e2d, 0x12d1, 4)},	/* Cinterion PLxx */
> =20
>  	/* 4. Gobi 1000 devices */
>  	{QMI_GOBI1K_DEVICE(0x05c6, 0x9212)},	/* Acer Gobi Modem Device */


Looks good.  Thanks.

Acked-by: Bj=C3=B8rn Mork <bjorn@mork.no>
