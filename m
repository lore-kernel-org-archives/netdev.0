From: =?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH v2 8/8][NET] fec.c: make FEC driver buildable as module
Date: Wed,  7 Dec 2011 14:37:20 +0100
Message-ID: <7338d82895fef133b2593d950ea4638887ed7a32.1323256319.git.LW@KARO-electronics.de>
References: <cover.1323256319.git.LW@KARO-electronics.de>
 <bd4415514fa0b40ece04d56b3ac4f549e79d87d7.1323256319.git.LW@KARO-electronics.de>
 <6c28f25c5c6d2f88d0985ce361c5e16f19db27d0.1323256319.git.LW@KARO-electronics.de>
 <0b92136d69e509a6ce49b526e1834f0ec90b04a4.1323256319.git.LW@KARO-electronics.de>
 <6d1e5cdcbfc48df864ec9e0939645c0e95389d2a.1323256319.git.LW@KARO-electronics.de>
 <55b78c1766da5b0d0d679f5eae3fb9fc74a6ceef.1323256319.git.LW@KARO-electronics.de>
 <d6f4de9e4cfb393754b42815a2ef1a59c96eab83.1323256319.git.LW@KARO-electronics.de>
 <04c11563fee748562d7b53d5e5b3c5cf37fef200.1323256319.git.LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Shawn Guo <shawn.guo@linaro.org>,
	=?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <04c11563fee748562d7b53d5e5b3c5cf37fef200.1323256319.git.LW@KARO-electronics.de>
In-Reply-To: <cover.1323256319.git.LW@KARO-electronics.de>
References: <cover.1323256319.git.LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/ethernet/freescale/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ether=
net/freescale/Kconfig
index c520cfd..b02e315 100644
--- a/drivers/net/ethernet/freescale/Kconfig
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -21,7 +21,7 @@ config NET_VENDOR_FREESCALE
 if NET_VENDOR_FREESCALE
=20
 config FEC
-	bool "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
+	tristate "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
 	depends on (M523x || M527x || M5272 || M528x || M520x || M532x || \
 		   ARCH_MXC || ARCH_MXS)
 	select PHYLIB
--=20
1.5.6.5
