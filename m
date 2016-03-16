From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] USB: qmi_wwan: add Dell Wireless 5809e Gobi 4G HSPA+ (rev3)
Date: Wed, 16 Mar 2016 12:26:00 +0100
Message-ID: <871t7apstz.fsf@nemi.mork.no>
References: <1458126825-15753-1-git-send-email-patrik_halfar@halfarit.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Patrik Halfar <patrik_halfar@halfarit.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:56008 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934163AbcCPL0M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 07:26:12 -0400
In-Reply-To: <1458126825-15753-1-git-send-email-patrik_halfar@halfarit.cz>
	(Patrik Halfar's message of "Wed, 16 Mar 2016 12:13:45 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrik Halfar <patrik_halfar@halfarit.cz> writes:

> --- a/drivers/net/usb/qmi_wwan.c
> +++ b/drivers/net/usb/qmi_wwan.c
> @@ -884,6 +884,7 @@ static const struct usb_device_id products[] =3D =
{
>  	{QMI_FIXED_INTF(0x413c, 0x81a8, 8)},	/* Dell Wireless 5808 Gobi(TM)=
 4G LTE Mobile Broadband Card */
>  	{QMI_FIXED_INTF(0x413c, 0x81a9, 8)},	/* Dell Wireless 5808e Gobi(TM=
) 4G LTE Mobile Broadband Card */
>  	{QMI_FIXED_INTF(0x413c, 0x81b1, 8)},	/* Dell Wireless 5809e Gobi(TM=
) 4G LTE Mobile Broadband Card */
> +	{QMI_FIXED_INTF(0x413c, 0x81b3, 8)},	/* Dell Wireless 5809e Gobi(TM=
) 4G LTE Mobile Broadband Card (rev3) */
>  	{QMI_FIXED_INTF(0x03f0, 0x4e1d, 8)},	/* HP lt4111 LTE/EV-DO/HSPA+ G=
obi 4G Module */
>  	{QMI_FIXED_INTF(0x22de, 0x9061, 3)},	/* WeTelecom WPD-600N */
>  	{QMI_FIXED_INTF(0x1e0e, 0x9001, 5)},	/* SIMCom 7230E */

Huh?  This is already applied AFAICS:
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/=
drivers/net/usb/qmi_wwan.c?id=3Dfb5eb24cdd5cdb83be77d3e4b2f16e92e06bd9e=
9



Bj=C3=B8rn
