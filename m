From: "Wei Hu(Xavier)" <xavier.huwei@huawei.com>
Subject: [PATCH 0/4] infiniband: hns: Hisilicon RoCE support
Date: Fri, 4 Mar 2016 16:41:13 +0800
Message-ID: <1457080877-13456-1-git-send-email-xavier.huwei@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <gongyangming@huawei.com>,
	<xiaokun@huawei.com>, <tangchaofei@huawei.com>,
	<oulijun@huawei.com>, <haifeng.wei@huawei.com>,
	<yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<lisheng011@huawei.com>, <charles.chenxin@huawei.com>,
	<linuxarm@huawei.com>
To: <dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
	<ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:7009 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932158AbcCDIca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 03:32:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Hisilicon Network Substem(hns) is a long term evolution IP which is
supposed to be used in Hisilicon ICT SoC. RoCE is a feature of hns.
The driver for Hisilicon RoCE engine is a platform driver.
The driver will support mulitple versions of hns. Currently only "v1"
for hip06 SOC is supported.

Wei Hu(Xavier) (4):
  net: hns: add Hisilicon RoCE support(the dependent routine)
  infiniband: hns: add Hisilicon RoCE support(binding)
  infiniband: hns: add Hisilicon RoCE support(driver code)
  infiniband: hns: add Hisilicon RoCE support(Kconfig)

 .../bindings/infiniband/hisilicon-hns-roce.txt     |   68 +
 drivers/infiniband/Kconfig                         |    2 +-
 drivers/infiniband/hw/Makefile                     |    1 +
 drivers/infiniband/hw/hisilicon/hns/Kconfig        |   10 +
 drivers/infiniband/hw/hisilicon/hns/Makefile       |    9 +
 drivers/infiniband/hw/hisilicon/hns/hns_roce_ah.c  |  114 +
 .../infiniband/hw/hisilicon/hns/hns_roce_alloc.c   |  256 ++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.c |  370 +++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.h |  173 ++
 .../infiniband/hw/hisilicon/hns/hns_roce_common.h  |  704 +++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_cq.c  |  481 +++
 .../infiniband/hw/hisilicon/hns/hns_roce_device.h  |  870 ++++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.c  |  835 ++++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.h  |  138 +
 drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.c |  637 ++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.h |  130 +
 .../infiniband/hw/hisilicon/hns/hns_roce_main.c    | 1147 +++++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_mr.c  |  671 +++++
 drivers/infiniband/hw/hisilicon/hns/hns_roce_pd.c  |  130 +
 drivers/infiniband/hw/hisilicon/hns/hns_roce_qp.c  |  945 ++++++
 .../infiniband/hw/hisilicon/hns/hns_roce_user.h    |   31 +
 .../infiniband/hw/hisilicon/hns/hns_roce_v1_hw.c   | 3146 ++++++++++++++++++++
 .../infiniband/hw/hisilicon/hns/hns_roce_v1_hw.h   | 1071 +++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |   82 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |    7 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |   62 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |   14 +
 27 files changed, 12093 insertions(+), 11 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/infiniband/hisilicon-hns-roce.txt
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/Kconfig
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/Makefile
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_ah.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_alloc.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.h
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_common.h
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_cq.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_device.h
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.h
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.h
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_main.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_mr.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_pd.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_qp.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_user.h
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_v1_hw.c
 create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_v1_hw.h

-- 
1.9.1
