From: y@pengutronix.de
Subject: FEC Patches V2
Date: Tue, 27 Jan 2009 11:23:59 +0100
Message-ID: <43657.448833301$1233051941@news.gmane.org>
Cc: Greg Ungerer <gerg@snapgear.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42848 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124AbZA0KYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 05:24:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all, hi Greg,

These patches are an updated version from the ones I posted some time ago.
They give the FEC ethernet driver a facelift and turn it into a
platform_device driver. The Coldfire cores are still supported through
legacy ifdefs. The platform driver support has been tested on a
Freescale i.MX27 SoC.

Sascha

The following changes since commit 5ee810072175042775e39bdd3eaaa68884c27805:
  Linus Torvalds (1):
        Fix "multiple definition of `debugfs_create_size_t'"

are available in the git repository at:

  git://git.pengutronix.de/git/imx/linux-2.6.git fec-pu

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
 drivers/net/fec.c   |  443 ++++++++++++++++++++++++++++-----------------------
 drivers/net/fec.h   |   11 +-
 3 files changed, 257 insertions(+), 203 deletions(-)


