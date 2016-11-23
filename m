From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V3 for-next 00/11] Code improvements & fixes for HNS RoCE driver
Date: Wed, 23 Nov 2016 19:40:58 +0000
Message-ID: <20161123194109.420760-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <xavier.huwei@huawei.com>,
        <oulijun@huawei.com>, <xushaobo2@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <lijun_nudt@163.com>,
        <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <dledford@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset introduces some code improvements and fixes
for the identified problems in the HNS RoCE driver.

Lijun Ou (4):
  IB/hns: Add the interface for querying QP1
  IB/hns: add self loopback for CM
  IB/hns: Modify the condition of notifying hardware loopback
  IB/hns: Fix the bug for qp state in hns_roce_v1_m_qp()

Salil Mehta (1):
  IB/hns: Fix for Checkpatch.pl comment style errors

Shaobo Xu (1):
  IB/hns: Implement the add_gid/del_gid and optimize the GIDs
    management

Wei Hu (Xavier) (5):
  IB/hns: Add code for refreshing CQ CI using TPTR
  IB/hns: Optimize the logic of allocating memory using APIs
  IB/hns: Modify the macro for the timeout when cmd process
  IB/hns: Modify query info named port_num when querying RC QP
  IB/hns: Change qpn allocation to round-robin mode.

 drivers/infiniband/hw/hns/hns_roce_alloc.c  |   11 +-
 drivers/infiniband/hw/hns/hns_roce_cmd.c    |    8 +-
 drivers/infiniband/hw/hns/hns_roce_cmd.h    |    7 +-
 drivers/infiniband/hw/hns/hns_roce_common.h |    2 -
 drivers/infiniband/hw/hns/hns_roce_cq.c     |   17 +-
 drivers/infiniband/hw/hns/hns_roce_device.h |   45 ++--
 drivers/infiniband/hw/hns/hns_roce_eq.c     |    6 +-
 drivers/infiniband/hw/hns/hns_roce_hem.c    |    6 +-
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c  |  267 +++++++++++++++++------
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h  |   17 +-
 drivers/infiniband/hw/hns/hns_roce_main.c   |  311 +++++++--------------------
 drivers/infiniband/hw/hns/hns_roce_mr.c     |   22 +-
 drivers/infiniband/hw/hns/hns_roce_pd.c     |    5 +-
 drivers/infiniband/hw/hns/hns_roce_qp.c     |    2 +-
 14 files changed, 364 insertions(+), 362 deletions(-)

-- 
1.7.9.5
