From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: rfkill vs. interface up
Date: Thu, 21 May 2009 18:05:24 +0200
Message-ID: <1242921924.4212.11.camel@johannes.local>
References: <1242736331.4797.22.camel@johannes.local>
	 <1242920389.14369.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-u9OoILAc7PMWrkYrCTQ0"
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1242920389.14369.16.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-u9OoILAc7PMWrkYrCTQ0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-05-21 at 11:39 -0400, Dan Williams wrote:

> That proposal sounds fine to me from a userspace perspective.  Sane
> implementations don't assume the interface is IFF_UP when they configure
> the device anyway (since it's not necessarily up at boot time or after
> hibernate for example), and since you need a reconfigure after rfkill,
> this seems reasonable.
>=20
> You wouldn't have to give up on txpower either, you could simply map
> 'txpower off' to SW-rfkill, and 'txpower on' to un-SW-rfkill, where of
> course the interface would be !IFF_UP after 'txpower on' just like
> flipping the killswitch would.

Yeah, good point, that sounds better than having to give up on it -- the
key though is that we can't recover IFF_UP state when that happens; if
that's ok this should be fairly simple.

johannes

--=-u9OoILAc7PMWrkYrCTQ0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKFXvBAAoJEODzc/N7+QmaCF8QAKAdwms2cuWt09HUtkvSKYXb
DBXcc+6f08O7yCIekWDQ8D6c3Vla1YsUZjS0+80GBKSjvhTwYfJhQp0yubzjypic
sOlF79MxUMMsqsd0LLgxl4lgBEabiJUaX87LSlSv5a08A4n9Bnt/TuNyvBO83GSG
sigaan9f772b+LGeZ+6pjIbVwuUGsp+72/CNBtpLrmxX7bo7JGjfiAsPNLL0VVjC
EUQ2hgS6o66Nksrsc6TXNhL6e3uzJVqakSfls3Ats51dyPi+6zgPJHeAS+fJaUTs
qVRaCawQA9fiMQIYQ4kU+RWddNzfdTgu+0mONJX3BEg9Op0j8sPf0K7VwbSfWaS/
1AXzUzsoFIovQ0iPRwTaQMplF/NFb8J2Gy4mXuRzAhQBEHV49+T8jtYj2BZdGJe6
YXUT1c+0hdJW4Du3HrQrcmmsLtutM9+YXLxelnKORCpSi2LntCdx3qyOTGqf57GD
Wq0APH2PrEQdkbsAe/OLBxvwm03yJTGhKIWBmxD8r+j0p9h6ds47JW7va/g4KUf5
PXEbLI4iuLXGkYHYn92qcajTXmSdTtOGHEp0r1N6THi9o/joFMdHYC0ShdPKRJvj
GlDLEtb+c4Tb9XO1A3qtZcZRniloyXDpJ7EkrrDOgb2eHBrUXLmMM9wdryTpWVPO
rLKMwYweuDScXpAE3dEU
=IMK9
-----END PGP SIGNATURE-----

--=-u9OoILAc7PMWrkYrCTQ0--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
