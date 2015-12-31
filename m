From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: pull request: bluetooth-next 2015-12-31
Date: Thu, 31 Dec 2015 18:28:32 +0200
Message-ID: <20151231162832.GA2124@t440s>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qMm9M+Fa2AknHoGS"
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:36179 "EHLO
	mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbbLaQ2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2015 11:28:41 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--qMm9M+Fa2AknHoGS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave,

Here's (probably) the last bluetooth-next pull request for the 4.5
kernel:

 - Add support for BCM2E65 ACPI ID
 - Minor fixes/cleanups in the bcm203x & bfusb drivers
 - Minor debugfs related fix in 6lowpan code

Please let me know if there are any issues pulling. Thanks.

Johan

---
The following changes since commit 07f6f4a31e5a8dee67960fc07bb0b37c5f879d4d:

  tcp: diag: add support for request sockets to tcp_abort() (2015-12-18 16:06:39 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git for-upstream

for you to fetch changes up to 7ddb69222d0fdc0bc83b60dbb21d9864ebf2907e:

  Bluetooth: bfusb: Fix the return error code (2015-12-22 15:25:33 +0100)

----------------------------------------------------------------
Alexander Aring (1):
      6lowpan: fix debugfs interface entry name

Geliang Tang (1):
      Bluetooth: use list_for_each_entry*

Luka Karinja (1):
      Bluetooth: hci_bcm: Add BCM2E65 ACPI ID

Syam Sidhardhan (3):
      Bluetooth: bcm203x: Remove redundant error message
      Bluetooth: bfusb: Remove redundant error message
      Bluetooth: bfusb: Fix the return error code

 drivers/bluetooth/bcm203x.c  |  4 +---
 drivers/bluetooth/bfusb.c    |  6 ++----
 drivers/bluetooth/hci_bcm.c  |  1 +
 net/6lowpan/core.c           |  6 +++---
 net/bluetooth/af_bluetooth.c | 12 +++++------
 net/bluetooth/cmtp/capi.c    |  8 ++------
 net/bluetooth/hci_core.c     |  8 +++-----
 net/bluetooth/rfcomm/core.c  | 46 +++++++++++++-----------------------------
 8 files changed, 32 insertions(+), 59 deletions(-)

--qMm9M+Fa2AknHoGS
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWhVewAAoJECQj9vv5qNQS/+wQAKoHaIz32LqynUUub6baY+yj
ItPbD0RT1qIzVrcY/utvAKG+xKAaha/lQthzCQ42bQQNhMSmh8wfYTfBl2wORTRe
2BCqHMPhugpmajfXg86sv+YjI9lKGEEZLOlLF4fWLq4LhdG+gPz/z4pTlDW3FD7a
1sTAQtRQA/x666eIz/H7htinWjvIEg3srlLxr8RX/pA4xmqCfCNZtB6+2jPJuwlL
6qu8ogirS4VpmpEKrKN9GaCvR8d0+oDHRd/HHOOtP99YwOtsNjTKMoyWYh0xLk3i
LyUSNecg86Dk08Lir1G3wM30dknEm5ml8yfQXiqGii8efCQmFN1RmxxD9F5ylJh0
uMAd+BtwBCus/jVUT8neXitddV4FMq5va/DL9rMpQxz21Ea6ZzqMLY3y5mGwkBTo
iNwZ7uCtQL+P8lTKpPDBOj+E040mf7tzWYJGluMJnV5Ar74hkYqZ67twI458QQVn
D2CDRrlHnz5C4q5IjNteBhXEPp8a4BkuBPkEnwo0Aw7ifBg0tAGbymBC2KvUb5fx
LHSVYRHDkYk4XGa6KFAq+PhfJ7VSjO/AtaBL0lGixrR99zLXLOCiwVvRNT85V5La
pilS7BS2IF87cNB5qbycBESI8TvRI5aJdC9En1L0K9lDfVXgAJxf3ErfsrOS+sao
pLbkvjl9oXWi7Kt0KPvR
=H+K5
-----END PGP SIGNATURE-----

--qMm9M+Fa2AknHoGS--
