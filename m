From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2] ixgbe: check adapter->vfinfo before dereference
Date: Fri, 10 Oct 2014 01:50:52 -0700
Message-ID: <1412931052.2427.33.camel@jtkirshe-mobl>
References: <1412930732-892-1-git-send-email-thierry.herbelot@6wind.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-B2vlqBT/rzKW3mtACxcZ"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org
To: Thierry Herbelot <thierry.herbelot@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51563 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751727AbaJJIux (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2014 04:50:53 -0400
In-Reply-To: <1412930732-892-1-git-send-email-thierry.herbelot@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-B2vlqBT/rzKW3mtACxcZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-10-10 at 10:45 +0200, Thierry Herbelot wrote:
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

Thanks for fixing that up Thierry.  I have added your patch to my queue.

--=-B2vlqBT/rzKW3mtACxcZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUN53sAAoJEOVv75VaS+3Od+UP/3s1b0J9BASYKsdOF4NOZKkf
VEYYXZKhjvu/Js5XWNmUjBR5/ZiyBsYNPtGtCDCNm+Jd9Wdg1iRmnkhPCjiBdmwO
yywx5SW7m+TlkaFJ/KBQnr47JG+Br+i/nEqPQ9kxv254/W17QiHE/toiGPH8fDCi
znc6GYPfLTcvi6fi0Cm7/kWvlsOyGoeie0scsgaUi09N8BBRbHsCQQvd7ArTmlao
TEnWQKe1r29Sy51+Tw9wM9n8aQZOhfUVM4rK0sngCV0m6rS+6O+Q3KKHfiGFxp1/
0CZYnbs8ln94CTcYWa2JS0mdi9Kb6U7FY01tZYvux42C2rOg3Z2rE87M2ajQ9ei5
+lCI4GEZQlwlNjg81IWqkYw8Hi2X6pnN31IbFlbvp+HflXPyI9PApMhk3NfydEbX
LNI1DITahGjdq3iBYS33iHcGE0yKprJflh+Qa8z5PFGk4x+ceTT1HxUjQysTLHgk
fy344toFwCOUauzbu+tknlGMX3yN2RT787vPiHPgYAA5nqO9aEP4/vl2hTDOOlA3
m+cJvMh6Q2F14g1X20T2XcOP2Xg19e4LcEI9d2YnpnPQbOOxJFof/RGEiBYDtvv/
i4lipWjaOyY7TmrO2n86+0vtGwpuKPY7DeomgdKoEMNbx3yBJJrFzqKxY8Ynv4lB
vvbBAeN3i25/3wCobrzA
=vjcv
-----END PGP SIGNATURE-----

--=-B2vlqBT/rzKW3mtACxcZ--
