From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the arm-soc tree
Date: Tue, 27 Jan 2015 13:04:37 +1100
Message-ID: <20150127130437.3cd05af9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/cAKF/xMDWBelX7fDnaj._Mk"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Roger Chen <roger.chen@rock-chips.com>,
	Chris Zhong <zyw@rock-chips.com>,
	Heiko Stuebner <heiko@sntech.de>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Olof Johansson <olof@lixom.net>, Arnd Bergmann <arnd@arndb.de>,
	<linux-arm-kernel@lists.infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/cAKF/xMDWBelX7fDnaj._Mk
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
arch/arm/boot/dts/rk3288.dtsi between commit eecfe981cecd ("ARM: dts:
rockchip: add RK3288 suspend support") from the arm-soc tree and commit
3d3fb74afc9b ("ARM: dts: rockchip: add gmac info for rk3288") from the
net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc arch/arm/boot/dts/rk3288.dtsi
index 2a878a35facc,910dcad2088a..000000000000
--- a/arch/arm/boot/dts/rk3288.dtsi
+++ b/arch/arm/boot/dts/rk3288.dtsi
@@@ -734,24 -741,11 +750,29 @@@
  			bias-disable;
  		};
 =20
+ 		pcfg_pull_none_12ma: pcfg-pull-none-12ma {
+ 			bias-disable;
+ 			drive-strength =3D <12>;
+ 		};
+=20
 +		sleep {
 +			global_pwroff: global-pwroff {
 +				rockchip,pins =3D <0 0 RK_FUNC_1 &pcfg_pull_none>;
 +			};
 +
 +			ddrio_pwroff: ddrio-pwroff {
 +				rockchip,pins =3D <0 1 RK_FUNC_1 &pcfg_pull_none>;
 +			};
 +
 +			ddr0_retention: ddr0-retention {
 +				rockchip,pins =3D <0 2 RK_FUNC_1 &pcfg_pull_up>;
 +			};
 +
 +			ddr1_retention: ddr1-retention {
 +				rockchip,pins =3D <0 3 RK_FUNC_1 &pcfg_pull_up>;
 +			};
 +		};
 +
  		i2c0 {
  			i2c0_xfer: i2c0-xfer {
  				rockchip,pins =3D <0 15 RK_FUNC_1 &pcfg_pull_none>,

--Sig_/cAKF/xMDWBelX7fDnaj._Mk
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUxvI6AAoJEMDTa8Ir7ZwVbSgP/idOy0pPtJCcga1mktJsnQiX
64W4nSTB0aHLwVgCtoo1zSkbtyKYCSKv5ePObrdz9MIhYBK9gZLsKf2XpOLU2fCS
Pheqwx8i4p8f6G3qr/Z+EM4kxHln4HDSIfWLZw26GzVx2OZXAHIhBr7v19/9Z3yj
d10qhfwB9V3/GpRqmlKKyDPUCofF2vFtfW3jGYTIi+UsuR1D96LIL/x5Qh9Ii6QT
bE5ZIG535YWCZB5Q46KuuU15G7tYBpxRlUT67LXTRLkctvfLr/EmyjoxHvSanNM2
BpKAgZi2OWHPySKj862uDVsZFNG5wc1jnv9EWUddidDK2zE8LEsBPrly7lA3txnP
3wb0yI9JmtjwrROp/vwOlHvSsUVxTY0NK4SEqB/02oJVtHGKpIFpTvx7V4/bJEW0
rpOfHSibBPuvAlueXm58y5pVJmbRFHxTW/QvYf/wr57rftyVUf/kRnHuevqghabu
Z+XuykDLKZgDDAN+O2G32pOnTFDx6BBg0krBHKC+KgHsFE4X71tCg2411/1hpWe4
UJucsNUSTlSW+Rm+4iIJ2p1+Ta5awMJ1VGwBR3wLeiaTUSRmSmdPGzOp9lfebx2C
pei6L+iT18rX+IleMmqeSK6MFw0ERT5Fg7RYY7mvgHq+pzfs3H7VtbuuGqiGi7Yb
Pakx2ScBTDffpLmXMXk2
=T0OE
-----END PGP SIGNATURE-----

--Sig_/cAKF/xMDWBelX7fDnaj._Mk--
