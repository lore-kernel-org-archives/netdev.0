From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2017-04-30
Date: Sun, 30 Apr 2017 17:09:28 +0300
Message-ID: <20170430140928.GA2753@x1c>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="Kj7319i9nmIyA2yE"
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:32768 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1422884AbdD3OJh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 10:09:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

Here's one last batch of Bluetooth patches in the bluetooth-next tree
targeting the 4.12 kernel.

 - Remove custom ECDH implementation and use new KPP API instead
 - Add protocol checks to hci_ldisc
 - Add module license to HCI UART Nokia H4+ driver
 - Minor fix for 32bit user space - 64 bit kernel combination

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit e3a724edeec3836ed44675a6587a6db7b6b68dbe:

  sparc64: Support cbcond instructions in eBPF JIT. (2017-04-24 15:56:21 -0=
700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.gi=
t for-upstream

for you to fetch changes up to 71653eb64bcca6110c42aadfd50b8d54d3a88079:

  Bluetooth: Add selftest for ECDH key generation (2017-04-30 16:52:43 +030=
0)

----------------------------------------------------------------
Dean Jenkins (3):
      Bluetooth: hci_ldisc: Add protocol check to hci_uart_send_frame()
      Bluetooth: hci_ldisc: Add protocol check to hci_uart_dequeue()
      Bluetooth: hci_ldisc: Add protocol check to hci_uart_tx_wakeup()

Fr=E9d=E9ric Danis (1):
      Bluetooth: Add module license for HCI UART Nokia H4+

Marcel Holtmann (2):
      Bluetooth: zero kpp input for key generation
      Bluetooth: Add selftest for ECDH key generation

Salvatore Benedetto (2):
      Bluetooth: convert smp and selftest to crypto kpp API
      Bluetooth: allocate data for kpp on heap

Szymon Janc (1):
      Bluetooth: Fix user channel for 32bit userspace on 64bit kernel

 drivers/bluetooth/hci_ldisc.c |  14 +-
 drivers/bluetooth/hci_nokia.c |   7 +
 net/bluetooth/Kconfig         |   1 +
 net/bluetooth/Makefile        |   2 +-
 net/bluetooth/ecc.c           | 816 --------------------------------------=
----
 net/bluetooth/ecc.h           |  54 ---
 net/bluetooth/ecdh_helper.c   | 231 ++++++++++++
 net/bluetooth/ecdh_helper.h   |  27 ++
 net/bluetooth/hci_sock.c      |   3 +-
 net/bluetooth/selftest.c      |  28 +-
 net/bluetooth/smp.c           |  46 ++-
 11 files changed, 342 insertions(+), 887 deletions(-)
 delete mode 100644 net/bluetooth/ecc.c
 delete mode 100644 net/bluetooth/ecc.h
 create mode 100644 net/bluetooth/ecdh_helper.c
 create mode 100644 net/bluetooth/ecdh_helper.h

--Kj7319i9nmIyA2yE
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZBfAXAAoJECQj9vv5qNQS6EwP/j6D9+AzDZ/v8FYuk/wlxLbO
av7QnLplZipKhl3BUZxuLyTcl4kAbxiv+dEA3IHhBO5puBQkbmPb2/1SJvwSOFB5
wgsWp9PVKzXwBW4Uty57izIP3NxPfmhf20lesiyBRpbbzVKiJ1+cC46w3/RpSJ+a
PrYudLOqOPkOTE0PFCFSZOMjpcouJQSAItse495QCcs8UcjTCt4FV3ni3GveCv47
XDCCWISI+1B9VcDle5/GV6gHeXpAThyxF1OhCZITUR9Ezlk/zmwtDizOOFWBxUg+
2b0H0a9W/gISUzou9hbqFLgA2u4eLl9Xo25IMjrAZOt2dVi2fkUWgokhblgP/mM8
GxtDuDaGUHOmAoVtE50D2Xwc/Kzg+aXmIrZccVENMbAAOg3H9INoIjYY9XhXfGVd
bYU0w07SogSiZkYAt3QXO/4bWN9z1d9ChOADxqeil0U3Ekbf0GQgLcyUfL09ijSf
6s0nhrZpitM4Qglor37iamVgwrm5G8woR4izeX0wnTD0ImnZcg2PpvFJkINYhSGt
ZIzL5+T0hyjeqYKqhoOaWhPEqiyl0s0xlacHIU9iHUtuy02P/HRWpumgLbF+K0J/
71zt+Z7vITgn3OyjB/isGbVqZsPbxrDeC2jmvTW/20AjnSjNj4IECt4lkAP+4gbJ
jUmvNlJprI2L78i6G80O
=kD8S
-----END PGP SIGNATURE-----

--Kj7319i9nmIyA2yE--
