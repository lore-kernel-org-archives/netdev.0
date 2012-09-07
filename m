From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: MBIM (was: Re: changing usbnet's API to better deal with cdc-ncm)
Date: Fri, 07 Sep 2012 09:40:59 +0200
Message-ID: <3121990.L41g6gGrVV@linux-lqwf.site>
References: <2791550.LhGu6po6Xy@linux-lqwf.site> <87ehmf36qd.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87ehmf36qd.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 06 September 2012 10:17:46 Bj=F8rn Mork wrote:
> Not really related, but I am still worrying how MBIM is going to fit
> into the usbnet model where you have a strict relation between one
> netdev and one USB interface.  Do you see any way usbnet could be
> extended to manage a list of netdevs?
>=20
> All the netdev related functions doing
>=20
>         struct usbnet           *dev =3D netdev_priv(net);
>=20
> would still work.  But all the USB related functions using dev->net t=
o
> get the netdev would fail.  Maybe this will be too difficult to
> implement within the usbnet framework at all?

It depends on how much support we get from upper layers.
You can give two IPs to an ethernet card as well.

It would be best if you could come up with some preliminary code
at least.

	Reagrds
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
