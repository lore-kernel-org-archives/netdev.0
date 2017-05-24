From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2017-05-23
Date: Tue, 23 May 2017 17:11:20 -0700
Message-ID: <20170524001120.GA3971@x1c.Skamania.guest>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="YZ5djTAD1cGYuMQK"
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35828 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753736AbdEXAL3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 20:11:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

Here's the first Bluetooth & 802.15.4 pull request targeting the 4.13
kernel release.

 - Bluetooth 5.0 improvements (Data Length Extensions and alternate PHY)
 - Support for new Intel Bluetooth adapter [[8087:0aaa]
 - Various fixes to ieee802154 code
 - Various fixes to HCI UART code

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 1fc4d180b3c6bed0e7f5160bcd553aec89594962:

  Merge branch 'phy-marvell-cleanups' (2017-05-17 16:27:52 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.gi=
t for-upstream

for you to fetch changes up to 7dab5467647be42736dcabcd5d035c7b571f4653:

  net: ieee802154: fix potential null pointer dereference (2017-05-23 20:12=
:53 +0200)

----------------------------------------------------------------
Alexander Aring (1):
      MAINTAINERS: update my mail address

Dean Jenkins (1):
      Bluetooth: hci_ldisc: Use rwlocking to avoid closing proto races

Guodong Xu (1):
      Bluetooth: hci_ll: Fix download_firmware() return when __hci_cmd_sync=
 fails

Gustavo A. R. Silva (1):
      net: ieee802154: fix potential null pointer dereference

J=FCrg Billeter (1):
      Bluetooth: btintel: Add MODULE_FIRMWARE entries for iBT 3.5 controlle=
rs

Lin Zhang (2):
      net: ieee802154: remove explicit set skb->sk
      net: ieee802154: fix net_device reference release too early

Loic Poulain (1):
      Bluetooth: btwilink: Fix unexpected skb free

Marcel Holtmann (5):
      Bluetooth: Set LE Suggested Default Data Length to maximum
      Bluetooth: Enable LE Channel Selection Algorithm event
      Bluetooth: Enable LE PHY Update Complete event
      Bluetooth: Set LE Default PHY preferences
      Bluetooth: Skip vendor diagnostic configuration for HCI User Channel

Markus Elfring (3):
      Bluetooth: Delete error messages for failed memory allocations in two=
 functions
      ieee802154: ca8210: Delete an error message for a failed memory alloc=
ation in ca8210_probe()
      ieee802154: ca8210: Delete an error message for a failed memory alloc=
ation in ca8210_skb_rx()

Tedd Ho-Jeong An (1):
      Bluetooth: Add support for Intel Bluetooth device 9460/9560 [8087:0aa=
a]

Tobias Regnery (2):
      Bluetooth: hci_uart: fix kconfig dependency
      Bluetooth: hci_nokia: select BT_HCIUART_H4

 MAINTAINERS                     |  4 ++--
 drivers/bluetooth/Kconfig       |  3 ++-
 drivers/bluetooth/btintel.c     |  2 ++
 drivers/bluetooth/btusb.c       |  4 ++++
 drivers/bluetooth/btwilink.c    |  1 -
 drivers/bluetooth/hci_ldisc.c   | 40 ++++++++++++++++++++++++++++++-----
 drivers/bluetooth/hci_ll.c      |  1 +
 drivers/bluetooth/hci_uart.h    |  1 +
 drivers/net/ieee802154/ca8210.c | 12 ++++-------
 include/net/bluetooth/hci.h     |  8 +++++++
 net/bluetooth/ecdh_helper.c     | 11 +++-------
 net/bluetooth/hci_core.c        | 46 ++++++++++++++++++++++++++++++++++++-=
----
 net/ieee802154/socket.c         | 10 ++++-----
 13 files changed, 107 insertions(+), 36 deletions(-)

--YZ5djTAD1cGYuMQK
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZJM+oAAoJECQj9vv5qNQSudIP/iej5TKN1QXWlRgFeJPy3f9d
vsA0mNU8J5xK5B26N8V/9xhutu7vW7GIlS5xKu1I5vDGY9ZFw20qRXvYAtJXEuUF
/5nQA2XpiTwVkwzvU/aoHZK7I4kuiWUJa0YEfeeLWVEf+P7APlkXPaDsokeesXbL
IgRiGi3/KCvoOq0n/Ce8zBG2ehx0+qWLG/Bh/ItR9HZICKnjVZ9kVVLV16c195wt
5zoPACippXiPSdV3KXQJTYsXX7vLA+3uWS6MIxqKo+F8VSptwtNfMDNNbDAQMCqB
1wRKr6a1DKQADKnpVJ26SNpRclIwlL40XdaiaKNxDVzPJZPFndr8PomCV+lfq+BY
vvdQbUCDVEDPdlkBKzrFpcA/i26JbZZ+HmZLZ6INIVbdL4rhswC58My+lJ3hIxuN
E8v1ugOFeNaQ4Mb18y56j9CUYTtl52MXZDGq7eIPIjBbElGyTxlXFO+F/VjAmfwD
vHwGLxj4SYQooFKDY4UZmECydKDiTUaQQzP5Dz51Xd7z+N9o7ONFo2YCvtSsQGtY
2POxw6iqWLjn4RQm/dY7Paw662alH1854J2o3yB7xxEaYue6oQ4sKiaFnfkjkOLY
GQeqf8D/rQ1+KPNirMa2/wGhsWUZA++7U7wzwPHXqqwJrg7w7cJVFwEOW+H4Ghex
vM5bIAMwVbvwb598i+Cf
=PJlE
-----END PGP SIGNATURE-----

--YZ5djTAD1cGYuMQK--
