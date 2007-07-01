From: dhananjay.phadke@gmail.com
Subject: RESEND [PATCH 0/3] NetXen: Bug fixes for multiport and blade adapters
Date: Sun, 01 Jul 2007 08:13:25 +0530
Message-ID: <20070701024325.287283308@netxen.com>
Cc: rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.199.144.227] ([203.199.144.227]:2944 "EHLO
	stellar.unminc.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754698AbXGACuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 22:50:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Resending with changes suggested.

-- 
Dhananjay Phadke
NetXen Inc.

 drivers/net/netxen/netxen_nic.h          |  177 +++++++++++++++++++++++++++---
 drivers/net/netxen/netxen_nic_hdr.h      |    2 +
 drivers/net/netxen/netxen_nic_hw.c       |   39 +++++--
 drivers/net/netxen/netxen_nic_init.c     |   64 +++++++----
 drivers/net/netxen/netxen_nic_main.c     |  177 +++++++++++++++++++-----------
 drivers/net/netxen/netxen_nic_phan_reg.h |   14 +++
 6 files changed, 357 insertions(+), 116 deletions(-)
