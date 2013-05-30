From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH v2 5/6] net: emaclite: Enable emaclite for Xilinx Arm Zynq platform
Date: Thu, 30 May 2013 12:28:07 +0200
Message-ID: <ca2770c39bc119d754854d978fada9931c48719f.1369909618.git.michal.simek@xilinx.com>
References: <cover.1369909618.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-5499-1369909700-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Michal Simek <monstr@monstr.eu>,
	Michal Simek <michal.simek@xilinx.com>, renner@efe-gmbh.de,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:55214 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968215Ab3E3K2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 06:28:23 -0400
Received: by mail-we0-f175.google.com with SMTP id p60so67538wes.6
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 03:28:22 -0700 (PDT)
In-Reply-To: <cover.1369909618.git.michal.simek@xilinx.com>
In-Reply-To: <cover.1369909618.git.michal.simek@xilinx.com>
References: <cover.1369909618.git.michal.simek@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-5499-1369909700-0001

Enable emaclite for Xilinx ARM Zynq platform.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---
Changes in v2: None

 drivers/net/ethernet/xilinx/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/Kconfig b/drivers/net/ethernet/xilinx/Kconfig
index 122d60c..7b90a5e 100644
--- a/drivers/net/ethernet/xilinx/Kconfig
+++ b/drivers/net/ethernet/xilinx/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_XILINX
 	bool "Xilinx devices"
 	default y
-	depends on PPC || PPC32 || MICROBLAZE
+	depends on PPC || PPC32 || MICROBLAZE || ARCH_ZYNQ
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -20,7 +20,7 @@ if NET_VENDOR_XILINX

 config XILINX_EMACLITE
 	tristate "Xilinx 10/100 Ethernet Lite support"
-	depends on (PPC32 || MICROBLAZE)
+	depends on (PPC32 || MICROBLAZE || ARCH_ZYNQ)
 	select PHYLIB
 	---help---
 	  This driver supports the 10/100 Ethernet Lite from Xilinx.
--
1.8.2.3


--=_mimegpg-monstr-desktop-5499-1369909700-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlGnKcQACgkQykllyylKDCEt5gCcCw6SFy6Jz1BJwoGJFpoGhh//
HzkAnjq3JIpOGx84laWrprYKjjvibGFq
=kCAu
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-5499-1369909700-0001--
