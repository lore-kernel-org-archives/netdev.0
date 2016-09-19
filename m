From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth-next 2016-09-19
Date: Mon, 19 Sep 2016 22:37:42 +0300
Message-ID: <20160919193742.GA10296@t440s>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="fUYQa+Pmc3FrFX/N"
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

Here's the main bluetooth-next pull request for the 4.9 kernel.

 - Added new messages for monitor sockets for better mgmt tracing
 - Added local name and appearance support in scan response
 - Added new Qualcomm WCNSS SMD based HCI driver
 - Minor fixes & cleanup to 802.15.4 code
 - New USB ID to btusb driver
 - Added Marvell support to HCI UART driver
 - Add combined LED trigger for controller power
 - Other minor fixes here and there

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit e867e87ae88c54f741d1cabd1de536b4497a0504:

  Merge tag 'rxrpc-rewrite-20160917-2' of git://git.kernel.org/pub/scm/linu=
x/kernel/git/dhowells/linux-fs (2016-09-19 01:52:21 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.gi=
t for-upstream

for you to fetch changes up to af4168c5a925dc3b11b0246c2b91124327919f47:

  Bluetooth: Set appearance only for LE capable controllers (2016-09-19 21:=
48:22 +0300)

----------------------------------------------------------------
Alexander Aring (3):
      mac802154: set phy net namespace for new ifaces
      6lowpan: ndisc: no overreact if no short address is available
      fakelb: fix schedule while atomic

Aristeu Rozanski (2):
      mac802154: don't warn on unsupported frames
      mac802154: use rate limited warnings for malformed frames

Arnd Bergmann (1):
      Bluetooth: add WCNSS dependency for HCI driver

Bart Van Assche (1):
      Bluetooth: btusb, hci_intel: Fix wait_on_bit_timeout() return value c=
hecks

Bhaktipriya Shridhar (1):
      Bluetooth: Remove deprecated create_singlethread_workqueue

Bjorn Andersson (2):
      Bluetooth: Add HCI device identifier for Qualcomm SMD
      Bluetooth: Introduce Qualcomm WCNSS SMD based HCI driver

Colin Ian King (1):
      Bluetooth: btqca: remove null checks on edl->data as it is an array

Fr=C3=A9d=C3=A9ric Dalleau (1):
      Bluetooth: Fix reason code used for rejecting SCO connections

Johan Hedberg (1):
      Bluetooth: mgmt: Fix sending redundant event for Advertising Instance

Kai-Heng Feng (1):
      Bluetooth: btusb: Add support for 0cf3:e009

Larry Finger (1):
      Bluetooth: btrtl: Add RTL8822BE Bluetooth device

Loic Poulain (3):
      Bluetooth: hci_bcm: Change protocol name
      Bluetooth: hci_uart: Add Nokia Protocol identifier
      Bluetooth: hci_uart: Add Marvell support

Marcel Holtmann (21):
      Bluetooth: Put led_trigger field behind CONFIG_BT_LEDS
      Bluetooth: Add combined LED trigger for controller power
      Bluetooth: Check SOL_HCI for raw socket options
      Bluetooth: Store control socket cookie and comm information
      Bluetooth: Introduce helper to pack mgmt version information
      Bluetooth: Add support for sending MGMT open and close to monitor
      Bluetooth: Add support for sending MGMT commands and events to monitor
      Bluetooth: Use individual flags for certain management events
      Bluetooth: Fix wrong Get Clock Information return parameters
      Bluetooth: Use command status event for Set IO Capability errors
      Bluetooth: Introduce helper functions for socket cookie handling
      Bluetooth: Use numbers for subsystem version string
      Bluetooth: Send control open and close only when cookie is present
      Bluetooth: Assign the channel early when binding HCI sockets
      Bluetooth: Add extra channel checks for control open/close messages
      Bluetooth: Send control open and close messages for HCI raw sockets
      Bluetooth: Handle HCI raw socket transition from unbound to bound
      Bluetooth: Add framework for Extended Controller Information
      Bluetooth: Send control open and close messages for HCI user channels
      Bluetooth: Fix wrong New Settings event when closing HCI User Channel
      Bluetooth: Increase the subsystem minor version number

Micha=C5=82 Narajowski (7):
      Bluetooth: Append local name and CoD to Extended Controller Info
      Bluetooth: Add support for local name in scan rsp
      Bluetooth: Add support for appearance in scan rsp
      Bluetooth: Factor appending EIR to separate helper
      Bluetooth: Add supported data types to ext info changed event
      Bluetooth: Fix missing ext info event when setting appearance
      Bluetooth: Set appearance only for LE capable controllers

Nicolas Iooss (1):
      Bluetooth: add printf format attribute to hci_set_[fh]w_info()

Szymon Janc (8):
      Bluetooth: btusb: Mark CW6622 devices to have broken link key commands
      Bluetooth: Fix not registering BR/EDR SMP channel with force_bredr fl=
ag
      Bluetooth: Remove unused parameter from tlv_data_is_valid function
      Bluetooth: Unify advertising instance flags check
      Bluetooth: Fix advertising instance validity check for flags
      Bluetooth: Increment management interface revision
      Bluetooth: Refactor read_ext_controller_info handler
      Bluetooth: Add appearance to Read Ext Controller Info command

Wei Yongjun (1):
      Bluetooth: Use kzalloc instead of kmalloc/memset

Wolfram Sang (1):
      Bluetooth: bcm203x: don't print error when allocating urb fails

 drivers/bluetooth/Kconfig         |  23 ++
 drivers/bluetooth/Makefile        |   2 +
 drivers/bluetooth/bcm203x.c       |   4 +-
 drivers/bluetooth/btqca.c         |   8 +-
 drivers/bluetooth/btqcomsmd.c     | 182 ++++++++++++++++
 drivers/bluetooth/btrtl.c         | 107 ++++++++--
 drivers/bluetooth/btusb.c         |  13 +-
 drivers/bluetooth/hci_bcm.c       |   2 +-
 drivers/bluetooth/hci_intel.c     |   6 +-
 drivers/bluetooth/hci_ldisc.c     |   6 +
 drivers/bluetooth/hci_mrvl.c      | 387 ++++++++++++++++++++++++++++++++++
 drivers/bluetooth/hci_qca.c       |   2 +-
 drivers/bluetooth/hci_uart.h      |   9 +-
 drivers/net/ieee802154/fakelb.c   |  14 +-
 include/net/bluetooth/bluetooth.h |   4 +-
 include/net/bluetooth/hci.h       |   7 +-
 include/net/bluetooth/hci_core.h  |  11 +-
 include/net/bluetooth/hci_mon.h   |   4 +
 include/net/bluetooth/mgmt.h      |  24 +++
 net/6lowpan/ndisc.c               |   2 -
 net/bluetooth/af_bluetooth.c      |  15 +-
 net/bluetooth/hci_core.c          |   1 +
 net/bluetooth/hci_request.c       |  49 +++--
 net/bluetooth/hci_request.h       |   5 +-
 net/bluetooth/hci_sock.c          | 396 ++++++++++++++++++++++++++++++++++-
 net/bluetooth/leds.c              |  27 +++
 net/bluetooth/leds.h              |  10 +
 net/bluetooth/mgmt.c              | 349 +++++++++++++++++++++++-------
 net/bluetooth/mgmt_util.c         |  66 +++++-
 net/bluetooth/smp.c               |   5 +-
 net/mac802154/iface.c             |   1 +
 net/mac802154/rx.c                |   9 +-
 32 files changed, 1600 insertions(+), 150 deletions(-)
 create mode 100644 drivers/bluetooth/btqcomsmd.c
 create mode 100644 drivers/bluetooth/hci_mrvl.c

--fUYQa+Pmc3FrFX/N
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJX4D6GAAoJECQj9vv5qNQSgRUP/1OYnpUEl38Ii8AeNa8kZM9H
WLB66nL2Jdt3SA908Uz8r9Ua9tTF77XX5x52DFUoTSMxFT50vv43v9Db/UBZff4K
K/zBfx0X8e5M7fu/Ubf7gqjgGxyo8htcO+TyezeBHuEyoFeeq5888X1h+cRj/StE
8kahuZ45aejqWQ26/CfLUH9O8L1UFKe09WUhTwGoS1CRXVQ7bXD25HyT9+lI3DNX
vu8LuRG3Af9/aLD+9wlkKtUo+gkdhebH/foRo+Lbw5xBWtFCFmvnOh2jmftrDhzI
JZb7R/hxVR0p1MxhAerft/vWsRHPYD99lMTP3lSbZCln6S1BYfWoJY96DoigRFzc
o3HhhG83CMyamS2Znbk7S6gT8W6/zKrs7knlqh6RLbLmJdHUfksZl1ECDVbEg17p
ueYn9LOuJUQfAd1LTM7yFYol90UonnjZebp3a2XtTqkaW51RhuzSJOsQ3oIprHee
c6szNvhYKchYkWpA0UlPNEhj01Duz0xyAi2WUV4fvuR7iOkU63YndmA1eKmePa0+
tKNJLyJ3pBJH1aP+mns5YEn3FUfGJ+RrSax7+a9jZbNDX6Uta/T3aXp9/dKS7ru7
vhMKvWoD6MptmHL3CIL2JV8PRtrb2NEO3ITLMz/vhw5N66TZ5VE5G4fuKrfb6jnZ
FNVct7A+ZGLjfd9LvYxD
=GLYx
-----END PGP SIGNATURE-----

--fUYQa+Pmc3FrFX/N--
