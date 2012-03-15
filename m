From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH net-next] usbnet: use netif_tx_wake_queue instead of netif_start_queue
Date: Thu, 15 Mar 2012 18:05:09 +0100
Message-ID: <201203151805.09136.oneukum@suse.de>
References: <1331733624-23266-1-git-send-email-alexey.orishko@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1331733624-23266-1-git-send-email-alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 14. M=C3=A4rz 2012, 15:00:24 schrieb Alexey Orishko:
> If host is going to autosuspend function with two interfaces and
> if IP packet has arrived in-between of two usbnet_suspend() callbacks=
,
> i.e usbnet_resume() is called in-between, tx data flow is stopped.
> When autosuspend timer expires and device is put to autosuspend
> again, tx queue is waked up and data can be sent again.
> This behavior might be repeated several times in a row.
>=20
> Tested on Intel/ARM.
>=20
> Reviewed-by: Sjur Br=C3=A6ndeland <sjur.brandeland-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
> Tested-by: Dmitry Tarnyagin <dmitry.tarnyagin-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
> Signed-off-by: Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Acked-by: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
