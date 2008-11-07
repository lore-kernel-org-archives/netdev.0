From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH 0/4] I/OAT fixes
Date: Fri, 07 Nov 2008 12:45:16 +0100
Message-ID: <20081107114325.25190.5419.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tom.s.picard@intel.com, mark_rustad@Xiotech.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	stable@kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65449 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750978AbYKGL4r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2008 06:56:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series contains couple of fixes for I/OAT DMA and DCA.

Maciej Sosnowski (3):
    I/OAT: fix channel resources free for not allocated channels
    I/OAT: fix dma_pin_iovec_pages() error handling
    I/OAT: fix async_tx.callback checking

Dan Williams (1):
    dca: fixup initialization dependency

 drivers/dca/dca-core.c |    2 +-
 drivers/dma/ioat_dma.c |   11 +++++++++--
 drivers/dma/iovlock.c  |   17 ++++++-----------
 3 files changed, 16 insertions(+), 14 deletions(-)

--
Maciej
