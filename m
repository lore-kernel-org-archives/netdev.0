From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v4 02/16] e100: Support RXFCS feature flag.
Date: Thu, 16 Feb 2012 16:07:44 -0800
Message-ID: <1329437264.2869.21.camel@jtkirshe-mobl>
References: <1329418421-31574-1-git-send-email-greearb@candelatech.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-gZFwl5cEBfDwy/c91yDO"
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58325 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752503Ab2BQAHp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Feb 2012 19:07:45 -0500
In-Reply-To: <1329418421-31574-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gZFwl5cEBfDwy/c91yDO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-02-16 at 10:53 -0800, greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
>=20
> This allows e100 to be configured to append the
> Ethernet FCS to the skb.
>=20
> Useful for sniffing networks.
>=20
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
>=20
> v4:  Incorporated Eric's suggestions regarding RFD.  Tested
>    with mtu-sized VLAN packets + rx-all + rx-fcs.
>=20
> :100644 100644 485ab8c... 3ecbded...
> M  drivers/net/ethernet/intel/e100.c
>  drivers/net/ethernet/intel/e100.c |   35
> ++++++++++++++++++++++++++++++-----
>  1 files changed, 30 insertions(+), 5 deletions(-)=20

Thanks Ben, I will replace the patch that is currently in my queue with
this updated patch.

--=-gZFwl5cEBfDwy/c91yDO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPPZpQAAoJEOVv75VaS+3OgwAQAI/RDs4k5Y2lfC38GaT2OS5A
140gRAxJrKbZqVYGtHML/Q2bWDhF+rr2aSTkMbkMASy6WKyar0ZVUMnuGQfoZSaj
4H1Hyk+eT1HNVLf7e5AWiutFrITgg8dp8n3X72CBRcZ4pW6CfpnUpaVYKP0XwEa6
mmm97wLZTYWynfSREVWswdwfnasvCXUhTjZ8O35vHc+drlfYXo1jbch30wf4uyc4
6naTMp2XOk6cJ6y24GUaWjch1FkRcwLSNf3bNuDHVBjyAR4PXSRW4dbnGN5bI7FA
Vq1KRW02QPKFb9A6C2UXA7OK9vBCm3HWyVOhAnlXo6c7HmuLlBbVMU2W8zFqR2eV
iPKsKIZUBk62RrUoaOkmHyTQ0VDKAzaUNE1RmPD4fVjHx1d4cJf9juGpx6CkAuGf
aHlitGBRPOl12/e2N7dU9sux6ohiJr3tUbnWdcBZ3IvevA8y6dTzCXK+TIbEldB+
F5Y+4jC7Z+SgqC3/koYLhS/tTH7nZ+CNJdzi9Q0gu/7Q9xv0wErm7qKqu9Z4j4YO
QQZAhXd+Sxf8k0NxQOfnfn9mcq/U5zOJ3CX64tqn73C20gG96ML42WV/KV3A8+t9
1kZttk8SsYDWv/4RO9s8HpDVDzqi45kvaaGovULrwFiW4rcTDeAyDRFlScaVJ2XR
tupwAifOmM++DhjacaE3
=O85u
-----END PGP SIGNATURE-----

--=-gZFwl5cEBfDwy/c91yDO--
