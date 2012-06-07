From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net] e1000e: Change wthresh to 1 to avoid possible Tx
 stalls.
Date: Wed, 06 Jun 2012 17:59:12 -0700
Message-ID: <1339030752.2075.1.camel@jtkirshe-mobl>
References: <20120606174355.823e9aa7.shimoda.hiroaki@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-5Eago++T/3nQdiSzbE2Y"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"denys@visp.net.lb" <denys@visp.net.lb>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"therbert@google.com" <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12957 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752217Ab2FGA7N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 20:59:13 -0400
In-Reply-To: <20120606174355.823e9aa7.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5Eago++T/3nQdiSzbE2Y
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-06-06 at 01:43 -0700, Hiroaki SHIMODA wrote:
> Denys Fedoryshchenko reported Tx stalls on e1000e with BQL enabled.
>=20
> e1000e has WTHRESH which determines when Tx descripters are written
> back and successive Tx interrupts are generated, and setting WTHRESH
> to 5 gives efficient bus utilization but this cause possible Tx
> stalls,
> especially on BQL enabled system.
>=20
> To avoid possible Tx stalls, change WTHRESH to 1.
>=20
> Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Tested-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
> ---
>  drivers/net/ethernet/intel/e1000e/e1000.h  |    6 +++---
>  drivers/net/ethernet/intel/e1000e/netdev.c |    2 +-
>  2 files changed, 4 insertions(+), 4 deletions(-)=20

After further internal review, NACK.

This patch will cause unacceptable performance issues with non-ESB2
parts.

I am dropping this patch from my queue.


--=-5Eago++T/3nQdiSzbE2Y
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPz/zgAAoJEOVv75VaS+3O/K4QAJGY6ZJvGWex3xEx3Kxx7GMY
J/eyGv8kjFE5TZClvfT3YP9Q9WVm/cI9dD5O8W7Mm0HQHYDm7H5ZChZYFbfAGW4R
+keUqAm1qUY8NrhSSspnEOePlgLKGCrT5CrkfCoa+rGwNkSP1145ecXQzij3yEGg
ffwUbMtelKDIgcd8OB11IpmmeQc5MAxSFQCECHe9lY/lv5mywqcsaW7EoKLrhK+e
9WAbv/NkS3hJi8EGQIgZ+DmL7e648XxIFuA+jsZG4eBBNJYKFOosRGWfaA5vqMjB
pluKKjB9zKBs3eWMIdHZ++7ZLEucijT/4p0PeLV8EQJTNvfHnqnJc8PIrEM4+a+d
AXNwz8vDaREwtnsl2V4U21qEMeKpLb9dVDOqWnr2JzLBzPaB7PmVFTqCjgIUUa8z
oaAm4EwV8yn4cWtlP03vUl0vYtmfM0YR5r4/nmtzuVmeow54TMdDvSXGTQcl+KTh
dY7vQ71XV5ulk85pnyfMQ7Sqj4+XfJh/u2SPu8Zm5gDjCQk96SdaCN4N7h813tsE
4YzVBzGEXrf9spNmFCtW3yZGHCuE6yOqHwcF+mPQtfgfO5AI/esACzh3meRmlJ88
0oF8phzo+w4XQ5/WGMBti1bmVwSHtmj+dvNlvSy9l6R4eO0GAMSES3soGhwUK7SL
rr92W3ZUjr3o9+2cscs+
=VXwn
-----END PGP SIGNATURE-----

--=-5Eago++T/3nQdiSzbE2Y--
