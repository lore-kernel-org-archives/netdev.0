From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2017-11-01
Date: Wed, 1 Nov 2017 10:32:13 +0200
Message-ID: <20171101083213.GA20632@x1c.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="6TrnltStXW4iwmi0"
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:50226 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753839AbdKAIcS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 04:32:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

Here's one more bluetooth-next pull request for the 4.15 kernel.

 - New NFA344A device entry for btusb drvier
 - Fix race conditions in hci_ldisc
 - Fix for isochronous interface assignments in btusb driver
 - A few other smaller fixes & improvements

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit fac72b243cc789bb209e6eca824919b42d98cfe2:

  Bluetooth: mark expected switch fall-throughs (2017-10-14 09:25:51 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.gi=
t for-upstream

for you to fetch changes up to 0338b1b393ec7910898e8f7b25b3bf31a7282e16:

  Bluetooth: hci_ldisc: Fix another race when closing the tty. (2017-10-30 =
15:48:32 +0100)

----------------------------------------------------------------
Bartosz Chronowski (1):
      Bluetooth: btusb: Add new NFA344A entry.

Jaganath Kanakkassery (1):
      Bluetooth: Fix potential memory leak

Jaya P G (1):
      Bluetooth: btusb: Update firmware filename for Intel 9x60 and later

Konrad Zapa=C5=82owicz (1):
      Bluetooth: increase timeout for le auto connections

Loic Poulain (1):
      Bluetooth: hci_ath: Add ath_vendor_cmd helper

Marcel Holtmann (2):
      Bluetooth: Use bt_dev_err and bt_dev_info when possible
      Bluetooth: btusb: Fix isochronous interface assignments

Ronald Tschal=C3=A4r (2):
      Bluetooth: hci_ldisc: Allow sleeping while proto locks are held.
      Bluetooth: hci_ldisc: Fix another race when closing the tty.

Sebastian Andrzej Siewior (1):
      Bluetooth: avoid recursive locking in hci_send_to_channel()

 drivers/bluetooth/bpa10x.c        |  15 ++-
 drivers/bluetooth/bt3c_cs.c       |   2 +-
 drivers/bluetooth/btbcm.c         | 103 +++++++++---------
 drivers/bluetooth/btintel.c       |  42 ++++----
 drivers/bluetooth/btqca.c         |   6 +-
 drivers/bluetooth/btrtl.c         |  21 ++--
 drivers/bluetooth/btusb.c         | 214 ++++++++++++++++++++++------------=
----
 drivers/bluetooth/hci_ath.c       |  51 +++++----
 drivers/bluetooth/hci_h4.c        |   2 +-
 drivers/bluetooth/hci_ldisc.c     |  42 ++++----
 drivers/bluetooth/hci_qca.c       |  12 +--
 drivers/bluetooth/hci_serdev.c    |   9 +-
 drivers/bluetooth/hci_uart.h      |   2 +-
 include/net/bluetooth/bluetooth.h |   3 +
 include/net/bluetooth/hci.h       |   2 +-
 net/bluetooth/a2mp.c              |   2 +-
 net/bluetooth/amp.c               |   4 +-
 net/bluetooth/hci_conn.c          |   6 +-
 net/bluetooth/hci_core.c          |  35 +++----
 net/bluetooth/hci_event.c         |  46 ++++----
 net/bluetooth/hci_request.c       |  21 ++--
 net/bluetooth/hci_request.h       |   1 +
 net/bluetooth/hci_sock.c          |  17 +--
 net/bluetooth/hci_sysfs.c         |   2 +-
 net/bluetooth/mgmt.c              |  57 +++++-----
 net/bluetooth/smp.c               |  22 ++--
 26 files changed, 407 insertions(+), 332 deletions(-)

--6TrnltStXW4iwmi0
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZ+YaNAAoJECQj9vv5qNQSaUgP/A90NqpZrBbB/ZSh4Iev94Yp
3PAPdAnyF3JUZmfg0kpdGRdhUZj+o1UyyQeMJoeJxdFqVk47FLmAJNnCduHqsihb
9mY8YUMTTmQ/+g4Mq12pvdUptznL4z2qwCZp9IFRMo0CaXJcwto6JIOCq3xIncl6
Y/2A+TeVHH8bCp52Mtk23Puard2inFWICocnIplYjoeRM+TJOY3gQAIvHfHTRhsz
Cwo1lUwQF1FM2ZvTGW3Gvsjl7TyQ0CIOhLo5VeGLQy9l0ZTha24+5CCDM6Dcmcl1
ALlMQ1V++4O99tBSJUqd8OL/mFr665EGAxQMydFPAc2igH8ZXL96pL5Lxg8OrXiF
eYdvzHzxLVVYWuKsncPsSSXgypQpRRJsaVAjsmsclPhvMaELdXBmRBTXAv+t6dfA
vijmsy1+lHzyEFNTA0HI1uV6zhmPjpYzLFuHcdgfE4OVAnFHLPKw1/EB40dRthIB
P1dEuOfT2TS6LWnmo+McJBxKgSXRue8NeAL57bYQ8qSU4IYSUi59NJvaTmWg2iy+
Oz8dEBj40gyliA5o/1EzMglgnsO3aPHO3jdwvLfILne3RxauLrqmHJR6w7Ngb/mr
uB037SEe9etc3+U5HdaDnpb8yCU5sgHnbYAmiZvdThQLplzEO7geVciYK18SF0fZ
pcj+2m3/1t06r7kdPiuo
=CL9F
-----END PGP SIGNATURE-----

--6TrnltStXW4iwmi0--
