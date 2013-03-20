From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 2/3] ixgb: Add missing dma_mapping_error-call in
 ixgb_alloc_rx_buffers
Date: Tue, 19 Mar 2013 17:48:03 -0700
Message-ID: <1363740483.2069.53.camel@jtkirshe-mobl>
References: <1363429925-12724-1-git-send-email-christoph.paasch@uclouvain.be>
	 <1363429925-12724-3-git-send-email-christoph.paasch@uclouvain.be>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-T5dgaTvnaAGySCnXBtpy"
Cc: Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37958 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756846Ab3CTAsG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 20:48:06 -0400
In-Reply-To: <1363429925-12724-3-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-T5dgaTvnaAGySCnXBtpy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-03-16 at 11:32 +0100, Christoph Paasch wrote:
> After dma_map_single, dma_mapping_error must be called. It seems safe
> to
> not free the skb allocated in this function, as the skb can be reused
> later.
>=20
> Additionally this patch fixes one coding-style error.
>=20
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
>  drivers/net/ethernet/intel/ixgb/ixgb_main.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)=20

Added to my ixgb patch queue

--=-T5dgaTvnaAGySCnXBtpy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRSQdDAAoJEOVv75VaS+3OaL4P/j0613Jn2ZG7tyoMrsBjTVSo
wCoCr4uwnUMaPiaFrOh70H+8Qxi84gcGovTHpcctCSAFkY+NJffTnCETwoiH7bw3
wd9/xXMX0tz9Hq/tfnfFTn1n83X1CaEdhMihNVyInoy483WaNvdc9i1OYDYWUCSL
RaqlC49FxJzwoyEo0ps/3cPCZ5kPLifvevCVOV6HEY+kcLael7+MdTEwnWp4nXjt
6kFVgy0GtfYCQVuPfDobqmNkceJbuKPMTAz7iSQIgnw6vvnb+qDC6xwdnF85plus
Q2hw0wDk2AJ6ZgGIM4lCWekuOFLA8MG0ou5/y63j5UEd9UE4SjchBVUzYWbb0+h8
aS/VbvZ6V40ehuM0pN1yHmeYCrLKqt2Q9eHkHYRzbhlUfYWqQ+6RxyC5M2a8hlNU
92ZX71CoRbMYsHzDypN+NMidtlgSCEGdfPSggmiQZ9xYSjiki18/36/XgRc8emSg
44S9JhTBE/1YRm7um1vhYQFwtFKaxPagDwYKdN9Y4JP8gzB9qFGXvKwhLtovd97W
3ixybRzv4/VXp948mJrAnrNmJKlEiOmg1+7VKus/bj0ojQd/X8XV8Mk1QHme5nBi
QM5zsVFbNNhWMp59prjNlws+oQnPjjOGk8GV1LN/+DOV9xtYKjcsuAJj69jP4LXI
NHX4KOYrGEi3xf0mznLl
=q7bv
-----END PGP SIGNATURE-----

--=-T5dgaTvnaAGySCnXBtpy--
