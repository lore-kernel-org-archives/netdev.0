From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 0/2] Add device tree support and resolving SOC dependency to cpsw driver
Date: Tue, 31 Jul 2012 01:47:12 +0530
Message-ID: <1343679434-2369-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:38116 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754768Ab2G3UR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 16:17:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds SOC dependency for CPSW dependent modules and adds support
for device tree for CPSW driver

Mugunthan V N (2):
  drivers: net: ethernet: cpsw: Add SOC dependency support for cpsw
    dependent modules
  drivers: net: ethernet: cpsw: Add device tree support to CPSW

 Documentation/devicetree/bindings/net/cpsw.txt |  104 ++++++++++++++
 drivers/net/ethernet/ti/Kconfig                |    4 +-
 drivers/net/ethernet/ti/cpsw.c                 |  174 +++++++++++++++++++++++-
 3 files changed, 274 insertions(+), 8 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/cpsw.txt
