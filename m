From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net 0/2][pull request] Intel Wired LAN Driver Updates
Date: Fri, 04 May 2012 03:52:35 -0700
Message-ID: <1336128755.2656.95.camel@jtkirshe-mobl>
References: <1336039717-12336-1-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-7byvoE0Zhdooy52fqt8l"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3977 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753237Ab2EDKwg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 06:52:36 -0400
In-Reply-To: <1336039717-12336-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7byvoE0Zhdooy52fqt8l
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-05-03 at 03:08 -0700, Kirsher, Jeffrey T wrote:
> This series of patches contains fixes for ixgbe.
>=20
> The following are changes since commit 5a8887d39e1ba5ee2d4ccb94b14d6f2dce=
5ddfca:
>   sungem: Fix WakeOnLan
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master`
>=20
> Don Skidmore (1):
>   ixgbe: fix race condition with shutdown
>=20
> John Fastabend (1):
>   ixgbe: dcb: BIT_APP_UPCHG not set by ixgbe_copy_dcb_cfg()
>=20
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h        |    3 --
>  drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |   43 ++++++++++-------=
-----
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |    6 ++-
>  3 files changed, 24 insertions(+), 28 deletions(-)
>=20
> --
> 1.7.7.6
>=20

Dave-

Since you have not pulled this yet, I plan to send a v2 of this pull
request because I need to add 2 more patches to this pull request.  So
please disregard this pull request while I update my net tree.

Cheers,
Jeff

--=-7byvoE0Zhdooy52fqt8l
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPo7TzAAoJEOVv75VaS+3Oll8P/3mh4v1f+Afd2CdiHRGEt46m
7OtQSM9EnHUpW4U1i2EW2EFGsFGhcZiyn4tmDZviETnQyVg8iiBK2TGWfkn6qYRd
5mYRi4v8NKaERV/HQotPO2lEJK/+vBGXwHfd0bt2CIT+h5btHSjxgm+4j/1uUDzd
rVIQ3m6dlLlp+2EzuC0JZ0spt5gcmK4M2zITMO8u2kLuDoX0rAjprDNTHkGF3eiJ
BVYDm+Xr2eBStptibuVNRq5x85t3sATn50TGYgiDpAvw3LLbFAY3+21y+/N7HQyR
Y5zIT1bHOBpur5wi0rZ7sfR3Qs9f0lBQrSg/1rJ9axBJsxFnoZ27LWrGasPhoh8d
5D3pfa5rRkBqhetzP31zUPhAsNgTUrK/Z+jaT1mBBJrM1dqRm9VtNJePRcqlAvTF
HzIyba5L2Dnv+bhnfDW/JJ7cI21WtAg5HGhAR06TlE2XKbPULMg0qIY9aLgaSF7W
mVhhTtwWh9vF7p/yA4Is3+HtGaEmPHOQr5ELWcpTebI37iRddLmU0l6n9pxcsjCK
YDnHCYSovuV03GATTA/0SqbKfZgzZBe9141XQnFkuFZL0w3LOO5EJTeBqjOyuC2O
3n1fVNt5s6eztCzQdF3ba9mEOP558VwWpU71RDbBXPuIjqwTmK5DLD/EyYXGBfNA
Yc25C+zxQ6eeGVUnxiCj
=BWHH
-----END PGP SIGNATURE-----

--=-7byvoE0Zhdooy52fqt8l--
