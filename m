From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v10 7/7] ixgbevf: Add the appropriate ethtool
 ops to query RSS indirection table and key
Date: Tue, 31 Mar 2015 00:36:28 -0700
Message-ID: <1427787388.2497.115.camel@jtkirshe-mobl>
References: <1427740529-9605-1-git-send-email-vladz@cloudius-systems.com>
	 <1427740529-9605-8-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-lUxjlC+vTv9qYtQrKEJc"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20840 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753184AbbCaHg3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2015 03:36:29 -0400
In-Reply-To: <1427740529-9605-8-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-lUxjlC+vTv9qYtQrKEJc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-03-30 at 21:35 +0300, Vlad Zolotarov wrote:
> Added get_rxfh_indir_size, get_rxfh_key_size and get_rxfh ethtool_ops
> callbacks
> implementations.
>=20
> This enables the ethtool's "-x" and "--show-rxfh[-indir]" options for
> VF devices.
>=20
> This patch adds the support for 82599 and x540 devices only. Support
> for other
> devices will be added later.
>=20
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
> New in v10:
>    - Move the mailbox locks outside the vf.c functions.
>    - Use IXGBEVF_82599_RETA_SIZE macro.
>=20
> New in v9:
>    - Use IXGBEVF_RSS_HASH_KEY_SIZE macro.
>=20
> New in v6:
>    - Added a required get_rxnfc callback to ixgbevf_ethtool_ops.
>=20
> New in v4:
>    - Removed not needed braces in if-statement in
> ixgbevf_get_rxfh_indir_size().
>=20
> New in v3:
>    - Added a proper support for x550 devices: return the correct
> redirection table size.
>=20
> New in v2:
>    - Added a detailed description to the patch.
> ---
>  drivers/net/ethernet/intel/ixgbevf/ethtool.c | 69
> ++++++++++++++++++++++++++++
>  1 file changed, 69 insertions(+)

Thanks Vlad, applied to my queue.
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-lUxjlC+vTv9qYtQrKEJc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVGk58AAoJEOVv75VaS+3Oj7YP/0MLafKITVnk87mX+Lj4ITc3
McJafqM4cUHIoueI+PJOK69wyaI726ejokFW2h9zoYf/PXSsl+KHh24Bpu363t/L
kfLEImoUkOfyI9DCJEuFN9N0CstDcLqPHo8o0QlHCSkp388ygKQR6s3r5k/VosIm
qqnxHs6dxz33QwwqmZB8mQM/5skEe5z1UcKe7WqKhC6lITPFhq22YcVsC/nRn+Zv
YqBMOmDFhom1Em/uS/O0mpUyS+wLO6WEF+N65ieal2qTU7vC5+/Kg0TR3oBdHKtZ
85sSYjaQyHuD5iFS8FdKoKkSP5T3b3S8bFfBse71XYxgaRQHFvR55p3NRLMxLtoz
CTbGcZjQHb0If+5wIFiQ041eMv9UKAXYZMfpVLGoAZV4HHXP2F+aOvfKZ1PfrXC/
Nas/qIioXfUefiOOuUpA6mhMlxkg2e7QGNGFAUQhihG1c4xD4x0Z20Y5oaKKFQaH
vmLPIF6e2XGpi6dBH2FSP1qyrlT0+iKoP6hqDnUHOPvT/Jy0+o+wS8WJGbfTMZI2
2APQSGY6oSyyrq7dVN95FxOLYE+fsoJz8yfh/yQI23saDA+b6nKkYHqzIqWYVt63
NRoiMDKQULjvlwJKIEZcf62TELT1DUsEI/4hSSdCMFbWyteKvVGZUmXkV9TqF2Tm
Fi6qfelK/BQ9QM8nLJfN
=HCaf
-----END PGP SIGNATURE-----

--=-lUxjlC+vTv9qYtQrKEJc--
