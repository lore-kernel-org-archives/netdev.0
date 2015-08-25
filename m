From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 0/6] RDS: Few more fixes
Date: Tue, 25 Aug 2015 12:01:57 -0700
Message-ID: <1440529323-4171-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As indicated in the earlier series [1], this is a follow-up series which
addresses few issues around the RDS FMR code. With [1] and the subject
series, now I can run many parallel threads with multiple sockets with
N x N traffic. The stress tests has survived overnight runs.


Santosh Shilimkar (5):
  RDS: fix the dangling reference to rds_ib_incoming_slab
  RDS: Fix rds MR reference count in rds_rdma_unuse()
  RDS: push FMR pool flush work to its own worker
  RDS: flush the FMR pool less often
  RDS: remove superfluous from rds_ib_alloc_fmr()

Wengang Wang (1):
  RDS: fix fmr pool dirty_count

 net/rds/ib.c      |  9 ++++++++-
 net/rds/ib.h      |  2 ++
 net/rds/ib_rdma.c | 46 ++++++++++++++++++++++++++++++++++------------
 net/rds/ib_recv.c |  5 +++--
 net/rds/rdma.c    |  5 +++--
 5 files changed, 50 insertions(+), 17 deletions(-)

Regards,
Santosh

[1] https://lkml.org/lkml/2015/8/22/127
-- 
1.9.1
