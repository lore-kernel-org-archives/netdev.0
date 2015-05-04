From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth 2015-05-04
Date: Mon, 4 May 2015 12:21:54 +0300
Message-ID: <20150504092154.GA9096@t440s.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cNdxnHkX5QqsyA0e"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here are a couple of important Bluetooth & mac802154 fixes for 4.1:

 - mac802154 fix for crypto algorithm allocation failure checking
 - mac802154 wpan phy leak fix for error code path
 - Fix for not calling Bluetooth shutdown() if interface is not up

Let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 7f0b8a56c978b0a3315ac84c6cbb065413afb8e9:

  cxgb4: Fix MC1 memory offset calculation (2015-04-29 15:50:16 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git for-upstream

for you to fetch changes up to 89eb6d0677a6daf134015bc7bd5ec1432911eed2:

  mac802154: llsec: fix return value check in llsec_key_alloc() (2015-04-30 18:46:28 +0200)

----------------------------------------------------------------
Alexander Aring (1):
      mac802154: fix ieee802154_register_hw error handling

Gabriele Mazzotta (1):
      Bluetooth: Skip the shutdown routine if the interface is not up

Wei Yongjun (1):
      mac802154: llsec: fix return value check in llsec_key_alloc()

 net/bluetooth/hci_core.c | 3 ++-
 net/mac802154/llsec.c    | 4 ++--
 net/mac802154/main.c     | 4 +++-
 3 files changed, 7 insertions(+), 4 deletions(-)


--cNdxnHkX5QqsyA0e
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVRzoyAAoJECQj9vv5qNQSOwUP/jI54ySBOkTAfyjVSuPUlcmg
yCPv1mxYTK66detAheMiLZj/CRO1J4wssqK6o1bu5MFOBmqnWQSMoFvOoCnP5VGu
XeU+eQJhEa1qq3PVAtKGNrji6lgRHa3nCpEfri6twM0gBqUMMwTWIqH1JUhQYDY5
QIg4iTtwFupRlg0AA/PgfhG1T2X15y/pgvqx3KkFumUIJvJrr/z30jEgqM4Ap2ZW
VLsC4tMiX5TxvhQBbFkXkJ21L+zVGGTsKs71i4GY+esSh7LgfPogucncHaX4g6fy
z3gzfGW1JbMix0Gk/uh1fA0SNYH3DU9Mj6e4SfYCvyCgSqkKiEr0Xcb3YLMEe5Wt
ALu9j7+xFQaagLAc5NknjU3PdGcV6oCsFSPLPLXigGugHkmK9/O6jO5BHBOyMRuQ
nT6HMkmFMyaQO6HABd9oSCCHC0nB6kNs6i9l/ti2ucWtvueL4g7Ud1cTguFnGLSG
eMZ0oVXogV6G8N0jdpHH0tP3c+747D/+q07Pi/KrukZ60KYuBFVEuSH14JrCvGII
ELqujDpqZ8oReksRsctiG3I1JafeJ46kFENMriQvvZf6OsciCjT0lMYqUTbj+waR
zDUJjJTVqNw1GfyNb+YKiCvb85O3vhUKEGl4qpAEvfbJmI50ogDqmjD+RuIQuuc0
EbugTLNXUs6Cvvm+qhHy
=FnzA
-----END PGP SIGNATURE-----

--cNdxnHkX5QqsyA0e--
