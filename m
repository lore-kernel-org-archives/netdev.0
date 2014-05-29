From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net: qmi_wwan: add additional Sierra Wireless QMI devices
Date: Thu, 29 May 2014 14:14:31 +0200
Message-ID: <87tx88bx3s.fsf@nemi.mork.no>
References: <1401363885-6846-1-git-send-email-aleksander@aleksander.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	davem@davemloft.net
To: Aleksander Morgado <aleksander@aleksander.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:38177 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757307AbaE2MOj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 08:14:39 -0400
In-Reply-To: <1401363885-6846-1-git-send-email-aleksander@aleksander.es>
	(Aleksander Morgado's message of "Thu, 29 May 2014 13:44:45 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Aleksander Morgado <aleksander@aleksander.es> writes:

> A set of new VID/PIDs retrieved from the out-of-tree GobiNet/GobiSeri=
al
> Sierra Wireless drivers.
>
> Signed-off-by: Aleksander Morgado <aleksander@aleksander.es>
> ---
>
> Hey,
>
> The patch should be applied after the following one:
>   [PATCH] net: qmi_wwan: add Netgear AirCard 341U
>   http://marc.info/?l=3Dlinux-netdev&m=3D140130407711048&w=3D2
>
> Cheers!
>
>  drivers/net/usb/qmi_wwan.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
> index c0b611f..faa1277 100644
> --- a/drivers/net/usb/qmi_wwan.c
> +++ b/drivers/net/usb/qmi_wwan.c
> @@ -753,7 +753,11 @@ static const struct usb_device_id products[] =3D=
 {
>  	{QMI_FIXED_INTF(0x1199, 0x901f, 8)},    /* Sierra Wireless EM7355 *=
/
>  	{QMI_FIXED_INTF(0x1199, 0x9041, 8)},	/* Sierra Wireless MC7305/MC73=
55 */
>  	{QMI_FIXED_INTF(0x1199, 0x9051, 8)},	/* Netgear AirCard 340U */
> +	{QMI_FIXED_INTF(0x1199, 0x9053, 8)},	/* Sierra Wireless Modem */
> +	{QMI_FIXED_INTF(0x1199, 0x9054, 8)},	/* Sierra Wireless Modem */
>  	{QMI_FIXED_INTF(0x1199, 0x9055, 8)},	/* Netgear AirCard 341U */
> +	{QMI_FIXED_INTF(0x1199, 0x9056, 8)},	/* Sierra Wireless Modem */
> +	{QMI_FIXED_INTF(0x1199, 0x9061, 8)},	/* Sierra Wireless Modem */
>  	{QMI_FIXED_INTF(0x1bbb, 0x011e, 4)},	/* Telekom Speedstick LTE II (=
Alcatel One Touch L100V LTE) */
>  	{QMI_FIXED_INTF(0x1bbb, 0x0203, 2)},	/* Alcatel L800MA */
>  	{QMI_FIXED_INTF(0x2357, 0x0201, 4)},	/* TP-LINK HSUPA Modem MA180 *=
/
> --
> 1.9.3

Acked-by: Bj=C3=B8rn Mork <bjorn@mork.no>
