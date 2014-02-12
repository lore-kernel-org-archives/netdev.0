From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 0/14] Xilinx axi ethernet patches
Date: Wed, 12 Feb 2014 16:55:34 +0100
Message-ID: <cover.1392220536.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-2173-1392220549-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Srikanth Thokala <sthokal@xilinx.com>, devicetree@vger.kernel.org,
	monstr@monstr.eu, John Linn <John.Linn@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	linux-kernel@vger.kernel.org,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:39083 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbaBLP4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 10:56:14 -0500
Received: by mail-ea0-f174.google.com with SMTP id z10so1212663ead.19
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 07:56:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-2173-1392220549-0001

Hi,

I have exctracted patches which I have in our
xilinx git tree which are missing in the mainline.

The first two patches fix compilation error and
warnings. Then 5 feature patches
and the rest is OF cleanup and with kernel-doc
and checkpatch problems.

Thanks,
Michal


Michal Simek (4):
  net: axienet: Fix compilation error
  net: axienet: Fix compilation warnings
  net: axienet: Fix comments blocks
  net: axienet: Fix kernel-doc warnings

Peter Crosthwaite (2):
  net: axienet: Handle 0 packet receive gracefully
  net: axienet: Service completion interrupts ASAP

Srikanth Thokala (8):
  net: axienet: Support for RGMII
  net: axienet: Handle jumbo frames for lesser frame sizes
  net: axienet: Support phy-less mode of operation
  net: axienet: Removed checkpatch errors/warnings
  net: axienet: Use pdev instead of op
  net: axienet: Use devm_* calls
  net: axienet: Use of_property_* calls
  net: axienet: Removed _of_ prefix in probe and remove functions

 drivers/net/ethernet/xilinx/xilinx_axienet.h      | 108 ++++----
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 307 ++++++++++++----------
 drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c |  30 ++-
 3 files changed, 241 insertions(+), 204 deletions(-)

--
1.8.2.3


--=_mimegpg-monstr-desktop-2173-1392220549-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlL7mYUACgkQykllyylKDCEDzgCdHpFHY1sUGDGLDK96iGCTYceW
Jk8AoI0hbTDGpZwJv5I2KPcYLz2YWJS9
=/UXf
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-2173-1392220549-0001--
