From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH 2.6] generic network statistics (was Re: [6/6]: jenkins hash for neigh / Statistics)
Date: Tue, 28 Sep 2004 18:24:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928162431.GK29961@sunbeam.de.gnumonks.org>
References: <20040925005623.2faf8faf.davem@davemloft.net> <E1CBu70-00010X-00@gondolin.me.apana.org.au> <20040927121403.767e2308.davem@davemloft.net> <20040927222613.GE3236@sunbeam.de.gnumonks.org> <20040927160636.7741d973.davem@davemloft.net> <1096327658.1729.19.camel@localhost.localdomain> <16729.9326.93269.422940@robur.slu.se> <20040928111906.GB29961@sunbeam.de.gnumonks.org> <20040928145505.GH29961@sunbeam.de.gnumonks.org> <16729.32927.352234.634227@robur.slu.se>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="CaPKgh3XHpq3rEUV"
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16729.32927.352234.634227@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--CaPKgh3XHpq3rEUV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 28, 2004 at 05:17:51PM +0200, Robert Olsson wrote:
>=20
> Harald Welte writes:
>  > Here goes some initial client code, so you can actually test the new
>  > proc files from kernel.
>  >=20
>  > As stated above, I'll continue working on this until it's somewhat
>  > more feature-complete.
>=20
>  OK! Seems pretty generic, maybe the stats info for headers could be read=
=20
>  from current kernels /proc? to keep kernel stats in sync with this user =
app?

that's what it intends to do.  The field names are all stored in
'lnstat_field.name', so it is easy to build that line.  However, it has
to be multiple-line, since the field names from the kernel are sometimes
quite long...

The only difference is that it won't show you "IN: hits" but rather
"in_hits" which I think we can safely ignore.

>  Cheers.
> 						--ro

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--CaPKgh3XHpq3rEUV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBWZA/XaXGVTD0i/8RAiG5AJ9cf++NW+ZRlCGCXgEY1Q4q59XCgQCfWvUD
CkMigVE1ZLiuIAzQODinuc0=
=EG7I
-----END PGP SIGNATURE-----

--CaPKgh3XHpq3rEUV--
