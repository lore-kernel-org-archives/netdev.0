From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: FEC patches
Date: Thu, 29 Jan 2009 10:03:02 +0100
Message-ID: <1233219791-18691-1-git-send-email-s.hauer@pengutronix.de>
Cc: David Miller <davem@davemloft.net>,
	Greg Ungerer <gerg@snapgear.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48048 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751637AbZA2JDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 04:03:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Please merge the following patches. The only change since I last sent
them is that I added CONFIG_M520x to the list of supported architectures
as Greg requested.

Regards
  Sascha

If you prefer to pull them via git, you can do it here:

The following changes since commit 5ee810072175042775e39bdd3eaaa68884c27805:
  Linus Torvalds (1):
        Fix "multiple definition of `debugfs_create_size_t'"

are available in the git repository at:

  git://pasiphae.extern.pengutronix.de/git/imx/linux-2.6.git fec-pu

Sascha Hauer (9):
      fec: remove unused #else branches
      fec: remove empty functions
      fec: use linux/*.h instead of asm/*.h
      fec: do not use memcpy on physical addresses
      fec: use dma_alloc_coherent for descriptor ring
      fec: Fix KS8721BL_ICSR phy register offset
      fec: replace flush_dcache_range with dma_sync_single
      fec: Add support for Freescale MX27
      FEC: Turn FEC driver into platform device driver

 drivers/net/Kconfig |    6 +-
 drivers/net/fec.c   |  446 ++++++++++++++++++++++++++++-----------------------
 drivers/net/fec.h   |   11 +-
 3 files changed, 260 insertions(+), 203 deletions(-)



