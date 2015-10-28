From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth-next 2015-10-28
Date: Wed, 28 Oct 2015 07:58:02 +0200
Message-ID: <20151028055802.GA17209@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9amGYk9869ThD9tj"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here are a some more Bluetooth patches for 4.4 which collected up during
the past week. The most important ones are from Kuba Pawlak for fixing
locking issues with SCO sockets. There's also a fix from Alexander Aring
for 6lowpan, a memleak fix from Julia Lawall for the btmrvl driver and
some cleanup patches from Marcel.

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 13972adc3240ea8b18b44906b819c622941a64b6:

  Bluetooth: Increase minor version of core module (2015-10-22 13:37:26 +0300)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 324e786ee39c70ffbdc280c34b7d2b6da5c87879:

  bluetooth: 6lowpan: fix NOHZ: local_softirq_pending (2015-10-27 09:53:36 +0100)

----------------------------------------------------------------
Alexander Aring (1):
      bluetooth: 6lowpan: fix NOHZ: local_softirq_pending

Julia Lawall (1):
      Bluetooth: btmrvl: add missing of_node_put

Kuba Pawlak (4):
      Bluetooth: Fix crash on SCO disconnect
      Bluetooth: Fix locking issue on SCO disconnection
      Bluetooth: Fix locking issue during fast SCO reconnection.
      Bluetooth: Fix crash on fast disconnect of SCO

Marcel Holtmann (4):
      Bluetooth: Remove unneeded parenthesis around MSG_OOB
      Bluetooth: Rename bt_cb()->req into bt_cb()->hci
      Bluetooth: Replace hci_notify with hci_sock_dev_event
      Bluetooth: Fix some obvious coding style issues in the SCO module

 drivers/bluetooth/btmrvl_main.c   |  5 ++++-
 include/net/bluetooth/bluetooth.h | 14 ++++++------
 net/bluetooth/6lowpan.c           |  2 +-
 net/bluetooth/af_bluetooth.c      |  2 +-
 net/bluetooth/hci_core.c          | 43 ++++++++++++++++---------------------
 net/bluetooth/hci_event.c         |  4 ++--
 net/bluetooth/hci_request.c       | 10 ++++-----
 net/bluetooth/hci_sock.c          |  4 ++--
 net/bluetooth/sco.c               | 44 ++++++++++++++++++++++++++++----------
 9 files changed, 73 insertions(+), 55 deletions(-)

--9amGYk9869ThD9tj
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWMGPqAAoJECQj9vv5qNQSCLYP/ikQeA7p6yy7ylClTHv8lMOM
JymZRJy0hwqFGsGpRXpewaLat918sgUQ1r2vo+dZM0qP1Vcq/MkmmxqTY7KqsWE/
w+TDYaCVI8H4m+knlJ7X4eitGhHwe3pN/cYt60UVKdivpattJ525cSiCeAKYI05G
6eWWSGbt0NNIiBX41NTuXrme5K9R987IFIGgQt3cXKSwNznG6n+1+X6xQXZc0Vih
UAc+I3XflQj3JKxgFk1cwx/LqL8jHSo8+8ockvHx8ldHFaZPPOfKu95UEeb0dz1g
UmOl9vUx52QiA/MUeApGG+3pDy4jmP2xbnWMa1oaVOOm3CWdzYPeE/NUEZc8RhcL
921wXl+JXH6eqRAeTw2r65HZu35pxcRyOPvvztSybl8rmzYwdeqQKlwSRNVeNlvj
YY/Ec/EcW1DTXH2MWue/Ce4IurF13QJN46NcEwFImql5NWZypgSRuWNlWtITb+p8
iZqzUnigRa2pEYdxDb3/XSzKICIClDh24vYw6jpscMOOgg5Y6pmpxfBSZgN4e7hG
XNWDRzRb+mSsNGu69gZQ1ucaPjRkHN/9qrxcMRvolfJdD5S/hPp3ERpaw6WSkDYM
ZtOTu8dAnlAFlLpdsiNE4IZCmprHOdWyVLsd1UGDXMf0kaUWjbWLswwYVVgEhcUq
7TbCudgT1+2S6apeCuyw
=Z95H
-----END PGP SIGNATURE-----

--9amGYk9869ThD9tj--
