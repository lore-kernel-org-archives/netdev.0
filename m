From: Vincent Sanders <vince@simtec.co.uk>
Subject: Re: [PATCH] Fix IXP 2000 network driver building.
Date: Mon, 12 Oct 2009 13:45:34 +0100
Message-ID: <20091012124534.GH28536@kyllikki.org>
References: <1255276546-31903-1-git-send-email-vince@simtec.co.uk> <1255349459.2931.7.camel@achroite>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9dgjiU4MmWPVapMU"
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from flounder.pepperfish.net ([87.237.62.181]:46292 "EHLO
	flounder.pepperfish.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755912AbZJLMqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 08:46:11 -0400
Content-Disposition: inline
In-Reply-To: <1255349459.2931.7.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--9dgjiU4MmWPVapMU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 12, 2009 at 01:10:59PM +0100, Ben Hutchings wrote:
> On Sun, 2009-10-11 at 16:55 +0100, Vincent Sanders wrote:
> > The IXP 2000 network driver was failing to build as it has its own
> > statistics gathering which was not compatible with the recent network
> > device operations changes. This patch fixes the driver in the obvious
> > way and has been compile tested. I have been unable to get the ixp2000
> > maintainer to comment or test this fix.

<snip>

>=20
> Is there any reason you can't use dev->stats instead of this private
> field?

I have absolutely no idea ;-) my interest in this is fixing the build
faliure and making the target useful again, unfortunately the
maintainer is MIA, I performed the minimal obvious change.=20

I could tidy this futher, but my version of this hardware will not run
the kernel at all (hardware is old broken dev. board) so I am worried
I may break something with a larger blind change.


--=20
Vincent Sanders
Simtec Electronics

--9dgjiU4MmWPVapMU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQFK0yTtiUwwPOvjHvURAv3wAKC8n7Z3XD7pNLnQ7toUIPB2itTdYACfTlrl
9MeaueIaJvXq/kfk4652L1I=
=Zq1J
-----END PGP SIGNATURE-----

--9dgjiU4MmWPVapMU--
