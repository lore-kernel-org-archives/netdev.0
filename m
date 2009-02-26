From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH 0/7] I/OAT update
Date: Thu, 26 Feb 2009 11:04:00 +0100
Message-ID: <20090226100327.3615.21419.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snakebyte@gmx.de, shannon.nelson@intel.com,
	jeffrey.t.krisher@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37824 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753462AbZBZKMn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 05:12:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series updates ioatdma driver
with a couple of fixes and workarounds,
including copybreak modification,
plus some cleanup like copyright dates update.

Maciej Sosnowski (6):
    I/OAT: add verification for proper APICID_TAG_MAP setting by BIOS
    I/OAT: do not set DCACTRL_CMPL_WRITE_ENABLE for I/OAT ver.3
    I/OAT: fail initialization on zero channels detection
    I/OAT: cancel watchdog before dma remove
    I/OAT: set tcp_dma_copybreak to 256k for I/OAT ver.3
    I/OAT: update driver version and copyright dates

Eric Sesterhenn (1):
    I/OAT: list usage cleanup

 drivers/dca/dca-core.c          |    2 -
 drivers/dma/ioat.c              |    2 -
 drivers/dma/ioat_dca.c          |   26 ++++++++++++++++++++++++-
 drivers/dma/ioat_dma.c          |   31 ++++++++++++++++++------------
 drivers/dma/ioatdma.h           |    8 ++++---
 drivers/dma/ioatdma_hw.h        |    2 -
 drivers/dma/ioatdma_registers.h |    2 -
 7 files changed, 53 insertions(+), 20 deletions(-)

--
Maciej
