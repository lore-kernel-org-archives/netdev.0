From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [README] net --> net-next merge
Date: Tue, 08 May 2012 02:02:40 -0700
Message-ID: <1336467760.2442.4.camel@jtkirshe-mobl>
References: <20120507.234113.2269441747611427613.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-IFRHzOApuYw1bQWECPQZ"
Cc: netdev@vger.kernel.org, sfr@canb.auug.org.au,
	linville@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58646 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751097Ab2EHJC4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 05:02:56 -0400
In-Reply-To: <20120507.234113.2269441747611427613.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-IFRHzOApuYw1bQWECPQZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-05-07 at 23:41 -0400, David Miller wrote:
> I just merged net into net-next, there were two major conflicts.
>=20
> 1) The known iwlwifi conflict due to the skb->truesize bug fix in
>    'net'.
>=20
>    I used the conflict resolution posted by John and later by Stephen
>    when he resolved it for -next.
>=20
>    John, please double-check my work.
>=20
> 2) drivers/net/ethernet/intel/e1000e/param.c got a conflict in
>    the code which validates adapter->itr settings.
>=20
>    The net-next side looked more sophisticated so that's what I
>    used.
>=20
>    Jeff, please double-check and send me fixup patches if necessary.
>=20
> Thanks.

Yeah, I will need to send a fixup patch.  I have something for you later
today.  Thanks Dave!

--=-IFRHzOApuYw1bQWECPQZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPqOEwAAoJEOVv75VaS+3OPmQQAIO8kFFmrjGqQPHVpROnhp3h
nkCLe3l60pJYIXsZbQ5DXiFgHEKc+3d8u0Lzihd8FmE+baKd3JA0IrvoL5zPYUmO
6Z6oEvUDZteD9dprlF7iPT5Vi8mOpwYLJJ+iVSkBbWC/DRE8BS1X4Ia+LFCdQywP
Vwsvk93C7dTVqgYbMmUifvaIt6GA6PKOsL43fr7jdTEiRR5L2spFwlBSmUg0U2Rw
9klWlAqTjFpJm+HdoeplgBDG6k4/1t8VZ/KIsOCy32CFH7us0x7AjHLDrC8cWLGe
lciD3KwhSUKpQWSgM3t8AoI40kKbzsnO/e9jhyCP6TRXAr0lVN4jbXZJTSm+bWEt
ShuiP/T4zcGLxRDtbsLTe0XYPCFy1/D/BLuHEPzfVmsN2Z55HEGkfhh+xjvkDoUy
X4Xn4GzicsYfVQD4El5oLrGdC3ny9ikydivG/vZugEgJf/bsR/n/xBsSmkLoup2l
+ov1J3WSIhbwey8qA0sCWnecfNnGKE5z922QEo12N7LnsJYokZfdyKzfpmxWZmqk
PkP+Jg1ORPQwSrJg1B2S/erV28/DgG3+h3XARAy5dqMKttt3OtBWw7qlqr1Amt6j
uNIPgDVE6x6hkbRioo75t29a/TzP0k7qOBlv+3bzYTtR+Ih4S8JH4t3FqGrgs7IQ
6Zlqig7legOobmzPym/J
=26qQ
-----END PGP SIGNATURE-----

--=-IFRHzOApuYw1bQWECPQZ--
