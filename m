From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH v2 0/5] Phylib changes
Date: Fri, 31 May 2013 08:08:22 +0200
Message-ID: <cover.1369980470.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-1654-1369980507-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Michal Simek <monstr@monstr.eu>,
	Michal Simek <michal.simek@xilinx.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Anirudha Sarangi <anirudh@xilinx.com>, netdev@vger.kernel.org,
	Christian Hohnstaedt <chohnstaedt@innominate.com>,
	"David S. Miller" <davem@davemloft.net>,
	Steven Wang <steven.wang@digilentinc.com>,
	Lars-Peter Clausen <lars@metafoo.de>,
	Rick Hoover <RHoover@digilentinc.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:42312 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790Ab3EaGIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 02:08:34 -0400
Received: by mail-ea0-f181.google.com with SMTP id a11so1184302eae.12
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 23:08:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-1654-1369980507-0001

We have these changes in our tree for quite a long
time and I would like to ask you for review.
All phys are used on xilinx zynq boards.

Thanks,
Michal

v2: Resent these phy patches without emaclite changes

Changes in v2:
- None

Michal Simek (5):
  phy: Clean coding style in vitesse phy
  phy: Add Vitesse 8211 phy ID
  phy: Use macros instead of hardcoded values in marvell phy driver
  phy: Add Marvell 88E1116R phy ID
  phy: Add Marvell 88E1510 phy ID

 drivers/net/phy/marvell.c   | 108 ++++++++++++++++++++++++++++++++++++++++----
 drivers/net/phy/vitesse.c   |  38 +++++++++++-----
 include/linux/marvell_phy.h |   2 +
 3 files changed, 127 insertions(+), 21 deletions(-)

--
1.8.2.3


--=_mimegpg-monstr-desktop-1654-1369980507-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlGoPlsACgkQykllyylKDCE5SACfTwa2mXp9R7xXIjF9oQtqB9ju
bP0AoJOhA95EXqxyNoI5kY5j5hN3XYOL
=3xt5
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-1654-1369980507-0001--
