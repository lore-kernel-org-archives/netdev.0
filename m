From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] net: fix NOHZ: local_softirq_pending 08
Date: Thu, 01 Oct 2009 21:26:35 +0200
Message-ID: <1254425195.3959.28.camel@johannes.local>
References: <1254324077.3959.7.camel@johannes.local>
	 <200910011604.42916.mb@bu3sch.de> <1254422548.3959.24.camel@johannes.local>
	 <200910012110.34216.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-iKg+nWQyOXEyTcUPbcyW"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org,
	kalle.valo-X3B1VOXEql0@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200910012110.34216.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-iKg+nWQyOXEyTcUPbcyW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-10-01 at 21:10 +0200, Michael Buesch wrote:

> > I agree with davem, don't. Just fix the driver to local_bh_disable()
> > around the rx function if necessary.
>=20
> For the benefit of a much bigger critical section? I don't get it why thi=
s would be any better.

And how do you know mac80211 is actually safe with this change? It uses
tasklets too. At the very least you'd have to require drivers to never
mix & match the regular/irqsafe functions at all.

johannes

--=-iKg+nWQyOXEyTcUPbcyW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKxQJoAAoJEODzc/N7+Qma4WwP/jj480RaWglWnvRWcKolKm5o
NWOacpurzJgZRe2RzSDfoF4E/8EXnMI/Y9UEd5tXHqLKPo+PNcF1NEQf6KJzuxAc
gYWtsgl5cexIx5vGapJlHDprB8y0ZWjUEHPfVUds8udPZAz9b5oxFwa021OZdXdi
vDnjbimcQz2MBPL9S5bOCtDD+9MJa/dw0mVFcwSGwOZwCnRbFKZQn4iR4Q5cC761
CqMYjMEyKnMBvKpG9qDcsrOv0kgVdu99gx4mrHwQj47/DUryr1mg7q2yjsHgQCxB
8yy9Tme+ARkyrg/cD53UMZmuEROxcq3r3ElmVlndJa+/KIQfRtS+Hklbj+dQus9a
Zz1SDdgQBgvdjfsKSi1/3dm1BZKJlS4hP9hcXYwUiTylOAohZIqu1Wq8Sbs6MzPk
md+HftuFIC6Ft3dNjmvca6U0Tv9yvVVSbj8FcIyFVTNyLDASjaa/ZGO7Tn5ZOBCH
IZvsdX0MfX7Mn7k1QZyC7lrcDgXuRA+yhpylvxzYuY8/GYEFcZLYjrYEKBPgnsYZ
EfaIQ0omv61eNFfiDouBvRbidLtn2tjRAMITao07Kn7Voxk7E7AThPtXMHNyzO4d
nNdMmPs0nLqK6kmdAnfJsKArzptywF2hWvJY9lVaUJahhIBfSFKKqWlMl1XfCvvY
jsAteEw/Cc+WcBpf0R8R
=VfVt
-----END PGP SIGNATURE-----

--=-iKg+nWQyOXEyTcUPbcyW--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
