From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] igb: mark igb_rxnfc_write_vlan_prio_filter() static
Date: Sun, 25 Sep 2016 15:23:37 -0700
Message-ID: <1474842217.2751.6.camel@intel.com>
References: <1474783558-7384-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-Pdu69Hhf/UPi1S0ApumI"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, xie.baoyou@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>,
        intel-wired-lan@lists.osuosl.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474783558-7384-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Pdu69Hhf/UPi1S0ApumI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2016-09-25 at 14:05 +0800, Baoyou Xie wrote:
> We get 1 warning when building kernel with W=3D1:
> drivers/net/ethernet/intel/igb/igb_ethtool.c:2707:5: warning: no previous
> prototype for 'igb_rxnfc_write_vlan_prio_filter' [-Wmissing-prototypes]
>=20
> In fact, this function is only used in the file in which it is
> declared and don't need a declaration, but can be made static.
> so this patch marks this function with 'static'.
>=20
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
> ---
> =C2=A0drivers/net/ethernet/intel/igb/igb_ethtool.c | 4 ++--
> =C2=A01 file changed, 2 insertions(+), 2 deletions(-)

This has been fixed as well, and there is already a patch.
--=-Pdu69Hhf/UPi1S0ApumI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJX6E5pAAoJEOVv75VaS+3O8/AP/iflysCZ8svD6aVwJuLB5BkH
a4zl24ZLaAGKldRCrey/ijALxRMcbm3vDYUqv54sk5r00dDE0fvcj50HpS4c/lao
rvNijqaIQk4ehs5q3M73MFXueER/j+c6MDATMr3A35XqcNONqlz9yA8nyu76vP61
7fPlQcEhHbIN4OO3GwEw7vauc1W/r/klsfyTShCwbOWll/UqimsSkTei+9kZ+Yf5
Wr88H5u/0bpQXwFLynquBZjSWMW0S5v8egzQoQI6HqZcsyn2lD2lhyptm7mNIAc/
iM+7kWM4ekO5RIPwtq+Dbbfoatq4r0bQq+6OCou/XrGsbm3csV6IaxVkoiOQxvau
XWX5e8iei/bIwB9hcexsx7nPjk+NwzeujtSIs5uremnISQ2TSqopj6cFxeT03Ydp
wNYns/o418Ssyswu7/BTzEhgkzT2aHAe4V8KFTnCgxmY59350rdgOIJRjWB6vCdR
T2HtzvHBO/lH+8uCPUufbLtuG/IQZknNZbHTKanuN7bNK6LwBFvzTAOqjtDOGhbE
hSuhjVLDdjfgmDyAQKmSaWgiiBb7tQzOTBXWB5beRFKnSO5qzHv3/kU9gfuYForz
ZaVhq9Lc1b/MQs06urR4BF3ZV03J4vLAbNO3DsJrrlIG3wmCVS+4VuvxBuxOjV/R
nxFt3bS7/2JkwYPlpOCR
=tyWT
-----END PGP SIGNATURE-----

--=-Pdu69Hhf/UPi1S0ApumI--
