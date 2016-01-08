From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2016-01-08
Date: Fri, 8 Jan 2016 12:46:22 +0200
Message-ID: <20160108104622.GA20780@t440s.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zYM0uCDKw75PZbzx"
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:35282 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932068AbcAHKqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 05:46:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's one more bluetooth-next pull request for the 4.5 kernel:

 - Support for CRC check and promiscuous mode for CC2520
 - Fixes to btmrvl driver
 - New ACPI IDs for hci_bcm driver
 - Limited Discovery support for the Bluetooth mgmt interface
 - Minor other cleanups here and there

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit c07f30ad68053181b3e8a0e65b0630e12e844f91:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-12-31 18:20:10 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 8cf60cf238ce1bea38593321e6ea8561fc32e38d:

  Bluetooth: btmrvl: don't send data to firmware while processing suspend (2016-01-06 16:37:14 +0100)

----------------------------------------------------------------
Brad Campbell (1):
      ieee802154: cc2520: Check CRC & add promiscuous

Chin-Ran Lo (3):
      Bluetooth: btmrvl: fix hung task warning dump
      Bluetooth: btmrvl: max out host sleep parameter 'gap'
      Bluetooth: btmrvl: don't send data to firmware while processing suspend

Heikki Krogerus (2):
      Bluetooth: hci_bcm: move all Broadcom ACPI IDs to BCM HCI driver
      Bluetooth: hci_bcm: new ACPI IDs

Johan Hedberg (2):
      Bluetooth: Change eir_has_data_type() to more generic eir_get_data()
      Bluetooth: Add support for Start Limited Discovery command

Johannes Berg (1):
      Bluetooth: avoid rebuilding hci_sock all the time

Julia Lawall (1):
      mac802154: constify ieee802154_llsec_ops structure

 drivers/bluetooth/btmrvl_drv.h   |   1 +
 drivers/bluetooth/btmrvl_main.c  |  13 +++-
 drivers/bluetooth/btmrvl_sdio.c  |   6 +-
 drivers/bluetooth/hci_bcm.c      |   7 ++
 drivers/net/ieee802154/cc2520.c  | 145 ++++++++++++++++++++++++++++++++------
 include/net/bluetooth/hci_core.h |  31 +++++---
 include/net/bluetooth/mgmt.h     |   2 +
 include/net/ieee802154_netdev.h  |   2 +-
 net/bluetooth/hci_event.c        |   6 +-
 net/bluetooth/hci_request.c      |  11 ++-
 net/bluetooth/hci_sock.c         |  27 ++++---
 net/bluetooth/mgmt.c             |  56 ++++++++++++---
 net/mac802154/mac_cmd.c          |   2 +-
 net/rfkill/rfkill-gpio.c         |   4 --
 14 files changed, 244 insertions(+), 69 deletions(-)

--zYM0uCDKw75PZbzx
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWj5N9AAoJECQj9vv5qNQSHMAP/jOp4VuDbbc37iW1VR7Uk1PQ
iLQe0ROrZPG/lfec4B69e5gUAVjDgDopkVVgF2UGiJ0eiS9Y0AopyVokDjWpjLuv
+uYVWEXk0V9Jfj19///w6W2y4b1+460OIZqWPplIwbvz4IaOIDW/qOu7i7dC2oO8
tkr+LbUL3rSj9xsWjOOALpI34VxGwn/qgfp0BPLEX8UUPHzvgyxfrrd535mToYMB
KG/BddgsnYptGSaRLsMuhOmng1KjOGFE+uW83OeHJwLMoFWNtb9Cn5nVKE8fq9Z4
zyV35ymaxbNpU7YLX9JmoNRlIU8oXUI0EVTdedyc9b2ba+wZosBJ1EiAVvpWjcPb
TfVj9mwuznf4rBregHbBlM3NaRpgWOP0sRjSsu7L15Zuj/mpG5Zi9J+W++7Ev/RA
dau4kbDV/hdO7B8/FfK+Ne5HMH0VFJCsJMV9fAq91DeCIDpQUUx4rQpKkpU5JXii
zhVKrVtIAoOimX68ue2CJnMrAScXeifvD6PiEJYj4ZQfgl20tj0f8xBe5F0ytfh6
rjljxejvvrIC5TKYKXWFRpkSfNqYg/9Z4zvOCGZ2o62WKFfxpGKmrXToeuK8VxZu
UNV7A8pKXqzoRmjFkgE93hpQ1aCXLkJquDbrqB029SYN9KTp3BUQ6U5Cr7gQL+l5
zhkCQ0TRVJQCY0vuMvGL
=tIh/
-----END PGP SIGNATURE-----

--zYM0uCDKw75PZbzx--
