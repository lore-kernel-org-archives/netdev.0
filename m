From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth-next 2017-06-14
Date: Wed, 14 Jun 2017 12:44:21 +0300
Message-ID: <20170614094421.GA29140@x1c.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="bg08WKrSYDhXBjb5"
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's another batch of Bluetooth patches for the 4.13 kernel:

 - Fix for Broadcom controllers not supporting Event Mask Page 2
 - New QCA ROME USB ID for btusb
 - Fix for Security Manager Protocol to use constant-time memcmp
 - Improved support for TI WiLink chips

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit fff88030b3ff930ca7a3d74acfee0472f33887ea:

  skbuff: only inherit relevant tx_flags (2017-06-08 16:12:08 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 06e41d8a36689f465006f017bbcd8a73edb98109:

  Bluetooth: btusb: Add support for 0489:e0a2 QCA_ROME device (2017-06-14 11:14:30 +0300)

----------------------------------------------------------------
Andy Shevchenko (2):
      Bluetooth: hci_bcm: Switch to devm_acpi_dev_add_driver_gpios()
      Bluetooth: hci_intel: Add GPIO ACPI mapping table

Jason A. Donenfeld (1):
      Bluetooth: use constant time memory comparison for secret values

Marcel Holtmann (2):
      Bluetooth: Send HCI Set Event Mask Page 2 command only when needed
      Bluetooth: btbcm: Read controller features during configuration

Sebastian Reichel (1):
      Bluetooth: hci_ll: Add compatible values for more WL chips

Shih-Yuan Lee (FourDollars) (1):
      Bluetooth: btusb: Add support for 0489:e0a2 QCA_ROME device

Ulf Hansson (3):
      dt-bindings: net: Add binding for the external clock for TI WiLink
      Bluetooth: hci_ll: Add support for the external clock
      arm64: dts: hikey: Add external clock to the Bluetooth node

 .../devicetree/bindings/net/ti,wilink-st.txt       | 12 +++++++
 arch/arm64/boot/dts/hisilicon/hi6220-hikey.dts     |  2 ++
 drivers/bluetooth/btbcm.c                          | 36 ++++++++++++++++++++
 drivers/bluetooth/btusb.c                          |  1 +
 drivers/bluetooth/hci_bcm.c                        |  5 +--
 drivers/bluetooth/hci_intel.c                      | 14 ++++++++
 drivers/bluetooth/hci_ll.c                         | 22 +++++++++++-
 net/bluetooth/hci_core.c                           | 17 ++++++++--
 net/bluetooth/smp.c                                | 39 +++++++++++-----------
 9 files changed, 122 insertions(+), 26 deletions(-)

--bg08WKrSYDhXBjb5
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZQQV1AAoJECQj9vv5qNQSqXoP/2ucybQrRWgQEgrN7rIpPIP5
IoFNVTXtwCCarGj2x5FOv0a3nHMWiHgnoM9DXwy/TxKkHJTzfL16A6d4lswt+K7J
6bhj7HWGZywIOSE1o4k1DT+InvJa25bc8jkPLPFscxzfKA+IxuolWZgR6+B6UFJa
o+ICMK4XsTfbHrOys7Mq8sBfLnjmJUoLS++SjSoEohl6dx26w/YZOLm4veKATwi2
vq5a8ddqQZ40u2sibEWC21/IWDFFB2fY4RfPWU0Jui69AIwmZiJyZrPHwITXCxuI
zaf/MseK37RZjqOvtVZQ5nbT9XsiNu2xbGsFSONweeuPCSdiP61E/eOdfXqjz9gF
9hGjT+Mip49HKwnTiYuoHTvezfqCcc/l/d1MjmxSlsvl3DwisPGi7ps+ScPl3PK2
YtOJA7NCR0oOYnWUafHZZb0cxBN8v+TWdZf+A7jo7OinJSlqDlu+hgZcJCeB7dVM
OKJSm4zIbRamhj0j48wxvv1fgPWdp9rALaPWetovpjHoZFOIQ01J6A6tMbm2vGZt
NsI3HlM0fEh3+Mj3hlZDsRIX+m1R92X4ZleMxfEGngAp2FHzgtLHKTZjC3hZBAtJ
3roWg/5NocFpYUAu72cxeXdv2d9Mm20ooML4Rjihlm6u2D/POZUAB48cUMGZcMeD
DKBSsIUjQwolV2P2DKH4
=k+xI
-----END PGP SIGNATURE-----

--bg08WKrSYDhXBjb5--
