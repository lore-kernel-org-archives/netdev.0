From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the tiny tree with the net-next tree
Date: Mon, 17 Nov 2014 16:35:03 +1100
Message-ID: <20141117163503.6543cd21@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/=opbwh43E4VXRfXcWrR.9.O"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Iulia Manda <iulia.manda21@gmail.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: Josh Triplett <josh@joshtriplett.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/=opbwh43E4VXRfXcWrR.9.O
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Josh,

Today's linux-next merge of the tiny tree got a conflict in
net/openvswitch/Kconfig between commit 8cd4313aa775 ("openvswitch: Fix
build failure") from the net-next tree and commit b043d487e255 ("lib:
Conditionally compile flex_array") from the tiny tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/openvswitch/Kconfig
index b7d818c59423,1d979cecd66e..000000000000
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@@ -4,9 -4,8 +4,10 @@@
 =20
  config OPENVSWITCH
  	tristate "Open vSwitch"
 +	depends on INET
  	select LIBCRC32C
 +	select NET_MPLS_GSO
+ 	select FLEX_ARRAY
  	---help---
  	  Open vSwitch is a multilayer Ethernet switch targeted at virtualized
  	  environments.  In addition to supporting a variety of features

--Sig_/=opbwh43E4VXRfXcWrR.9.O
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUaYkMAAoJEMDTa8Ir7ZwV3KsP+wfcHz8/VAXm2NvJOQWtueMF
M816cN6KUtpXVGhYvr+ou/KS5nXpYARkshfmvKDI4X9Flq1EbkMtlltbqtCBUd6v
4NvWrxjv0sCIyc3loCa26Du40Oft4QlpOTiu+AABspOSOk0sWf3gviK0cPajYSFV
7NW0UEwmuCnkwz7WQTK2f1e9bUawI3lmXnT/wHPz9OV5vqIPbwmN5MinyI8lNOuW
QMOqhCf3tQlbwniKCxnrwCSWij32SVSrl81stz4+9eZJIJ+v7DK5G3bB6Ol2eSQf
HxmGNWqRHqGmzzxrfw5HaqJjheRJ9x0irGrUtCP1imFvBBGNyNP7NRiyUuB21X1J
rNm9KXUERSfVLEBVAgJGPMsiHByn43RCMwIyqNApU4cw1V9r9bhNgMcUkzvAbaG0
HMf7seuhlI9aQEQnXteivuRqizFPaEr6I4jktiOnvKzEV7Pix7Aijb6qAM5k7P1i
S3wZjBFly+Cc41gBZDecrwFnBTOpl/SA+gb4bbG9JcOreFn3ehqltNXLhI3lt4vp
asbjF1dO86poiGsQh+YkiRM0E0SunR2YF1PIxh8JmjpcUezU0fvFwmLawQqpDPn5
AmM4diskEeR/0AGiz9N1uGaTBdIafgd1eF96n3O2+dLN+VBja0slh6uexM2CKgnX
UwTBujbkcEErjzPo+Jx/
=4LfU
-----END PGP SIGNATURE-----

--Sig_/=opbwh43E4VXRfXcWrR.9.O--
