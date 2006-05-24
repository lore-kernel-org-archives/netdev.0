From: Phil Dibowitz <phil@ipom.com>
Subject: Re: reminder, 2.6.18 window...
Date: Wed, 24 May 2006 12:14:42 -0700
Message-ID: <20060524191442.GG22881@ipom.com>
References: <20060523.182217.59656237.davem@davemloft.net> <447412CA.50303@ipom.com> <4474A489.4080308@garzik.org> <20060524185644.GF22881@ipom.com> <4474AE92.3030501@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="PW0Eas8rCkcu1VkF"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpe-24-24-245-191.socal.res.rr.com ([24.24.245.191]:29750 "EHLO
	alt") by vger.kernel.org with ESMTP id S1751263AbWEXTOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 15:14:46 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <4474AE92.3030501@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--PW0Eas8rCkcu1VkF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 24, 2006 at 03:05:54PM -0400, Jeff Garzik wrote:
> Phil Dibowitz wrote:
> >On Wed, May 24, 2006 at 02:23:05PM -0400, Jeff Garzik wrote:
> >>I disagree that we should bother about clearing statistics.  It always=
=20
> >>adds more complication than necessary.  Few (if any) other statistics i=
n=20
> >>Linux permit easy clearing, often because adding operations other than=
=20
> >>'increment' or 'read' requires adding expensive spinlocks or atomic=20
> >>operations.
> >
> >Every networking device in the world supports clearing interface=20
> >statistics.
> >Why should linux not be able to do the most basic operation on any
> >cisco/juniper/enterasys/whatever managed switch or router?
> >
> >It's a common operation on a network interface, I don't see why this is a
> >concern.
> >
> >When I'm debugging a networking issue On a cluster of hundreds and hundr=
eds
> >of machines at work, I want to be able to reset them all quickly, and ge=
t a
> >rough idea of if they're all climbing, if they're all climbing at the sa=
me
> >rate, etc. And being able to do "for i in `cat hostlist`; do ssh $i=20
> >ethtool -z
> >eth0; done" is really, really, REALLY, useful.
>=20
> Obtaining the difference between two numbers is not that difficult.
>=20
> Given any method of clearing statistics across your cluster, I'm certain=
=20
> you can come up with a similar method of obtaining the current statistic=
=20
> (the baseline).

Right, I'm aware there are other ways of doing this - I've written scripts =
to
record a hundreds of numbers, and then subtract them from each other. But
those scripts are work arounds for a feature _lacking_ in the kernel. A
feature that, as I've mentioned, is supported on any piece of networking ge=
ar
(and of course, lets not forget there's a specific option in the kernel con=
fig
*just* for "behave like a router").

If my patch was invasive and broke things, I would understand the hesitatio=
n,
but this is a feature that allows people to *choose* to do this if they need
to and the code is pretty self-contained.

--=20
Phil Dibowitz                             phil@ipom.com
Freeware and Technical Pages              Insanity Palace of Metallica
http://www.phildev.net/                   http://www.ipom.com/

"They that can give up essential liberty to obtain a little temporary
safety deserve neither liberty nor safety."
 - Benjamin Franklin, 1759


--PW0Eas8rCkcu1VkF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQFEdLCiN5XoxaHnMrsRAumnAJ9zfoGnfP6yIFju+FQkKodcTi/ycACfdky5
ysDgNbQ8j2Ehh5RFlozlLeM=
=bUm4
-----END PGP SIGNATURE-----

--PW0Eas8rCkcu1VkF--
