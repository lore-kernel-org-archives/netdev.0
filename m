From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH 1/2] ixgbe: fix build err, num_rx_queues is
 only available with CONFIG_RPS
Date: Fri, 08 Nov 2013 04:35:57 -0800
Message-ID: <1383914157.2365.30.camel@jtkirshe-mobl>
References: <20131108084654.6935.36501.stgit@nitbit.x32>
	 <20131108085031.6935.61765.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-hlcgjxm2OaIWSpRrjpVU"
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30875 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756664Ab3KHMf6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Nov 2013 07:35:58 -0500
In-Reply-To: <20131108085031.6935.61765.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-hlcgjxm2OaIWSpRrjpVU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-11-08 at 00:50 -0800, John Fastabend wrote:
> In the recent support for layer 2 hardware acceleration, I added a
> few references to real_num_rx_queues and num_rx_queues which are
> only available with CONFIG_RPS.
>=20
> The fix is first to remove unnecessary references to num_rx_queues.
> Because the hardware offload case is limited to cases where RX queues
> and TX queues are equal we only need a single check. Then wrap the
> single case in an ifdef.
>=20
> The patch that introduce this is here,
>=20
> commit a6cc0cfa72e0b6d9f2c8fd858aacc32313c4f272
> Author: John Fastabend <john.r.fastabend@intel.com>
> Date:   Wed Nov 6 09:54:46 2013 -0800
>=20
>     net: Add layer 2 hardware acceleration operations for macvlan
> devices
>=20
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-hlcgjxm2OaIWSpRrjpVU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSfNqtAAoJEOVv75VaS+3OCfQQAIfnR1IMXEAkN1Yzx7Y+JJyT
8b1lLxX+i1o+pQXYf9kSM3FxZxh2sSnCo7hFT+PZuP24d75rbMsvtN0Vva7hE1tu
+GYPil8MCnRYqc5gL2YZaDhvqwRwipO6VeF3CBGXl7Hkxwfp6aXqLcJpGCub5JnL
4qJXsKKp+6iGkyRHo1sRH4+D+twKhqnaT0SuBnw0lY/Bhs4ux80FgBEVe33igL1g
G0X2gLHdY0fj1l37ZCAsIgMU6NXpodEmBmBFkifemMt+ngQXIwvhTGzXXAFm5Smn
Zs+vKQS04bgj5x1wdUlxUHyqkebZouTe6+otqo6meyXOtYn+kC5gGBwHfiBInArx
k0K8oChy0AAXuVSYdj53Mz6+I7RHlFDVSAU8c1mciYSa/8cCO73RWS0h7cO5Mq4x
SicleQW85qu4RtLI8e4IrD+5rDkvQd7VuqIhmW7NxMiEpAY0URrDPrCRZQAFr7QX
GjWr1V0QGVOob7GIZrkqh3PN3k31tTXIY0pKkZ+reM87WEgQerfekWP40t5oDC7z
ZNl3H1Z4Onf2Gqs+MksejrQa5kPi6Wac4G7W0cEqIlFwX7Uoc/dC7pEsvWGcGmtm
kdDx+NUxgZn5yYGLf1iNQM1IeQvcocUJQKqP9yt0vuv1cBe53p7o+tCikVuHcQNs
OJ/1CvJTPRSvrDoa208B
=CeXV
-----END PGP SIGNATURE-----

--=-hlcgjxm2OaIWSpRrjpVU--
