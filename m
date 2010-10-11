From: Samuel Ortiz <samuel@sortiz.org>
Subject: [GIT PULL net-next-2.6] IrDA 2.6.37 updates
Date: Mon, 11 Oct 2010 02:24:57 +0200
Message-ID: <cover.1286756123.git.sameo@linux.intel.com>
Cc: netdev@vger.kernel.org, Samuel Ortiz <samuel@sortiz.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39169 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751042Ab0JKAZZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Oct 2010 20:25:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I have 5 pending IrDA patches for the next merge window.
The bulk of it is made of the BKL removal for irda, along with a couple of
security fixes.

The following changes since commit 7b738b55b2ec0e95a5030037c45b3c312e385789:

  sundance: get_stats proper locking (2010-10-09 09:22:54 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/sameo/irda-2.6.git for-davem

Roel Kluin (1):
  irda: Test index before read in stir421x_patch_device()

Samuel Ortiz (4):
  irda: Remove BKL instances from af_irda.c
  irda: Remove BKL instances from irnet
  irda: Fix parameter extraction stack overflow
  irda: Fix heap memory corruption in iriap.c

 drivers/net/irda/irda-usb.c |    8 +-
 net/irda/af_irda.c          |  370 +++++++++++++++++++++++--------------------
 net/irda/iriap.c            |    3 +-
 net/irda/irnet/irnet.h      |    2 +
 net/irda/irnet/irnet_ppp.c  |   61 +++++---
 net/irda/parameters.c       |    4 +-
 6 files changed, 249 insertions(+), 199 deletions(-)

