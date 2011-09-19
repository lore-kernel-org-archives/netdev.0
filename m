From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: MSI-X vector count on 82754L
Date: Mon, 19 Sep 2011 16:56:09 -0700
Message-ID: <1316476569.2184.13.camel@jtkirshe-mobl>
References: <CACqU3MVZ6GT7hNKsnWq-otxsX4TDtTi8qYPG=4gYn=cBF7-tJg@mail.gmail.com>
	 <CACqU3MUfQn_r2oJ+ptuzYhkkUoucfL_NTMnHoCa0+TouP0s0kA@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-/ytanNBBbU3UzhpDoAN5"
Cc: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Vogel, Jack" <jack.vogel@intel.com>
To: Arnaud Lacombe <lacombar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:49355 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751681Ab1ISX4K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Sep 2011 19:56:10 -0400
In-Reply-To: <CACqU3MUfQn_r2oJ+ptuzYhkkUoucfL_NTMnHoCa0+TouP0s0kA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/ytanNBBbU3UzhpDoAN5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-09-18 at 22:34 -0700, Arnaud Lacombe wrote:
> [fixing address of the netdev@ list, sorry - A.]
>=20
> On Mon, Sep 19, 2011 at 1:31 AM, Arnaud Lacombe <lacombar@gmail.com> wrot=
e:
> > Hi folks,
> >
> > In:
> >
> > commit 4662e82b2cb41c60826e50474dd86dd5c6372b0c
> > Author: Bruce Allan <bruce.w.allan@intel.com>
> > Date:   Tue Aug 26 18:37:06 2008 -0700
> >
> >    e1000e: add support for new 82574L part
> >
> >    This new part has the same feature set as previous parts with the ad=
dition
> >    of MSI-X support.
> >
> >    Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
> >
> > MSI-X support was added to the e1000e driver, later on slightly reworke=
d by:
> >
> > commit 8e86acd7d5968e08b3e1604e685a8c45f6fd7f40
> > Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date:   Mon Aug 2 14:27:23 2010 +0000
> >
> >    e1000e: Fix irq_synchronize in MSI-X case
> >
> >    Based on original patch/work from Jean Delvare <jdelvare@suse.de>
> >    Synchronize all IRQs when in MSI-X IRQ mode.
> >
> >    Jean's original patch hard coded the sync with the 3 possible vector=
s,
> >    this patch incorporates more flexibility for the future and aligns
> >    with how igb stores the number of vectors into the adapter structure=
.
> >
> >    CC: Jean Delvare <jdelvare@suse.de>
> >    Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >    Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> >    Acked-by: Bruce Allan <bruce.w.allan@intel.com>
> >    Signed-off-by: David S. Miller <davem@davemloft.net>
> >
> > [It is unclear to what "Jean" does this commit log refers to, as the
> > support MSI-X was added Bruce, anyway...]
> >
> > Why only 3 vectors are used when both the product brief and the
> > datasheet advertise up to 5 MSI-X vector usable by the chip ? That is
> > 2*RX + 2*TX.
> >
> > Thanks in advance,
> >  - Arnaud
> >

The e1000e driver is only a single queue driver so it does not need more
than 3 vectors, that is the reason we only use the 3 vectors.

--=-/ytanNBBbU3UzhpDoAN5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOd9aZAAoJECTsCADr/EWUdHkIAIoHeUE131nrv2xUcXOl3ssO
W3mN3laUDO2sR/FvVqm8IJH4qBB4IUHjcaqa4KVUwDS38lZDUJX3qJwicL2bMDja
1hS7EBI+zgDW3oX1SF6LfDxJ/SBh1RLTW218dv+pjMRtaKwHj25i7XXnzhERxGLI
l5nrdXW+/teKeb91QWIUU/RbKSmfhMyVdwijS6TTIQyvOEKdpsu0XjU2e6lrX0ZB
iS8qJmB0/2A8/vKQPQFYrizTvFSLIHar93iJ1sWgHuAuH3f6cx74gis2OsqZHq1O
8Y8V5KFaOvC1SBijsjvw3Q/CQshcIwu5svVWDAo3+vbLLr9RtfDXIdghPyr9PXU=
=NVJJ
-----END PGP SIGNATURE-----

--=-/ytanNBBbU3UzhpDoAN5--
