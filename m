From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH 1/1] smsc95xx: add FLAG_POINTTOPOINT flag for driver_info
Date: Wed, 16 May 2012 19:56:33 +0800
Message-ID: <CACVXFVNzmq74BKYZN1SpXYULneV2ASmniMhs4LhevPm-XgSJpg@mail.gmail.com>
References: <1337155302-26244-1-git-send-email-jgq516@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steve.glendinning@smsc.com, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jgq516@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337155302-26244-1-git-send-email-jgq516@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 16, 2012 at 4:01 PM,  <jgq516@gmail.com> wrote:
> From: Xiao Jiang <jgq516@gmail.com>
>
> commit c26134 introduced FLAG_POINTTOPOINT flag for USB ethernet devi=
ces
> which possibly use "usb%d" names, add this flag to make sure pandaboa=
rd
> can mount nfs with smsc95xx NIC.

Without the flag, I also can mount nfs successfully on my Pandaboard...

>
> Signed-off-by: Xiao Jiang <jgq516@gmail.com>
> ---
> =A0drivers/net/usb/smsc95xx.c | =A0 =A03 ++-
> =A01 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> index 94ae669..e158288 100644
> --- a/drivers/net/usb/smsc95xx.c
> +++ b/drivers/net/usb/smsc95xx.c
> @@ -1192,7 +1192,8 @@ static const struct driver_info smsc95xx_info =3D=
 {
> =A0 =A0 =A0 =A0.rx_fixup =A0 =A0 =A0 =3D smsc95xx_rx_fixup,
> =A0 =A0 =A0 =A0.tx_fixup =A0 =A0 =A0 =3D smsc95xx_tx_fixup,
> =A0 =A0 =A0 =A0.status =A0 =A0 =A0 =A0 =3D smsc95xx_status,
> - =A0 =A0 =A0 .flags =A0 =A0 =A0 =A0 =A0=3D FLAG_ETHER | FLAG_SEND_ZL=
P | FLAG_LINK_INTR,
> + =A0 =A0 =A0 .flags =A0 =A0 =A0 =A0 =A0=3D FLAG_ETHER | FLAG_POINTTO=
POINT | FLAG_SEND_ZLP |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 FLAG_LINK_INTR,
> =A0};
>
> =A0static const struct usb_device_id products[] =3D {
> --
> 1.7.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/


Thanks,
--=20
Ming Lei
