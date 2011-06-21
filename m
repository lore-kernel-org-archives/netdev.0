From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 04/17] ixgbevf: provide 64 bit statistics
Date: Tue, 21 Jun 2011 13:50:33 -0700
Message-ID: <1308689433.22851.55.camel@jtkirshe-mobl>
References: <1308531518-17298-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1308531518-17298-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1308545992.3539.114.camel@edumazet-laptop>
	 <1308572991.22851.50.camel@jtkirshe-mobl>
	 <1308584788.26922.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-yFtt4B8l6NtvVqC6Vy7z"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53352 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756830Ab1FUUue (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 16:50:34 -0400
In-Reply-To: <1308584788.26922.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-yFtt4B8l6NtvVqC6Vy7z
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-06-20 at 08:46 -0700, Eric Dumazet wrote:
> Le lundi 20 juin 2011 =C3=A0 05:29 -0700, Jeff Kirsher a =C3=A9crit :
>=20
> > I will drop Stephen's patch from this series and look forward to
> your
> > fixes.  Thanks Eric.
> >=20
> >=20
>=20
> Here is an updated patch :
>=20
> [PATCH net-next] ixgbevf: provide 64 bit statistics
>=20
> Compute statistics per ring using 64 bits, and provide
> network device stats in 64 bits.
>=20
> It should make this driver multiqueue operations faster (no more cache
> line ping pongs on netdev->stats structure)
>=20
> Use u64_stats_sync infrastructure so that its safe on 32bit arches as
> well.
>=20
> Based on a prior patch from Stephen Hemminger
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Stephen Hemminger <shemminger@vyatta.com>=20

Thanks Eric, I have added the patch to my queue.

--=-yFtt4B8l6NtvVqC6Vy7z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOAQQZAAoJECTsCADr/EWUpagIAKS0Z6NRXBg5UdI+lZ6IYtjt
qMgmthPt1UN7TeM43AU9pyZ5idNe4yYgl4AAxPzBOGozpMRqH6DcxaMDs39Vvh7p
Ucmm+ukJ/nFzfp9kw7BTWcS5P1ApvgNNwZXGh1WG7Qvq1BMQVlZv5DH3NbWYOxMD
wcIP7z2vH96UUs0mv3C06mULX6qwMJzFqgSmsXcPDrsO6110cZyo8zqY/m6JwYv9
TjaCDFebNX9J1V1qMMjXhdJ021QJbqYIy5XuLwC3rNb35W6FGx/13qlWdX1etGTF
HrvvvLDo+fMlsbfb2uZ7aTN2B0uXjf+V4sZohZ5iEnPTA2hX+BvHR9ntGiKY1IU=
=8RcU
-----END PGP SIGNATURE-----

--=-yFtt4B8l6NtvVqC6Vy7z--

