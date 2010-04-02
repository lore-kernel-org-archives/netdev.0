From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 0/6] updated cxgb4 submission v6
Date: Thu,  1 Apr 2010 17:28:21 -0800
Message-ID: <1270171707-26058-1-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:30827 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757573Ab0DBB3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 21:29:01 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o321T0Px031525
	for <netdev@vger.kernel.org>; Thu, 1 Apr 2010 18:29:00 -0700
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id o321SRj2026110
	for <netdev@vger.kernel.org>; Thu, 1 Apr 2010 17:28:27 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id o321SRZr026109
	for netdev@vger.kernel.org; Thu, 1 Apr 2010 17:28:27 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is an updated patch series for the cxgb4 driver.  Changes from previous
version:

- Replaced __u* types with u*
- Of the proc files I kept one and moved it to debugfs (it dumps a largish
table, it's not a good fit for a value-per-file model).  I've removed all
the other proc files.  I'll look at making some of their information available
in sysfs as separate work.

The patches are against net-next as of 6c57990.

 drivers/net/Kconfig            |   25 +
 drivers/net/Makefile           |    1 +
 drivers/net/cxgb4/Makefile     |    7 +
 drivers/net/cxgb4/cxgb4.h      |  741 +++++++++
 drivers/net/cxgb4/cxgb4_main.c | 3388 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/cxgb4/cxgb4_uld.h  |  239 +++
 drivers/net/cxgb4/l2t.c        |  624 ++++++++
 drivers/net/cxgb4/l2t.h        |  110 ++
 drivers/net/cxgb4/sge.c        | 2431 ++++++++++++++++++++++++++++
 drivers/net/cxgb4/t4_hw.c      | 3131 +++++++++++++++++++++++++++++++++++++
 drivers/net/cxgb4/t4_hw.h      |  100 ++
 drivers/net/cxgb4/t4_msg.h     |  664 ++++++++
 drivers/net/cxgb4/t4_regs.h    |  878 +++++++++++
 drivers/net/cxgb4/t4fw_api.h   | 1580 +++++++++++++++++++
 14 files changed, 13919 insertions(+), 0 deletions(-)
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
