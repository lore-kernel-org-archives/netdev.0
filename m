From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] qmi_wwan: Added support for Gemalto's Cinterion PHxx WWAN interface
Date: Thu, 17 Mar 2016 17:23:21 +0100
Message-ID: <87egb9nkee.fsf@nemi.mork.no>
References: <1978E4F2CF12DD4A899FA7487323EB11010836882A@A1GTOEMBXV004.gto.a3c.atos.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Schemmel Hans-Christoph <Hans-Christoph.Schemmel@gemalto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:40562 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932295AbcCQQXg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 12:23:36 -0400
In-Reply-To: <1978E4F2CF12DD4A899FA7487323EB11010836882A@A1GTOEMBXV004.gto.a3c.atos.net>
	(Schemmel Hans-Christoph's message of "Thu, 17 Mar 2016 10:07:56
	+0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Schemmel Hans-Christoph <Hans-Christoph.Schemmel@gemalto.com> writes:

> Added support for Gemalto's Cinterion PHxx WWAN interfaces=20
> by adding QMI_FIXED_INTF with Cinterion's VID and PID.
>
> PHxx can have:
> 2 RmNet Interfaces (PID 0x0082) or
> 1 RmNet + 1 USB Audio interface (PID 0x0083).
>
> Signed-off-by: Hans-Christoph Schemmel <hans-christoph.schemmel@gemal=
to.com>
> ---
> patch is against linux-4.5
> --- linux/drivers/net/usb/qmi_wwan.c.orig	2016-03-14 12:18:07.1534974=
89 +0100
> +++ linux/drivers/net/usb/qmi_wwan.c	2016-03-14 12:21:37.722541644 +0=
100
> @@ -881,6 +881,9 @@ static const struct usb_device_id produc
>  	{QMI_FIXED_INTF(0x0b3c, 0xc00b, 4)},	/* Olivetti Olicard 500 */
>  	{QMI_FIXED_INTF(0x1e2d, 0x0060, 4)},	/* Cinterion PLxx */
>  	{QMI_FIXED_INTF(0x1e2d, 0x0053, 4)},	/* Cinterion PHxx,PXxx */
> +	{QMI_FIXED_INTF(0x1e2d, 0x0082, 4)},	/* Cinterion PHxx,PXxx (2 RmNe=
t) */
> +	{QMI_FIXED_INTF(0x1e2d, 0x0082, 5)},	/* Cinterion PHxx,PXxx (2 RmNe=
t) */
> +	{QMI_FIXED_INTF(0x1e2d, 0x0083, 4)},	/* Cinterion PHxx,PXxx (1 RmNe=
t + USB Audio)*/
>  	{QMI_FIXED_INTF(0x413c, 0x81a2, 8)},	/* Dell Wireless 5806 Gobi(TM)=
 4G LTE Mobile Broadband Card */
>  	{QMI_FIXED_INTF(0x413c, 0x81a3, 8)},	/* Dell Wireless 5570 HSPA+ (4=
2Mbps) Mobile Broadband Card */
>  	{QMI_FIXED_INTF(0x413c, 0x81a4, 8)},	/* Dell Wireless 5570e HSPA+ (=
42Mbps) Mobile Broadband Card */

Perfect.  Thanks.

Acked-by: Bj=C3=B8rn Mork <bjorn@mork.no>
