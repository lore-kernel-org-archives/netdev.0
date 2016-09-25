From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2016-09-25
Date: Sun, 25 Sep 2016 15:42:38 +0300
Message-ID: <20160925124238.GA19411@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="bg08WKrSYDhXBjb5"
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:36720 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966135AbcIYMmr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 08:42:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

Here are a few more Bluetooth & 802.15.4 patches for the 4.9 kernel that
have popped up during the past week:

 - New USB ID for QCA_ROME Bluetooth device
 - NULL pointer dereference fix for Bluetooth mgmt sockets
 - Fixes for BCSP driver
 - Fix for updating LE scan response

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit cdd0766d7da19085e88df86d1e5e21d9fe3d374f:

  Merge branch 'ftgmac100-ast2500-support' (2016-09-22 03:31:22 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.gi=
t for-upstream

for you to fetch changes up to 056506944a58814e5767d55ef6389aa2ab06908c:

  Bluetooth: Use single return in hci_uart_tty_ioctl() call (2016-09-24 06:=
40:24 +0200)

----------------------------------------------------------------
Arek Lichwa (1):
      Bluetooth: Fix NULL pointer dereference in mgmt context

Dean Jenkins (2):
      Bluetooth: Tidy-up coding style in hci_bcsp.c
      Bluetooth: BCSP fails to ACK re-transmitted frames from the peer

Dmitry Tunin (1):
      Bluetooth: Add a new 04ca:3011 QCA_ROME device

Laura Abbott (1):
      Bluetooth: btwilink: Save the packet type before sending

Micha=C5=82 Narajowski (1):
      Bluetooth: Fix not updating scan rsp when adv off

Vignesh Raman (1):
      Bluetooth: Use single return in hci_uart_tty_ioctl() call

 drivers/bluetooth/btusb.c     |   1 +
 drivers/bluetooth/btwilink.c  |   4 +-
 drivers/bluetooth/hci_bcsp.c  | 128 ++++++++++++++++++++---------------
 drivers/bluetooth/hci_ldisc.c |  28 ++++----
 net/bluetooth/mgmt.c          |   4 +-
 5 files changed, 96 insertions(+), 69 deletions(-)

--bg08WKrSYDhXBjb5
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJX58Y+AAoJECQj9vv5qNQSjrsP/R7/9SpGNaJdYMuYJ2BIila4
0ull+Qxs+HZTYjoxcYmyoLneEcb/DFPZfI61IPfSbElgOuxml00+rHW7DHYd6WtM
xBjMIebcqG8uSM/18rQsWA8bst08FWWDwtGyjrcSItvKc5tAjRVfeUAPWzsRxL63
YWvo8BBYzXQ2kcVY/agDLrJF9Og8+R26GqWAN7Lderu4dKiszv4fiAoknz67wz4X
zfsnI13zCywd02QU4y3lNksPTAzG+aNqYgAgLfh+55CoN+K6RGjNgR5gI1Zl7jcZ
fIgQ1A6EMhr1zxpZ5lepb7469DrSp7883bBq2hNvPYlF+beYAkzO/drd0MYKJzft
aBGUV6qnVDiomOC87mNq+/nf64fViyLmuy6ld/iot3YXbZzrsbQZEXjbRWtVm7je
QajHKfgzXimsLNmncLT6SS5t+ovcUUijxgSYVN095IfYeh7s4S6ZrlqQUsAr0L4L
JTXBN1lLQ+IzwCUNFvTcNpt+zt1Atg9BEQOVnI1neKMAnaZ2N45LwvUbuB0SYacQ
8WdFoTNdFgsy3gOw8XMeZessE099sLk/XO1CcQoHhqbrTuqEoflT5gV4NL75bg19
oUiUE9Nn3pOr3HOCav3hqJnbwkFg61bP14wKarawlOM8W9po7KY8fBYNzXu60DJO
8zmZOIsoS6L9pfDYvnuT
=JGCj
-----END PGP SIGNATURE-----

--bg08WKrSYDhXBjb5--
