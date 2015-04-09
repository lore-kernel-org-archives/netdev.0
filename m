From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH 3/4] i40e/i40evf: Use dma_rmb where appropriate
Date: Wed, 08 Apr 2015 19:52:06 -0700
Message-ID: <1428547926.2729.8.camel@jtkirshe-mobl>
References: <20150409014001.4434.85280.stgit@ahduyck-vm-fedora22>
	 <20150409014943.4434.58640.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-G+7cxvjEEhPJtJcg8Cpf"
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50581 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754357AbbDICwM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 22:52:12 -0400
In-Reply-To: <20150409014943.4434.58640.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-G+7cxvjEEhPJtJcg8Cpf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-04-08 at 18:49 -0700, Alexander Duyck wrote:
> Update i40e and i40evf to use dma_rmb.  This should improve
> performance by
> decreasing the barrier overhead on strong ordered architectures.
>=20
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> ---
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c   |    4 ++--
>  drivers/net/ethernet/intel/i40evf/i40e_txrx.c |    4 ++--
>  2 files changed, 4 insertions(+), 4 deletions(-)



--=-G+7cxvjEEhPJtJcg8Cpf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVJelWAAoJEOVv75VaS+3O3twP/3GIczy6Z7NEfhzBiSOpZ4pu
FIqj+4Far2d9ppdpiHuSfnGr1r6LHh+ZFdvJtUG4JdpsonzzNXL43DRaoCmg4EDI
be/QH9e1C4EPjr3gx+hJHCqiLWXOK24orLUvPFttNyvWUyEX/LR6LnSRDqIadDvO
dHyWOJX3q7Po77mA/t2Nr2Uumyx//7y5JDGbX31JvQOeg2ahssXvNGG4CgnH7WRk
RCQLqJbaOKRGt4+JKMfiRf1KHEEoJfi/5WYg2rPe2LcbPoe71xfYN4Og75IEAc7z
3bZbj5Fnx04SMLAbaHuA1bUhOuCo36jFsTPwb3xBKcToc1kasSUR7Mm8rI6KYVyM
wp29olt0cWnDra2ApSdKjQk/XzeX5nkUbz79iVOvZ8V3WQHH+JDRkCqZIIzlvV5L
0vvJfvnhJ35A6Tkgf0PTWFaLsAIY9vrCXi3TXqjMd8EGq4IpBIGI1fRvrBSt3lc5
Y+JtXWMY9PbyINI8J6hwfKOG6XEFfoFPNjb61/gsv6OF4oDXKVwYL3Gzl5X52ePk
mAB/A+eJYU05LfgLNQiQgojr60RVX/KIqm8+ZpwOTCNTnay13y84tPiBFZYQjCE1
5KsA0L0srht7q1BRUdnjI/BPeMEEyqyPlH7SUJecIvKcIFgJOn3891EvY9jaOfih
oGk8UwyJna4i0JSO2cYM
=fNdj
-----END PGP SIGNATURE-----

--=-G+7cxvjEEhPJtJcg8Cpf--
