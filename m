From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 2.6] ip_nat_ftp - manip at the right place
Date: Tue, 14 Sep 2004 09:12:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040914071241.GM8434@sunbeam.de.gnumonks.org>
References: <Pine.LNX.4.58.0409111042580.1315@u.domain.uli> <20040912170323.65eadc38.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="L1EIGrW/+75u5Nmw"
Cc: Julian Anastasov <ja@ssi.bg>, netdev@oss.sgi.com, rusty@rustcorp.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040912170323.65eadc38.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--L1EIGrW/+75u5Nmw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Sep 12, 2004 at 05:03:23PM -0700, David S. Miller wrote:
> On Sat, 11 Sep 2004 10:53:53 +0300 (EEST)
> Julian Anastasov <ja@ssi.bg> wrote:
>=20
> > 	This is a resend/resync for v2.6.9-rc1-bk17: change the
> > way the ip_nat_ftp helper manipulates the packets:
> >=20
> > - no manips =3D> no fixup
> >=20
> > - check the direction, do manip once and at the same time when the
> > headers are changed
> >=20
> > 	This is needed mostly for IPVS setups and I hope we do not
> > create troubles for other setups or FTP software.
> >=20
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
>=20
> Harald and/or Rusty, please ACK/NACK this for me.

I agree with the change (although I didn't test it here on my systems so
far).  However, as indicated in private mail to Julian, the change
should be made consistent over all helpers.

So please hold back the patch until I get back to you, thanks.

> Thanks.

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--L1EIGrW/+75u5Nmw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBRpnpXaXGVTD0i/8RAiB9AJ4kgujUlqVuxTEXmBWUc9p7CSm5QACfedCu
O2ACl+oHH+dPTEqxI+qLDfU=
=lYlI
-----END PGP SIGNATURE-----

--L1EIGrW/+75u5Nmw--
