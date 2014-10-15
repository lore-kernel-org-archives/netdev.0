From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v3 net] ixgbe: check adapter->vfinfo before dereference
Date: Wed, 15 Oct 2014 04:00:34 -0700
Message-ID: <1413370834.2412.5.camel@jtkirshe-mobl>
References: <1412930732-892-1-git-send-email-thierry.herbelot@6wind.com>
	 <1413367080-31540-1-git-send-email-thierry.herbelot@6wind.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-QNp3OUPRFkhUlwix3+Ou"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	emil.s.tantilov@intel.com
To: Thierry Herbelot <thierry.herbelot@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:49022 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751533AbaJOLAk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Oct 2014 07:00:40 -0400
In-Reply-To: <1413367080-31540-1-git-send-email-thierry.herbelot@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-QNp3OUPRFkhUlwix3+Ou
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-10-15 at 11:58 +0200, Thierry Herbelot wrote:
> this protects against the following panic:
> (before a VF was actually created on p96p1 PF Ethernet port)
>=20
> ip link set p96p1 vf 0 spoofchk off
> BUG: unable to handle kernel NULL pointer dereference at
> 0000000000000052
> IP: [<ffffffffa044a1c1>] ixgbe_ndo_set_vf_spoofchk+0x51/0x150 [ixgbe]
>=20
> Signed-off-by: Thierry Herbelot <thierry.herbelot@6wind.com>
> ---
>=20
> v2:
>   compilation fixes
>=20
> v3:
>   remove checks in functions where vfinfo is known not to be NULL
>   return -EINVAL as error code
>=20
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |   42
> ++++++++++++++++++++++--
>  1 file changed, 40 insertions(+), 2 deletions(-)

Thanks Thierry, I have added this patch to my queue (and dropped your
v2).

--=-QNp3OUPRFkhUlwix3+Ou
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUPlPSAAoJEOVv75VaS+3Oh6kP/1XzBKSo7EVsU52y4JFO2B8d
CCvYNuegQDsal4dHk74mARqlZmHymrVbodcObnvJq58FaRfxN3Od2kYdH35bblDF
VSqAfasz0a+8jC9zdZ9MLzo6hVnIoiFNrEVPnh27KnY5l0YALjC6dhuGBP8187bN
guHdWGpG3XBhx4nqPLDgBbCEztf5noKikXVBP77vX5yRB+wLNLPTlbeJNFbxBQPI
+8R6aSbco4PNxEP2cZEBiYb9W3j9pnjgSZC5GBPWD47ZbRBMdzLMi//h0dNbE1xj
F94fi5HbhcTnp08v2Rx3iNO13Fi28Cofo5HA/bggGpQbjIQd+733fuDQj+q92+oj
lac4ZieZ3siSCRpb8gUF5kVsjbKlihw+xn9og6TbyNAtLwz0QztvTu4xu77Lm1ap
sPLrhOA3mkY5vrs7Sit2JTvqYW/pit7agQdlYu3zQsWRUhjwTuQXl5MfZWxN+3Yv
+CuCtN1H0cipdn+eS1FuW/u/HFJLkfM5NbGEjth6PC/PTfTp5WcqGMUaGcVrFGof
J6udW04a3AnD9j3ePWUgBhxymadw5wWUWNYnbCLjLnAxb27JqC4EFGNIKdQlvhxR
00kGymOzkNUFfnf3jqPnfVaLQV0qe/J6xaczBpw6kNxP2heaEZoIgg6Rv3KAHQEm
mEYawaFycFdAkVtnhDFX
=P5C7
-----END PGP SIGNATURE-----

--=-QNp3OUPRFkhUlwix3+Ou--
