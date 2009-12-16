From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wireless: wext: allocate space for NULL-termination
 for 32byte SSIDs
Date: Wed, 16 Dec 2009 09:20:33 +0100
Message-ID: <1260951633.10356.61.camel@johannes.local>
References: <1260650850-16163-1-git-send-email-daniel@caiaq.de>
	 <20091215.014308.77044043.davem@davemloft.net>
	 <1260871411.3692.4.camel@johannes.local>
	 <20091216035844.GN28375@buzzloop.caiaq.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-L/Dl6eEgTCZxlb0x32KY"
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	dcbw@redhat.com, m.hirsch@raumfeld.com, netdev@vger.kernel.org,
	libertas-dev@lists.infradead.org, stable@kernel.org,
	linux-wireless@vger.kernel.org
To: Daniel Mack <daniel@caiaq.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757996AbZLPI4N@vger.kernel.org>
In-Reply-To: <20091216035844.GN28375@buzzloop.caiaq.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-L/Dl6eEgTCZxlb0x32KY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-12-16 at 11:58 +0800, Daniel Mack wrote:

> > If this is used in a GET, then it will be filled up to 32 bytes by the
> > get handler, and the trailing \0 your patch reserves will never be
> > copied into userspace.
>=20
> The problem is the GET case. The libertas driver copies ssid_len
> characters here and appends a trailing \0, which my patch caught now and
> which caused memory corruption in before.
>=20
> From what I've seen, libertas _does_ treat the extra data correctly
> at all places, I checked it several times now. (Btw, the %s format
> string you pointed out all use print_ssid() to properly escape all
> non-printable characters, so they're rules out, too).

Oh, ok, print_ssid() is correct of course, it gets the length.

> I'll send a patch to fix the flaw in libertas.

Thanks.

johannes

--=-L/Dl6eEgTCZxlb0x32KY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLKJhNAAoJEODzc/N7+QmahVwP/jMVe1Xgd0dEbJLXx/u1bOVA
rBEUz7YVaCaS9DSS7jhb1l3FmPmnQJ1vtryfOikdSCBAVOUyOH2AQAQkkCyZvxPm
Fvf7nNqsQ+mKiazZT8I/q8TG8Ht3BMmTsw08IW2qrY6L6FtGvKa7u6hVYxwuYTmW
hzasJKwAhh6y5bpMATQGeByVPWU5VHSOXdmTCEHUJvwx5va4pIJtCiEfoxmJbH62
4Qkz3dN0TxjvROHg2ADaHTSuD4IMOUtLB9/o2yJ0OQRFWCSoexq942zFRk87m3rv
hCyXdjuMZGUH01F4CdRLarpIJU9KdScM38yeMt8DiuR2kQYEqaMl12plQElc1RoV
CNNQorYfNPyOuzS9yGlwx71bIiO/U8aaeXE7ncq60/yE49BzGN61kPJRUvdVkBCO
4mV54R+KdoRXKwW38FGc3yWIDfKDRjImKVvGCzexEW9CXoyPQj//a3Afd7U8CzxN
XBeT2OrmEf1qpkbsJc/amYlQWZeQSKSOy+lD+MA2CtClhIzt+MCm6f3OnPpHjSoy
g9cQAWqyzygZslxcZiidTmYoymRMoTls91uOr++bd2hAXA5G09M5fWdmPE1YQgl9
lM/PfLN+NQo1g/osG29e7xliRqOhrXsTCzeKaMsGWPgYeEGGokXK0fnrph+4bquE
v/CC73TaeITP7aiYuYAH
=SGfL
-----END PGP SIGNATURE-----

--=-L/Dl6eEgTCZxlb0x32KY--
