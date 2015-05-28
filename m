From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH iproute2] enable transparent LFS
Date: Wed, 27 May 2015 20:53:24 -0400
Message-ID: <20150528005324.GD23204@vapier>
References: <1432623090-2264-1-git-send-email-vapier@gentoo.org>
 <20150527120726.65e9dd98@urahara>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="HWvPVVuAAfuRc6SZ"
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:39360 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751658AbbE1AxZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2015 20:53:25 -0400
Content-Disposition: inline
In-Reply-To: <20150527120726.65e9dd98@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--HWvPVVuAAfuRc6SZ
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 27 May 2015 12:07, Stephen Hemminger wrote:
> On Tue, 26 May 2015 02:51:30 -0400
> Mike Frysinger <vapier@gentoo.org> wrote:
> > From: Mike Frysinger <vapier@chromium.org>
> >=20
> > Make sure we use 64-bit filesystem functions everywhere.  This applies =
not
> > only to being able to read large files (which generally doesn't apply to
> > us), but also being able to simply stat them (as they might be using la=
rge
> > inodes).
> >=20
> > Signed-off-by: Mike Frysinger <vapier@chromium.org>
> > ---
> >  Makefile | 2 ++
> >  1 file changed, 2 insertions(+)
> >=20
> > diff --git a/Makefile b/Makefile
> > index 35cacc4..9d35ef1 100644
> > --- a/Makefile
> > +++ b/Makefile
> > @@ -32,6 +32,8 @@ ADDLIB+=3Dmpls_ntop.o mpls_pton.o
> >  CC =3D gcc
> >  HOSTCC =3D gcc
> >  DEFINES +=3D -D_GNU_SOURCE
> > +# Turn on transparent support for LFS
> > +DEFINES +=3D -D_FILE_OFFSET_BITS=3D64 -D_LARGEFILE_SOURCE -D_LARGEFILE=
64_SOURCE
> >  CCOPTS =3D -O2
> >  WFLAGS :=3D -Wall -Wstrict-prototypes  -Wmissing-prototypes
> >  WFLAGS +=3D -Wmissing-declarations -Wold-style-definition -Wformat=3D2
>=20
> I am okay with this, is something specific it fixes or is it just
> general good practice?

general good practice at this point.  we've started Gentoo down the path of=
=20
killing off non-LFS in projects.
-mike

--HWvPVVuAAfuRc6SZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVZmcEAAoJEEFjO5/oN/WBAIEQAMJhr6kWS3Apr24N8bWmbm/z
5VE7iM+Z7+519itz8f0rAJw+qzv8d6NjL/gEMl5SpRLuC6kyY6UNwaw+Z6H/PZj0
dL5ZcUTAH37l27R1Lo3rbXgAeTZeFeyEpXCPwjSPDZtvQNXUTmsoF+rdoVG0hrb3
blKP19QqUWkXJCkIH4zT5JkxKvQ3hVAVXlVdmsKux2R4vDiMME8Ftib5jK6QuQnP
ZNEpEVwxqUIt8oWU/jQbHd+WA/LF/cQ3iMK22tRPFUNtQcwQjRyBvKNSDlYH0h+t
TMkjTKOydWdIZqDr3O3RZMcz/q/zmrFGwawUH40d2oMBi9+hs3LxgEY2D87z27ox
p2Rr7diXA+WCJQkgad5A4+9ODi1VCgNrZ7cGJ3OxXR3ZJGI3AfA+co4FE0dEhUBa
9iZ7jvGyLVmkwv/I7YLU3CeTMaO0lKFiOu8amrWPoMdJ08OPpWaDPdhJXuaQmqne
XmVVX0TdgdBzDrLXj0BUGjuyr03MiroiE05cJafEY2RQdkrym2wmF98ImoZZRp/x
grxEobTzUgAPLSsmkiVZeBmRTGrW2wkMpngSH821LGYXGfqErEkBUeDkFsHLIQXw
eTxL3PYi/ofjLm4+iD7Mw+ee9uBtx0wARWxV+24gyFQ6uLWSTgx8AC2NDe5QHDHL
iFXsFceTZMHi8UTPEqvu
=ZFMl
-----END PGP SIGNATURE-----

--HWvPVVuAAfuRc6SZ--
