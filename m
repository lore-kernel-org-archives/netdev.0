From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] i40e: make functions static and remove dead
 code
Date: Thu, 12 Dec 2013 12:25:14 -0800
Message-ID: <1386879914.2204.91.camel@jtkirshe-mobl>
References: <20131212120759.430fab12@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-e+vcKShjucDT66ld90fR"
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16369 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751585Ab3LLUZP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 15:25:15 -0500
In-Reply-To: <20131212120759.430fab12@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-e+vcKShjucDT66ld90fR
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-12-12 at 12:07 -0800, Stephen Hemminger wrote:
>=20
> Make local functions static in the file they are used.
>=20
> Remove functions i40e_aq_add_vlan and i40e_aq_remove_vlan since
> they are not used anywhere by current code.
>=20
> Compile tested only.
>=20
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>=20
>=20
> ---
>  drivers/net/ethernet/intel/i40e/i40e_adminq.c    |    6 +
>  drivers/net/ethernet/intel/i40e/i40e_common.c    |   80
> -----------------------
>  drivers/net/ethernet/intel/i40e/i40e_prototype.h |    8 --
>  3 files changed, 4 insertions(+), 90 deletions(-)

Thanks Stephen, currently I have nearly 80 i40e patches in my queue
right now which may take advantage of these functions.  If not, I will
add your patch to my queue.  I am hoping to get all these patches for
i40e out over the next couple of weeks, so if there are patches in my
queue that will take advantage of these functions, they will be pushed
soon.

--=-e+vcKShjucDT66ld90fR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSqhuqAAoJEOVv75VaS+3O8u8QAIKpvsuOncXjiSxvY9ZYyH5d
QimQEtgWHmWtpLQkaTpabP5EYJUsOurvKodPfBBhG0KYZ0MwxQ97kQsTb4Y8jCKD
5mBHs5tEJqg4wZiw6NP4fvqX4cWuve4QJMiWn2YrZToTkNDAu2/fzqxVUe3AcmJE
mXsySfOG+/CchzEOLkgu8WDXcISnUoaGW+4NWIwD7WUH1ztzVruNpx3YCoowtewS
qXSqp2nA/FNEQOUB7Dt3yXwKYnB28nk3BQdaZXgHGvPCf3k3hwMpv7+BZRTMjYJT
zrrKSZqpQwMwDMff1P6unkiIOTBVNGlDmmYVAc+bd90vKlVgom6LRuTrgSba/a0p
N8jwpb0ZGq8g4+V8GAuR3fgn+vXNYeNMZMiCYSFZTKnnT6cShpOm3Ej2jDG2mdxe
GOQVhPGVa6V5NEgn5vt93ntDf2JE3r0YGp5EPR5XLSas5BTr+MAL6d/w59MbfqqC
axN4SYhfaRTpArtDZbKOoZD7hjG/mh4zUNd3BoXrQpvKQicFdf6Z3Fc4GpvM2Xoo
dLMyj4YqAcnoGhfjMoEySsMTe77AikJq1f7hwP5RGhIQSZ/kSeWvc2PeeG0CjazL
D/CZITkRoyrCOe6MhK2ainBNGBAKUpFwVY6RPi6s1U0fbTjJwV7SOvescDqkxQhp
7ykpm2PZSkfZQvirxC+q
=y05+
-----END PGP SIGNATURE-----

--=-e+vcKShjucDT66ld90fR--
