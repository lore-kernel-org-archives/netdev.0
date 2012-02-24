From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH v3 0/2] Adding new TI Common Platform ethernet SWitch driver
Date: Fri, 24 Feb 2012 16:09:50 +0530
Message-ID: <1330079992-13368-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:56145 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753182Ab2BXKj6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 05:39:58 -0500
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

Changes from v2:

* Modified ale_control structure into named initializer for better readability

* Removed unnecessary WARN_ON after kzalloc as kzalloc itself provide a stack
  dump during alloc failure

* Moved all embedded #defines inside the structure definitions outside for
  better readability

* Added priv variable argument to msg define as it is used, also change msg
  define to multiple defines like cpsw_info, cpsw_err etc

* Used printf extension %pM to print the MAC address

* Added inline functions for cpdma register offsets for better readability

Mugunthan V N (2):
  netdev: driver: ethernet: add cpsw address lookup engine support
  netdev: driver: ethernet: Add TI CPSW driver

 drivers/net/ethernet/ti/Kconfig    |   11 +
 drivers/net/ethernet/ti/Makefile   |    2 +
 drivers/net/ethernet/ti/cpsw.c     | 1060 ++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/ti/cpsw_ale.c |  638 ++++++++++++++++++++++
 drivers/net/ethernet/ti/cpsw_ale.h |   93 ++++
 include/linux/platform_data/cpsw.h |   55 ++
 6 files changed, 1859 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ethernet/ti/cpsw.c
 create mode 100644 drivers/net/ethernet/ti/cpsw_ale.c
 create mode 100644 drivers/net/ethernet/ti/cpsw_ale.h
 create mode 100644 include/linux/platform_data/cpsw.h
