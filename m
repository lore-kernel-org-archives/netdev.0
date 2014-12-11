From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH 3/6] ethernet/intel: Use napi_alloc_skb
Date: Thu, 11 Dec 2014 13:43:09 -0800
Message-ID: <1418334189.2410.113.camel@jtkirshe-mobl>
References: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>
	 <20141210034056.2114.52972.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-SVmCaOUrzZyRENluLBfX"
Cc: netdev@vger.kernel.org, brouer@redhat.com, ast@plumgrid.com,
	eric.dumazet@gmail.com, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:60910 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933369AbaLKVnP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2014 16:43:15 -0500
In-Reply-To: <20141210034056.2114.52972.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SVmCaOUrzZyRENluLBfX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-12-09 at 19:40 -0800, Alexander Duyck wrote:
> This change replaces calls to netdev_alloc_skb_ip_align with
> napi_alloc_skb.  The advantage of napi_alloc_skb is currently the fact
> that
> the page allocation doesn't make use of any irq disable calls.
>=20
> There are few spots where I couldn't replace the calls as the buffer
> allocation routine is called as a part of init which is outside of the
> softirq context.
>=20
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c |    2 +-
>  drivers/net/ethernet/intel/e1000e/netdev.c    |    2 +-
>  drivers/net/ethernet/intel/fm10k/fm10k_main.c |    4 ++--
>  drivers/net/ethernet/intel/igb/igb_main.c     |    3 +--
>  drivers/net/ethernet/intel/ixgb/ixgb_main.c   |    6 +++---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ++--
>  6 files changed, 10 insertions(+), 11 deletions(-)


--=-SVmCaOUrzZyRENluLBfX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUig/tAAoJEOVv75VaS+3O3T4P/jMIta4qyq7uWrKMkyPxfpt+
/QR95ZmIGE29HMcrKuGrFvCAmtCZlSB5u82C/jzcBFm/gfZKNmYM9kwWAWkDDkcO
qgDmkcDOJCZFiHv0IgLvnH7YD4NVy4cSk0Gx7tNY8EeQot5+aBoAnmKooJdeNzJ0
vhrCyG8fukKF0xBTjuOqKAborM0iajAYSHxYjcNaEeDgNwKSw/lhm4CZH3lxnq/X
o4xUh6109LWLU8RjaA3gy+pasKYUem1D0kNuwIc5bi/ehPbaKim34ankIEnBkyGM
M7MIJSmRdqe9PD04AWE+/roNPHOePlwwvrqvd0dDa1kdm/45An9xCwcW+HpzY855
CUoaENrAtQFHMF/s5PIk58YfQoNAntDPUfep7q8UGl/n5aM7tpjZhTKzKcemgtVW
wH5O443cVhHZg6xEjF6buY+Zfut1egBDUM8eURzW/zbWOyPFGNYMfdeVXXq36yHj
LCdMLpZoRElJoY2VUyxA/Prw/QDc907CXCfBBBXlT3GOQcIMEZnyKSiV/todhgDx
rMi64R8YBzprd518UtiU4UcXSj8MUF3UwJ6+dZx7SMXlBRQAxu97UE4L5LzihHww
kB7msZIpPgE4gHkVtxb1aWTPkbZ/tHORqtvpTvAf4p0o21L6S2mTW/grt1WNMx+M
i0uJjMd8OezRAOPc9AIE
=UaGG
-----END PGP SIGNATURE-----

--=-SVmCaOUrzZyRENluLBfX--
