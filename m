From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH 0/9] Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,NULL)
Date: Thu, 20 Mar 2014 20:07:10 +0530
Message-ID: <cover.1395324808.git.monamagarwal123@gmail.com>
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
  net/ethernet: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,
    NULL) in drivers/net/ethernet/broadcom/bnx2.c
  net/ethernet: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,
    NULL) in drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
  net: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,
    NULL) in drivers/net/macvtap.c
  net: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,
    NULL) in drivers/net/ppp/pptp.c
  net/wireless: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,
    NULL) in drivers/net/wireless/ath/carl9170/main.c
  scsi: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,
    NULL) in drivers/scsi/libfc/fc_libfc.c
  target: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, 
       NULL) in drivers/target/tcm_fc/tfc_sess.c
  vhost: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,  
      NULL) in drivers/vhost/net.c
  vhost: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,  
      NULL) in drivers/vhost/test.c

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
