From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth 2015-11-05
Date: Thu, 5 Nov 2015 08:19:29 +0200
Message-ID: <20151105061929.GA599@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="sm4nu43k4a2Rpi4c"
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:34197 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756174AbbKEGTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 01:19:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--sm4nu43k4a2Rpi4c
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

The following set of Bluetooth patches would be good to get into 4.4-rc1
if possible:

 - Fix for missing LE CoC parameter validity checks
 - Fix for potential deadlock in btusb
 - Fix for issuing unsupported commands during HCI init

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit e1b8d903c6c3862160d2d5036806a94786c8fc4e:

  net: Fix prefsrc lookups (2015-11-04 21:34:37 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git for-upstream

for you to fetch changes up to 40624183c202278e7e0edd01d1273efc87ddd1f2:

  Bluetooth: L2CAP: Add missing checks for invalid LE DCID (2015-11-05 04:04:15 +0100)

----------------------------------------------------------------
Johan Hedberg (3):
      Bluetooth: L2CAP: Fix returning correct LE CoC response codes
      Bluetooth: L2CAP: Fix checked range when allocating new CID
      Bluetooth: L2CAP: Add missing checks for invalid LE DCID

Kuba Pawlak (1):
      Bluetooth: Fix possible deadlock in btusb

Marcel Holtmann (1):
      Bluetooth: Check for supported white list before issuing commands

 drivers/bluetooth/btusb.c     |  6 ++++--
 include/net/bluetooth/l2cap.h |  2 ++
 net/bluetooth/hci_core.c      | 17 +++++++++++------
 net/bluetooth/l2cap_core.c    | 20 +++++++++++++++++---
 4 files changed, 34 insertions(+), 11 deletions(-)

--sm4nu43k4a2Rpi4c
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWOvTxAAoJECQj9vv5qNQSJv0P/1bp+LX0vIiNbKMNWNtuh7cH
6dFSqC8voyCrRL/PyYddiwY8BA0Twg1s/ytcNBVfVDq3YCBgXxyebFErGItEvvXV
r+qXBwYZUFK6EHiUkigHVhGO2Gq6xcv3BIu/9FrvBMKs2nqS8vh332PZkq7j8FAc
krKsTMZ2Vhm6UYg5FrXzoSc1BONTxXPcgkIR6F2DAAjTePdr8ePHFTTCYC4pWrU+
K2S1DSdFIhv8/jmWirMW9QrkGCqxs3smOV/6d2M8RQtjSZXDUZj2q38IwcTgLtnn
8TEVIu1ED8Ct9oYs6SWV9oACnQTsIeLZdaEryYXpAxiBgeItqfKsgbiY1H5eLLjK
GGhswSejqhYmkKsPr7uFyn3ZWwWhveBAKNpyJdvN7LOViNnbFwO9YZfrhigRIipT
kudEJ2YwVbvRv1BJxyKs6rjbToYUcZp9EYx2lzCNpVERYm2jrNWfBN0ngKNxu4AA
Cdb7ttqaUhRURdenMKG4knJfUgt5SqhWzbAMEY1wNG6jvsm9iGxMKMFXlDgBrGg0
hJPzEwGLF5TjdUzNkDZTJijcX5OcvhmXlhqmMuEoa9IMz802JSUlG7+wZ0JYFal0
W8/s6zXyGUjb4HVVs4aTen6yvOHkx7N0U/AiAzwSro0wCnu9DINwAJ189ZkPzYQt
xDJIrbJb/MHcAkfCMyBl
=inpY
-----END PGP SIGNATURE-----

--sm4nu43k4a2Rpi4c--
