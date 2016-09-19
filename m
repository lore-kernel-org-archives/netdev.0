From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] igb: mark igb_rxnfc_write_vlan_prio_filter() static
Date: Mon, 19 Sep 2016 15:16:08 -0700
Message-ID: <1474323368.28223.49.camel@intel.com>
References: <1474188628-420-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-OhqwHPJ9GQu93tEzU3nn"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, xie.baoyou@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>,
        intel-wired-lan@lists.osuosl.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474188628-420-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-OhqwHPJ9GQu93tEzU3nn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2016-09-18 at 16:50 +0800, Baoyou Xie wrote:
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

Already fixed, see=C2=A0http://patchwork.ozlabs.org/patch/661904/
--=-OhqwHPJ9GQu93tEzU3nn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJX4GOoAAoJEOVv75VaS+3OEoAP/AuryXUu9nGf4XK8kkjQt6hB
/CxNWClaxiZJ0gnYUjcGy86ivs5muP+8aMrgaPyCcbrLzPE2XGTF2mmye2pGzf9X
nWYbEKcInWk5vLtuwVVAS4unHw2naWWOpEnope5109792Wm+pTWfXwJMirOOMSD6
plsTMlLjFyJQxA1GQEi4YIjaLdqmdNetdIPJl0hpHP6C0+DVQFt1umn5URO0Lxzv
j12Nj5MUjse07S0ZyOlKs9cCBido5orFh8uPU98sAZJEAiJ0ftUsrAzuPtxi672j
Hlg8NMVQrs9QNpwow4P8ru9SCj9LO38DieBn5pd7Yqp9MYNShVozCzjK6QY9JVsr
RLL5rP0j+m8ZwWYEspiVdespz72JyDOzwu6VIyUJ6Zfh4j5OU7a6G7ZYa3NOwIus
WltBc0ekNW/HLK+vY4kAKamC/z02+wMcJwMbIMNcwqFDE71dg3e8zTVu6Gx3Gzrc
ArgLxbbvIm04ZDqLpZhRn20fK7p2/JP3AT7bVCFXrR93EJbC4zqmQ8HIWWbsm6JV
cNtEkpL0PqVAdLa85MsGBEVTm7qnHqnKkXpj0pnBxxIn09mNIdKAkUXtkQlE1Rbd
LwUaD/OTSMQrL3Zu5eFgGo4nkeoLMbTfiGF/5+yiz/om5CvtzffQooNrFg893iHR
Fl9tLEODMcteYYnP89VF
=Bblu
-----END PGP SIGNATURE-----

--=-OhqwHPJ9GQu93tEzU3nn--
