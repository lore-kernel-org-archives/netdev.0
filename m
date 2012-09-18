From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH] asix: Support DLink DUB-E100 H/W Ver C1
Date: Tue, 18 Sep 2012 07:41:11 +0200
Message-ID: <CABkLObpU3P84AHTBG1hkrHt_HdaPzdTiRU1ACnJv=Qhb+wYPbQ@mail.gmail.com>
References: <1347909800-3056-1-git-send-email-sgh@sgh.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: =?UTF-8?Q?S=C3=B8ren_Holm?= <sgh@sgh.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:34295 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755270Ab2IRFlM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 01:41:12 -0400
In-Reply-To: <1347909800-3056-1-git-send-email-sgh@sgh.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi S=C3=B8ren,

On Mon, Sep 17, 2012 at 9:23 PM, S=C3=B8ren Holm <sgh@sgh.dk> wrote:
> Signed-off-by: S=C3=B8ren Holm <sgh@sgh.dk>
> Cc: stable@vger.kernel.org
> ---
>  drivers/net/usb/asix.c |    4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
> index 3ae80ec..12f372e 100644
> --- a/drivers/net/usb/asix.c
> +++ b/drivers/net/usb/asix.c
> @@ -1604,6 +1604,10 @@ static const struct usb_device_id        produ=
cts [] =3D {
>         USB_DEVICE (0x2001, 0x3c05),
>         .driver_info =3D (unsigned long) &ax88772_info,
>  }, {
> +       // DLink DUB-E100 H/W Ver C1
> +       USB_DEVICE (0x2001, 0x1a02),
> +       .driver_info =3D (unsigned long) &ax88772_info,
> +}, {

This will not apply to recent kernels, drivers/net/usb/asix.c has been
split into several files, please make these changes in
drivers/net/usb/asix_devices.c.

Regards, Christian

>         // Linksys USB1000
>         USB_DEVICE (0x1737, 0x0039),
>         .driver_info =3D (unsigned long) &ax88178_info,
> --
> 1.7.10.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
