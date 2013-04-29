From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2013-04-29
Date: Mon, 29 Apr 2013 15:45:51 -0400
Message-ID: <20130429194550.GC4590@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2oS5YaxWCcQjTEyO"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

A few more stragglers intended for 3.10...

For the Bluetooth bits, Gustavo says:

"A few more patches intended for 3.10, the most important one is the suppor=
t in
btusb for fw loading for the Intel Bluetooth device. Other than that we have
only fixes and clean ups."

For the iwlwifi bits, Johannes says:

"Here are a few more changes for the 3.10 stream, some bugfixes,
adjustments to some powersave parameters and a new device ID."

For the NFC bits, Samuel says:

"This pull request includes Marcel's Kconfig dependency fix on top of the L=
LCP
code move to net/nfc."

On top of that...Yogesh Ashok Powar provides a few PCI-related mwifiex
updates, Hauke Mehrtens provides a small ssb feature for spurious
tone avoidance on a specific chip, and Larry Finger provides a small
rtlwifi fix related to avoiding false detection of AP loss.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 94dace10142790ddeb0a3a7b8b33d9540d30c79f:

  cxgb4vf: Support CPL_SGE_EGR_UPDATEs encapsulated in a CPL_FW4_MSG (2013-=
04-29 15:24:44 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 17a2911f3395d66694fcbd2e8970015904d9b034:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2013-04-29 15:31:57 -0400)

----------------------------------------------------------------

Alexander Bondar (2):
      iwlwifi: mvm: change TX/RX AM-to-PSM transition time for LP mode
      iwlwifi: mvm: remove usage of power_save module parameter

Andreas Fenkart (2):
      Bluetooth: btmrvl: release lock while waiting for fw download complete
      Bluetooth: btmrvl: report error if verify_fw_download times out

Andy Shevchenko (1):
      Bluetooth: btmrvl: use native helpers for debugfs

Emmanuel Grumbach (4):
      iwlwifi: mvm: remove TODO which has been addressed
      iwlwifi: mvm: fix first_antenna
      iwlwifi: dvm: don't send zeroed LQ cmd
      iwlwifi: add a subdevice ID for 7000 series

Fengguang Wu (1):
      Bluetooth: hci_get_cmd_complete() can be static

Gustavo Padovan (1):
      Bluetooth: remove unneeded var initialization in btmrvl

Hauke Mehrtens (1):
      ssb: implement ssb spuravoid for chipid BCM43222

Johan Hedberg (2):
      Bluetooth: Fix HCI command send functions to use const specifier
      Bluetooth: Fix sending write_le_host_supporte for LE-only controllers

John W. Linville (4):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge tag 'nfc-next-3.10-4' of git://git.kernel.org/.../sameo/nfc-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Larry Finger (1):
      rtlwifi: rtl8192cu: Fix false loss of AP indication

Marcel Holtmann (2):
      Bluetooth: Remove unneeded parameter from L2CAP ATT channel handling
      NFC: Add missing RFKILL dependency for Kconfig

Piotr Haber (1):
      brcmsmac: Fix merge issue

Samuel Ortiz (1):
      NFC: Move LLCP code to the NFC top level diirectory

Stanislaw Gruszka (3):
      iwlwifi: fix freeing uninitialized pointer
      iwlwifi: remove redundant argument from iwl_dump_nic_event_log
      iwlwifi: remove unneeded goto from iwl_dbgfs_log_event_read

Tedd Ho-Jeong An (1):
      Bluetooth: Add support for Intel Bluetooth device [8087:07dc]

Yogesh Ashok Powar (4):
      mwifiex: Use pci_release_region() instead of a pci_release_regions()
      mwifiex: Call pci_release_region after calling pci_disable_device
      mwifiex: Do not kfree cmd buf while unregistering PCIe
      mwifiex: Correct pci_unmap_single's size

 drivers/bluetooth/btmrvl_debugfs.c                 | 266 ++-------------
 drivers/bluetooth/btmrvl_sdio.c                    |  41 ++-
 drivers/bluetooth/btusb.c                          | 377 +++++++++++++++++=
