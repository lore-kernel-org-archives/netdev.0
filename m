From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH v4 0/2] Adding new TI Common Platform ethernet SWitch driver
Date: Wed, 29 Feb 2012 10:15:35 +0530
Message-ID: <1330490737-28973-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:55690 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964932Ab2B2Epo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2012 23:45:44 -0500
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

Changes from v3:

* Removed "struct cpsw_hw_stats" as it is not used in current driver
  implementation

* Added Module Authors

Mugunthan V N (2):
  netdev: driver: ethernet: add cpsw address lookup engine support
  netdev: driver: ethernet: Add TI CPSW driver

 drivers/net/ethernet/ti/Kconfig    |   11 +
 drivers/net/ethernet/ti/Makefile   |    2 +
 drivers/net/ethernet/ti/cpsw.c     | 1022 ++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/ti/cpsw_ale.c |  638 ++++++++++++++++++++++
 drivers/net/ethernet/ti/cpsw_ale.h |   93 ++++
 include/linux/platform_data/cpsw.h |   55 ++
 6 files changed, 1821 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ethernet/ti/cpsw.c
 create mode 100644 drivers/net/ethernet/ti/cpsw_ale.c
 create mode 100644 drivers/net/ethernet/ti/cpsw_ale.h
 create mode 100644 include/linux/platform_data/cpsw.h
