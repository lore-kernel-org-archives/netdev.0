From: Harald Welte <laforge@gnumonks.org>
Subject: Re: recommendations for NIC HW(/SW) design?
Date: Mon, 27 Sep 2004 17:51:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927155144.GU3236@sunbeam.de.gnumonks.org>
References: <20040926152955.GD17043@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="399d5c/rwW6QrXB5"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Content-Disposition: inline
In-Reply-To: <20040926152955.GD17043@xi.wantstofly.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--399d5c/rwW6QrXB5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Sep 26, 2004 at 05:29:55PM +0200, Lennert Buytenhek wrote:

> (Since the Intel IXP processor is just an ARM processor with a network
> interface grafted onto the chip, a bunch of things that apply to PCI
> NIC design might not apply here.)

I think this IXP is only a UP architecture, is it?  For SMP scalability
it would be nice to specify the Tx Interrupt in every descriptor, so you
can cause Tx interrupts go to the cpu that actually sent the packet
(cache locality).

> thanks,
> Lennert

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--399d5c/rwW6QrXB5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBWDcQXaXGVTD0i/8RAkPwAJ40onleObLszderlWAjhfgfIa8axACgrMe3
deBeIUaHHFpUtQrRMxLdEYo=
=hAgD
-----END PGP SIGNATURE-----

--399d5c/rwW6QrXB5--
