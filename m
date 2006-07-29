From: Kyle McMartin <kyle@parisc-linux.org>
Subject: [git patches] tulip fixes from parisc-linux
Date: Sat, 29 Jul 2006 18:54:59 -0400
Message-ID: <20060729225459.GA4835@athena.road.mcmartin.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: parisc-linux@lists.parisc-linux.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stout.engsoc.carleton.ca ([134.117.69.22]:11185 "EHLO
	stout.engsoc.carleton.ca") by vger.kernel.org with ESMTP
	id S1750743AbWG2Wzk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jul 2006 18:55:40 -0400
To: Valerie Henson <val_henson@linux.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Val,

Sorry it took so long for me to get around to splitting
up the changes from the parisc-linux tree. But here
they finally are. This patchset has been running on a
variety of parisc and ia64 machines for quite some
time (several years...) without issue. Some of these
are more cosmetic changes than anything else.

Cheers,
	Kyle M.

The following changes since commit dc710afe95ee9b263ab593c11d86a684f1606872:
  Linus Torvalds:
        Merge branch 'upstream-linus' of master.kernel.org:/.../jgarzik/libata-dev

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kyle/tulip-2.6.git

Francois Romieu:
      [TULIP] Defer tulip_select_media() to process context

Grant Grundler:
      [TULIP] Fix PHY init and reset
      [TULIP] Print physical address in tulip_init_one
      [TULIP] Make tulip_stop_rxtx() failure case slightly more informative
      [TULIP] Clean tulip.h so it can be used by winbond-840.c
      [TULIP] Flush MMIO writes in reset sequence
      [TULIP] Fix IRQ/DMA race

Helge Deller:
      [TULIP] Fix section mismatch in de2104x.c

Thibaut Varene:
      [TULIP] Make DS21143 printout match lspci output

 drivers/net/tulip/21142.c       |    4 +-
 drivers/net/tulip/de2104x.c     |    6 +-
 drivers/net/tulip/interrupt.c   |    4 ++
 drivers/net/tulip/media.c       |   40 ++++++++++++++-
 drivers/net/tulip/timer.c       |   14 +++++
 drivers/net/tulip/tulip.h       |   43 ++++++++++++----
 drivers/net/tulip/tulip_core.c  |  102 +++++++++++++++++++--------------------
 drivers/net/tulip/winbond-840.c |   68 +++++++++-----------------
 8 files changed, 164 insertions(+), 117 deletions(-)
