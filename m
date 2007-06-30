From: dhananjay.phadke@gmail.com
Subject: [PATCH 0/3] NetXen: Bug fixes for multiport and blade adapters
Date: Sun, 01 Jul 2007 02:08:44 +0530
Message-ID: <20070630203844.256007454@netxen.com>
Cc: rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.199.144.227] ([203.199.144.227]:2710 "EHLO
	stellar.unminc.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752597AbXF3VTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 17:19:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sending reworked patches based on Michael's feedback (originally sent
by Mithlesh Thukral). These patches address interrupt mask issues on 
multiport adapters, as well as stability issues on powerpc blades.

-- 
Dhananjay Phadke
NetXen Inc.

 drivers/net/netxen/netxen_nic.h          |  176 +++++++++++++++++++++++++++---
 drivers/net/netxen/netxen_nic_hdr.h      |    2 +
 drivers/net/netxen/netxen_nic_hw.c       |   33 ++++--
 drivers/net/netxen/netxen_nic_init.c     |   56 ++++++----
 drivers/net/netxen/netxen_nic_main.c     |  176 +++++++++++++++++++-----------
 drivers/net/netxen/netxen_nic_phan_reg.h |   14 +++
 6 files changed, 341 insertions(+), 116 deletions(-)
