From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH] net: qmi_wwan: new device: Foxconn/Novatel E396
Date: Wed, 29 Aug 2012 09:03:34 +0200
Message-ID: <87r4qq89ix.fsf@nemi.mork.no>
References: <1346157032-31742-1-git-send-email-aleksander@lanedo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ben Chan <benchan-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: Aleksander Morgado <aleksander-bhGbAngMcJvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1346157032-31742-1-git-send-email-aleksander-bhGbAngMcJvQT0dZR+AlfA@public.gmane.org>
	(Aleksander Morgado's message of "Tue, 28 Aug 2012 14:30:32 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Aleksander Morgado <aleksander-bhGbAngMcJvQT0dZR+AlfA@public.gmane.org> writes:

> Foxconn-branded Novatel E396, Gobi3k modem.
>
> Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> Cc: Ben Chan <benchan-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Aleksander Morgado <aleksander-bhGbAngMcJvQT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/net/usb/qmi_wwan.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
> index 328397c..189e52d 100644
> --- a/drivers/net/usb/qmi_wwan.c
> +++ b/drivers/net/usb/qmi_wwan.c
> @@ -441,6 +441,7 @@ static const struct usb_device_id products[] =3D =
{
>  	{QMI_GOBI_DEVICE(0x1199, 0x9015)},	/* Sierra Wireless Gobi 3000 Mod=
em device */
>  	{QMI_GOBI_DEVICE(0x1199, 0x9019)},	/* Sierra Wireless Gobi 3000 Mod=
em device */
>  	{QMI_GOBI_DEVICE(0x1199, 0x901b)},	/* Sierra Wireless MC7770 */
> +	{QMI_GOBI_DEVICE(0x1410, 0xa021)},	/* Foxconn Gobi 3000 Modem devic=
e (Novatel E396) */
> =20
>  	{ }					/* END */
>  };

Thanks.  Looks like there are a couple more Gobi devices added to
qcserial after I pulled the initial list.  Care to add those as well?
I'm a bit inbetween spare time at the moment...

If it matters to anyone:

Acked-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
