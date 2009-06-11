From: Karsten Keil <keil@b1-systems.de>
Subject: [PATCH 0/6] ISDN fixes
Date: Thu, 11 Jun 2009 19:06:34 +0200
Message-ID: <cover.1244739994.git.keil@b1-systems.de>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	i4ldeveloper@listserv.isdn4linux.de
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754832AbZFKR2W@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some more fixes for ISDN.

You can pull it from
git://master.kernel.org/pub/scm/linux/kernel/git/kkeil/ISDN-2.6-net-next.git for_david

Andreas Mohr (1):
  mISDN: Free hfcpci IRQ if init was not successful

Karsten Keil (4):
  ISDN:Fix DMA alloc for hfcpci
  mISDN: Fix overlapping data access
  mISDN: Do not disable IRQ in ph_data_ind()
  mISDN: cleanup mISDNhw.h

Roel Kluin (1):
  drivers/isdn/i4l/isdn_tty.c: fix check for array overindexing

 drivers/isdn/hardware/mISDN/hfcpci.c |    7 ++---
 drivers/isdn/hisax/hfc_pci.c         |   41 ++++++++++++++++++++++++---------
 drivers/isdn/hisax/hisax.h           |    2 +-
 drivers/isdn/i4l/isdn_tty.c          |    2 +-
 drivers/isdn/mISDN/dsp_pipeline.c    |   11 ++++-----
 drivers/isdn/mISDN/tei.c             |    7 +----
 include/linux/mISDNhw.h              |   10 --------
 7 files changed, 42 insertions(+), 38 deletions(-)
