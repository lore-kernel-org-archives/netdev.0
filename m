From: Harald Welte <laforge@gnumonks.org>
Subject: Re: WLAN power saving: brain dump
Date: Sun, 21 Nov 2004 20:22:25 +0100
Message-ID: <20041121192225.GF4009@obroa-skai.de.gnumonks.org>
References: <20041116113027.A4026@almesberger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ULyIDA2m8JTe+TiX"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Werner Almesberger <wa@almesberger.net>
Content-Disposition: inline
In-Reply-To: <20041116113027.A4026@almesberger.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--ULyIDA2m8JTe+TiX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Werner!

On Tue, Nov 16, 2004 at 11:30:27AM -0300, Werner Almesberger wrote:
> This is just a brain dump, so that the ideas are out in public.
> Some day, I might actually implement this, unless somebody else
> beats me to it :-)

Mh.  Don't recent 802.11 chipsets already have a number of power-saving
features, even going as far as having special provisions in the 802.11
protocol for special power saving modes?

Sorry for that indefinitive and blurry response, but power saving is the
about the single part of 802.11 that I'm actually not really interested
in (and thus haven't read up with the docs).

The problem when you just 'stupidly' power down a card is that you will
loose the association [and thus authentication] with the AP.  Thus you
have to re-associate and re-authenticate every time you come up from
power down mode.  Especially when you rune more advanced authentication
mechanisms like WPA/WPA2 this process can take quite some time, and
involve latency-prone operations such as contacting a radius server from
the AP, etc.

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--ULyIDA2m8JTe+TiX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBoOrwXaXGVTD0i/8RAj4lAJ9uG+YBz/M13ww7JDVCSCNNRd92VwCbB5Qj
T810M/fBCg7y3g+1HDb/TZE=
=Bvmx
-----END PGP SIGNATURE-----

--ULyIDA2m8JTe+TiX--
