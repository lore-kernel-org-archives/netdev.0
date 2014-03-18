From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH 0/9] Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,NULL)
Date: Wed, 19 Mar 2014 04:09:19 +0530
Message-ID: <cover.1395182132.git.monamagarwal123@gmail.com>
Cc: linux-kernel@vger.kernel.org, eddie.wai@broadcom.com,
	paulmck@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset uses following coccinelle script to replace 
rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,NULL)

@@
expression E;
@@
- rcu_assign_pointer(
+ RCU_INIT_POINTER(
E, NULL)

Monam Agarwal (9):
  rcu: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,
    NULL)     in drivers/net/ethernet/broadcom/bnx2.c
  rcu: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,
    NULL)     in drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
  rcu: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,
    NULL)     in drivers/net/macvtap.c
  rcu: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,
    NULL)
  rcu: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,
    NULL)
  rcu: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,
    NULL)
  rcu: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,
    NULL)
  rcu: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,
    NULL)
  rcu: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,
    NULL)

 drivers/net/ethernet/broadcom/bnx2.c               |    2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c |    4 ++--
 drivers/net/macvtap.c                              |    8 ++++----
 drivers/net/ppp/pptp.c                             |    2 +-
 drivers/net/wireless/ath/carl9170/main.c           |   12 ++++++------
 drivers/scsi/libfc/fc_libfc.c                      |    4 ++--
 drivers/target/tcm_fc/tfc_sess.c                   |    2 +-
 drivers/vhost/net.c                                |    2 +-
 drivers/vhost/test.c                               |    2 +-
 9 files changed, 19 insertions(+), 19 deletions(-)

-- 
1.7.9.5
