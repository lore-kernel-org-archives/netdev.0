From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth-next 2016-07-19
Date: Tue, 19 Jul 2016 09:14:52 +0300
Message-ID: <20160719061452.GA21654@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YZ5djTAD1cGYuMQK"
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	mchehab-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

Here's likely the last bluetooth-next pull request for the 4.8 kernel:

 - Fix for L2CAP setsockopt
 - Fix for is_suspending flag handling in btmrvl driver
 - Addition of Bluetooth HW & FW info fields to debugfs
 - Fix to use int instead of char for callback status.

The last one (from Geert Uytterhoeven) is actually not purely a
Bluetooth (or 802.15.4) patch, but it was agreed with other maintainers
that we take it through the bluetooth-next tree.

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 858d68f10238fdd1ebdd0096f912f063e97c6766:

  bpf: bpf_event_entry_gen's alloc needs to be in atomic context (2016-07-1=
6 22:03:39 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.gi=
t for-upstream

for you to fetch changes up to e7acf43024e95faa7460e77fe7e0fec2a3de582a:

  Bluetooth: btmrvl: reset is_suspending flag in failure path (2016-07-18 1=
0:13:02 +0200)

----------------------------------------------------------------
Amadeusz S=C5=82awi=C5=84ski (1):
      Bluetooth: Fix l2cap_sock_setsockopt() with optname BT_RCVMTU

Amitkumar Karwar (1):
      Bluetooth: btmrvl: reset is_suspending flag in failure path

Geert Uytterhoeven (1):
      drivers: misc: ti-st: Use int instead of fuzzy char for callback stat=
us

Marcel Holtmann (3):
      Bluetooth: Move hci_recv_frame and hci_recv_diag prototypes
      Bluetooth: Add debugfs fields for hardware and firmware info
      Bluetooth: bpa10x: Add support for hci_set_fw_info

 drivers/bluetooth/bpa10x.c                |  2 ++
 drivers/bluetooth/btmrvl_sdio.c           |  1 +
 drivers/bluetooth/btwilink.c              |  4 ++--
 drivers/media/radio/wl128x/fmdrv_common.c |  2 +-
 drivers/misc/ti-st/st_core.c              |  2 +-
 drivers/nfc/nfcwilink.c                   |  4 ++--
 include/linux/ti_wilink_st.h              |  2 +-
 include/net/bluetooth/hci_core.h          |  9 +++++---
 net/bluetooth/hci_core.c                  | 24 ++++++++++++++++++++
 net/bluetooth/hci_debugfs.c               | 35 +++++++++++++++++++++++++++=
++
 net/bluetooth/l2cap_sock.c                |  2 +-
 11 files changed, 76 insertions(+), 11 deletions(-)

--YZ5djTAD1cGYuMQK
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXjcVbAAoJECQj9vv5qNQS8yAQALzTdSLNo9h9AI7ORLU7Nonc
8iVqxjSSpXeHJujFnp2bN4GfWL5N9O+eMpHLnyRoOL42diyGlqWk5525kmIe8jol
VmjvfoDJSMkb01j3vIbABM9Rdl0Na/CihpeDV+44BUDG4dM7Dlmp5Dxr6j0JNXZw
uatoxcCgbSCF8si1RGa9+5d9ugHGMLF15DkFelXGd4VPpGdlLE8793+OFTB48Y76
hozh29gzl9CnBjKQC3jAGFKK2KsjfbXNQZqLBxxol5fX20Jt+7hAd/g+fbh2cFeB
jK14ajDFUyH4Y1AvkAUAk5EGKVCxcdKlwNG/7lpEODeiFPHe0wjNrOtbXgGLiGur
E7abg13XyxJe3rrpwkASFUe2cmBVvE5rYwMT0gcYyFo2/sw0QY0mc2WEG0lnKiXk
A8WLZ1Yh6FW3AXGpvr5wo9wZB15dZ+NJ/zW/H4OGjCKHRNf7wUOakm9tg71mw+VB
fONGVON1vngC+Myo7eczzubOUk0X1ht3wAMfs7XIpcf+qL+5ZyMWzMyaV8TdzzkA
bj0g8YN5Rqu9YuxpgQqCxrEyTRJ0rCvtUgwPM2QIMBXw3S68+Hj9NAYCR4HUz099
5uP1Y+1Xk5N6Crt5JQZ1Uy+xQV2HE+F5Eoi6BMr5JjafatLDDAUrrWhsEshYBU0Q
b4skEPGNqR+0N4LsP5KT
=OvTm
-----END PGP SIGNATURE-----

--YZ5djTAD1cGYuMQK--
