From: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Subject: [RFC PATCH 0/2] net: ethernet: Add support for gmii2rgmii converter
Date: Fri, 1 Jul 2016 11:50:10 +0530
Message-ID: <1467354012-7364-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <appanad@xilinx.com>, <michal.simek@xilinx.com>,
	<nicolas.ferre@atmel.com>, <punnaia@xilinx.com>,
	<anirudh@xilinx.com>, <harinik@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series does the following
---> Add support for gmii2rgmii converter.
---> Add support for gmii2rgmii converter in the macb driver.

Earlier sent one RFC patch https://patchwork.kernel.org/patch/9186615/ 
which includes converter related stuff also in macb driver.
This patch series fixes this issue.

Kedareswara rao Appana (2):
  net: ethernet: xilinx: Add gmii2rgmii converter support
  net: macb: Add gmii2rgmii phy converter support

 drivers/net/ethernet/cadence/macb.c             |   21 ++++++-
 drivers/net/ethernet/cadence/macb.h             |    3 +
 drivers/net/ethernet/xilinx/Kconfig             |    7 ++
 drivers/net/ethernet/xilinx/Makefile            |    1 +
 drivers/net/ethernet/xilinx/xilinx_gmii2rgmii.c |   76 +++++++++++++++++++++++
 include/linux/xilinx_gmii2rgmii.h               |   24 +++++++
 6 files changed, 131 insertions(+), 1 deletions(-)
 create mode 100644 drivers/net/ethernet/xilinx/xilinx_gmii2rgmii.c
 create mode 100644 include/linux/xilinx_gmii2rgmii.h
