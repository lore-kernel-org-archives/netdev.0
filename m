From: =?UTF-8?q?Vincent=20Stehl=C3=A9?= <vincent.stehle@laposte.net>
Subject: [PATCH linux-next] hisax: disable build for big-endian arm
Date: Fri, 22 Nov 2013 00:49:54 +0100
Message-ID: <1385077794-17022-1-git-send-email-vincent.stehle@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Vincent=20Stehl=C3=A9?= <vincent.stehle@laposte.net>,
	Karsten Keil <isdn@linux-pingi.de>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Teles PCI and HFC PCI-bus refuse to build on big-endian ARM; disable th=
em in
Kconfig.

Signed-off-by: Vincent Stehl=C3=A9 <vincent.stehle@laposte.net>
Cc: Karsten Keil <isdn@linux-pingi.de>
---

Hi,

This can be seen on e.g. linux next-20131121 with arm allyesconfig.

Best regards,

V.

 drivers/isdn/hisax/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hisax/Kconfig b/drivers/isdn/hisax/Kconfig
index d9edcc9..53dbb75 100644
--- a/drivers/isdn/hisax/Kconfig
+++ b/drivers/isdn/hisax/Kconfig
@@ -109,7 +109,7 @@ config HISAX_16_3
=20
 config HISAX_TELESPCI
 	bool "Teles PCI"
-	depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIP=
S && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
+	depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIP=
S && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN) || (A=
RM && !CPU_LITTLE_ENDIAN)))
 	help
 	  This enables HiSax support for the Teles PCI.
 	  See <file:Documentation/isdn/README.HiSax> on how to configure it.
@@ -318,7 +318,7 @@ config HISAX_GAZEL
=20
 config HISAX_HFC_PCI
 	bool "HFC PCI-Bus cards"
-	depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIP=
S && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
+	depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIP=
S && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN) || (A=
RM && !CPU_LITTLE_ENDIAN)))
 	help
 	  This enables HiSax support for the HFC-S PCI 2BDS0 based cards.
=20
--=20
1.8.4.2
