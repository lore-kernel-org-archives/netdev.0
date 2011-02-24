From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000: power off PHY after reset when interface is down
Date: Wed, 23 Feb 2011 16:02:45 -0800
Message-ID: <1298505765.25453.17.camel@jtkirshe-linux>
References: <1298424313-9840-1-git-send-email-prasanna.panchamukhi@riverbed.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-Rnz930OUXJjYFXFNO/G2"
Cc: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "prasanna.panchamukhi@riverbed.com"
	<prasanna.panchamukhi@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:28098 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754535Ab1BXACq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 19:02:46 -0500
In-Reply-To: <1298424313-9840-1-git-send-email-prasanna.panchamukhi@riverbed.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Rnz930OUXJjYFXFNO/G2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-02-22 at 17:25 -0800, prasanna.panchamukhi@riverbed.com
wrote:
> From: Prasanna S. Panchamukhi <prasanna.panchamukhi@riverbed.com>
>=20
> Some Phys supported by the e1000 driver do not remain powered off
> across
> a reset of the device when the interface is down, e.g. on 82546.
> This patch powers down (only when WoL is disabled) the PHY after reset
> if
> the interface is down and ethtool diagnostics are not currently
> running.
>=20
> Similar problem was see on 82571 controller and was fixed in e1000e
> driver
> by Bruce Allan.
> Please refer commit 31dbe5b4ac6fca72dec946e4d0fa7f0913f1d9b1 for
> details.
>=20
> Signed-off-by: Prasanna S. Panchamukhi
> <prasanna.panchamukhi@riverbed.com>
> ---
>  drivers/net/e1000/e1000_ethtool.c |   27 +++++++++++++++++++--------
>  drivers/net/e1000/e1000_main.c    |    7 +++++++
>  2 files changed, 26 insertions(+), 8 deletions(-)=20

Thanks Prasanna!  I have added the patch to my queue of e1000 patches.

--=-Rnz930OUXJjYFXFNO/G2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNZaAlAAoJECTsCADr/EWUqpwIAJcJgTTvEa/3vKjBAD+hmQOC
mklU+yB11zf6kSWmLfegk1Wylrhzti/JiYIgIWrg3NgEwygJ+QNKdE1vEDQGszEy
wl/yq98X48pqijsjPlTiEvQXFp9D3Z8IOU49wpMaoBXkZZVDYgWSCWi9fMzgIAae
nQNhLQFNfLXwdQX08QPfGadpT+btIx7aXVaOCwuyUKDXcw3VyCji0wYVH32Spnj2
el2yvL1JTI8v0Zvhzm/uxLnsbH+iSKo42fqTy2yHuS5o5zg133n04Kkk6Q9saPzI
zPAbmUhJk6AEjynK+qz1O/OJtL4sjhzcBu35dsb2TX3NbEDKaB2yrgJJcgAugzg=
=NjuD
-----END PGP SIGNATURE-----

--=-Rnz930OUXJjYFXFNO/G2--

