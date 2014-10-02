From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: [PATCH] drivers/net/dsa/Kconfig: Let NET_DSA_BCM_SF2 depend on HAS_IOMEM
Date: Thu, 02 Oct 2014 22:14:04 +0800
Message-ID: <542D5DAC.4010001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Richard Weinberger <richard@nod.at>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: davem@davemloft.net, f.fainelli@gmail.com, leitec@staticky.com,
	andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:57543 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbaJBOIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 10:08:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NET_DSA_BCM_SF2 need HAS_IOMEM, so depend on it, the related error (wit=
h
allmodconfig under um):

    CC [M]  drivers/net/dsa/bcm_sf2.o
  drivers/net/dsa/bcm_sf2.c: In function =E2=80=98bcm_sf2_sw_setup=E2=80=
=99:
  drivers/net/dsa/bcm_sf2.c:487:3: error: implicit declaration of funct=
ion =E2=80=98iounmap=E2=80=99 [-Werror=3Dimplicit-function-declaration]
     iounmap(*base);
     ^

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 drivers/net/dsa/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index ea0697e..9234d80 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -47,6 +47,7 @@ config NET_DSA_MV88E6171
=20
 config NET_DSA_BCM_SF2
 	tristate "Broadcom Starfighter 2 Ethernet switch support"
+	depends on HAS_IOMEM
 	select NET_DSA
 	select NET_DSA_TAG_BRCM
 	select FIXED_PHY if NET_DSA_BCM_SF2=3Dy
--=20
1.9.3
