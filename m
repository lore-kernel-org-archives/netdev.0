From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH v5 0/2] Adding new TI Common Platform ethernet SWitch driver
Date: Mon, 19 Mar 2012 11:47:52 +0530
Message-ID: <1332137874-3247-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:55702 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932119Ab2CSGSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 02:18:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains driver implementation for TI Common Platform
ethernet SWitch (CPSW) driver.

CPSW is found in following SoC.
* AM335X - http://www.ti.com/litv/pdf/spruh73c
* DM814X - http://www.ti.com/litv/pdf/sprugz8

CPSW:
The three port switch gigabit ethernet subsystem provides ethernet packet
communication and can be configured as an ethernet switch.  It
supports 10/100/1000 Mbps. It provides the gigabit media independent
interface (G/MII), reduced gigabit media independent interface (RGMII),
reduced media independent interface (RMII), the management data input
output (MDIO) for physical layer device (PHY) management.

Changes from v4:

* Handled Kzalloc failure in cpsw_ale_create

* Removed pr_fmt as it is not used in driver

* removed "cpsw" prefix as it is not required

Mugunthan V N (2):
  netdev: driver: ethernet: add cpsw address lookup engine support
  netdev: driver: ethernet: Add TI CPSW driver

 drivers/net/ethernet/ti/Kconfig    |   11 +
 drivers/net/ethernet/ti/Makefile   |    2 +
 drivers/net/ethernet/ti/cpsw.c     | 1018 ++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/ti/cpsw_ale.c |  641 +++++++++++++++++++++++
 drivers/net/ethernet/ti/cpsw_ale.h |   93 ++++
 include/linux/platform_data/cpsw.h |   55 ++
 6 files changed, 1820 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ethernet/ti/cpsw.c
 create mode 100644 drivers/net/ethernet/ti/cpsw_ale.c
 create mode 100644 drivers/net/ethernet/ti/cpsw_ale.h
 create mode 100644 include/linux/platform_data/cpsw.h
