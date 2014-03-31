From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the arm-soc tree
Date: Mon, 31 Mar 2014 13:24:57 +1100
Message-ID: <20140331132457.2d8d71019a52033bbef5b2c2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__31_Mar_2014_13_24_57_+1100_koNqZvvbLcL0O6vW"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Dinh Nguyen <dinguyen@altera.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Olof Johansson <olof@lixom.net>, Arnd Bergmann <arnd@arndb.de>,
	<linux-arm-kernel@lists.infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__31_Mar_2014_13_24_57_+1100_koNqZvvbLcL0O6vW
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
Documentation/devicetree/bindings/net/stmmac.txt between commit
50b4af414d41 ("dts: stmmac: Document the clocks property in the stmmac
base document") from the arm-soc tree and commit e8f08ee0ad86 ("DT: net:
document Ethernet bindings in one place") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc Documentation/devicetree/bindings/net/stmmac.txt
index 9a0c1b7bee29,5748351fb9df..000000000000
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@@ -31,13 -30,7 +30,11 @@@ Optional properties
  - resets: Should contain a phandle to the STMMAC reset signal, if any
  - reset-names: Should contain the reset signal name "stmmaceth", if a
  	reset phandle is given
- - max-frame-size:	Maximum Transfer Unit (IEEE defined MTU), rather
- 			than the maximum frame size.
+ - max-frame-size: See ethernet.txt file in the same directory
 +- clocks: If present, the first clock should be the GMAC main clock,
 +  further clocks may be specified in derived bindings.
 +- clocks-names: One name for each entry in the clocks property, the
 +  first one should be "stmmaceth".
 =20
  Examples:
 =20

--Signature=_Mon__31_Mar_2014_13_24_57_+1100_koNqZvvbLcL0O6vW
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTONH9AAoJEMDTa8Ir7ZwV9RsP+wVYaiWA18sy5ZqCQUKBXRzV
thf/oU5dc68Cgbtx9hPuL5Kd8YmFVGFEx5bYhuV6f849vbchQoxWXcbGkL1HHUts
g33WEapmAC46AkV5l4ir4VWxjsDtDAAFkfYXIgXqHfUX5T2SUMHo44H7WyJK7kjF
TQLKfjwFYeuWGDlfTL6Kea3Gfgm1tw0ghTCgE7a1AmBThyJ1Bwx8V93ga1VvUwLX
F1nExFTRgIYzo/tJ8xySz4JPPTt1YfR4Agg3Eprt+X1MTbvjG5o1D5BJ27Jq02Jb
o8qet+9EZN6on+cFOwq8phK8v0SwBCILLUKwn+xu1xagR/Ptkzjz08GqUwOIhUQD
jUVdlwRwViNLi3AH2rWE+mx0BH987BgNdj9GUleduq5dqL+K30jGyKlkS/OVsiaW
JIk0NZQIPpvHjE3KvcSsFLsKR4kIaB8HUx/QV3BYcUUkzOWM1rbYhyom0ZtWvNR/
5sZenr1F3509xVHOEIM7LJXIqcRpTPCD/jUz1cl83G8PH9UngOIr6yjFk5WyCg8h
uu2kWKffL3g/9llDBUARhJV6uWp8/ASae5bFXtN3LLB1I2g6pZOvilgvMkFbzkMv
OIvo5YyifmbzehAed9w3fFBDNEGq3afn5QDIA5rIdq0Q7IzY1yVqhw/u8qtSbqad
TmVN7XnoNhCUqsP9IxIl
=25pF
-----END PGP SIGNATURE-----

--Signature=_Mon__31_Mar_2014_13_24_57_+1100_koNqZvvbLcL0O6vW--
