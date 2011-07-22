From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 00/10][pull request] Intel Wired LAN Driver Update
Date: Thu, 21 Jul 2011 21:31:16 -0700
Message-ID: <1311309077.2835.19.camel@jtkirshe-mobl>
References: <1311300078-12876-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110721.203921.500337781144914240.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-VteNcWVicQb4j0XwWanN"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46657 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751085Ab1GVEbT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2011 00:31:19 -0400
In-Reply-To: <20110721.203921.500337781144914240.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-VteNcWVicQb4j0XwWanN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-07-21 at 20:39 -0700, David Miller wrote:
> This breaks the build:
>=20
> drivers/net/ixgbe/ixgbe_main.c: In function =E2=80=98ixgbe_clean_rx_irq=
=E2=80=99:
> drivers/net/ixgbe/ixgbe_main.c:1458:3: error: implicit declaration of fun=
ction =E2=80=98xgbe_rx_is_fcoe=E2=80=99 [-Werror=3Dimplicit-function-declar=
ation]
>=20
> The only function with a similar name is ixgbe_rx_is_fcoe().
>=20
> I can't see how this was build tested.

This was my fault, while reviewing the patches to send, I accidentally
deleted the "i" in ixgbe_rx_is_fcoe().  This was after I did my compile
testing.


--=-VteNcWVicQb4j0XwWanN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOKP0UAAoJECTsCADr/EWU6u0H/RUaeBZcLUBXuCIlG4LRlJVW
+ryBNKM+S2ijR+WqGtSVxXgoyhbKPZQyp9oQ+5at2Y+BF0kNkfJcL2/DIRuhTMMm
36ncLRDaaMDGzMEWwvuemv8yqyR3SMNd9ELGKDtP6OTepcUwJmDvC/tV70BmOxuq
b+1F8Num4ZCPU5r3LKtVtE22a446Xv5eptRXzCQcmVJviPMyag7axW3bfbxaVoFN
PC8qUKGQCOZXAvIi3iPJj+LKn7bVY5CggTnaPWeiFJu9MCDGSy4VCxdYM5BVPrMu
0i0WH6Wlk5Z/eam9aqttw5i4uyCBS8VP7x7zLtsNKiCkCbrq5cD2pB2vfn40xtw=
=orpB
-----END PGP SIGNATURE-----

--=-VteNcWVicQb4j0XwWanN--

