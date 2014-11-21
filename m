From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next V2 0/4] igb: auxiliary PHC functions for the
 i210.
Date: Fri, 21 Nov 2014 04:37:55 -0800
Message-ID: <1416573475.2280.35.camel@jtkirshe-mobl>
References: <cover.1416562191.git.rcochran@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-gpZEbZelnvGpDjLKouhR"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	bruce.w.allan@intel.com, Jacob Keller <jacob.e.keller@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Jian Yu <jian.yu@ni.com>,
	Richard Cochran <rcochran@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37332 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750922AbaKUMh4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2014 07:37:56 -0500
In-Reply-To: <cover.1416562191.git.rcochran@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gpZEbZelnvGpDjLKouhR
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-11-21 at 10:41 +0100, Richard Cochran wrote:
> From: Richard Cochran <rcochran@linutronix.de>
>=20
> * ChangeLog
> ** V2
>    - Add missing serialization in the reset function
>    - Reset the auxiliary functions along with the rest
>    - Guard against spurious SYS_WRAP interrupts (these occur in the
>      82580 device from time to time)
>=20
> This patch series adds three features: time stamping external events,
> producing a periodic output signal, and an internal PPS event. The
> i210 PCIe card has a 6 pin header with SDP0-3, making it easy to try
> out this new functionality.
>=20
> An earlier version of this series was posted way back in May, 2013,
> but that version lacked a good way to assign functions to the pins. In
> the mean time, the PHC core has a standard method to configure the
> pins, and this series makes use of it.
>=20
> Thanks,
> Richard
>=20
> Richard Cochran (4):
>   igb: refactor time sync interrupt handling
>   igb: serialize access to the time sync interrupt registers.
>   igb: enable internal PPS for the i210.
>   igb: enable auxiliary PHC functions for the i210.
>=20
>  drivers/net/ethernet/intel/igb/igb.h      |    9 +
>  drivers/net/ethernet/intel/igb/igb_main.c |  110 +++++++++----
>  drivers/net/ethernet/intel/igb/igb_ptp.c  |  254
> ++++++++++++++++++++++++++++-
>  3 files changed, 337 insertions(+), 36 deletions(-)

Thanks Richard, I have added your series to my queue.

--=-gpZEbZelnvGpDjLKouhR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUbzIjAAoJEOVv75VaS+3O+V4QAIF8G0wzNMrT4ReyED6xk6jj
IhqaPzAjmCgbYfPoPXBxybXCPHVvF7qK7lEHN5i5VtLaetjjdHCDc3+s+Oin2xbh
JC9g/hK3hF9ssbghVqOLIVzmLSIUxS2Gak/yyYtQtndkkQ7sUEcOk3f+sSyfhChH
DvYunuip3luVMCz3K0yUN/fZlDe3C51MbObpzc82+mt+9gkG398rltuQhFHbCB0H
1nYmJwgAqIYbm3rnalaGH/TS5Au6roxR/BCGUiP1CZpZeMcAjLXIvlpF4k3sNXF8
zUtk2f0YkpqXEKqGVy6/8EddaYenDVoH7PXGucVoaJd8/J1f9xk9b4iJlj8Fuunn
OCUQ8f+ttbC0RhDCJBuGXQvNxZgeEmpEEtfAXeNs3R/IH4/2Osn2U8H7kcuTl/a6
kzpWo9pELNWNXh1Vorf6KFviMCHQjKdl2Uyn6qNaxBnO8hj+5jxQonfMIcl0epWV
4lHZi+JrHoHfXZPxbxQ/VGeLG6z6ffiHQrcis35kk97uJjDcxQIi/pQxPrW19O2M
ClWdmiby+4Px1p/TR2tik/NEaHsKVft23CVv1SqNgMZEGGwXCbGnvwGawBBDKVYG
wuZHZrZwTdfWFprVvkV84HvgUzIM3PMMJCG22F1CiHYBP9xd/FGsA3/tIXMuyqNT
XO0jPQtvYeyhOW9JYafG
=0Gtp
-----END PGP SIGNATURE-----

--=-gpZEbZelnvGpDjLKouhR--
