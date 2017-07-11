From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2 00/10] Constify attribute_group structures
Date: Tue, 11 Jul 2017 09:48:20 +0200
Message-ID: <fec4d3c9-1ac8-c752-b8a5-3f446042fe4e@pengutronix.de>
References: <1499758158-24741-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="9o5CtbvjURle51Ca8EBPi7aw7a4a5vMv1"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arvind Yadav <arvind.yadav.cs@gmail.com>, davem@davemloft.net,
        wg@grandegger.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499758158-24741-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--9o5CtbvjURle51Ca8EBPi7aw7a4a5vMv1
Content-Type: multipart/mixed; boundary="N00eADBRhqlqGptp0PumkVpVNNQG6mJhH";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Arvind Yadav <arvind.yadav.cs@gmail.com>, davem@davemloft.net,
 wg@grandegger.com
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Message-ID: <fec4d3c9-1ac8-c752-b8a5-3f446042fe4e@pengutronix.de>
Subject: Re: [PATCH v2 00/10] Constify attribute_group structures
References: <1499758158-24741-1-git-send-email-arvind.yadav.cs@gmail.com>
In-Reply-To: <1499758158-24741-1-git-send-email-arvind.yadav.cs@gmail.com>

--N00eADBRhqlqGptp0PumkVpVNNQG6mJhH
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 07/11/2017 09:29 AM, Arvind Yadav wrote:
> attribute_groups are not supposed to change at runtime. So mark the
> non-const structs as const.

[...]

>  drivers/net/can/at91_can.c                      | 2 +-
>  drivers/net/can/janz-ican3.c                    | 2 +-

For the can drivers:

Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--N00eADBRhqlqGptp0PumkVpVNNQG6mJhH--

--9o5CtbvjURle51Ca8EBPi7aw7a4a5vMv1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAllkgscACgkQHv7KIOw4
HPYwNAgAk2kOIukJk8ux3GPqCWM4A9Pd53xDAls0D3CN6dVgIkvUnvuy21a7Hhr/
DOevkALOlPqMIC1aM6szd0kao1yR+Wqj0OFmHRD51nq92WAf5Jmfa0+20KcQ5I7D
a8EPMNw/V9ZmEPr/XPL+9bLvuhioQKjnjwQzNqzB3iQW+hAkn9IPYEbRSCcX2Zht
6ZTHxvImEsdlB5rYqi2QL37QRrFWggfHSKxk7ZMwJji+jmfB5JZKskWsTfslHLSI
mPxnDnim1Je+zsHfPPABD7QKfcZsBvZvpnKRFzarcW5+ZC8cyNW9epX6JSqjD2fs
OQ7zYTptJR85irO1r9SnizyADPEfeA==
=k+Y5
-----END PGP SIGNATURE-----

--9o5CtbvjURle51Ca8EBPi7aw7a4a5vMv1--
