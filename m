From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: xen-netback stable backports request (regression fixes)
Date: Thu, 13 Jun 2013 03:38:49 +0100
Message-ID: <1371091129.10688.32.camel@deadeye.wl.decadent.org.uk>
References: <1369734465.3469.52.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-IeyVo6tCpCZplPYODBmK"
Cc: stable@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	xen-devel <xen-devel@lists.xen.org>, netdev@vger.kernel.org,
	Wei Liu <wei.liu2@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1369734465.3469.52.camel@zakaz.uk.xensource.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-IeyVo6tCpCZplPYODBmK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-05-28 at 10:47 +0100, Ian Campbell wrote:
> Hi Dave, stable folks,
>=20
> The following set of patches fix a xen netback regression caused by the
> fixes for CVE-2013-0216 / CVE-2013-0217 / XSA-39 (the original change
> was several patches starting at 48856286b64e), we'd like to see them
> backported to stable branches if possible. I think the fixups have now
> been in Linus tree since around the start of May.
>=20
> Wei and I are happy to help with backports if necessary. Some of the
> patches are cleanups which make backports easier but if you would prefer
> we could produce backports without them.

For 3.2, I've picked:

> 27f85228 xen-netback: remove skb in xen_netbk_alloc_page

  16ecba26 netback: remove redundant assignment
  9eaee8be xen-netback: fix sparse warning

> 2810e5b9 xen-netback: coalesce slots in TX path and fix regressions
> 03393fd5 xen-netback: don't disconnect frontend when seeing oversize pack=
et
> ac69c26e xen-netback: remove redundent parameter in netbk_count_requests
> 59ccb4eb xen-netback: avoid allocating variable size array on stack
> 37641494 xen-netback: better names for thresholds
>=20
> In addition there are some useful related (but not security relevant)
> fixes to netfront:

[Omitted the 3 cosmetic changes]

  3a3bfb61 net: Add net_ratelimited_function and net_<level>_ratelimited ma=
cros

> 9ecd1a75 xen-netfront: reduce gso_max_size to account for max TCP header

I just fixed up context for this.

Ben.

--=20
Ben Hutchings
friends: People who know you well, but like you anyway.

--=-IeyVo6tCpCZplPYODBmK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUbkwuee/yOyVhhEJAQoQ4Q//QsanBR10JC23KYic8wY52uP23FDR7/aj
4t53mx9YaPes8kuoYYYvbmsWhWTjLiUV8WuB9p0ogwZ6OGDnOWY0lRn9X5vOSvFE
cXQsGhVn/ZNeSMwZKKlWwC0sse0jF7rA8Z2BI4smYiPGfzYojU4t0S1zPJz5g0t6
Kmc0byC7wv/ghp7giMCQbOaw6BjxI507+X7IlL6n+7V3WlltGTP6rNpnJ4S3jWJT
m9zQF/6coCHsJqolFRDLdgwzIcj0MTaX+54B9eOK8eS1ArT06yD4qlgkrq28s9ua
1rDZDkgh7u2tA+p5KeXeCPC9SxsN/c3Z7DKMiMi6UfOP7SpfHbQDkE7sYX2xHuOi
+0YB16fOgQOW+dBwPXq8IlrCig04lWzl4oPRpLc0+FMWHNiNITRvNAAi2o0KmHdc
U5RtO4FKN/jgXIztALsZahdoLUbLiaf3PlJKCvOpDZovu9W4o22q4fftdohbDTKI
tjveBRi+cikxymIgdZ3HINEIuIFYC5quCVfniR3U7c4pUy6FTMluYWeN2pUMjja6
Ou1/fStWpTel3Eat0S4ONecs+x77DbhoKo4r6oea19UJ1cqAkCMoO5QwHnfo+qxi
//8TXupZueu9rSzsI7M/dItpzOLVJXkz4Y80LpMKTgUz9bn/qKo7d7nFy0JySfsG
Gwel+rrcBjc=
=cuN+
-----END PGP SIGNATURE-----

--=-IeyVo6tCpCZplPYODBmK--
