From: =?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH v2 0/8][NET] fec.c: several cleanups and bugfixes
Date: Wed,  7 Dec 2011 14:37:12 +0100
Message-ID: <cover.1323256319.git.LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Shawn Guo <shawn.guo@linaro.org>,
	=?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following set of patches provides some cleanup and bugfixes for
drivers/net/ethernet/freescale/fec.c and makes the driver buildable as
a module.

Changes wrt v1:
 - more appropriate subject lines
 - fix a messup in patch 7: mii_cnt must be a driver global variable

Lothar Wa=C3=9Fmann (8):
  misc cleanups
  set con_id in clk_get() call to NULL
  prevent dobule restart of interface on FDX/HDX change
  don't request invalid IRQ
  don't munge MAC address from platform data
  preserve MII/RMII setting in fec_stop()
  fix the .remove code
  make FEC driver buildable as module

 drivers/net/ethernet/freescale/Kconfig |    2 +-
 drivers/net/ethernet/freescale/fec.c   |   63 ++++++++++++++++++++++--=
--------
 2 files changed, 44 insertions(+), 21 deletions(-)
