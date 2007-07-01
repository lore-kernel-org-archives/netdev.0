From: dhananjay.phadke@gmail.com
Subject: RESEND [PATCH 0/3] NetXen: Bug fixes for multiport and blade adapters
Date: Mon, 02 Jul 2007 00:25:58 +0530
Message-ID: <20070701185558.881537150@netxen.com>
Cc: rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.199.144.227] ([203.199.144.227]:2210 "EHLO
	stellar.unminc.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754716AbXGATDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2007 15:03:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removed signal_pending checks during init, per Jeff's suggestion.


 drivers/net/netxen/netxen_nic.h          |  180 +++++++++++++++++++++++++++---
 drivers/net/netxen/netxen_nic_hdr.h      |    2 +
 drivers/net/netxen/netxen_nic_hw.c       |   33 ++++--
 drivers/net/netxen/netxen_nic_init.c     |   51 +++++----
 drivers/net/netxen/netxen_nic_main.c     |  177 ++++++++++++++++++-----------
 drivers/net/netxen/netxen_nic_phan_reg.h |   14 +++
 6 files changed, 341 insertions(+), 116 deletions(-)
