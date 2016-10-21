From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth 2016-10-21
Date: Fri, 21 Oct 2016 17:40:53 +0300
Message-ID: <20161021144053.GA14245@x1c.dominarus.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="2fHTh5uZTiUOsy+g"
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

Here are some more Bluetooth fixes for the 4.9 kernel:

 - Fix to btwilink driver probe function return value
 - Power management fix to hci_bcm
 - Fix to encoding name in scan response data

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 6d3a4c404648e415e7d96e285d723936d4df7ed0:

  strparser: Propagate correct error code in strp_recv() (2016-10-12 01:51:=
49 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git for=
-upstream

for you to fetch changes up to 6add49fff9233a5c43011eb42b521257cbaa9bda:

  Bluetooth: btwilink: Fix probe return value (2016-10-20 10:14:49 +0200)

----------------------------------------------------------------
Jacob Siverskog (1):
      Bluetooth: btwilink: Fix probe return value

J=C3=A9r=C3=B4me de Bretagne (1):
      Bluetooth: hci_bcm: Fix autosuspend PM for Lenovo ThinkPad 8

Micha=C5=82 Narajowski (1):
      Bluetooth: Fix append max 11 bytes of name to scan rsp data

 drivers/bluetooth/btwilink.c |  2 +-
 drivers/bluetooth/hci_bcm.c  |  8 +++++
 net/bluetooth/hci_request.c  | 49 +++++++++++++--------------
 net/bluetooth/hci_request.h  |  2 ++
 net/bluetooth/mgmt.c         | 26 +++++++++-----
 5 files changed, 51 insertions(+), 36 deletions(-)

--2fHTh5uZTiUOsy+g
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJYCij1AAoJECQj9vv5qNQSAbcP/3GRNUaB+O535KBd8dbpH7TL
ZT2qgPktzS0d6ND3hvGJKT6xsq+ZOJHcIu1jQq2oa/igSPf4q8YFzal186dwABFr
ey61FC7DsaAMhHzuyYfcGQgfhTztu3lMOYsqCiRroZrUC0Ohg8Rc+y1F+CnDaSq5
FC23Dwpo+4ApDdrAr2pffMt41YR8ZLsV9WVTDprl+sxBDBa2DwDqRVyka44d7Vbf
UQ2hZU0VluFuCDhIQh+pJrf5cXvirzXOr/xycJkNZTweayrnB6g3Z799wdppp5NV
ThO62r+dd6CKvCUXdNx9UKM1lVmsGvpyiOCzjIdPBeqwrCQYp3M8EyK8POAKGlRk
op6UCI9xaD33D7Ch7d7fsJmjAJVpqkCv+M5/2GfEb4pt9LQu1eoPUguVWKDG/6mn
f1olJoJ77bBEkKHSkFKFsLRKT4omcZ6sILYr6armStgHrbBrIT55AMXyWKc5xFpC
s4ap86PM+otnUI6KuXTEDyXXwd5kBq1yCpZ3ruk5Jayu8OtKQxjY9vp1N5vx5VA0
L/IVTEuz3Xj8xPJKj7Q9QLJpoSahr/zVGNnS3Ht3PwDk/3YxIOWgbiKIQvqmw3aU
KV8m/s4aHOroa8vCdOySTGDlSU0qKdtqEHUlPgCAk2Q9u26UNLf1l77l6jEY0e/0
2Cv0UWVSN6nf8N28FXUA
=1VCX
-----END PGP SIGNATURE-----

--2fHTh5uZTiUOsy+g--
