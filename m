From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2017-07-01
Date: Sat, 1 Jul 2017 21:19:50 +0300
Message-ID: <20170701181950.GA27217@x1c.home>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="UlVJffcvxoiEqYs2"
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:34310 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751851AbdGASUA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2017 14:20:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here are some more Bluetooth patches for the 4.13 kernel:

 - Added support for Broadcom BCM43430 controllers
 - Added sockaddr length checks before accessing sa_family
 - Fixed possible "might sleep" errors in bnep, cmtp and hidp modules
 - A few other minor fixes

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 4b943faedfc29eda882851b772c06cecdf78d8e3:

  udp/v6: prefetch rmem_alloc in udp6_queue_rcv_skb() (2017-06-22 13:44:04 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to feb16722b5d5f05b7ae1278a43e717c3d35cd512:

  Bluetooth: btbcm: Add entry for BCM43430 UART bluetooth (2017-06-29 14:39:42 +0200)

----------------------------------------------------------------
Colin Ian King (1):
      Bluetooth: hci_serdev: make hci_serdev_client_ops static

Hans de Goede (1):
      Bluetooth: hci_bcm: Add active_low irq polarity quirk for Asus T100CHI

Ian Molton (1):
      Bluetooth: btbcm: Add entry for BCM43430 UART bluetooth

Jeffy Chen (3):
      Bluetooth: bnep: fix possible might sleep error in bnep_session
      Bluetooth: cmtp: fix possible might sleep error in cmtp_session
      Bluetooth: hidp: fix possible might sleep error in hidp_session_thread

Loic Poulain (1):
      Bluetooth: hci_bcm: Fix unwanted error reporting if no bcm dev

Mateusz Jurczyk (1):
      Bluetooth: Add sockaddr length checks before accessing sa_family in bind and connect handlers

Tejun Heo (1):
      bluetooth: remove WQ_MEM_RECLAIM from hci workqueues

 drivers/bluetooth/btbcm.c      |  1 +
 drivers/bluetooth/hci_bcm.c    | 12 ++++++++++--
 drivers/bluetooth/hci_serdev.c |  4 ++--
 net/bluetooth/bnep/core.c      | 11 +++++------
 net/bluetooth/cmtp/core.c      | 17 ++++++++++-------
 net/bluetooth/hci_core.c       |  7 +++----
 net/bluetooth/hidp/core.c      | 33 ++++++++++++++++++++++-----------
 net/bluetooth/l2cap_sock.c     |  5 +++--
 net/bluetooth/rfcomm/sock.c    |  3 ++-
 net/bluetooth/sco.c            |  6 ++----
 10 files changed, 60 insertions(+), 39 deletions(-)

--UlVJffcvxoiEqYs2
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZV+fGAAoJECQj9vv5qNQS12kQAK0PUjuV1ZcQ08pjsTWDTpxI
RnkexIrbu3KU9q35ov4fGpZmpu9Gmq3xX10NDucWb7+HZTQa5/efD//qul77rq/m
+7hyJWGkU79rLjLT7KpeWwIGjO5iglyifyUTTzzflAn9VeF8eHGaQGLyFhxQnaOE
axVod0sJEpEHLBtxBW/8s2BkEYdPW1PxlkYohrVrlB1hr6QdNXX5T2zM8Zkxksq1
njdGmuk99ui9pzfIioUXZymybfbVP246thQw0whK6OJI9yD1Dzz97LJnbxthpZsy
jFPNKFKLPu7QH34VptD9MQ5bTV0DjDMvl8bPj8ijfJQywubxZ5UoiNAPfJ1POgBz
mMjezQghO/nMh0ssHCz2R/3I2f5je8vDQkPGNqc2YMrL6NldBM8RU7oL7eUlvvO4
f6PIFDkjKvTA0eghAoGt8EYCgTEVB5MTdB/tBIfFhwqCbnCpafwnLJvK0ncF/tvO
fGGz3hPVvufd1YGqTZdxm1H6/YVezadNBwLf+4vMwvAfDPO7SgAT/HmZGsIyF9UF
jTb8T52wt1nANzjeIrMYOI2MvWQ2RoLsHfmc53I1hHEywV1bEW4biCCxGWR0RFrt
MotDuv1er4xN03d3Oqe917nm6/MMYJaxRGcgwxb1Ga/bKk42Pkrzg33ysqqELN5q
WCx0svtMqCqJYKxKmQ5C
=A0h5
-----END PGP SIGNATURE-----

--UlVJffcvxoiEqYs2--
