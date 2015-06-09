From: Praveen Madhavan <praveenm@chelsio.com>
Subject: [PATCH 0/3] csiostor:Debugfs support update.
Date: Tue,  9 Jun 2015 18:44:43 +0530
Message-ID: <1433855686-15768-1-git-send-email-praveenm@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com,
	hariprasad@chelsio.com, praveenm@chelsio.com, varun@chelsio.com,
	rajesh.kumar@chelsio.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series adds debugfs functionality to dump adapter log,
adapter queues and fcoe DDP stats.

This patch has been created against net-next. 

Praveen Madhavan (3):
  csiostor:Add devlog mailbox support.
  csiostor:Cleanup debugfs.
  csiostor:Adds debugfs support.

 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h |    1 +
 drivers/scsi/csiostor/Makefile               |    2 +-
 drivers/scsi/csiostor/csio_debugfs.c         | 1100 ++++++++++++++++++++++++++
 drivers/scsi/csiostor/csio_hw.c              |   72 +-
 drivers/scsi/csiostor/csio_hw.h              |   12 +
 drivers/scsi/csiostor/csio_init.c            |  132 ----
 drivers/scsi/csiostor/csio_init.h            |    4 +
 drivers/scsi/csiostor/csio_mb.c              |   60 +-
 drivers/scsi/csiostor/csio_mb.h              |   17 +-
 9 files changed, 1237 insertions(+), 163 deletions(-)
 create mode 100644 drivers/scsi/csiostor/csio_debugfs.c

-- 
2.0.2

