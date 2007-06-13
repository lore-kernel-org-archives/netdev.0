From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH 0/15] spidernet driver bug fixes
Date: Wed, 13 Jun 2007 11:33:16 +1000
Message-ID: <1181698396.6988.5.camel@concordia.ozlabs.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com>
	 <1181265151.6026.1.camel@concordia.ozlabs.ibm.com>
	 <20070608170608.GI7904@austin.ibm.com>
	 <20070608172020.GA31089@havoc.gtf.org>
	 <20070611181429.GA4397@austin.ibm.com>  <466F2581.2080808@garzik.org>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Bzbis3OR5T/OdaLeJj+c"
Cc: Linas Vepstas <linas@austin.ibm.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:37062 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751564AbXFMBdT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 21:33:19 -0400
In-Reply-To: <466F2581.2080808@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Bzbis3OR5T/OdaLeJj+c
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-06-12 at 19:00 -0400, Jeff Garzik wrote:
> Linas Vepstas wrote:
> > On Fri, Jun 08, 2007 at 01:20:20PM -0400, Jeff Garzik wrote:
> >> On Fri, Jun 08, 2007 at 12:06:08PM -0500, Linas Vepstas wrote:
> >>> On Fri, Jun 08, 2007 at 11:12:31AM +1000, Michael Ellerman wrote:
> >>>> On Thu, 2007-06-07 at 14:17 -0500, Linas Vepstas wrote:
> >>>>> The major bug fixes are:=20
> >>>> I realise it's late, but shouldn't "major bugfixes" be going into 22=
 ?
> >>> Yeah, I suppose, I admit I've lost track of the process.=20
> >> You need to order your bug fixes first in the queue.=20
> >=20
> > OK, here are the patches, re-ordered. There is a different number
> > than last time, as I threw out one, merged one, and got cold feet
> > on a third one.  They still pass the tests.
> >=20
> > The first five patches focus on three serious bugs, fixing crashes or
> > hangs.
> >=20
> > -- patch 1 -- kernel crash when ifdown while receiving packets.
> > -- patch 2,3,4 -- device driver deadlocks on "RX ram full" mesgs.
> >                   (kernel stays up, ifdown/up clear the problem).
> > -- patch 5 -- misconfigured TX interrupts results in 3x-4x per
> >               degradation for small packets.
> >=20
> > -- patch 6 -- rx stats may be mangled
> > -- patch 7 -- hw checksum sometimes breaks ipv6 operation
> >=20
> > -- patches 8-15 -- misc tweaks, and documentation.
> >=20
> >=20
> > I re-ran my stress tests with patches 1-7 applied; they pass.
>=20
> This is a bit frustrating, because this includes many patches that you=20
> ALREADY told me to queue for 2.6.23, which I did, in=20
> netdev-2.6.git#upstream.

Linas posted the patches, I responded querying whether the bug fixes
should go into 2.6.22, and then you told him "you need to order your bug
fixes first in the queue". Which seemed pretty clear to me that you'd
wait for the reordered series.

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-Bzbis3OR5T/OdaLeJj+c
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGb0lcdSjSd0sB4dIRAnnjAJ4qSbUV+uBRGwIzKgPwXqEp+y/iYQCcDNhI
vGXkdp0wvyMTUyN5ALFpXSk=
=xIcI
-----END PGP SIGNATURE-----

--=-Bzbis3OR5T/OdaLeJj+c--

