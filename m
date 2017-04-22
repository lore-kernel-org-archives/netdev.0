From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2017-04-22
Date: Sat, 22 Apr 2017 16:13:02 +0300
Message-ID: <20170422131302.GA17928@x1c>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="G4iJoqBmSsgzjUCe"
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:34072 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423675AbdDVNNL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 09:13:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here are some more Bluetooth patches (and one 802.15.4 patch) in the
bluetooth-next tree targeting the 4.12 kernel. Most of them are pure
fixes.

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit fb796707d7a6c9b24fdf80b9b4f24fa5ffcf0ec5:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-04-21 20:23:53 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to d160b74da85a4ec072b076db056e27ba7246eba0:

  Bluetooth: hci_ldisc: Add missing clear HCI_UART_PROTO_READY (2017-04-22 10:28:40 +0200)

----------------------------------------------------------------
Arnd Bergmann (2):
      Bluetooth: try to improve CONFIG_SERIAL_DEV_BUS dependency
      ieee802154: don't select COMMON_CLK

Dean Jenkins (3):
      Bluetooth: hci_ldisc: Add missing return in hci_uart_init_work()
      Bluetooth: hci_ldisc: Ensure hu->hdev set to NULL before freeing hdev
      Bluetooth: hci_ldisc: Add missing clear HCI_UART_PROTO_READY

Sebastian Reichel (1):
      Bluetooth: hci_ll: Fix NULL pointer deref on FW upload failure

 drivers/bluetooth/Kconfig      | 8 +++++++-
 drivers/bluetooth/Makefile     | 2 +-
 drivers/bluetooth/hci_ldisc.c  | 7 ++++++-
 drivers/bluetooth/hci_ll.c     | 3 +--
 drivers/net/ieee802154/Kconfig | 2 +-
 5 files changed, 16 insertions(+), 6 deletions(-)

--G4iJoqBmSsgzjUCe
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJY+1beAAoJECQj9vv5qNQSFLUQAJ5MFJkh+WTxYn9i0BdJ6Luk
gf+B/cvSkc+svQ1eQicCfBwzxt0Ib9p/NMQmnjuj5Qzs8d7/8EoHsTr+wBmuwL6q
rbn0VfWb80+O7TARgTEGzVMZNyXKwCOyrN07DHRVbcLDxb7PZLcT3DilN8aC1WSB
/n5tV0WR1F4SSyfkdEKiRLQBIYR0uB8uukG6ptbgWvo2ATROG4m6XbDkMMr0OfI9
UpGF0eynIoB9cPYBDxbH10Mx8fpuTthBn6fR+XWx6xtuEctjD6AFtO/c7a6sCupb
Y5tEVdvQstFE+SHGI1QTKPk+nGPLLUvauizMfljOJmoUGTHf2nEQzotugvzJJfID
x7bLgxicZA47/nyao9zrNB124VSkKKvqATKxTe2FA4H6PgmcoG1tGWQphAAUcquy
PwLoqvwWySfNoe/TzDiC32upfEHgEY3wrj6DR2sN+VNoCaFxtfmxYhKLqHCM/48y
I5xlOiP2sMMyAb4i4/88vBqHBasykhAsG/KofmgrGEUGw0+/Z5TH/zA4feZlVZrS
JtDldDIBY9XRcifMulgAQfSZo7b+E3ceqxJzsiGxK7doCtU9s2c/4tfmG7attZxD
MlwTt3H2flg16hPzyLaTe9sVTdUCngNwh+mq7ajDZAe+zCrMby4kZ+zbz2qTgtpt
/5PZEXjjjWrypdCsFjM4
=J2HE
-----END PGP SIGNATURE-----

--G4iJoqBmSsgzjUCe--
