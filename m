From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 2/3] rt2x00 drivers: rt61pci
Date: Sat, 29 Apr 2006 21:35:40 +0200
Message-ID: <200604292135.41196.IvDoorn@gmail.com>
References: <200604291147.26887.IvDoorn@gmail.com> <200604291735.12720.IvDoorn@gmail.com> <20060429161002.GA3345@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2383864.oxOq71NBaB";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.189]:39109 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1750806AbWD2Te3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2006 15:34:29 -0400
Received: by nproxy.gmail.com with SMTP id x30so1646898nfb
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2006 12:34:27 -0700 (PDT)
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060429161002.GA3345@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2383864.oxOq71NBaB
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Saturday 29 April 2006 18:10, Francois Romieu wrote:
> Ivo van Doorn <ivdoorn@gmail.com> :
> [...]
> > Not sure about that either. I usually choose the type of the counter
> > depending on the max size of that counter.
>=20
> It is not arch-neutral. powerpc favors unsigned int over int but I am
> too lazy to check if the size matters.

Ok, I'll make sure the counters will made of the unsigned int type.

> [...]
> > Perhaps, but I prefer the usage of the name "counter".
> > I am not sure if there is a coding style about this? If so I could
> > rename "counter" to "i".
>=20
> Chapter 4 of Documentation/CodingStyle goes in this direction.
> The document is not meant to be a taken too literally though.
>=20
> The repetitive use of 'counter' + foo[counter].blah tends to be a
> bit bloaty.
>=20
> [...]
> > I'll create a bugreport in the rt2x00 project bugzilla
> > with some of the coding style change requests.
>=20
> I will not complain if you open a bugreport to provide a git repo
> as well.
>=20
> /me hides...

The git repository has indeed been discussed between the
rt2x00 developers before. And at the moment we see no major
benefit from using git. We need to have something like CVS
for regular users to use rt2x00 and we don't want them to
use git only to use the drivers.
In the CVS tree we have multiple backwards compatibility
fixes for both rt2x00 as the dscape stack to make it work
on kernel 2.6.13 and above. So making a git repository
would mean a lot duplicate work, since we have to keep
2 trees up to date, as well as making sure the wireless-dev
tree contains an up to date version.

--nextPart2383864.oxOq71NBaB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEU8ANaqndE37Em0gRAmEEAKDam3WY6T3CwqvE2oqFcIWzCbQJlwCgxw1D
XQyB/alzOqZPuVjO+QL0SLo=
=6Z03
-----END PGP SIGNATURE-----

--nextPart2383864.oxOq71NBaB--
