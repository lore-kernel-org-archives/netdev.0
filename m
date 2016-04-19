From: Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHv2] wlcore: spi: add wl18xx support
Date: Tue, 19 Apr 2016 18:54:02 +0100
Message-ID: <20160419175402.GE3217@sirena.org.uk>
References: <1460273570-12298-1-git-send-email-eyalr@ti.com>
 <14313437.cDJIgY3kzo@wuerfel>
 <8665E2433BC68541A24DFFCA87B70F5B360BF614@DFRE01.ent.ti.com>
 <1463330011.BhWEcYYuGD@wuerfel>
 <8665E2433BC68541A24DFFCA87B70F5B360C0745@DFRE01.ent.ti.com>
 <20160419171239.GC3217@sirena.org.uk>
 <sjdvun1fuj4nyi0bgf268g53.1461086401627@email.android.com>
 <20160419172706.GD3217@sirena.org.uk>
 <oe8hqfknrcljrjawnrxlohvr.1461087275186@email.android.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="xzV2nyj/vUZRUtI2"
Cc: "kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org" <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	=?utf-8?B?15DXmdeZ15wg16jXmdeZ15bXqA==?= <eyalreizer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Reizer, Eyal" <eyalr-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <oe8hqfknrcljrjawnrxlohvr.1461087275186-2ueSQiBKiTY7tOexoI0I+QC/G2K4zDHf@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--xzV2nyj/vUZRUtI2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 19, 2016 at 05:38:02PM +0000, Reizer, Eyal wrote:
> Hi Mark,
>=20
> Hope you can see the attached picture that illustrates what need to sent =
for sucesfull SPI init.

I think what the picture shows is that you just need to send at least
one byte at the end of the transfer *after* deasserting /CS which is
totally not what I'd have understood from any of the previous
discussion.  That is already supported, just send an extra byte using
=2Ecs_change to do what is says.

--xzV2nyj/vUZRUtI2
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJXFnC3AAoJECTWi3JdVIfQU8kH/3jz5VWTyBTQmHtKqmredWGw
RCR7Gu9WWJy4QZKDJsnKK0bfYB2uwv2CoiWQoHsfKmnQUOImfeO3AsoMqKgFOqlB
ejS61RJfH8LGFv9vYR+6+hiAetRz1QU8klHemhxZ+DoYkTeqTW2hb6Igzr2TVrEi
OJQDhPYSBJFqEjrd3U7Ew/lLHmpTmq0ITo2OPn203djVqUlaBnS/jbS5LFriGfds
cAd6FKENsrYdq3r4YNpoi7pD2heRWK4mPKzSrza6cAN//HB7Uqx0FO9A2tsh4Q7+
bsyY/GKjhwuo6CfP0LVuzcw8pQ+WaMj4lOa86b2W0t4ZzITDHEQC3BLsFKhWAEo=
=1OGS
-----END PGP SIGNATURE-----

--xzV2nyj/vUZRUtI2--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
