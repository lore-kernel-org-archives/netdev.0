From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] net: fix NOHZ: local_softirq_pending 08
Date: Thu, 01 Oct 2009 20:42:28 +0200
Message-ID: <1254422548.3959.24.camel@johannes.local>
References: <1254324077.3959.7.camel@johannes.local>
	 <4AC3A0F1.3060306@hartkopp.net>
	 <20090930.163333.234658158.davem@davemloft.net>
	 <200910011604.42916.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-UWaNvcKK6UaNhO8ESa4v"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org,
	kalle.valo-X3B1VOXEql0@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200910011604.42916.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-UWaNvcKK6UaNhO8ESa4v
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-10-01 at 16:04 +0200, Michael Buesch wrote:
> On Thursday 01 October 2009 01:33:33 David Miller wrote:
>=20
> > I'm not applying this until all of these details are sorted out=20
>=20
> John, please apply my fix to wireless-testing to get rid of the regressio=
n.
> You can revert it later, if there's a better fix available.

I agree with davem, don't. Just fix the driver to local_bh_disable()
around the rx function if necessary.

johannes

--=-UWaNvcKK6UaNhO8ESa4v
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKxPgRAAoJEODzc/N7+QmayZ0QALY2U6DnK2r+UoDOY4HqxZed
GUWVYaUaGfskmBksb4j+EcK/4y0S5aU4ZTUi19UK/fTU3Q7wXVofly2GnUrfOakU
8BIocy+eTOpuochVHpmnej8UlXtVstpKPuonAuLPwAC2i4xAhR3hUz5MTBVKe+Av
cb1zzF8X3IBApxD+Op2ZFjOAj0/zeEQt8bOSwOPc0DRxjpXFM7zAfgGNpfQ3g+Cz
0OFOSwdWfWWoPb6HtsEh9fQFBdf/IGSdxBDNj/2FIIbhZTLyusv0v2wbBpLsb56g
CbP7tbOTz9eH497bGihAsdFAfn6PskHDKflsaQGq0k6PVgd78xElr5YJE1Dy5zt1
VYbTDzejgkKfkTSQzeHPomx2GuBGzJkDghwxADcoqiz9GVHkYe4+rjSDVIxV5K7K
lc3ZfQU0Or0zvuxZuAQ0XaMbDbQbqA0Q8wU6TO+YsdSOphcasdTHiJamNPQb3DeB
hWDXVfl0aN2PAF8zluB3QO6hIMODZODgpw0i59xErF1FxG6uAjPB8V2Udf60/H9U
OrKamIE8Czc9mEzty+y9atFsQOKCqrOI4lfoF3jSHCjEBl0DUjk561qYA4y5Z1FD
mOrKW00GP923d103/8hCrjHfj9C9fboSzEtjRyA9jQmLTqrc7uhWrAOexFfgmeeQ
8Tl9rphg8I19dXK8EfWP
=5Q8H
-----END PGP SIGNATURE-----

--=-UWaNvcKK6UaNhO8ESa4v--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
