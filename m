From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net] ixgbe: check adapter->vfinfo before dereference
Date: Wed, 08 Oct 2014 05:22:51 -0700
Message-ID: <1412770971.2295.40.camel@jtkirshe-mobl>
References: <1412769913-22306-1-git-send-email-thierry.herbelot@6wind.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-xVyEi78uvGsdHRFIPx/t"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org
To: Thierry Herbelot <thierry.herbelot@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:60899 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753446AbaJHMXN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2014 08:23:13 -0400
In-Reply-To: <1412769913-22306-1-git-send-email-thierry.herbelot@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xVyEi78uvGsdHRFIPx/t
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-10-08 at 14:05 +0200, Thierry Herbelot wrote:
> this protects against the following panic:
> (before a VF was actually created on p96p1 PF Ethernet port)
> ip link set p96p1 vf 0 spoofchk off
> BUG: unable to handle kernel NULL pointer dereference at
> 0000000000000052
> IP: [<ffffffffa044a1c1>] ixgbe_ndo_set_vf_spoofchk+0x51/0x150 [ixgbe]
>=20
> Signed-off-by: Thierry Herbelot <thierry.herbelot@6wind.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |   73
> +++++++++++++++++++++++-
>  1 file changed, 70 insertions(+), 3 deletions(-)

Thanks Thierry, I have added your patch to my queue.

--=-xVyEi78uvGsdHRFIPx/t
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUNSybAAoJEOVv75VaS+3OMR4P/38Sg46vwp1SSC2EU2ioXfYf
vUkfHZnroxuEp04JvtnZkIzHkAz/Wb+EIraPRdjbEkACmwgNViaOXwg4HzeVW+by
2xE6VAHQWD3c71R7xP5pVQKExhCBC2hIjvtf2LHqQ/eadZOXCguFjNJDWxVPS9MO
b29wQq1SrPKejHJ8agCDiFLPIo4/Ng2Lo7z2qVIiw8RL7E0OY4zTGIOZs6xYpRkV
XWOSgpdegiCGORQn8RImDQ9nv561Z/tFKMVDrHHwOu6LAIyX/m674ZBYLMDFhsw7
zwJRFDuJP8erU7EC0LYeUiPq5IMnlhJjQlrd8oiYLulVsS+yIjaAoqHxpaCMGggx
ORT9T8j8b2ijZs/SFAwgPDieVQqN+k0j5SD00rGl/v5VLMGutyTTz1qqb/UdhyvI
fzMXXrtCzPO0xvvhXq7gljJhEAfZdE6Lgl40O4KDW0zN8pwm0z+hEFZknHcYw7ni
XJCUItlLEiaE4N4T5xP3I0RoG77YEpj7uARlO1zsnPYSWt+fTARYfsK2AD0QoJWN
FvJpxCPzRDzIjbZbDlp8f4xHqHkBhrxdzYAxbbIhMpD+5gFNYdWaDyN4v3xDSBWO
/bRfXRboxyyTe8WK27aPXHxlbnCc47o+pXjs1jcPqVuOGytnkhwxkgcduNJ+SoO9
aExmEmvmEz8GQdRNohWp
=N8nB
-----END PGP SIGNATURE-----

--=-xVyEi78uvGsdHRFIPx/t--
