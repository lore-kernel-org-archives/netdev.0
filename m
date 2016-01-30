From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth 2016-01-30
Date: Sat, 30 Jan 2016 18:25:18 +0200
Message-ID: <20160130162518.GA14664@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="k1lZvvs/B4yU6o8G"
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:34055 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757022AbcA3QZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2016 11:25:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's a set of important Bluetooth fixes for the 4.5 kernel:

 - Two fixes to 6LoWPAN code (one fixing a potential crash)
 - Fix LE pairing with devices using both public and random addresses
 - Fix allocation of dynamic LE PSM values
 - Fix missing COMPATIBLE_IOCTL for UART line discipline

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 00ae40e71d85ea3fed1b906951ffd80e0321a96d:

  mlxsw: fix SWITCHDEV_OBJ_ID_PORT_MDB (2016-01-13 10:31:21 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git for-upstream

for you to fetch changes up to cff10ce7b4f02718ffd25e3914e60559f5ef6ca0:

  Bluetooth: Fix incorrect removing of IRKs (2016-01-29 11:47:24 +0100)

----------------------------------------------------------------
Glenn Ruben Bakke (1):
      Bluetooth: 6lowpan: Fix kernel NULL pointer dereferences

Johan Hedberg (4):
      Bluetooth: L2CAP: Introduce proper defines for PSM ranges
      Bluetooth: L2CAP: Fix auto-allocating LE PSM values
      Bluetooth: L2CAP: Fix setting chan src info before adding PSM/CID
      Bluetooth: Fix incorrect removing of IRKs

Lukasz Duda (1):
      Bluetooth: 6lowpan: Fix handling of uncompressed IPv6 packets

Marcel Holtmann (1):
      Bluetooth: Add missing COMPATIBLE_IOCTL for UART line discipline

 fs/compat_ioctl.c             |  3 +++
 include/net/bluetooth/l2cap.h |  6 ++++++
 net/bluetooth/6lowpan.c       |  7 ++++++-
 net/bluetooth/hci_request.c   | 28 ++++++++++++++++++----------
 net/bluetooth/l2cap_core.c    | 14 ++++++++++++--
 net/bluetooth/l2cap_sock.c    | 12 ++++++------
 net/bluetooth/smp.c           | 16 ----------------
 7 files changed, 51 insertions(+), 35 deletions(-)

--k1lZvvs/B4yU6o8G
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWrOPuAAoJECQj9vv5qNQSB3UP/35porH6kZ9ISPdxzCJ3N+RD
Uj5govaLgF2aVi2BM/hR3G9dlRk5+oUkbwCi6sJIAeaXypR1EeaKjXaiUvRFs0c0
apnqVrTFllc0nCWbCYDay93Y4zY2fs6LbSNi8ez8H1pAuHtkz7UFN/TtDFJO2Hju
rMmpnHDklBrlM8xKXe/CIwAJfK3OUv5IXA/1vSJtUdd3hAKeo8PvxRSMx8pdSi25
OWaHjM9cDiK+fyJ2z/0SSRC6EvUJt39xySJtDFGjvvNbFc8eMfpRJoZrabSFx0HS
PbKoSRpDUHNp7rkkGSJw+TaDwf6bFgMFriAK2d5jEcjBKYlsw43AuJZ8pBpjkuWW
qOue024T7GiewpCZPsgh7UPTkOIWV84TBtlUzy4j8s0toZoQm1PKwDeJO9h3hk6y
RZJTpw34M3O92IMMJFVi5N+I9B3069I4CqopWmimwGx13bGRMwnBQfoXQhcKomVo
UFoTzf5GlN9ECRJ+HlU43hOU/YJpkrgQdBw0l4gAkiFGPB4MLKZQ56lJ7veH4ydA
DR64vlxEkOnt3sGEOP8aqzu+WsjZ5RYLJuGBRhbJ4F3o3uPLduaBr9CjT+hVeO+L
E5yge0azUFl80kdWX+SaIAmv8TfO7uf2UFtNRPCx+KTCZs+12IUSgsR9BcnvpNHR
2DHbwYllGNOOgISsmQTx
=zv9A
-----END PGP SIGNATURE-----

--k1lZvvs/B4yU6o8G--
