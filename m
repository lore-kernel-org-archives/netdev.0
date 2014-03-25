From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 25 Mar 2014 12:58:35 +1100
Message-ID: <20140325125835.f3dc8f542b4d11394373718b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__25_Mar_2014_12_58_35_+1100_19fGEbkp3wXSpBUO"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nishanth Menon <nm@ti.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__25_Mar_2014_12_58_35_+1100_19fGEbkp3wXSpBUO
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
Documentation/devicetree/bindings/net/micrel-ks8851.txt between commit
ebf4ad955d3e ("net: micrel : ks8851-ml: add vdd-supply support") from
the  tree and commit e8f08ee0ad86 ("DT: net: document Ethernet bindings
in one place") from the net-next tree.

I fixed it up (maybe - see below) and can carry the fix as necessary (no
action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc Documentation/devicetree/bindings/net/micrel-ks8851.txt
index 4fc392763611,8e20c04a1da1..000000000000
--- a/Documentation/devicetree/bindings/net/micrel-ks8851.txt
+++ b/Documentation/devicetree/bindings/net/micrel-ks8851.txt
@@@ -4,7 -4,3 +4,6 @@@ Required properties
  - compatible =3D "micrel,ks8851-ml" of parallel interface
  - reg : 2 physical address and size of registers for data and command
  - interrupts : interrupt connection
 +
 +Optional properties:
- - local-mac-address : Ethernet mac address to use
 +- vdd-supply:	supply for Ethernet mac

--Signature=_Tue__25_Mar_2014_12_58_35_+1100_19fGEbkp3wXSpBUO
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTMOLUAAoJEMDTa8Ir7ZwVLkAP/jTGl+rW6nyN2FStqgtz2dIL
ZriBGMK9ZRZoaDDpsP2dCXQH2XA7tmuYIoRH6aLOd1M/oEfvWTu9OXBkQW/ANLWj
wCG/oveXB9jDtVGMjpCHIwS2zj54BMzrDeWrMNvc7JOiEdTMOFnQRhiIFjcA8BsL
X8ByqQHHU5rKcuzg3Yd7wobi5l6K9u297bQ51yVF13h7nWoiYysOySY19vvrLN3+
K5yt4PI6blYpjs/M+L3z9Zrj3vFRtmfMvTY58rKEnb6EcV4mHUCmaUsW8w15TRuy
puXJ4gvB41C+Uykcpcy4muQ/mt3q+WYmpbk6ws61P+XNSZL+F0zfJsTvSaFfgI3H
YeGXF/VYYsDCduBYJ71O+NSBMYhFwTkWaUGzcb82DEb1XjbyTgAJR2HA9cfnRryN
npOz+EKVdES3XNJ8F8Q2G8A1pR6TtaRUXnHE+zoKmAojRV+4Llftyp+N4hF1SI0H
puSEo/tKnRYUzdOT4ENFd6VOVPNjhef6Cu91m73LgOy/U5njDazGGYFw1yjoYp86
VK8dG8LUDksoAn40a6sp8WZuHYEjCmf9ixEP9LLlsRtKt0qDrJGcsDscS2PSgIpl
VgVydw4C+6T6uL1z4iM2+Sm1VQaSSOHUK1/nbxIJNsojvNsASaiGC6JIwmlRkjmw
LTLpw2dlwckPmOCYROrq
=L+Ts
-----END PGP SIGNATURE-----

--Signature=_Tue__25_Mar_2014_12_58_35_+1100_19fGEbkp3wXSpBUO--
