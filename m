From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH] ixgbe: Remove IXGBE_FLAG_IN_NETPOLL since it
 doesn't do anything
Date: Tue, 11 Nov 2014 00:26:38 -0800
Message-ID: <1415694398.2466.97.camel@jtkirshe-mobl>
References: <20141110224922.7245.35078.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-/7hdG8rPD/rNPsSs2pwo"
Cc: netdev@vger.kernel.org, donald.c.skidmore@intel.com,
	davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:1970 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752734AbaKKIbH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2014 03:31:07 -0500
In-Reply-To: <20141110224922.7245.35078.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/7hdG8rPD/rNPsSs2pwo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-11-10 at 14:50 -0800, Alexander Duyck wrote:
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
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    1 -
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   16 ++++------------
>  2 files changed, 4 insertions(+), 13 deletions(-)

Thanks Alex, I have added your patch to my queue.

--=-/7hdG8rPD/rNPsSs2pwo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUYcg+AAoJEOVv75VaS+3Om6MQAKB80mgr9tw3BRpl2o7VAxpT
dPmsryGYpRpBRXPp7KvylSHivABTQ6FjFDiTB4OxdoQrEVYva7a5t7MgNtQysWVo
wC+cDmOQ3x/oIuh7SD+Vi9FE0CmrwUhMjyfch2v2D33kUitgkHZh0BppqESPaxKi
CiUpmsUTc1j6Ql7KE72UDnrSsD9n2zfb2LDvGqpvX5cIE2UllZI2fNDUKHV1XWRN
VTuJitrVx6zTM1SJVozsO6selPsTQbYChJLH99y7IMgdrz3T0lCUHiyCuGk2+h1c
XYjuMKaqXM6oCv5//BdCKi4DAq2QBtDavJi3UKdS9CDpQ17oI0ZNDxGVPlQ5JQeg
DGS8Ze1dmFRDCGpeGohDjPjr8ybC75CW2l+iZr6bv+ab6KgYljqp1eWtfdh9BpHR
N1jYWf7rxkn9L+sxC5hu9SFzYKFVC2iFd9CNqBYA3I6Jfb0VSfA1Wh5P4u4w05y1
UyGzMYewMtOzpY0J7dkfBOt5Kf1xdNqAJjy1zZI/N8YwCD3PNN1mepPevUB63RgU
vAc5BNTYj6CGfy8yy5Vtrf6TNr0baxMNQjWTiOhyjNhlx6bX8ID9k/NEt4xG1MMx
1vx0EK4xXW/vdV+6XDgtqKwXWLN8/GGEh0x03MB0kBrDE2cg7VYN79GnBGdK+if9
kdjFym26S4z5H39tl+Jp
=7bcL
-----END PGP SIGNATURE-----

--=-/7hdG8rPD/rNPsSs2pwo--
