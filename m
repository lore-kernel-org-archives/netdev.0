From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH v2] ixgbe: Remove IXGBE_FLAG_IN_NETPOLL since
 it doesn't do anything
Date: Wed, 19 Nov 2014 16:09:42 -0800
Message-ID: <1416442182.2281.2.camel@jtkirshe-mobl>
References: <20141119232710.19544.20012.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-gXCEgtnpdc0lk5zS2/xe"
Cc: netdev@vger.kernel.org, donald.c.skidmore@intel.com
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28917 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755427AbaKTAKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2014 19:10:32 -0500
In-Reply-To: <20141119232710.19544.20012.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gXCEgtnpdc0lk5zS2/xe
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-11-19 at 15:28 -0800, Alexander Duyck wrote:
> This patch removes some dead code from the cleanup path for ixgbe.
>=20
> Setting and clearing the flag doesn't do anything since all we are
> doing is
> setting the flag, scheduling napi, clearing the flag and then letting
> netpoll do the polling cleanup.  As such it doesn't make much sense to
> have
> it there.
>=20
> This patch also removes one minor white-space error.
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>=20
> v2: Fixed an unused variable warning for adapter in ixgbe_rx_skb
>=20
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    1 -
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   18
> ++++--------------
>  2 files changed, 4 insertions(+), 15 deletions(-)

Thanks Alex, I will add your patch to my queue.

--=-gXCEgtnpdc0lk5zS2/xe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUbTFGAAoJEOVv75VaS+3OV6AQAJuyLMweq4pZzYqhUPf01fxa
BcqgiCQROPXPNYPgTAr/KLUIGzt0Vxa3zjHqkFS6z1Zm/Z/JkqsML4s9tw35C/RT
7cFBgXrxr1pxEzMKgrdvloOAtVCqhVObPwa3OUW8/uX7CQKjFfpzBqHlArxyIqTt
EMBPBMVisqffQFCcb57FqQUYZQJ9fid62Nc6kIAvoCiCZflD4cIVeZsjH7pkDPmr
SPxTZ9FdBhnMxBweTBp6TlBJTd8buy89M7GxtIri2wAIlQDYEJN6HNY8TL6QE05V
aP3JxRe4XhiR8qXoyHal1IqxFJj7vk1ZmC+wFPeQdIGlevjpcrusPUIqnvepdvT5
dxId0oyBBT6+k0g6+UHtDYjv3V57lBPc3lJQwrN//bdSjW4pc2C7Mb4VNCNnwk0C
fR57zK/YdJ4mN5XC7YMjCJL/fRkVUeX8YD+fcTi/bbCBAdBmZS3tI5z/myMASt7h
b1WqQAcngD1sGnLxgcOKTp/Na7t3OJeiKlhfuHzbA7BbiA4ETzXMmpCl9qjJGI07
UMkVBgYErx8HAOtfy7IkQzfGyI8+3PTFFLwUHzWWpmAy5kwKlROs5TLcUoUgcGEB
AmLrFr3gSgHZ41Z2ORgFZn8QWx3e40hkWnx2h1+2+gdR7Vkt6kVNNqkFbrBzyN61
BGcqcSzGEim5EDm7LQad
=sObA
-----END PGP SIGNATURE-----

--=-gXCEgtnpdc0lk5zS2/xe--
