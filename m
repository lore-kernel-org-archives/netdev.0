From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 02/15] i40evf: correctly program RSS HLUT table
Date: Wed, 19 Mar 2014 01:14:35 -0700
Message-ID: <1395216875.2050.21.camel@jtkirshe-mobl>
References: <CAJZOPZ+RWb-ybx3xmgSpOWRC5a=4-Kp7c4tFu145gtvnTQY8Jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-g4xznFnQiTlJ54QshaDp"
Cc: David Miller <davem@davemloft.net>,
	Mitch Williams <mitch.a.williams@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Catherine Sullivan <catherine.sullivan@intel.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41508 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757388AbaCSIPH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Mar 2014 04:15:07 -0400
In-Reply-To: <CAJZOPZ+RWb-ybx3xmgSpOWRC5a=4-Kp7c4tFu145gtvnTQY8Jg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-g4xznFnQiTlJ54QshaDp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-03-19 at 10:08 +0200, Or Gerlitz wrote:
> On Wed, Mar 19, 2014 at 5:42 AM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > From: Mitch Williams <mitch.a.williams@intel.com>
> >
> > The HLUT programming loop in in i40evf_configure_rss was a) overly-
> > complicated, and b) just plain broken. Most of the entries ended up bei=
ng
> > not written at all, so most of the flows ended up at queue zero.
>=20
> In the V2 cover letter you wrote
>=20
> dropped patch Mitch's patch "i40evf: correctly program RSS HLUT table"
>=20
> so what is this patch?

Sorry, that was may bad.  In v2 I dropped patch 3 which was "i40evf:
Support RSS option in ethtool" patch.  I referenced the wrong patch in
the cover letter, thanks for noticing that Or.

--=-g4xznFnQiTlJ54QshaDp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTKVHrAAoJEOVv75VaS+3O9xwP/23bKvTxJ6HFLjv16oPZL4pA
S893ouQSSmfyoU4AVMdaaQI3Ob+rsKXx7WcvGr8yujQLYTFDByNZlA1D0Ypgw4q5
mSOfGyp0DrPDfR9SnDHmuVVuUlwZZLGWJ6vwDe5sWFEg5Dj+vRRe04BuyHsxE4gK
nP2EXn8cGakReCa40pOW0NUG/BQEfxZ35smw4qUineZWVDTqFE+v6sJRyhmhY1yS
byWBUwDLbMqqBWu9Ov/nVoUzl1XJe6ra4CEB2b0uHSab3IvFRxU/eu+uFD85uISi
vExqndoZ6EVxJ9n6yl84J586PCekUTUFHnlaw6+C07JIqmy29b8v45RPP8MSvqa1
yg+ON8OAfcSQP6eFeDo66ByuxlQSCl+GqYsX2Tx6gwDWPpwxOrCKTqHzgVxvXUoD
nxviKT/AHJkPKp+KB1TbAFTWji1RYC9M0Pr7BOmI/OQxgnxXsCWTc1eBwlyk3xzZ
x564V8cbM0X1WAVkPcS7RXAyj18Egi7UcCgYDV+4zshw70Ctf6yL2yfsXfN/9Liv
6ch6RJKw3L2fGlaK6NmaxGhZaQRUf/DcuUm+7xtQq6toP9JA9UVFTso0CJCMzCXq
TTs1+O7LYL9vvYEdDCGLohxbxAucDnZDKkjevWWLrjytPMlqP/wTck8GkTHJilaS
vYGiziBs+84ii0TQkZRe
=UgMt
-----END PGP SIGNATURE-----

--=-g4xznFnQiTlJ54QshaDp--
