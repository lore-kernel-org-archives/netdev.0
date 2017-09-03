From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2017-09-03
Date: Sun, 3 Sep 2017 09:20:55 +0300
Message-ID: <20170903062055.GA9569@x1c.home>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="uAKRQypu60I7Lcqm"
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33510 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751159AbdICGVA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 02:21:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's one last bluetooth-next pull request for the 4.14 kernel:

 - NULL pointer fix in ca8210 802.15.4 driver
 - A few "const" fixes
 - New Kconfig option for disabling legacy interfaces

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 01d300c577c72229b0a3b09e194cae52b219d5b3:

  Merge branch 'amd-xgbe-next' (2017-08-18 16:30:17 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 65bce46298d064dff9db1282e17bb26602715819:

  Bluetooth: make baswap src const (2017-09-01 22:49:47 +0200)

----------------------------------------------------------------
Bhumika Goyal (2):
      Bluetooth: make device_type const
      ieee802154: 6lowpan: make header_ops const

Christophe JAILLET (1):
      ieee802154: ca8210: Fix a potential NULL pointer dereference

Loic Poulain (1):
      Bluetooth: make baswap src const

Marcel Holtmann (1):
      Bluetooth: Add option for disabling legacy ioctl interfaces

 drivers/net/ieee802154/ca8210.c   |  5 +----
 include/net/bluetooth/bluetooth.h |  2 +-
 net/bluetooth/Kconfig             | 10 ++++++++++
 net/bluetooth/hci_sock.c          |  6 ++++++
 net/bluetooth/hci_sysfs.c         |  4 ++--
 net/bluetooth/lib.c               |  6 +++---
 net/ieee802154/6lowpan/core.c     |  2 +-
 7 files changed, 24 insertions(+), 11 deletions(-)

--uAKRQypu60I7Lcqm
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZq59HAAoJECQj9vv5qNQSsbQP/38mrRolDq7Qy43Pxe0ZdYyF
XiregObVTlH9hjCviLghiXSJ8MVpn5C+UNH+MUwH8Ho+e4GUcoeyAdnEfr/+kORF
XwAHTKyJVnsKp6rwyjlUHhKB10ADE+aZMuk3HDZc3yMSxxygt8Aq/NQ2C8zUrgE1
bkrbsJSi9JWAMHYnMKOe9To0Ik8+nlzmPkXFjH3jc63tssLL8yVoKx90Unb1eZUr
pXZOiwsKeS+yHhAVcyV0ZPfO6jTbovZ9/32/MsYM/676bDDJ0GKmj8XubOZpAjZs
0gqQargrOh9yyp/H1QX0Ii3Ru+s0vOJKjfkFKBcZQPw1bpzttNpuXzzZw9GXv2jQ
6mCgo7iVJR2NoVGVCLIdhdnxRyIfvQe8ajJzr2roVhroo4OGxTBU7wrgl8sSBRqX
OI854cbgL/UHFRY07frDsFg5DDsQW1x/c0aAW0BYT+b9TjYatp64z5btUYjj3Hkp
ttcCGHnqAWwNwWAtWESDzzLA0WYvFTWwXxR2B9s2oVpjaCJP1kMMqpSrrw+0vbGx
VtGfd6rw0wGUaDI8vP/ZtS7Mac3gPh9N7TO+7pkfHKWq4+NRkgVyhJLpsXhSw/wh
Imrt+mIJQOS5BzKd6IRoqGlxXkRLeBaPQuttUSnQlincTEZkW1MVCZ5Knf6utTIG
HTyvjMn/sJ5263lzu6Pi
=rCUI
-----END PGP SIGNATURE-----

--uAKRQypu60I7Lcqm--
