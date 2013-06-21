From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the arm-soc tree with the net-next tree
Date: Fri, 21 Jun 2013 15:58:46 +1000
Message-ID: <20130621155846.71c2d64923a1e505c08eca72@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__21_Jun_2013_15_58_46_+1000_65_mf/mprHFJC7Ku"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Olof Johansson <olof@lixom.net>, Arnd Bergmann <arnd@arndb.de>,
	<linux-arm-kernel@lists.infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__21_Jun_2013_15_58_46_+1000_65_mf/mprHFJC7Ku
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the arm-soc tree got a conflict in
arch/arm/boot/dts/sun4i-a10.dtsi between commit b21da664120b ("ARM:
sun4i: Add muxing options for the ethernet controller") from the net-next
tree and commit 27cce4ff34ec ("ARM: sun4i: dt: Add i2c muxing options")
from the arm-soc tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc arch/arm/boot/dts/sun4i-a10.dtsi
index 983da33,82e03d2..0000000
--- a/arch/arm/boot/dts/sun4i-a10.dtsi
+++ b/arch/arm/boot/dts/sun4i-a10.dtsi
@@@ -214,18 -204,28 +220,39 @@@
  				allwinner,function =3D "uart1";
  				allwinner,drive =3D <0>;
  				allwinner,pull =3D <0>;
 +			};
 +
 +			emac_pins_a: emac0@0 {
 +				allwinner,pins =3D "PA0", "PA1", "PA2",
 +						"PA3", "PA4", "PA5", "PA6",
 +						"PA7", "PA8", "PA9", "PA10",
 +						"PA11", "PA12", "PA13", "PA14",
 +						"PA15", "PA16";
 +				allwinner,function =3D "emac";
 +				allwinner,drive =3D <0>;
 +				allwinner,pull =3D <0>;
  			};
+=20
+ 			i2c0_pins_a: i2c0@0 {
+ 				allwinner,pins =3D "PB0", "PB1";
+ 				allwinner,function =3D "i2c0";
+ 				allwinner,drive =3D <0>;
+ 				allwinner,pull =3D <0>;
+ 			};
+=20
+ 			i2c1_pins_a: i2c1@0 {
+ 				allwinner,pins =3D "PB18", "PB19";
+ 				allwinner,function =3D "i2c1";
+ 				allwinner,drive =3D <0>;
+ 				allwinner,pull =3D <0>;
+ 			};
+=20
+ 			i2c2_pins_a: i2c2@0 {
+ 				allwinner,pins =3D "PB20", "PB21";
+ 				allwinner,function =3D "i2c2";
+ 				allwinner,drive =3D <0>;
+ 				allwinner,pull =3D <0>;
+ 			};
  		};
 =20
  		timer@01c20c00 {

--Signature=_Fri__21_Jun_2013_15_58_46_+1000_65_mf/mprHFJC7Ku
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRw+uWAAoJEECxmPOUX5FEqcYP/irkP7oOLg8wONVfwBEwuH2D
ZSxYvoKWgtG+VhtQTJOoYBVsJeTSPTtvhdebANRL5rF81728RXm3eE/bBon9cU4l
epw5gEFfYDOpACGudp9zUuV6zCC9gzY/jNNpr2zvPLhsd5UBtU3mCLZM6kf8WNZ4
nQYapo46oNqmoWAmNVP2R8fjugs3P5wwkUseBjm60bWE4Qp921g6S+CDyuKrgKjO
cWF+Q7LR2f+yxe3nfPmFPZZqy2qVDJmArlKqhuYpaY6EnV5WV+rV0+J/K8P58I/L
vge41V+h1p32S+WwQjTQdqb6HvhejSLRs1g4vyGgmYCZkjsp5MPwAKuaypAC4nSH
NKDbdEMXjlZCvZ5RQ4V4BYVHlLv+rSzg3cm4R3D8V1LAm9xTTrX9k6pobRPUee5Y
Kx1DbKyrvbD+kLEuwg/hH4/RrpB87s1+VZUPthbIcicr2TfMNBHnSwvH1hj6+tnp
Ld51/wUkuXDJZsVf4/uXl8jDObPiCZ8qaSzn4cv0VOQ4xbpbuj9u1N+jJSPR6lwn
vG8RIgeBnfkc5Eg9UIG1y3fHMeP9DBwemBLLHrvww8+5NTWcJs2tH91FzIIIRb0R
EEEJ/eo+fJH+r8h/pCojc9YfHipZJgjXlvJfcNFNbVMtcMUAvsgdmJ68XrJV+b65
5aj/b0jkiKenB+Z4MipK
=eh/C
-----END PGP SIGNATURE-----

--Signature=_Fri__21_Jun_2013_15_58_46_+1000_65_mf/mprHFJC7Ku--
