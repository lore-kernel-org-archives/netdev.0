From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/3] e1000e: e1000e_cyclecounter_read(): incvalue is 32
 bits, not 64
Date: Tue, 19 Apr 2016 13:57:14 -0700
Message-ID: <1461099434.2923.6.camel@intel.com>
References: <1461069286-31946-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-XEdlnNZGkuDI70ZjBCvU"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Denys Vlasenko <dvlasenk@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59528 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932091AbcDSU5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2016 16:57:16 -0400
In-Reply-To: <1461069286-31946-1-git-send-email-dvlasenk@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-XEdlnNZGkuDI70ZjBCvU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-04-19 at 14:34 +0200, Denys Vlasenko wrote:
> "incvalue" variable holds a result of "er32(TIMINCA) &
> E1000_TIMINCA_INCVALUE_MASK"
> and used in "do_div(temp, incvalue)" as a divisor.
>=20
> Thus, "u64 incvalue" declaration is probably a mistake.
> Even though it seems to be a harmless one, let's fix it.
>=20
> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: Shannon Nelson <shannon.nelson@intel.com>
> CC: Carolyn Wyborny <carolyn.wyborny@intel.com>
> CC: Don Skidmore <donald.c.skidmore@intel.com>
> CC: Bruce Allan <bruce.w.allan@intel.com>
> CC: John Ronciak <john.ronciak@intel.com>
> CC: Mitch Williams <mitch.a.williams@intel.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: LKML <linux-kernel@vger.kernel.org>
> CC: netdev@vger.kernel.org
> ---
> =C2=A0drivers/net/ethernet/intel/e1000e/netdev.c | 3 ++-
> =C2=A01 file changed, 2 insertions(+), 1 deletion(-)

First of all, trimmed down the recipient list since almost all of the
reviewers you added have nothing to do with e1000e.

Any chance you can send this to the "correct" list intel-wired-
lan@lists.osuosl.org? =C2=A0Kind of amazing that your shotgun blast approac=
h
in emailing out the patch series managed to miss sending it to the one
email list that handles Intel Wired LAN kernel patches.
--=-XEdlnNZGkuDI70ZjBCvU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXFpuqAAoJEOVv75VaS+3OdUYP/1e32625WF2nvKKMUCEdF7aB
pBH0Yq4IDERUk9bM7/Se0ht+ZoKxtaRhFz8XMr7FTc6tTpDYRMv2kLBhEvTrRyjN
qt9/zc4a5FPkJbNgMhyBNtrGmEj0ZPDh4w4kqQGz6F5Pse8bVsl/oDDcE5F4grj/
QuW0A3Yn0q7eON0dlxGuRK39VNM71TZWrmeyAXI3fvKVvIbZz98OxCJddDx8aOFu
GYRJLQRHQV2BOMdf9EsOCS6rWaeM/K/ALbSAfQcsh9JWGoyddZxL6NVBy34BgBME
Nwnj8gk8lt7Smy56XkbhCm/TnzNyQS8mlHHY+wsAcCm683cxOHNitaFYcs9iayKt
OnWyZ9j8e/vdix9vWrRFm5UXMAy6AjSIlTt7XYEy92YFMI6qc98a0XbGj7KysRqK
PkBSGQw/0lAAitKVpHZycYi0WMzebWIT6xkdWXad8XpARYlO5bLHp/rcX3w5F6tu
dW8gSeYWis0vFKL0P7t/l5zSnme3MjRVd3nGEfhkRlDo8j1kUJrZTgcXDU+9PSiA
W64neFDa4kv/lGXXY7r7y7lSgIK83FjGyK/NWphuDkmLo5DD9jCV9rYnuBZPM2h2
ASN6RWESWGb0NIE9Npa+bOpZB1Cx6tYUki7AmYb0ZdWhvTvBTeRUCVs1h+1bOoNJ
qvyr5K1MNY53b5thCZQG
=7fS+
-----END PGP SIGNATURE-----

--=-XEdlnNZGkuDI70ZjBCvU--