++++
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   1 +
 drivers/net/wireless/iwlwifi/dvm/agn.h             |   2 +-
 drivers/net/wireless/iwlwifi/dvm/debugfs.c         |  16 +-
 drivers/net/wireless/iwlwifi/dvm/main.c            |   6 +-
 drivers/net/wireless/iwlwifi/dvm/sta.c             |   5 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |   2 +-
 drivers/net/wireless/iwlwifi/mvm/phy-ctxt.c        |   5 -
 drivers/net/wireless/iwlwifi/mvm/power.c           |  16 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |   5 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |   1 +
 drivers/net/wireless/mwifiex/pcie.c                |   9 +-
 drivers/net/wireless/rtlwifi/usb.c                 |   3 +
 drivers/ssb/driver_chipcommon_pmu.c                |  19 +-
 include/net/bluetooth/hci_core.h                   |  14 +-
 net/bluetooth/hci_core.c                           |  29 +-
 net/bluetooth/l2cap_core.c                         |   7 +-
 net/bluetooth/mgmt.c                               |   8 +-
 net/nfc/Kconfig                                    |   2 +-
 net/nfc/Makefile                                   |   6 +-
 net/nfc/{llcp =3D> }/llcp.h                          |   0
 net/nfc/llcp/Kconfig                               |   7 -
 net/nfc/{llcp/commands.c =3D> llcp_commands.c}       |   2 +-
 net/nfc/{llcp/llcp.c =3D> llcp_core.c}               |   2 +-
 net/nfc/{llcp/sock.c =3D> llcp_sock.c}               |   2 +-
 net/nfc/netlink.c                                  |   3 +-
 net/nfc/nfc.h                                      |  64 ----
 29 files changed, 520 insertions(+), 400 deletions(-)
 rename net/nfc/{llcp =3D> }/llcp.h (100%)
 delete mode 100644 net/nfc/llcp/Kconfig
 rename net/nfc/{llcp/commands.c =3D> llcp_commands.c} (99%)
 rename net/nfc/{llcp/llcp.c =3D> llcp_core.c} (99%)
 rename net/nfc/{llcp/sock.c =3D> llcp_sock.c} (99%)
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--2oS5YaxWCcQjTEyO
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRfs3uAAoJEJctW/TcYTgGYI8P/jpSxEDxYnQ6eVJemhS9ikby
v/5avSc5Awd5iZNRLAb8Ita0dV9F3ktXN2xmXvKbhjdPn7/+i2ghUyHzxOwrD0wc
2KTr0z7UvNCTYbrhSsrdwYoEaAsUJh0a9lQCgW1QqhLmnOo3YcxtDyr/17FEgpbC
+FC5KLltntE5vVfGI64qQhr6r9mloHVCaPKGJwM7/qk14Iz4exyJF3Ti0zDqE6p5
o8G5SvQ9Etz6qPZvuc+A4f/T6aYGpzXS3DsOE2HCYJIGO1+LX7xtHJ+HuOss53fn
Sl8Hi4sUBpSkD9PKPsStsd35qX3oSbmCWVEhPVRE7N4jdqTKQGcOON8CcXlhyboc
mu/6JqFEohNKc8M1UtqG22DouVweGYBDU4tsRBhOyj3jeorTjTSEp2wbf+Q+6Rd7
qygmkdVpQNYXJkbqvKeI+3KInX0q1XwcP1b5ZfB7/2sd7qSPi7lXSfSVO9IYhMuM
k2MEiI9J6qTE3N1nOs6wsv1bM4hd7uIYFKnHJHYbqAZAEIm2U9+UANj8EeOxjK4G
WI5giEfYdjxxrVm/UbmYvc/pgnPmu1TXNHLEDTVNQ6Jvp0nAfZooUvqSmL6krulC
lQ9VfcU07TRcCw/Q11iVQVCJ8apNJP+wLgusVs+cDNLRo5+S80sBpRvkb9hPpvsz
+MIed1OqH12EywncFOvR
=OluY
-----END PGP SIGNATURE-----

--2oS5YaxWCcQjTEyO--
