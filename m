From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth 2016-10-08
Date: Sat, 8 Oct 2016 14:29:14 +0300
Message-ID: <20161008112914.GA10187@x1c.P-661HNU-F1>
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

Here are a couple of Bluetooth fixes for the 4.9 kernel:

 - Firmware download fix for Atheros controllers
 - Fixes to the content of LE scan response
 - New USB ID for a Marvell chipset

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit af70c1f92d3567035d2f73f39079459d58c706dc:

  phy: micrel.c: Enable ksz9031 energy-detect power-down mode (2016-10-05 2=
1:19:06 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git for=
-upstream

for you to fetch changes up to c7e163fe282f34efdf77fb09b333529de97a6a10:

  Bluetooth: btusb: Fix atheros firmware download error (2016-10-07 09:46:5=
6 +0200)

----------------------------------------------------------------
Amitkumar Karwar (1):
      Bluetooth: btusb: add entry for Marvell 8997 chipset

Ethan Hsieh (1):
      Bluetooth: btusb: Fix atheros firmware download error

Micha=C5=82 Narajowski (3):
      Bluetooth: Fix local name in scan rsp
      Bluetooth: Add appearance to default scan rsp data
      Bluetooth: Refactor append name and appearance

 drivers/bluetooth/btusb.c   |  9 ++--
 net/bluetooth/hci_request.c | 66 +++++++++++++++---------
 net/bluetooth/hci_request.h | 23 +++++++++
 net/bluetooth/mgmt.c        | 21 --------
 4 files changed, 70 insertions(+), 49 deletions(-)

--2fHTh5uZTiUOsy+g
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJX+NiJAAoJECQj9vv5qNQSFy8P/0jvTkyxZCnYaBJ4ZIQ/DIAU
BjOd5xeB8mhIZZ6oEZk1svVCvZgVhcEtTjLwfQKa3ZdLMGY6lxgeg2SsMa1IzxkD
569XLcLuDyOoE2CjZ7pdJfQsOqO9P4PTqEOe5LxQ9vxHRZHmA+WWC6mn6Ly7Fm2J
AhGw+xIhf7+SPWPxwQ6PvNdZT+/jz1+fyFFe5WXvBiISh7mBPsZLjkjn8GtgbHTm
79gnz0o+7Rhr9gL2jorBfHTbhmDJaLpVkHSUhqQ1QlPE/J4TcTbOstqsLLKDa5xB
LVw7nQu2hAstx6wpG4qyr1HiYIoxyutNUBh+6l7d195fRG+iAdqVeLGpN49FHZZu
2AdmtiF9/ybso4K53mtmvP3RVpNETyO2s44Z9lVJhSV1O+Bf2gdApUwo7V2HCIDy
04uOl1F4Iqm0dsa80kEMsGaJWnsA+FBgHn5T42z6tEMS3H3oKzkSMmj0I/HaiCsl
OnJDA5SIhefvoPCuLIaCRXp4t9f6ONnK7J0Ty64L5n2l1q/3fC4j1sv3tv2xjiMT
ZFvxHRY3j+08395QODmnOb+g9eyc7OmQihe8d5gP+a+5Y6HBKiUu1ckGEhqUj8Sq
Fm1J/kQzBVocvtyHXdZGIJ/yK7EL+iE2eoJMwTSUC/3A6NDHkRbJVJL9/QktWKNy
Xtr9B5I9v9OqTykulo5+
=U/JD
-----END PGP SIGNATURE-----

--2fHTh5uZTiUOsy+g--
