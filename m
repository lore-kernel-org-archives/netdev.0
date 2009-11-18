From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC v2] mac80211: disallow bridging managed/adhoc interfaces
Date: Wed, 18 Nov 2009 11:52:49 +0100
Message-ID: <1258541569.30511.6.camel@johannes.local>
References: <1258465585.3682.7.camel@johannes.local>
	 <1258490898.21197.42.camel@johannes.local>
	 <jwvy6m4bnqp.fsf-monnier+gmane.linux.kernel.wireless.general@gnu.org>
	 <20091118025920.GA4588@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-VU7yDuZK0OV6yxIzUikD"
Cc: Stefan Monnier <monnier-CRDzTM1onBSWkKpYnGOUKg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091118025920.GA4588-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-VU7yDuZK0OV6yxIzUikD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-11-17 at 21:59 -0500, John W. Linville wrote:

> > As someone who's been bitten by this, I fully support this change.
> > Still, it makes me wonder: my broadcom-based home-router using the wl.o
> > driver can be set in "client bridge" mode.  How does it work?
>=20
> If I'm not mistaken, that has a bunch of code embedded in it that
> among other things can do a layer-2 version of NAT to rewrite the
> MAC adresses for frames on the air.

Yeah, that's how it works. You can probably achieve the same effect with
the ebtable_nat module in ebtables but I've never even attempted to try
that.

johannes

--=-VU7yDuZK0OV6yxIzUikD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLA9H+AAoJEODzc/N7+QmaoMEP/2fgsrNYENPFT2tobU932a3d
OyD5uhJv8+LIQoHLyXclz1pl3jKImpKlNrBFMdh6O+c2RSbIlgGsqRN3JUp8E+gM
FmAUDbT55ONrhgeamGAduwHYnuoYSNhbXZF2J4poRhn0JGxAlt7lcBzBhoWmtJJ4
5r+2Vp4oTSkp+P4FAHDSOd8XddWDaQT/taaHXbCDuJmyi70mKKFYoZzx8KhcUuw3
sW6lHNCV1HqMy4AS1GwA9WCFoba2jELOFhV/Xeqn4TLbqVr4ecG3a2bypAnbX0pt
joEbTqNAshUy06G6e5s2lA9JgKD3qZtewv86Lt4OyTpQda+ELlWGUJMjBt4SKm8O
DWfhM77+TsEWdcXsLaY1m/9b28DcgkzBFUm8uncl+3ajPMuW6ZNf1bTHBXosyBwR
KckZqWKYHzp2ZiKgXuLUGSOvmlPM5VwxO5HGdqJ5PRFjdA91YM0E6kWaSd02KhkE
9WqW5GZn7ReKZbq+QFHP56hJmkX3noY8+bpkP8Ke+ErnbeYphuoUecI9/w7ur55K
m3DNq39J/3e9lZpi+IRif1VUOAR5wwmkWSTQ3NVbzrHzuxeJROiZOvQIq59ihQhr
ll5KWWA7ybYEV5O5TJeYgoWbzCULigiJzgphqsOTV19CARYiHEixnNWigGEmw/mA
yIq81C8cNV5Rfr+DPj9o
=m0cB
-----END PGP SIGNATURE-----

--=-VU7yDuZK0OV6yxIzUikD--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
