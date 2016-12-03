From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2016-12-03
Date: Sat, 3 Dec 2016 19:53:41 +0000
Message-ID: <20161203195341.GA17607@x1c.ukservers.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="sdtB3X0nJg68CQEu"
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36220 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750995AbcLCTxu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 14:53:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's a set of Bluetooth & 802.15.4 patches for net-next (i.e. 4.10
kernel):

 - Fix for a potential NULL deref in the ieee802154 netlink code
 - Fix for the ED values of the at86rf2xx driver
 - Documentation updates to ieee802154
 - Cleanups to u8 vs __u8 usage
 - Timer API usage cleanups in HCI drivers

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 0b42f25d2f123bb7fbd3565d003a8ea9e1e810fe:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-11-26 23:42:21 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 6bf0d84d13e968b4f8bf0710e0cae785e228dbba:

  docs: ieee802154: update main documentation file (2016-11-30 12:33:07 +0100)

----------------------------------------------------------------
Alexander Aring (1):
      at86rf230: fix cca ed values for rf233

Pavel Machek (1):
      Bluetooth: __ variants of u8 and friends are not neccessary inside kernel

Prasanna Karthik (3):
      Bluetooth: hci_bcsp: Use setup_timer Kernel API instead of init_timer
      Bluetooth: hci_h5: Use setup_timer Kernel API instead of init_timer
      Bluetooth: hci_qca: Use setup_timer Kernel API instead of init_timer

Stefan Schmidt (3):
      ieee802154: add myself as co-maintainer to MAINTAINERS file
      ieee802154: fakelb: print number of created fake devices during probe
      docs: ieee802154: update main documentation file

vegard.nossum@oracle.com (1):
      ieee802154: check device type

 Documentation/networking/ieee802154.txt | 26 +++++++++++---------------
 MAINTAINERS                             |  1 +
 drivers/bluetooth/hci_bcsp.c            |  4 +---
 drivers/bluetooth/hci_h5.c              |  4 +---
 drivers/bluetooth/hci_qca.c             |  9 +++------
 drivers/net/ieee802154/at86rf230.c      | 16 +++++++++++-----
 drivers/net/ieee802154/fakelb.c         |  2 +-
 include/net/bluetooth/bluetooth.h       | 25 +++++++++++++------------
 net/ieee802154/nl-phy.c                 |  6 +++++-
 9 files changed, 47 insertions(+), 46 deletions(-)

--sdtB3X0nJg68CQEu
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJYQyLFAAoJECQj9vv5qNQS6EMQAJ6TRUzrRkngNY0bZijtwCUx
+oRjk+VFJ17Aq81Oo0uHOxEbnS+BwFmCaIEsfZkLD0TbKlwqYUcqUQzdbPZGXVdw
iIq5sexSfgz5YqQ65+evlFWXQKtHgqA1f+LnQwEWNuV/vNBTM+ALrSj8B/qMF6sW
q7QpAvwKjfrKPhkngqL6FIlv6JGTEBeidZkQIS2kNdWHf9Y0OVdBm5+Jxz4EfIeU
+yNtvcwsOreqWwHKv3Gb/rar0SL5dVwA7xPgpAo690CzSZ6YaBJSkrg+GNKATDlm
imauRutw1Kx4Iovj7IA4sQSPZQ9ALoS3m6Vrz1gm+X+zcavP52w4jinWo6CJ1IUr
NOK3J4HI9QGQSU6UNw1gv1gh5nU0h/ClFE9D2qeQn7V4OriI2lbxay0WZ2RvDVkL
ZDDQKBYvfaLA0WXzckyvO0euQtKhnrhCDbIq/EcREND6Y87AVZlJjInIEKGU5T8l
N3DIfZKXm3ZtpMFYrkbxvbMP5mGMk3SJuKZaPbDKbTwa0PgUKJMGTpvrHzTG42Wd
wu1XLxkiKGa+uNa438em5PyWFTeNdLxb2+uFFtQebAfLjzlG4Sg3ksPcVxyznkpn
tvdTTFbvUVbkq5dKeJyLbBW82dcjOl2gIlVYG0D9DR9IJe/w0RKA9BxLLMIFaz6r
oSE2ja6JOyUP4jcYFxpH
=9bCs
-----END PGP SIGNATURE-----

--sdtB3X0nJg68CQEu--
