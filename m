From: Varun Prakash <varun@chelsio.com>
Subject: [net-next PATCH 00/11] iw_cxgb4,cxgbit: remove duplicate code
Date: Tue, 13 Sep 2016 21:23:55 +0530
Message-ID: <cover.1473781521.git.varun@chelsio.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        target-devel@vger.kernel.org, nab@linux-iscsi.org,
        dledford@redhat.com, swise@opengridcomputing.com,
        gerlitz.or@gmail.com, indranil@chelsio.com, varun@chelsio.com
To: davem@davemloft.net
Return-path: <target-devel-owner@vger.kernel.org>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series removes duplicate code from
iw_cxgb4 and cxgbit by adding common function
definitions in libcxgb.

Please review.

Thanks
Varun

Varun Prakash (11):
  libcxgb,iw_cxgb4,cxgbit: add cxgb_get_4tuple()
  libcxgb,iw_cxgb4,cxgbit: add cxgb_find_route()
  libcxgb,iw_cxgb4,cxgbit: add cxgb_find_route6()
  libcxgb,iw_cxgb4,cxgbit: add cxgb_is_neg_adv()
  libcxgb,iw_cxgb4,cxgbit: add cxgb_best_mtu()
  libcxgb,iw_cxgb4,cxgbit: add cxgb_compute_wscale()
  libcxgb,iw_cxgb4,cxgbit: add cxgb_mk_tid_release()
  libcxgb,iw_cxgb4,cxgbit: add cxgb_mk_close_con_req()
  libcxgb,iw_cxgb4,cxgbit: add cxgb_mk_abort_req()
  libcxgb,iw_cxgb4,cxgbit: add cxgb_mk_abort_rpl()
  libcxgb,iw_cxgb4,cxgbit: add cxgb_mk_rx_data_ack()

 drivers/infiniband/hw/cxgb4/Kconfig               |   1 +
 drivers/infiniband/hw/cxgb4/Makefile              |   1 +
 drivers/infiniband/hw/cxgb4/cm.c                  | 288 ++++++----------------
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h            |   9 -
 drivers/net/ethernet/chelsio/libcxgb/Makefile     |   4 +-
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c | 149 +++++++++++
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h | 160 ++++++++++++
 drivers/target/iscsi/cxgbit/cxgbit_cm.c           | 234 +++---------------
 8 files changed, 428 insertions(+), 418 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c
 create mode 100644 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h

-- 
2.0.2
