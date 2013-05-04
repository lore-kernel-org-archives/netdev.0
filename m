From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: ixgbe: RTNL assertion failed
Date: Sat, 04 May 2013 22:21:32 +0100
Message-ID: <1367702492.5106.164.camel@deadeye.wl.decadent.org.uk>
References: <20130503120907.4f13d41b@nehalam.linuxnetplumber.net>
	 <F6FB0E698C9B3143BDF729DF222866464C28E112@ORSMSX110.amr.corp.intel.com>
	 <20130504015406.GP2619@decadent.org.uk>
	 <F6FB0E698C9B3143BDF729DF222866464C28E2AE@ORSMSX110.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-sjBr18gTy2wBbwZttgnE"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:41622 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757526Ab3EDVVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 May 2013 17:21:39 -0400
In-Reply-To: <F6FB0E698C9B3143BDF729DF222866464C28E2AE@ORSMSX110.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-sjBr18gTy2wBbwZttgnE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-05-04 at 21:05 +0000, Skidmore, Donald C wrote:
[...]
> > The version of ixgbe in this Debian kernel has bql support backported, =
but is
> > otherwise the same as in 3.2.41.  I assume that this bug has been fixed=
 some
> > time between 3.2 and 3.9, but no-one requested that the fix be included=
 in
> > stable branches.  Please can you identify the fix?
> >=20
> > Ben.
> >=20
> > --
> > Ben Hutchings
> > We get into the habit of living before acquiring the habit of thinking.
> >                                                               - Albert =
Camus
>=20
> I believe this is the patch:
>=20
> commit 34948a947d1a576c10afee6d14792fd237549577
> Author: Benjamin Poirier <bpoirier@suse.de>
> Date:   Fri Apr 6 07:20:21 2012 +0000
>=20
>     ixgbe: add missing rtnl_lock in PM resume path
[...]

Looks like it.  And it applies cleanly to 3.2.y.  Stephen, could you
test this on top of 3.2.y and then nominate it for stable?

Ben.

--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.

--=-sjBr18gTy2wBbwZttgnE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUYV73Oe/yOyVhhEJAQrWZxAAnYJ53aRxp24mnx9vc67rROaxPvh9fabj
WrXJtEb1sjBib3x3xLWh+NpbDCwJKo6Uiyfw3Zy6O0v5tuuirCz/fH9Dt7AQGE5D
fifh9paWDe/hMHkWR5rehGftakHOL6Im14oAP3/Hpk6HlN7DbcQL8+aCBuY/woZ9
vjpER5VQQpOlPPQpfD5faOOuwTn5pPaN+ONFyQ1B7Kbu/ekKrOpTgMQtcj3Lttta
31tq2TWGKS6HcQ1e1YY+v1Tyl6Fl+sxjRqFam77gEwTcVstw9qK+geKhMMXVqfVW
I0gdKCaCzzI/+TCAb9HwbijSbu64Z3kSc8d9oiDnPjzF6lNGAw5HmPqb7MhCjRBV
czqicYk8aYGeOJrkn2b/7lLzmTK666f5w77OCrXsbXy6ahMyACX61PYAvaroe8vS
qi2KtKx5EHSbSXZIF+dx/xXorfhUvq8R1emtvIsx7ZYoexI5/m/dTBJfU0VMpJ6g
5jW3H50K1aXQjsQZAwjSexLTDseinJ9ThAQChJe0rAZPhJQVl1fFtuo2gBmK91jq
8tguGu5F9Er5I71doRliwoFaFL84jsVI9opvLZB7teJtavnmCI+9Ads5qg+47kRQ
VScG0L/Cz8p7lHEGhd6yjLSKSGf2oxxuUp7skmk6yBhRxpWtIlN5qZLOFd4DtUg2
GEeJM1GIC3U=
=JuwH
-----END PGP SIGNATURE-----

--=-sjBr18gTy2wBbwZttgnE--
