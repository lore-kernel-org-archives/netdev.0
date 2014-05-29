From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net: qmi_wwan: interface #11 in Sierra Wireless MC73xx is not QMI
Date: Thu, 29 May 2014 14:14:37 +0200
Message-ID: <87ppiwbx3m.fsf@nemi.mork.no>
References: <1401364296-7207-1-git-send-email-aleksander@aleksander.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	davem@davemloft.net
To: Aleksander Morgado <aleksander@aleksander.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:38180 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757307AbaE2MOo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 08:14:44 -0400
In-Reply-To: <1401364296-7207-1-git-send-email-aleksander@aleksander.es>
	(Aleksander Morgado's message of "Thu, 29 May 2014 13:51:36 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Aleksander Morgado <aleksander@aleksander.es> writes:

> This interface is unusable, as the cdc-wdm character device doesn't r=
eply to
> any QMI command. Also, the out-of-tree Sierra Wireless GobiNet driver=
 fully
> skips it.
>
> Signed-off-by: Aleksander Morgado <aleksander@aleksander.es>
> ---
>  drivers/net/usb/qmi_wwan.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
> index faa1277..dc4bf06 100644
> --- a/drivers/net/usb/qmi_wwan.c
> +++ b/drivers/net/usb/qmi_wwan.c
> @@ -748,7 +748,6 @@ static const struct usb_device_id products[] =3D =
{
>  	{QMI_FIXED_INTF(0x1199, 0x68a2, 19)},	/* Sierra Wireless MC7710 in =
QMI mode */
>  	{QMI_FIXED_INTF(0x1199, 0x68c0, 8)},	/* Sierra Wireless MC73xx */
>  	{QMI_FIXED_INTF(0x1199, 0x68c0, 10)},	/* Sierra Wireless MC73xx */
> -	{QMI_FIXED_INTF(0x1199, 0x68c0, 11)},	/* Sierra Wireless MC73xx */
>  	{QMI_FIXED_INTF(0x1199, 0x901c, 8)},    /* Sierra Wireless EM7700 *=
/
>  	{QMI_FIXED_INTF(0x1199, 0x901f, 8)},    /* Sierra Wireless EM7355 *=
/
>  	{QMI_FIXED_INTF(0x1199, 0x9041, 8)},	/* Sierra Wireless MC7305/MC73=
55 */

Acked-by: Bj=C3=B8rn Mork <bjorn@mork.no>
