From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH for-next 0/6] IB/hns: Bug Fixes for HNS RoCE Driver
Date: Tue, 29 Nov 2016 23:10:24 +0000
Message-ID: <20161129231030.1105600-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xushaobo2-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <lijun_nudt-9Onoh4P/yGk@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch-set contains bug fixes for the HNS RoCE driver.

Lijun Ou (1):
  IB/hns: Fix the IB device name

Shaobo Xu (2):
  IB/hns: Fix the bug when free mr
  IB/hns: Fix the bug when free cq

Wei Hu (Xavier) (3):
  IB/hns: Fix the bug when destroy qp
  IB/hns: Fix the bug of setting port mtu
  IB/hns: Delete the redundant memset operation

 drivers/infiniband/hw/hns/hns_roce_cmd.h    |    5 -
 drivers/infiniband/hw/hns/hns_roce_common.h |   42 ++
 drivers/infiniband/hw/hns/hns_roce_cq.c     |   27 +-
 drivers/infiniband/hw/hns/hns_roce_device.h |   18 +
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c  |  967 ++++++++++++++++++++++++---
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h  |   57 ++
 drivers/infiniband/hw/hns/hns_roce_main.c   |   26 +-
 drivers/infiniband/hw/hns/hns_roce_mr.c     |   21 +-
 8 files changed, 1026 insertions(+), 137 deletions(-)

-- 
1.7.9.5


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
