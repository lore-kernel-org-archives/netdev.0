From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 0/2] Adding new TI Common Platform ethernet SWitch driver
Date: Mon, 13 Feb 2012 11:34:19 +0530
Message-ID: <1329113061-13026-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:50481 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750875Ab2BMGE2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 01:04:28 -0500
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

Mugunthan V N (2):
  netdev: driver: ethernet: add cpsw address lookup engine support
  netdev: driver: ethernet: Add TI CPSW driver

 drivers/net/ethernet/ti/Kconfig    |   11 +
 drivers/net/ethernet/ti/Makefile   |    2 +
 drivers/net/ethernet/ti/cpsw.c     | 1095 ++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/ti/cpsw_ale.c |  505 +++++++++++++++++
 drivers/net/ethernet/ti/cpsw_ale.h |   99 ++++
 include/linux/platform_data/cpsw.h |   55 ++
 6 files changed, 1767 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ethernet/ti/cpsw.c
 create mode 100644 drivers/net/ethernet/ti/cpsw_ale.c
 create mode 100644 drivers/net/ethernet/ti/cpsw_ale.h
 create mode 100644 include/linux/platform_data/cpsw.h
