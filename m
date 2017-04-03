From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCHv4] net: usbnet: support 64bit stats
Date: Mon, 03 Apr 2017 10:22:29 +0200
Message-ID: <87vaqlx5mi.fsf@miraculix.mork.no>
References: <1491198603-24160-1-git-send-email-gerg@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: oneukum-IBi9RG/b67k@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Greg Ungerer <gerg-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1491198603-24160-1-git-send-email-gerg-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org> (Greg
        Ungerer's message of "Mon, 3 Apr 2017 15:50:03 +1000")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Greg Ungerer <gerg-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org> writes:

> Add support for the net stats64 counters to the usbnet core. With that
> in place put the hooks into every usbnet driver to use it.
>
> This is a strait forward addition of 64bit counters for RX and TX packet
> and byte counts. It is done in the same style as for the other net drivers
> that support stats64. Note that the other stats fields remain as 32bit
> sized values (error counts, etc).
>
> The motivation to add this is that it is not particularly difficult to
> get the RX and TX byte counts to wrap on 32bit platforms.
>
> Signed-off-by: Greg Ungerer <gerg-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
> ---
>  drivers/net/usb/asix_devices.c    |  3 +++
>  drivers/net/usb/ax88172a.c        |  1 +
>  drivers/net/usb/ax88179_178a.c    |  1 +
>  drivers/net/usb/cdc_mbim.c        |  1 +
>  drivers/net/usb/cdc_ncm.c         |  1 +
>  drivers/net/usb/dm9601.c          |  1 +
>  drivers/net/usb/int51x1.c         |  1 +
>  drivers/net/usb/mcs7830.c         |  1 +
>  drivers/net/usb/qmi_wwan.c        |  1 +
>  drivers/net/usb/rndis_host.c      |  1 +
>  drivers/net/usb/sierra_net.c      |  1 +
>  drivers/net/usb/smsc75xx.c        |  1 +
>  drivers/net/usb/smsc95xx.c        |  1 +
>  drivers/net/usb/sr9700.c          |  1 +
>  drivers/net/usb/sr9800.c          |  1 +
>  drivers/net/usb/usbnet.c          | 55 +++++++++++++++++++++++++++++++++=
+++---
>  drivers/net/wireless/rndis_wlan.c |  1 +
>  include/linux/usb/usbnet.h        |  4 +++
>  18 files changed, 73 insertions(+), 4 deletions(-)
>
> v2: EXPORT usbnet_get_stats64()
>     rebase on top of net-next
>
> v3: use percpu vars for stats64 counters
>
> v4: update all usbnet drivers to use stats64


Looking good.  For the qmi_wwan part:

Acked-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
