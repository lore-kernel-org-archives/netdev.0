From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH V2] qmi_wwan: add ONDA MT689DC device ID (fwd)
Date: Sat, 29 Jun 2013 16:01:04 +0200
Message-ID: <87wqpdxbhb.fsf@nemi.mork.no>
References: <alpine.LNX.2.02.1306291536160.3968@eeeadesso>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	scuall8907@gmail.com
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:33803 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751056Ab3F2OBI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 10:01:08 -0400
In-Reply-To: <alpine.LNX.2.02.1306291536160.3968@eeeadesso> (Enrico Mioso's
	message of "Sat, 29 Jun 2013 15:39:19 +0200 (CEST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enrico Mioso <mrkiko.rs@gmail.com> writes:

> Another QMI-speaking device by ZTE, re-branded by ONDA!
>
> I'm connected ovr this device's QMI interface right now, so I can say=
 I tested
> it! :)
>
> Note: a follow-up patch was posted to the linux-usb mailing list, to
> prevent the option driver from binding to the device's QMI interface,
> making it unusable.
>
> Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
>
>
> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
> index 5645921..d793ee9 100644
> --- a/drivers/net/usb/qmi_wwan.c
> +++ b/drivers/net/usb/qmi_wwan.c
> @@ -523,6 +523,7 @@ static const struct usb_device_id products[] =3D =
{
>  	{QMI_FIXED_INTF(0x19d2, 0x0002, 1)},
>  	{QMI_FIXED_INTF(0x19d2, 0x0012, 1)},
>  	{QMI_FIXED_INTF(0x19d2, 0x0017, 3)},
> +	{QMI_FIXED_INTF(0x19d2, 0x0019, 3)}, /* ONDA MT689DC */
>  	{QMI_FIXED_INTF(0x19d2, 0x0021, 4)},
>  	{QMI_FIXED_INTF(0x19d2, 0x0025, 1)},
>  	{QMI_FIXED_INTF(0x19d2, 0x0031, 4)},

Acked-by: Bj=C3=B8rn Mork <bjorn@mork.no>
