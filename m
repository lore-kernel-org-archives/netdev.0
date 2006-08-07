From: Kyle McMartin <kyle@parisc-linux.org>
Subject: [PATCH 0/9] tulip patches from parisc-linux
Date: Mon, 7 Aug 2006 16:44:18 -0400
Message-ID: <20060807204418.GE401@athena.road.mcmartin.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, grundler@parisc-linux.org,
	val_henson@linux.intel.com, varenet@parisc-linux.org,
	jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stout.engsoc.carleton.ca ([134.117.69.22]:14294 "EHLO
	stout.engsoc.carleton.ca") by vger.kernel.org with ESMTP
	id S932267AbWHGUo6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 16:44:58 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Val asked that I split this out, instead of just publishing a git tree,
so here goes nothing. I don't think I've ever used git-send-email before,
but hopefully I won't screw up too badly.]

The following patch series brings the mainline tulip driver in synch
with the modifications made in parisc-linux. Most of these patches
have been in parisc-linux cvs for the better part of several years,
so they are quite well tested.

It contains the following changes,

 21142.c       |    4 +-
 de2104x.c     |    6 +--
 interrupt.c   |    4 ++
 media.c       |   40 +++++++++++++++++++++-
 timer.c       |   14 ++++++-
 tulip.h       |   43 ++++++++++++++++++------
 tulip_core.c  |  102 ++++++++++++++++++++++++++++------------------------------
 winbond-840.c |   68 +++++++++++++-------------------------
 8 files changed, 164 insertions(+), 117 deletions(-)

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

Cheers!
	Kyle M.
