From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 2.6] ip_nat_ftp - manip at the right place
Date: Sat, 11 Sep 2004 23:57:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040911215746.GF19871@obroa-skai.de.gnumonks.org>
References: <Pine.LNX.4.58.0409111042580.1315@u.domain.uli>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MZf7D3rAEoQgPanC"
Cc: Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
        netdev@oss.sgi.com, Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0409111042580.1315@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--MZf7D3rAEoQgPanC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Sep 11, 2004 at 10:53:53AM +0300, Julian Anastasov wrote:
> 	Hello,
>=20
> 	This is a resend/resync for v2.6.9-rc1-bk17: change the
> way the ip_nat_ftp helper manipulates the packets:
>=20
> - no manips =3D> no fixup
>=20
> - check the direction, do manip once and at the same time when the
> headers are changed

I agree with this change, but shouldn't we make it consistently over all
NAT helpers?  In case you didn't check yet, and assuming that this is
applicable to other helpers as well:  Please include patches for other
protocol helpers as well.

Thanks!

> Signed-off-by: Julian Anastasov <ja@ssi.bg>
--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--MZf7D3rAEoQgPanC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBQ3TaXaXGVTD0i/8RAmTxAJ9ktGTt1eOru0wIrLid2gEjMRFJBwCgpNx0
pnQyfK2GmkS3WA73Nvpu/SE=
=CJnS
-----END PGP SIGNATURE-----

--MZf7D3rAEoQgPanC--
