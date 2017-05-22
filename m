From: Sebastian Reichel <sebastian.reichel-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
Subject: Re: [PATCHv4] wlcore: add wl1285 compatible
Date: Mon, 22 May 2017 18:21:15 +0200
Message-ID: <20170522162114.w4pw25pcecsm6lhi@earth>
References: <20170505141553.2605-1-sebastian.reichel@collabora.co.uk>
 <8737bx5jgr.fsf@purkki.adurom.net>
 <20170522.103010.1779800840743690143.davem@davemloft.net>
 <87wp99t0hj.fsf@kamboji.qca.qualcomm.com>
 <20170522152112.634mnsv65lryrmkp@earth>
 <CAL_JsqL91sruKNaWmVEqT+L_OCh5xFkkGY07mBBUmqkKHc5fQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="qudstgvlcj7ysmyi"
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
        Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-omap <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAL_JsqL91sruKNaWmVEqT+L_OCh5xFkkGY07mBBUmqkKHc5fQw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--qudstgvlcj7ysmyi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Mon, May 22, 2017 at 11:11:49AM -0500, Rob Herring wrote:
> On Mon, May 22, 2017 at 10:21 AM, Sebastian Reichel
> <sebastian.reichel-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org> wrote:
> > Hi,
> >
> > On Mon, May 22, 2017 at 05:44:24PM +0300, Kalle Valo wrote:
> >> David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:
> >> > From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
> >> > Date: Mon, 22 May 2017 12:28:20 +0300
> >> >
> >> >> Sebastian Reichel <sebastian.reichel-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org> writes:
> >> >>
> >> >>> Motorola Droid 4 uses a WL1285C. With differences between the
> >> >>> chips not being public let's add explicit binding for wl1285
> >> >>> instead of relying on wl1283 being very similar.
> >> >>>
> >> >>> Reviewed-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> >> >>> Acked-by: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
> >> >>> Acked-by: Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>
> >> >>> Signed-off-by: Sebastian Reichel <sebastian.reichel-ZGY8ohtN/8oXa1LcwEujcA@public.gmane.org=
k>
> >> >>> ---
> >> >>> Hi Dave,
> >> >>>
> >> >>> I previously send this in two patches, but its hard to apply witho=
ut
> >> >>> requiring multiple kernel releases (the driver must be updated bef=
ore
> >> >>> the DTS change). Since the actual change is not very complex Marcel
> >> >>> Holtmann & Tony Lindgren suggested, that I send this directly to y=
ou
> >> >>> in a single patch for inclusion into 4.12. This also means, that t=
he
> >> >>> remaining series can be queued normally for 4.13.
> >> >>
> >> >> I noticed that Dave set this patch to Awaiting Upstream state on his
> >> >> patchwork:
> >> >>
> >> >> https://patchwork.ozlabs.org/patch/759042/
> >> >>
> >> >> Which makes me suspect that he is waiting me to apply this (as I
> >> >> normally apply wlcore patches). Dave, should I actually take this p=
atch?
> >> >> What do you prefer?
> >> >
> >> > Anything that touches wireless drivers I defer to you, yes.
> >>
> >> Thanks, I'll take it then. Not sure why Sebastian was suggested to
> >> submit this patch via your tree in the first place.
> >>
> >> https://patchwork.kernel.org/patch/9713645/
> >
> > Thanks. The idea was to get into early 4.12-rc to avoid merge
> > conflicts in the droid 4 *.dts during 4.13 cycle. This strategy
> > obviously failed :)
>=20
> First, I'm not sure why you combined everything. A maintainer can just
> as easily take a series as a single patch and we prefer binding doc,
> dts and driver changes all separate.
>=20
> Second, the dts changes could go thru arm-soc and the driver change
> thru netdev. The binding doc can be thru either. There's no bisecting
> dependency and things shouldn't break. It just won't all work until
> you have both branches.

This is only true for new devices. WLAN for droid4 works at the
moment using incorrect compatible string. If *.dts is updated and
driver is not yet updated WLAN does not work. IMHO that is a
bisecting dependency.

It would have been fine to sneak the driver change into 4.12 and
queue the *.dts change in 4.13, though. IIRC Tony suggest to make
it one patch.

-- Sebastian

--qudstgvlcj7ysmyi
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEE72YNB0Y/i3JqeVQT2O7X88g7+poFAlkjD/gACgkQ2O7X88g7
+potAQ//Zg4paFigzw/mj9gBU3ClP6Uok7Jh92nHYiOIzIb7AyWDhmz8oUJWwHU7
Jpj1zO3ZJHx9SvEZ15UqZOEmzIvSZkJF9k6q8gxJLBMfEbQLQqtXvgjsBAlXq5Tk
fEtDVFbpl+NDNGJZaVqy2D48pz0CCJ01QpDt+XeoVJjUkNmuoWb6VexZAEoKgE9i
7j0hxHxhfxbyebFVxZD5tgzC3c7+kS2ev7PAQ8ugCjVn/uPcVOAO8GOXYO9vtBbD
ZjNiDg51u5Qev0DRXHXZErbjgf/Exxyo9H+kRLzOTvEJuWYpWPeRvX9UOuH+KSPs
4RMweYw/MCnpIFH/SMzBNVcxs4OfnF0EzjGHVw9rOXHcC5B2werltKq08mEaHsJk
ukxqp+jsDUxiPiMqrYH3QjakNJ1Zvhs9Co1wdqoRP/5NI+JqWjxVCqxdKE30KkwH
YIHnRV0BiSbcsIy25m+nWKInA3kIOEW8Z8o15s6I7Cfd+oXCZvhmpm5q4pU47k3P
zz3w+Mi/VRAnOyi9JeKvUi0dSfWPmA0I+zk7kpLgHZouZWj87RgNg7aaaJozfPrZ
vFDLZkxcJS8qEX8/EGIJ9SDX7zm1P+MACo4fjyjlGchd35uj2xDVUGqc3XFhcv3C
dUpT2LjatyzAsTHPwnHLtf0CFIeVjHfTqqURE75C6FsKvZYEewE=
=yoyo
-----END PGP SIGNATURE-----

--qudstgvlcj7ysmyi--
