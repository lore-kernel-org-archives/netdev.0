From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2] igb: fix rtnl race in PM resume path
Date: Thu, 05 Apr 2012 16:02:42 -0700
Message-ID: <1333666962.2567.18.camel@jtkirshe-mobl>
References: <1333638664-17062-1-git-send-email-bpoirier@suse.de>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-jdn7DrY/BTWNCgZuvLsZ"
Cc: Alex Duyck <alexander.h.duyck@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50854 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751431Ab2DEXCq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2012 19:02:46 -0400
In-Reply-To: <1333638664-17062-1-git-send-email-bpoirier@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-jdn7DrY/BTWNCgZuvLsZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-04-05 at 11:11 -0400, Benjamin Poirier wrote:
> Since the caller (PM resume code) is not the one holding rtnl, when
> taking the
> 'else' branch rtnl may be released at any moment, thereby defeating
> the whole
> purpose of this code block.
>=20
> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c |   20 ++++++--------------
>  1 files changed, 6 insertions(+), 14 deletions(-)=20

Thanks Benjamin, I will add the patch to my igb queue of patches.

--=-jdn7DrY/BTWNCgZuvLsZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPfiSSAAoJEOVv75VaS+3Ozv4P/25134S/5/yCRlnheOE0VRJo
ercJHQgQP3lCbLLjFlauScZfg+LyAUtwaB5WF2Yb8rSzkWof7jiVFKoO/XKsotba
GfPIdOoDy9b9VgviXTa0AkJXv9tWVjCnL81BkltzKH/OWFNEhDQjbX7IzkdDL/bd
VuEVxrzI3majvqCawIu/lkdqD58I9Oh4G6bOMtOJ92H7hDhgdjwH1OYSJzaw/AOL
g6NdTsbIUI+cRaMwOy04JaXhiVue/nYr2VqFolWFI3LgDlbAOLcI7Y9N1JF9R3IS
R4K4vdwoRcV2yu0RPg7cEaFmSCr/BUtr3Xyfw4+kB3XR//P7kKY2tvZsH2uKIpm/
pO4i/JntmTQlLKqow5KD8Cj0q+AvFy5DmkWsQuBhtvrIOu/5HM4uZ1kEX2sbOfkW
OuSA/d9OOGDaLKqlzejnxo2LOu3/DN8mYZdhg+CT7f9uKfcRXwRRidYLcO/UgSog
Q/bosYWgBMol3hYX8BISl6PoGkfSBZp9MzpGtRCgNjF2ZRHgl6bsEMMQfUSdEymw
5gG2DzBXGhv6JCdeogVJeaiM3HESZNZim8dnop+l++2CqEvZrMKhDv0EaHu54F3g
S136++M2pq5B4SA+Ubi8H/GIraKWZUj32FcOzaJYGEumqQIop74iaO8cg8cuNd59
bdAPmNhEWagnI4EW/nsx
=V5s4
-----END PGP SIGNATURE-----

--=-jdn7DrY/BTWNCgZuvLsZ--
