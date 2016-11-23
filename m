From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth 2016-11-23
Date: Wed, 23 Nov 2016 09:29:12 +0200
Message-ID: <20161123072912.GA3538@x1c>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="RnlQjJ0d97Da+TV1"
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33445 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750999AbcKWH3U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 02:29:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--RnlQjJ0d97Da+TV1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Sorry about the late pull request for 4.9, but we have one more
important Bluetooth patch that should make it to the release. It fixes
connection creation for Bluetooth LE controllers that do not have a
public address (only a random one).

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit c9b8af1330198ae241cd545e1f040019010d44d9:

  flow_dissect: call init_default_flow_dissectors() earlier (2016-11-22 14:44:01 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git for-upstream

for you to fetch changes up to 39385cb5f3274735b03ed1f8e7ff517b02a0beed:

  Bluetooth: Fix using the correct source address type (2016-11-22 22:50:46 +0100)

----------------------------------------------------------------
Johan Hedberg (1):
      Bluetooth: Fix using the correct source address type

 include/net/bluetooth/hci_core.h |  2 +-
 net/bluetooth/6lowpan.c          |  4 ++--
 net/bluetooth/hci_conn.c         | 26 ++++++++++++++++++++++++--
 net/bluetooth/l2cap_core.c       |  2 +-
 net/bluetooth/rfcomm/tty.c       |  2 +-
 net/bluetooth/sco.c              |  2 +-
 6 files changed, 30 insertions(+), 8 deletions(-)


--RnlQjJ0d97Da+TV1
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJYNUVHAAoJECQj9vv5qNQS66gQALndXVs28c8VjZFbKUZTW+bF
FRDmPb9qn9Ev7dJtjBILPyIoSfYnONQEp2SOS0j6kN2R4jiRBN9SZUqRe/NTvvPc
AN5PA3/FwQ4I6VWFeR4hSP6yrDkl444GLv/NfhrcWBum7SAtYTGMxIEBTeIXH/WG
WxUCrZ/N6pFy5TfU5Iun21oqgVoEZC9p2mI+Qr84yDIk25VkO2lfWl2ZTl8qAXb5
Z8EKK6dpHs6A9BbqW3hJ088Fl3ON49bYEJ5u/2l04tDDpFs98RkmM96Hr15ZPdiL
VJFP53CY/Dsl1wZ/my/R1GMgXOS8OCo4O4oKjP+EXMRO8oBXMmzboW5LNwvav+iv
GlybEuPxLnnO6GQVS53HLchvgf0rITe4Yb5CITRZ4p6vV49gVn/Wv2lNyh15NU5X
2TIPs9CKpfA33Mr4hcZoYTMqqrtlHpy9+x27rcgNi/uS799AZQGI/8EvjhbwQTSs
ZuMbnDRE027i8iwKnCCQNOzZrN0XTmwjHQawB/XGE8Q/fPNu0WwCQXr6KYq6rrcZ
z8PU5cjr3G1hOlbVROkkelX7TQ/7svIbETzWeC1vvBj+UcAsifLr6Bid0+xUhhyl
z4XY2oElir++i+Nu46hZDL52VKKmJYZ7qxIUcAVBD7g1iaRgo1kfxySKCj3CzJeW
2ExJLyVlTQfJ3fWoYBei
=/h79
-----END PGP SIGNATURE-----

--RnlQjJ0d97Da+TV1--
