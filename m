From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 3/3] e1000e: Add missing dma_mapping_error-call in
 e1000_alloc_jumbo_rx_buffers
Date: Tue, 19 Mar 2013 17:47:44 -0700
Message-ID: <1363740464.2069.52.camel@jtkirshe-mobl>
References: <1363429925-12724-1-git-send-email-christoph.paasch@uclouvain.be>
	 <1363429925-12724-4-git-send-email-christoph.paasch@uclouvain.be>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-9Gn7atG86aLppc9wO6Xm"
Cc: Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12607 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752320Ab3CTArq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 20:47:46 -0400
In-Reply-To: <1363429925-12724-4-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-9Gn7atG86aLppc9wO6Xm
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-03-16 at 11:32 +0100, Christoph Paasch wrote:
> After dma_map_page, dma_mapping_error must be called. It seems safe to
> not free the skb/page allocated in this function, as the skb/page can
> be
> reused later.
>=20
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)=20

Added to my e1000e patch queue

--=-9Gn7atG86aLppc9wO6Xm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRSQcwAAoJEOVv75VaS+3O784P/2+pEQtzd0gBoJMG7xGqzK2h
LySvKtNMRZzQqnlSNzXDkozllUlvbkyIGx1xGEaUFpIn5wkLUKq9Jh86jABqRCCm
i1UAGKRMnBPiFULbgMv2HnAGzzXmzXsugi9ofTKmipBBtQmaVbDeRYNsk13Sjv8X
6Ot3fP4qO+oI2iR082hqPo+t5WipzbcEhgxlQxGRW2Bt+X2xiLgoInpJq3WbMI2s
kysFyv7Zi4pujDMbPgKU5VkBa1GI56STvJ/K7NAeH9sSxpPPBagscPkla3aiVxRU
H31OGW+MVgVYkT9DQaO06WEmjf0r/3Hjs8JHu+h7CTSAvLkKPxl4RoEBqXmkGolK
8V0FGCJY2vY5y9gXRWtlIUkhxvNnbD5gwibezOLV0vLhNzhNBKNzNufXk/lPn+OX
xm/qRy6TgCulB3RXInTitR+kW1FmwMTfTmYw3JZxmAD/HLFechheQmystYbXBJsJ
aGtiTdIDS9luLa5wgB06kCnSJWRfK26cTBmB6Nbe7YbZDvrbS0QBCe68whgKJWDL
J+Yv+kZ5UTIszeXNgC/SI+cdwbROvXOovfnwc/kwbJ9DNGta3Z9LFQQuW4HWX9f7
Bfvkx2RHvuFAtVidHWFMsHbw+uKyAwxL2flenmRmIK0OdN1QECBOErF5M8ldTuOB
en3tWp8ShVaq7YUGqF+k
=k/HL
-----END PGP SIGNATURE-----

--=-9Gn7atG86aLppc9wO6Xm--
