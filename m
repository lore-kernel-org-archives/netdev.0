From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2 2/6] ethernet/intel: Use eth_skb_pad and
 skb_put_padto helpers
Date: Wed, 03 Dec 2014 11:25:23 -0800
Message-ID: <1417634723.2276.1.camel@jtkirshe-mobl.jf.intel.com>
References: <20141203161440.9223.39633.stgit@ahduyck-vm-fedora20>
	 <20141203161739.9223.52060.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-3R9bAuT0kf3Tu4vAzMfS"
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24787 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751190AbaLCUmL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 15:42:11 -0500
In-Reply-To: <20141203161739.9223.52060.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-3R9bAuT0kf3Tu4vAzMfS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-12-03 at 08:17 -0800, Alexander Duyck wrote:
> Update the Intel Ethernet drivers to use eth_skb_pad() and
> skb_put_padto
> instead of doing their own implementations of the function.
>=20
> Also this cleans up two other spots where skb_pad was called but the
> length
> and tail pointers were being manipulated directly instead of just
> having
> the padding length added via __skb_put.
>=20
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c     |    8 ++------
>  drivers/net/ethernet/intel/e1000e/netdev.c        |    8 ++------
>  drivers/net/ethernet/intel/fm10k/fm10k_main.c     |   11 +++--------
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c       |    8 ++------
>  drivers/net/ethernet/intel/igb/igb_main.c         |   19
> +++++--------------
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   19
> +++++--------------
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   11 +++--------
>  7 files changed, 22 insertions(+), 62 deletions(-)

Since this is a part of a series, no need to break it up, by having me
only pull in this one patch.

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>


--=-3R9bAuT0kf3Tu4vAzMfS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUf2OjAAoJEOVv75VaS+3Oi8gQAJZgJ8p37pGDdEbr0XoVpz2I
Ndpmpmj/bU8o9tS4n9BtNTCF+O7N/fHJfvKQdsT90iHDJ+rltlzDt5Y0HdqN8FAj
kvmuU3vLq5pLTP1oTnvGWjI3Vk8nDDSSRu3+FKKD5DNvl4vscPTwZJNxaG78L00K
WQ7MAzVt9K+8tDsV2nCOHnvHpFB52EGytnTprR8Tnl6U/5zXFD8KWsItGh1fL5Yw
xwGvx2K6HgR8HrTZuEyC6Le2S/OHH/FPFeVvEFFhxY5sMYFtE+lgN4rWPA/arTvI
VhBhG67VlxLm57ccot8MhyeMoehcz4+LT9TqjouJdXyUK8R0CFvn9Y3XSL8lfQMp
284G1TnX/p1wskrEUNFp1YEovRJRzLZc2gvmgrHSuLqWI0syHC3e0galRM4Ab5Sb
BLKjJVkp6/QD4UBTNnDtKIq2XVgDn3oPvJfa/abl7Wwobw/Eh9UOy3lwuUlOj9Sy
puA3UObXBhF//Ybe9lomeTxLMI3PSkutKS6fGoRcvfr8KhJ0z5rjVq1LMcxEf1rK
b0AEvGWLmjsSe43pveSrJvQzHTc+HxKY2jEexSZbnIzAnI8WsfQVs6aZcT+KRJbb
BQhERs8akRV4sECuBuVbxi3aMHB4vD/8fMc1YjQmPxUSRI5QYMV3TuK9aCIjmrOV
sUGaGyZ0n6xRBNRsCpHZ
=juAz
-----END PGP SIGNATURE-----

--=-3R9bAuT0kf3Tu4vAzMfS--
