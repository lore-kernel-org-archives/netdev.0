From: Harald Welte <laforge@gnumonks.org>
Subject: Re: pktgen problem (skb refcount) in 2.6.12-rc1
Date: Tue, 5 Apr 2005 17:58:20 +0200
Message-ID: <20050405155820.GB3261@obroa-skai.de.gnumonks.org>
References: <9D602ABCE51B0B488BF857A4787939B5042E7396@orsmsx410>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="JWEK1jqKZ6MHAcjA"
Cc: Harald Welte <laforge@gnumonks.org>,
        Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>
Content-Disposition: inline
In-Reply-To: <9D602ABCE51B0B488BF857A4787939B5042E7396@orsmsx410>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--JWEK1jqKZ6MHAcjA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 04, 2005 at 10:26:18AM -0700, Veeraiyan, Ayyappan wrote:
> Harald,
>=20
> >=20
> > As for e1000 and or generic TX path changes, I don't have the time to
> > review them now, sorry :(  That's why I posted it to netdev, to let
> > people who have an idea about the committed changes know that there is
> > an issue.
> >
>=20
> What version of e1000 you are using?=20

as indicated before, I've observed the problem in 2.6.12-rc1.  No
modifications to e1000.  So whatever is in 2.6.12-rc1, that's what
showed the problems.

> If you are using e1000 5.7.6-k2 and haven't tried older versions, Could
> you please try e1000 version 5.6.10.1-k2 (available in kernel 2.6.11)
> and inform us the result?

I have tried a 2.6.11 kernel which works fine.  I have not tested
patching e1000 in 2.6.12-rc1 to go back to whatever was shipped in
2.6.11.

I'll try to remember testing that once I'm back from my current business
trip (friday), though

> Thanks,
> Ayyappan V.
--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--JWEK1jqKZ6MHAcjA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFCUrWcXaXGVTD0i/8RAnIeAKCswTwsBAWvq2ZPxu/8Xo8j3AwCRgCePcVM
2fCGl7IAUKVIl+jSZK2/EG0=
=SnlO
-----END PGP SIGNATURE-----

--JWEK1jqKZ6MHAcjA--
