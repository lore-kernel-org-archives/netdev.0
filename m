From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: [RFC fs_enet: Convert MII bitbang driver to use GPIO lib
Date: Tue, 22 Apr 2008 10:55:06 +0200
Message-ID: <200804221055.09038.laurentp@cse-semaphore.com>
References: <200804161640.42693.laurentp@cse-semaphore.com> <200804181334.34229.laurentp@cse-semaphore.com> <20080421175627.GD4134@ld0162-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart40300019.yNJIJPMb30";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, avorontsov@ru.mvista.com,
	netdev@vger.kernel.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:46802 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754392AbYDVIzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 04:55:12 -0400
In-Reply-To: <20080421175627.GD4134@ld0162-tx32.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart40300019.yNJIJPMb30
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 21 April 2008 19:56, Scott Wood wrote:
> On Fri, Apr 18, 2008 at 01:34:29PM +0200, Laurent Pinchart wrote:
> > Scott Wood was concerned in=20
> > http://patchwork.ozlabs.org/linuxppc/patch?id=3D17490 that the gpio lib
> > might be an unnecessary burden for memory-constraint platforms. Should =
we
> > keep two mdio bitbang drivers, one with direct access to the ports and =
one
> > using gpio lib ? The later solves the concurrent access issues present =
in
> > the current fs_enet mdio bitbang driber.
>=20
> The memory-constrained platform I had in mind was 8xx, which doesn't use
> bitbanged MDIO.  It might nice to keep the gpiolib bit separate to avoid
> situations such as ep8248e where mdiobb would be the only thing requiring
> a gpiolib binding, though -- but it shouldn't be two separate bitbang
> drivers, just the existing bitbang driver plus some glue code that binds
> it to gpiolib.

I would be fine with that if the glue code wasn't 90% of the whole driver.=
=20
There is really little (not to say nothing) that can be shared between the=
=20
two drivers.

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart40300019.yNJIJPMb30
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBIDafs8y9gWxC9vpcRAkEQAJ9wSZJN1wqlcE8dLMjvr0FGya5eXwCgl0iF
3/44XV0J1k3E+u7X+5FVJF4=
=5N8a
-----END PGP SIGNATURE-----

--nextPart40300019.yNJIJPMb30--
