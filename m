From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth-next 2016-05-07
Date: Sat, 7 May 2016 21:56:23 +0300
Message-ID: <20160507185623.GA18557@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="liOOAslEiF7prFVr"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here are a few more Bluetooth patches for the 4.7 kernel:

 - NULL pointer fix in hci_intel driver
 - New Intel Bluetooth controller id in btusb driver
 - Added device tree binding documentation for Marvel's bt-sd8xxx
 - Platform specific wakeup interrupt support for btmrvl driver

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 582a1db98892ef4c1f34c7338b272331994d44ab:

  Merge branch 'qed-selftests' (2016-05-02 00:16:45 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to a0af53b511423cca93900066512379e21586d7dd:

  Bluetooth: Add support for Intel Bluetooth device 8265 [8087:0a2b] (2016-05-06 21:52:35 +0200)

----------------------------------------------------------------
Loic Poulain (1):
      Bluetooth: hci_intel: Fix null gpio desc pointer dereference

Tedd Ho-Jeong An (1):
      Bluetooth: Add support for Intel Bluetooth device 8265 [8087:0a2b]

Xinming Hu (2):
      dt: bindings: add MARVELL's bt-sd8xxx wireless device
      btmrvl: add platform specific wakeup interrupt support

 Documentation/devicetree/bindings/btmrvl.txt       | 29 --------
 .../devicetree/bindings/net/marvell-bt-sd8xxx.txt  | 56 +++++++++++++++
 drivers/bluetooth/btmrvl_drv.h                     | 11 +++
 drivers/bluetooth/btmrvl_main.c                    | 35 +++++----
 drivers/bluetooth/btmrvl_sdio.c                    | 79 +++++++++++++++++++++
 drivers/bluetooth/btmrvl_sdio.h                    |  6 ++
 drivers/bluetooth/btusb.c                          | 11 +--
 drivers/bluetooth/hci_intel.c                      |  6 +-
 8 files changed, 180 insertions(+), 53 deletions(-)
 delete mode 100644 Documentation/devicetree/bindings/btmrvl.txt
 create mode 100644 Documentation/devicetree/bindings/net/marvell-bt-sd8xxx.txt

--liOOAslEiF7prFVr
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXLjpXAAoJECQj9vv5qNQSpXYP/1aihY7+FIKzvYdH/bqgAxK5
7i5ggXk1wnfLpLVZxcggMDa2oKLIrYacRJgKKtO9AXflgh5TYwvgzhauGKrmxSpB
5hk6RMhSmD/a6BC0qnMOziYmVFZDEuCTKfaYEh9iUOF1Qlw9Y/p727l/V1a4Wg47
gXk5NhVg5W2WKuOJyFN1Tme714nPuG3q1FsOTgfqTgzyryBizQn4nttnWAFREhm6
eECfAN2Mmb8UcioWyNhXBIiGBK9JDJ36n0lO4XzEsbhfLlpwnGbLA1hBefs8ePVg
zHlltiQSiourbG1KOLVXlMswiGjE0WLDkTXl0jV24GV+qG+vEaL027/0Kui+ynXE
QRWWxS0n8a4IoVqKThxR0xHXUw7QocHGS7mMUzwMKY4Yti7Y6mAtBmuytKoRPbA0
hFe8WIKBD3gCCqsyoES6PP39218qUTsWdY9Q+rxAx4gTpZnVMKwKU0mrhxFBPx/8
oEF/67/EoRVb2yVL8L6c5omtBMnItDJylwOj5z98R8AOku86bCAu3I1jFoMFho07
GVMS6OPwLyekfe2/qN9Bs6dvvpdiXtGYLPOw3VVH129fq22PtkmJiOPuUADiC49e
VB7cJmqAZUlRPzQRxwewItfdc4sP76PwvPXamfQAkjo3pnJJZYI2cBm2t+7gq+sm
ZHcwCADUmX6RlN4vlHSD
=LdEK
-----END PGP SIGNATURE-----

--liOOAslEiF7prFVr--
