From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH v2 0/6] Emaclite patches
Date: Thu, 30 May 2013 12:28:02 +0200
Message-ID: <cover.1369909618.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-5423-1369909688-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Michal Simek <monstr@monstr.eu>,
	Michal Simek <michal.simek@xilinx.com>, renner@efe-gmbh.de,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Bill Pemberton <wfp5p@virginia.edu>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:63761 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968137Ab3E3K2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 06:28:12 -0400
Received: by mail-we0-f174.google.com with SMTP id x50so68492wes.19
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 03:28:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-5423-1369909688-0001

I have separated these emaclite patches from
phy patches because it is easier for creating
new versions.

Thanks,
Michal

Changes in v2:
- Fix __raw_iowrite() to pass correct parameters
- s/Corrent/Correct/ in patch description

Michal Simek (6):
  net: emaclite: Report failures in mdio setup
  net: emaclite: Support multiple phys connected to one MDIO bus
  net: emaclite: Let's make xemaclite_adjust_link static
  net: emaclite: Do not use microblaze and ppc IO functions
  net: emaclite: Enable emaclite for Xilinx Arm Zynq platform
  net: emaclite: Update driver header

 drivers/net/ethernet/xilinx/Kconfig           |   4 +-
 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 169 ++++++++++++++------------
 2 files changed, 95 insertions(+), 78 deletions(-)

--
1.8.2.3


--=_mimegpg-monstr-desktop-5423-1369909688-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlGnKbgACgkQykllyylKDCFeSQCePtMXUJXtRD3gkQ/7MWQh91mm
zEsAn3cORIkhACwH15sfqNDY4zkWvC+Y
=XPdB
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-5423-1369909688-0001--
