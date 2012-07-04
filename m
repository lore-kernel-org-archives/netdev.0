From: <gerg@snapgear.com>
Subject: [PATCH 0/2] net: support for NS8390 based ethernet on ColdFire CPU boards
Date: Wed, 4 Jul 2012 14:56:27 +1000
Message-ID: <1341377789-12970-1-git-send-email-gerg@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <linux-m68k@vger.kernel.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The following 2 patches add platform support for using the NS8390 based
ethernet ports used on some ColdFire CPU boards. Patches to use these
have existed out-of-tree for years. Some of the base IO definitions 
(those in arch/m68k/include/asm/mcfne.h) have been in mainline, but unused
for most of that time.

The first patch just neatens up mcfne.h (moving it to mcf8390.h). The
second patch is the platform driver. The first patch would normaly just
go through the m68knommu git tree, but I figured keeping these together made
more sense.

---
 arch/m68k/include/asm/mcf8390.h     |  371 ++++++++++++++++++---------
 arch/m68k/include/asm/mcfne.h       |  242 ------------------
 drivers/net/ethernet/8390/Kconfig   |   14 +
 drivers/net/ethernet/8390/Makefile  |    1 
 drivers/net/ethernet/8390/mcf8390.c |  478 ++++++++++++++++++++++++++++++++++++
 5 files changed, 744 insertions(+), 362 deletions(-)
