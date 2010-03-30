From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 0/6] updated cxgb4 submission
Date: Tue, 30 Mar 2010 10:52:16 -0800
Message-ID: <1269975142-30896-1-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:26782 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754968Ab0C3SwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 14:52:23 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o2UIqNgj011235
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 11:52:23 -0700
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id o2UIqMPD030946
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 10:52:22 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id o2UIqMuU030944
	for netdev@vger.kernel.org; Tue, 30 Mar 2010 10:52:22 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is an updated patch series for the cxgb4 driver.  Since the previous
posting there have been some fixes, simplifications, and updates here and
there but nothing extensive in any particular area.

The patches are against net-next as of 36c0d8c.

 drivers/net/Kconfig            |   25 +
 drivers/net/Makefile           |    1 +
 drivers/net/cxgb4/Makefile     |    7 +
 drivers/net/cxgb4/cxgb4.h      |  743 +++++++
 drivers/net/cxgb4/cxgb4_main.c | 4240 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/cxgb4/cxgb4_uld.h  |  235 +++
 drivers/net/cxgb4/l2t.c        |  626 ++++++
 drivers/net/cxgb4/l2t.h        |  110 ++
 drivers/net/cxgb4/sge.c        | 2431 +++++++++++++++++++++++
 drivers/net/cxgb4/t4_hw.c      | 3131 +++++++++++++++++++++++++++++
 drivers/net/cxgb4/t4_hw.h      |  100 +
 drivers/net/cxgb4/t4_msg.h     |  664 +++++++
 drivers/net/cxgb4/t4_regs.h    |  878 +++++++++
 drivers/net/cxgb4/t4fw_api.h   | 1584 +++++++++++++++
 14 files changed, 14775 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/cxgb4/Makefile
 create mode 100644 drivers/net/cxgb4/cxgb4.h
 create mode 100644 drivers/net/cxgb4/cxgb4_main.c
 create mode 100644 drivers/net/cxgb4/cxgb4_uld.h
 create mode 100644 drivers/net/cxgb4/l2t.c
 create mode 100644 drivers/net/cxgb4/l2t.h
 create mode 100644 drivers/net/cxgb4/sge.c
 create mode 100644 drivers/net/cxgb4/t4_hw.c
 create mode 100644 drivers/net/cxgb4/t4_hw.h
 create mode 100644 drivers/net/cxgb4/t4_msg.h
 create mode 100644 drivers/net/cxgb4/t4_regs.h
 create mode 100644 drivers/net/cxgb4/t4fw_api.h
