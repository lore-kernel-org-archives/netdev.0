From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH net 00/20] Huawei HiNIC Ethernet Driver
Date: Wed, 12 Jul 2017 22:17:06 +0800
Message-ID: <cover.1499865197.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <aviad.krawczyk@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch-set contains the support of the HiNIC Ethernet driver for 
hinic family of PCIE Network interface cards.

The Huawei's PCIE HiNIC card is a new ethernet card and hence there was 
a need of a new driver.

The current driver is meant to be used for the Physical Function and 
there would soon be a support for Virtual Function and more features 
once this basic PF driver has been accepted.

Aviad Krawczyk (20):
  net/hinic: Initialize hw interface
  nic/hinic: Initialize hw device components
  net/hinic: Initialize api cmd resources
  net/hinic: Initialize api cmd hw
  net/hinic: Add management messages
  net/hinic: Add api cmd commands
  net/hinic: Add aeqs
  net/hinic: Add port management commands
  net/hinic: Add Rx mode and link event handler
  net/hinic: Add logical Txq and Rxq
  net/hinic: Add wq
  net/hinic: Add qp resources
  net/hinic: Set qp context
  net/hinic: Initialize cmdq
  net/hinic: Add ceqs
  net/hinic: Add cmdq commands
  net/hinic: Add cmdq completion handler
  net/hinic: Add Rx handler
  net/hinic: Add Tx operation
  net/hinic: Add ethtool and stats

 Documentation/networking/hinic.txt                 |  125 +++
 MAINTAINERS                                        |    7 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/huawei/Kconfig                |   19 +
 drivers/net/ethernet/huawei/Makefile               |    5 +
 drivers/net/ethernet/huawei/hinic/Kconfig          |   13 +
 drivers/net/ethernet/huawei/hinic/Makefile         |    6 +
 drivers/net/ethernet/huawei/hinic/hinic_common.c   |   80 ++
 drivers/net/ethernet/huawei/hinic/hinic_common.h   |   38 +
 drivers/net/ethernet/huawei/hinic/hinic_dev.h      |   65 ++
 .../net/ethernet/huawei/hinic/hinic_hw_api_cmd.c   |  990 +++++++++++++++++
 .../net/ethernet/huawei/hinic/hinic_hw_api_cmd.h   |  208 ++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c  |  942 ++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h  |  302 +++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h   |  149 +++
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c   | 1065 ++++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h   |  239 ++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c   |  879 +++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.h   |  265 +++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_if.c    |  353 ++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_if.h    |  272 +++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_io.c    |  534 +++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_io.h    |   92 ++
 drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.c  |  628 +++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h  |  153 +++
 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c    |  871 +++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h    |  394 +++++++
 .../net/ethernet/huawei/hinic/hinic_hw_qp_ctxt.h   |  214 ++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c    |  867 +++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h    |  111 ++
 drivers/net/ethernet/huawei/hinic/hinic_main.c     | 1153 ++++++++++++++++++++
 .../net/ethernet/huawei/hinic/hinic_pci_id_tbl.h   |   27 +
 drivers/net/ethernet/huawei/hinic/hinic_port.c     |  403 +++++++
 drivers/net/ethernet/huawei/hinic/hinic_port.h     |  198 ++++
 drivers/net/ethernet/huawei/hinic/hinic_rx.c       |  513 +++++++++
 drivers/net/ethernet/huawei/hinic/hinic_rx.h       |   55 +
 drivers/net/ethernet/huawei/hinic/hinic_tx.c       |  513 +++++++++
 drivers/net/ethernet/huawei/hinic/hinic_tx.h       |   62 ++
 39 files changed, 12812 insertions(+)
 create mode 100644 Documentation/networking/hinic.txt
 create mode 100644 drivers/net/ethernet/huawei/Kconfig
 create mode 100644 drivers/net/ethernet/huawei/Makefile
 create mode 100644 drivers/net/ethernet/huawei/hinic/Kconfig
 create mode 100644 drivers/net/ethernet/huawei/hinic/Makefile
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_common.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_common.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_dev.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_if.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_io.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_io.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_qp_ctxt.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_main.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_pci_id_tbl.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_port.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_port.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_rx.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_rx.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_tx.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_tx.h

-- 
1.9.1
