From: Sebastian Reichel <sebastian.reichel-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
Subject: Re: [PATCHv4] wlcore: add wl1285 compatible
Date: Tue, 23 May 2017 20:29:41 +0200
Message-ID: <20170523182941.abristnic2o2uiyi@earth>
References: <20170505141553.2605-1-sebastian.reichel@collabora.co.uk>
 <8737bx5jgr.fsf@purkki.adurom.net>
 <20170522.103010.1779800840743690143.davem@davemloft.net>
 <87wp99t0hj.fsf@kamboji.qca.qualcomm.com>
 <20170522152112.634mnsv65lryrmkp@earth>
 <CAL_JsqL91sruKNaWmVEqT+L_OCh5xFkkGY07mBBUmqkKHc5fQw@mail.gmail.com>
 <20170522162114.w4pw25pcecsm6lhi@earth>
 <CAL_JsqLJ1F-2So4fSeVwR7RsUZZwMLv7HcnzHdKrOUGCU2F8+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="lf5tzu75bfsjxpve"
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
In-Reply-To: <CAL_JsqLJ1F-2So4fSeVwR7RsUZZwMLv7HcnzHdKrOUGCU2F8+w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--lf5tzu75bfsjxpve
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Mon, May 22, 2017 at 11:50:04AM -0500, Rob Herring wrote:
> [...]
> >> >> Thanks, I'll take it then. Not sure why Sebastian was suggested to
> >> >> submit this patch via your tree in the first place.
> >> >>
> >> >> https://patchwork.kernel.org/patch/9713645/
> >> >
> >> > Thanks. The idea was to get into early 4.12-rc to avoid merge
> >> > conflicts in the droid 4 *.dts during 4.13 cycle. This strategy
> >> > obviously failed :)
> >>
> >> First, I'm not sure why you combined everything. A maintainer can just
> >> as easily take a series as a single patch and we prefer binding doc,
> >> dts and driver changes all separate.
> >>
> >> Second, the dts changes could go thru arm-soc and the driver change
> >> thru netdev. The binding doc can be thru either. There's no bisecting
> >> dependency and things shouldn't break. It just won't all work until
> >> you have both branches.
> >
> > This is only true for new devices. WLAN for droid4 works at the
> > moment using incorrect compatible string. If *.dts is updated and
> > driver is not yet updated WLAN does not work. IMHO that is a
> > bisecting dependency.
>=20
> True. That's also breaking compatibility if a new kernel doesn't work
> with an old DT.

This way around works. It's the other way around, that does not work
(new DT with old kernel).

> Is it just a compatible string change? If so, then just keep the
> old string as a fallback.

That should work.

-- Sebastian

--lf5tzu75bfsjxpve
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEE72YNB0Y/i3JqeVQT2O7X88g7+poFAlkkf5IACgkQ2O7X88g7
+poTAA//Z6U35mqgoF8/6rsezcFzrkocAerO7+eP15HDHZ3Y5KIbGjeU0Q38Pw8Q
VUMIKFuMBbiDHiUMubFuBSHnxml6vq056866ykgqpzH9/OoRVNzuixUU66c9u96/
nxeyWunVBy5gtUKogIQVwJsn27f2zYT3+TQqg8gXs+WAz8M9cbI9LeakMNjIvQ4l
yn5Ri96dgxiE7Y7m0MqxzlO80S2BK6RkLMYkjqfNXUXw0rFArdmUilQhKN4cjEXh
mYXgRoQ2WvoaV64zthIcxWGe7Y/enNZEsjhOp54Je7d3WuYeihOH/sWViRo2TdwR
9B0SIGeJTRr+9Xytnkw5btF7vCGlm6Ls2J9cFVyTXkedWW7NWxWiFz1QbldkceHG
PPMbs8NbNncrKFjxJB02+mfr8oqDlTi6pPLQlTTYOFO3e6w5YgrDt9059w3T0EDP
yZM6sHPR0ZqoxhPvHJw66JMc13T/VVH0GTzmhmMfs0GeeTuCQNJyEIBoB+wSD9IO
uPVrhvLbRlMuNbhj83jzdua1QCo6Epp8QJbMzYTE2i42HvKgPaDp8qvzKc8GqApj
DgYuXqIi6oidTToIi6TZPMbL5RYiWOwyg9qlreU2iD3EENlWyEydz6oS3f2qi8We
44fAckBNcv9+grATzYz21IvrhL80ZQffdEXW0cVcm09C6DiBgm4=
=iayZ
-----END PGP SIGNATURE-----

--lf5tzu75bfsjxpve--
