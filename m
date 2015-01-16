From: Praveen Madhavan <praveenm@chelsio.com>
Subject: [PATCH v2 0/2] csiostor:Remove T4 FCoE support
Date: Fri, 16 Jan 2015 21:30:18 +0530
Message-ID: <cover.1421423434.git.praveenm@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com, hch@infradead.org,
	hariprasad@chelsio.com, praveenm@chelsio.com, varun@chelsio.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We found a subtle issue with FCoE on T4 very late in the game
and decided not to productize FCoE on T4 and therefore there
are no customers that will be impacted by this change. FCoE is
supported on T5 cards.

Please apply on net-next since depends on previous commits.

Changes in v2:
  - Make the commit message more clearer.

Praveen Madhavan (2):
  csiostor:Remove T4 FCoE Support.
  csiostor:Removed file csio_hw_t4.c

 drivers/scsi/csiostor/Makefile       |   2 +-
 drivers/scsi/csiostor/csio_hw.c      |  61 ++----
 drivers/scsi/csiostor/csio_hw_chip.h |  43 ----
 drivers/scsi/csiostor/csio_hw_t4.c   | 404 -----------------------------------
 drivers/scsi/csiostor/csio_init.c    |   6 +-
 drivers/scsi/csiostor/csio_wr.c      |  15 +-
 6 files changed, 25 insertions(+), 506 deletions(-)
 delete mode 100644 drivers/scsi/csiostor/csio_hw_t4.c

-- 
2.0.2

