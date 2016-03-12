From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth-next 2016-03-12
Date: Sat, 12 Mar 2016 08:39:34 +0200
Message-ID: <20160312063934.GA21940@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="RnlQjJ0d97Da+TV1"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--RnlQjJ0d97Da+TV1
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

Here's the last bluetooth-next pull request for the 4.6 kernel.

 - New USB ID for AR3012 in btusb
 - New BCM2E55 ACPI ID
 - Buffer overflow fix for the Add Advertising command
 - Support for a new Bluetooth LE limited privacy mode
 - Fix for firmware activation in btmrvl_sdio
 - Cleanups to mac802154 & 6lowpan code

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 798fee48035f0c5fc6787767ff9e27de7e1a4fbb:

  Merge tag 'linux-can-next-for-4.6-20160310' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/mkl/linux-can-next (2016-03-10 12:41:33 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.gi=
t for-upstream

for you to fetch changes up to 6a0e78072c2ae7b20b14e0249d8108441ea928d2:

  Bluetooth: Fix potential buffer overflow with Add Advertising (2016-03-11=
 16:28:43 +0100)

----------------------------------------------------------------
Alexander Aring (3):
      mac802154: use put and get unaligned functions
      6lowpan: debugfs: add missing static
      6lowpan: iphc: fix SAM/DAM bit comment

Dmitry Tunin (1):
      Bluetooth: btusb: Add a new AR3012 ID 13d3:3472

Johan Hedberg (6):
      Bluetooth: Move memset closer to where it's needed
      Bluetooth: Fix adding discoverable to adv instance flags
      Bluetooth: Add support for limited privacy mode
      Bluetooth: Increment management interface revision
      Bluetooth: Fix setting correct flags in AD
      Bluetooth: Fix potential buffer overflow with Add Advertising

J=E9r=F4me de Bretagne (1):
      Bluetooth: hci_bcm: Add BCM2E55 ACPI ID used in Lenovo ThinkPad Table=
t 8

Wei-Ning Huang (1):
      Bluetooth: btmrvl_sdio: fix firmware activation failure

 drivers/bluetooth/ath3k.c       |  2 ++
 drivers/bluetooth/btmrvl_sdio.c |  2 +-
 drivers/bluetooth/btusb.c       |  1 +
 drivers/bluetooth/hci_bcm.c     |  1 +
 include/net/bluetooth/hci.h     |  1 +
 include/net/mac802154.h         | 10 +++----
 net/6lowpan/debugfs.c           |  4 +--
 net/6lowpan/iphc.c              |  4 +--
 net/bluetooth/hci_conn.c        | 17 +++++++++---
 net/bluetooth/hci_request.c     | 56 +++++++++++++++++++++++++++++++++++--=
---
 net/bluetooth/hci_request.h     |  2 +-
 net/bluetooth/mgmt.c            | 26 ++++++++++++++++---
 12 files changed, 102 insertions(+), 24 deletions(-)

--RnlQjJ0d97Da+TV1
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJW47mmAAoJECQj9vv5qNQSeB0P/RzjaBzgkTEfyvaXv8+pmX9E
ceI+iMaEqraNTugCzQebMLuk0RJf6pJngmAPlV9XLzoYULWDxsWK6J1izVMYuSG8
CLSo2M82kpWCemzwk/3/Ymm332aUr/OHLjfP7SrcSJ6J62lvVEc0QdCbICjF0iZM
yNBO5Ikm+wB00pt3gU4NvoceUrqdonDX8XlnSg6NLGx9CxVPHeRKwF4wQKPsqE4b
MMv39zqIJ6RLCYUeggvDY42/NGeM+3Hvta2MUqLDM7PVIXAd8lXJrucfGvmpGCjR
dUZJjCTGqXVBzFH8xxLGlmyKrzQH6mdBW9K7dkdRxIO+hecstzonHbYEQxo8STh5
8mr/zqJo/xRNqH2G2d8/WJom2sIi4EQHvBNQi7gmpYa9bQE7UJE8DoiLf/LAjR7r
+vlI/P5nE5aW/KTNY9KjV/x+xL/+C2CJfjewL9IFemfJgUr6KixlwxRntRlu0SJ4
V7oMBr/4MC/kR/Hff8PEMmUItAmSxmE1axQklXemF7tXFGPlGX73BLSSygQbGtzq
vkQGK3mO67qwuVhRtxE8OaK+JgBTjMuNRtOQqiJnk3FEneu4Cm11UhZEa83e4ut7
+wUP/GPk1CQdsupfBgEiG12wJDOaJJySqLj+Al+m0Dgvp8nehLXbx+MFvsF9EnVg
ICGuWe1MrPG+Qk+hDvC3
=tWko
-----END PGP SIGNATURE-----

--RnlQjJ0d97Da+TV1--
