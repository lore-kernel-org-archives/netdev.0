From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH] qmi_wwan: Added support for Cinterion's PLxx WWAN Interface
Date: Tue, 21 May 2013 15:19:43 +0200
Message-ID: <877gislbbk.fsf@nemi.mork.no>
References: <376FB829F3ECB542B825EAF4D8CA8A97013E8459E48B@CROEXCFWP03.gemalto.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb\@vger.kernel.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Schemmel Hans-Christoph <Hans-Christoph.Schemmel-av01+Y74gORBDgjK7y7TUQ@public.gmane.org>
To: Schmiedl Christian <Christian.Schmiedl-av01+Y74gORBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <376FB829F3ECB542B825EAF4D8CA8A97013E8459E48B-6vtk6ynWDJf9L9UzlSODQOG7l92LEt8e@public.gmane.org>
	(Schmiedl Christian's message of "Tue, 21 May 2013 14:07:17 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Schmiedl Christian <Christian.Schmiedl-av01+Y74gORBDgjK7y7TUQ@public.gmane.org> writes:

> From: Hans-Christoph Schemmel <hans-christoph.schemmel-av01+Y74gORBDgjK7y7TUQ@public.gmane.org>
>
> Added support for Cinterion's PLxx WWAN Interface by adding QMI_FIXED=
_INTF with
> Cinterion's Vendor ID as well as Product ID and WWAN Interface Number=
=2E
>
> Signed-off-by: Hans-Christoph Schemmel <hans-christoph.schemmel@gemal=
to.com>
> Signed-off-by: Christian Schmiedl <christian.schmiedl-av01+Y74gORBDgjK7y7TUQ@public.gmane.org>
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
>
>  	/* 4. Gobi 1000 devices */
>  	{QMI_GOBI1K_DEVICE(0x05c6, 0x9212)},	/* Acer Gobi Modem Device */

Acked-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
