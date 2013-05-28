From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 4/4] igb: enable auxiliary PHC functions for
 the i210.
Date: Mon, 27 May 2013 17:45:07 -0700
Message-ID: <1369701907.2116.138.camel@jtkirshe-mobl>
References: <cover.1369645944.git.richardcochran@gmail.com>
	 <cfbb4fdcf968d81b2211b97c75c9b5bf820570e4.1369645944.git.richardcochran@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-gGy/ILq8gBERzyGAzzkT"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	Matthew Vick <matthew.vick@intel.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65295 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753145Ab3E1ApK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 20:45:10 -0400
In-Reply-To: <cfbb4fdcf968d81b2211b97c75c9b5bf820570e4.1369645944.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gGy/ILq8gBERzyGAzzkT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-05-27 at 11:21 +0200, Richard Cochran wrote:
> The i210 device offers a number of special PTP Hardware Clock features
> on
> the Software Defined Pins (SDPs). This patch adds support for three of
> the
> possible functions, namely time stamping external events, a periodic
> output signal, and an internal PPS event for adjusting the kernel
> system
> time.
>=20
> A pair of module parameters lets the user choose which of the four
> SDPs
> will be used as the input signal and which as the output.
>=20
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> ---
>  drivers/net/ethernet/intel/igb/igb.h      |    2 +
>  drivers/net/ethernet/intel/igb/igb_main.c |   30 ++++++
>  drivers/net/ethernet/intel/igb/igb_ptp.c  |  157
> ++++++++++++++++++++++++++++-
>  3 files changed, 188 insertions(+), 1 deletion(-)=20

Thanks Richard, I will add this to my queue.

--=-gGy/ILq8gBERzyGAzzkT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRo/4TAAoJEOVv75VaS+3OzjEP/AuFOGpjOaIo4tGh/OiMwJbi
WtlbLxno4vek1fHX4V2ZLuzNiapXDfpYtHyuNPFcv7nq4IHvA5WeN4lA9zl/HlpZ
+icj1l/oxsWlUqxJ7q+Ur9qUMfC2BetpeWvZCXDMipLmRgAO2O9pP3Y71QYmI7ix
ualhW3egkb+xtA9sTg9+rSJ28caP90pLr7q8P7xfb38tI8VlIdoNAEuJnJYhdZUu
LjmH0MnANu35vWdT7SzgFLgD4OXaKBIqd4q/qQD3wO7uJGF9tC4uzGg2t7iyVQLg
72mbVyqlFqwsa89mSp7l4uuNMp+l/37UdhlccDle0NfNozSsFYANeGBPDvA6vsTu
PfFzmoMudxW1L032EJbBWszjfa5qvp253C33LtPdFot04oyp9MvN+Z6ahEq7hbSQ
tKapDcYAnV54qcmXPW8oCbmRg41SNVUc9udpEDqyK+d3FpeNtmnxy8pxiIZsjL0m
Ono3X1+HGCyASPCnOD1NETVDHX9Z94Xxg8UrCNVvbM0mhwQ2clqHk2YZbDW4YDYv
BtwunIKDcZbrGkKo5TW5Zrsdttd3dbe58tUVl6WE/alKdi5QcHlrjIWgNPJPJYgx
syp2fH7B6RKYs+8bRZ6+YbY+r7hA10eQV94oFy/x0IB5NFVZUHomNrttAt6SBYwW
p3QEFS55gpNrX+20UDeH
=flMw
-----END PGP SIGNATURE-----

--=-gGy/ILq8gBERzyGAzzkT--
