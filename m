From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: pull request: bluetooth-next 2015-08-28
Date: Fri, 28 Aug 2015 23:13:51 +0300
Message-ID: <20150828201351.GA29774@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fUYQa+Pmc3FrFX/N"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

One more bunch of Bluetooth patches for 4.3:

 - Crash fix for hci_bcm driver
 - Enhancements to hci_intel driver (e.g. baudrate configuration)
 - Fix for SCO link type after multiple connect attempts
 - Cleanups & minor fixes in a few other places

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 9cd3778cd7e8f165675705511cfcd4ea6eb88d27:

  Merge branch 'mlx5e-next' (2015-08-17 15:51:36 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 917522aae169ad02010dcee6ae42c16155bcd285:

  Bluetooth: hci_bcm: Fix crash on suspend (2015-08-28 21:09:14 +0200)

----------------------------------------------------------------
Frederic Danis (1):
      Bluetooth: hci_bcm: Fix crash on suspend

Kuba Pawlak (1):
      Bluetooth: Fix SCO link type handling on connection complete

Loic Poulain (4):
      Bluetooth: hci_bcm: Use non-sleep version of gpio_set_value
      Bluetooth: hci_uart: Fix zero len data packet reception issue
      Bluetooth: hci_intel: Add Intel baudrate configuration support
      Bluetooth: hci_intel: Add support for platform driver

Marcel Holtmann (1):
      Bluetooth: btintel: Add MODULE_FIRMWARE entries for iBT 3.0 controllers

Minjune Kim (1):
      Bluetooth: btusb: Correct typos based on checkpatch.pl

Nicholas Krause (1):
      Bluetooth: Make the function sco_conn_del have a return type of void

Shengzhen Li (1):
      Bluetooth: btmrvl: change device pointer passed to dev_coredumpv

Stefan Schmidt (1):
      nl802154: stricter input checking for boolean inputs

 drivers/bluetooth/btintel.c     |   2 +
 drivers/bluetooth/btmrvl_sdio.c |   3 +-
 drivers/bluetooth/btusb.c       |   4 +-
 drivers/bluetooth/hci_bcm.c     |  40 +++--
 drivers/bluetooth/hci_h4.c      |   9 +-
 drivers/bluetooth/hci_intel.c   | 321 +++++++++++++++++++++++++++++++++++++--
 net/bluetooth/hci_event.c       |  12 +-
 net/bluetooth/sco.c             |   5 +-
 net/ieee802154/nl802154.c       |  16 +-
 9 files changed, 372 insertions(+), 40 deletions(-)

--fUYQa+Pmc3FrFX/N
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJV4MD/AAoJECQj9vv5qNQSXwUP/3bjIuA0t0K7NAe9tbLprl2R
pLNz5V3W83TxxCSmolh4szl4FyONWHWeTAaZYVUCRV1jtMnMjCcG0on09znrA9AZ
Vf8eZ8hfTrKxR6lIhpA3E6Ka/mu6QKifC5KYtNgwgmK5gg14tpO1mnX260wqeorg
RevxIUwWvxuT00RZrW/e9yAWfwGpSyRPI7oxlBHTQ9Osfje9uXSM3VBQ+jkobrko
jteXaIED50GnPhdZfLq5UAHqempTtcpxDLzKWOGn4hycS96md1OEQkleYByCKmqt
W84vd+p7RuH1xjYjkYk9BCsjMK/8Sow2QQe3qhoeNdemNoiL8yHm2XZIaX2aTLnA
BcHduSPc9gEO/gTuz4dmMjiVFox009I0AQJqYsQVeJ0fLCVFUnGb5YkuUAekX/+Z
xYTGv7tirxToDu3doIRR2neuScHTxv3VmqgdmGZwg5dh66qXLikmCqs24YzyN5Rz
47nrhZ356n8xosmDhdFBO85YqYC0mh7bAxB1ACFiUm2JapLjX4++ogaQUaJzdLJK
qjaQM1oFriZT+ec2e6R7220DZ1CMIxV/Ws9aj2MEBw2FYDFrrtzZnRFWQB/q2jUe
/RRyxu3GdRxZ0YF2Ys3oQHtdWb8RGcGTe41WcSMEcDJV92BCfxdPw6tP1HDJdxlh
5XbDrOmdYP7ns/wT7HCi
=RQ4l
-----END PGP SIGNATURE-----

--fUYQa+Pmc3FrFX/N--
