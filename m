From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [linux-nics] [PATCH] ixgbe: Look up MAC address in Open Firmware
Date: Fri, 14 Nov 2014 13:40:15 -0800
Message-ID: <1416001215.2478.8.camel@jtkirshe-mobl>
References: <yq1r3x5vbh9.fsf@sermon.lab.mkp.net>
	 <54666106.9000609@cogentembedded.com> <yq1mw7tv8jq.fsf@sermon.lab.mkp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-D/S+jBfYX4FbSlYC+fcA"
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, linux.nics@intel.com
To: "Martin K. Petersen" <martin.petersen@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41943 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754335AbaKNVkR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2014 16:40:17 -0500
In-Reply-To: <yq1mw7tv8jq.fsf@sermon.lab.mkp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-D/S+jBfYX4FbSlYC+fcA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-11-14 at 15:20 -0500, Martin K. Petersen wrote:
> >>>>> "Sergei" =3D=3D Sergei Shtylyov <sergei.shtylyov@cogentembedded.com=
>
> writes:
>=20
> >> +#ifdef CONFIG_OF
> >> + ixgbe_of_mac_addr(adapter);
> >> +#endif
>=20
> Sergei>    Eww... why not define the following above instead:
>=20
> Sergei> #else
> Sergei> static inline void ixgbe_of_mac_addr(struct ixgbe_adapter
> Sergei> *adapter) {}
> Sergei> #endif
>=20
> I don't care much either way. But we might as well do this, then, and
> shave off an ifdef...
>=20
> commit 01e25f145972563ee87ebf85b7cb02a4ff8fce3b
> Author: Martin K. Petersen <martin.petersen@oracle.com>
> Date:   Wed Nov 12 20:47:42 2014 -0500
>=20
>     ixgbe: Look up MAC address in Open Firmware
>    =20
>     Attempt to look up the MAC address in Open Firmware on systems
> that
>     support it. If the "local-mac-address" property is not valid
> resort to
>     using the IDPROM value.
>    =20
>     Signed-off-by: Martin K. Petersen <martin.petersen@oracle.com>

Was this meant to be a v2 patch???  Yikes!

Based on the feedback from Segei, Dave and Jesse.  Dropping this patch
from my queue and will wait for a properly formatted v2 of this patch.

Please CC me on any future patches against any changes to
drivers/net/ethernet/intel/*

--=-D/S+jBfYX4FbSlYC+fcA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUZna/AAoJEOVv75VaS+3O/TMP/jRo4MQqh0LDjCPoIOTcSuxy
esOK1+642CpOOOp1RfL55tEwUdryA3DeOpjm1re4DSrp37ReljL+8xPG6E2iPlU9
15DYWrUvnHmvWt66FX8quzc3S7s/h+XkIQGaYT/6yefmo6x/eTbZ0i8NJEPvpBzF
hV7aLGltN2QVxqhH55DlFWi5N5pGmHocL0eJzAPvGTLqMS3dVpawD0DHysOeqaKb
NFW12rcix+RVLn4K/hcUyJS8vwdHXgEyoBAJVymJtc9HfSN45T35PHLMFJLclbnW
jW3EotEt2TKac7eQa4uNCJU7jZhR4eS3yezIeLmDWofzG4BWk2S19vy0zI7YLniD
CQ+smoNaW/x+2b4P1wfY2KBP9378BGofpWXC2f7V0zv7kqC1nEKmINRs+AXm42Rk
nRTvBdNqJN3U2kmEc4DZkqIHpdnW42Gy6BpKT7IfZbuFWFR2KZ7ApnMCTcyu7DcT
hvAme7onYLezHQqr3PSTAcdfStUOzgl7sjFxg17EvDFQ1Uj68CR9OgwZvpb7iJx5
Ik+C0jAjy/5qCCnvyH8gGAmwORqbg5thMHOF5zx9b+JEu0o+BLJqMTDvTkR0q0GL
o8W9QNVP0SFY8d6hC73UbvdTWfbcsMxKBiGtffRScKCZ6Q1nDuBAl5GefR3BLQk4
v4n4txaXcgxXzTxI7TgP
=58S6
-----END PGP SIGNATURE-----

--=-D/S+jBfYX4FbSlYC+fcA--
