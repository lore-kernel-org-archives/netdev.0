From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 0/7] cxgb4: driver submission V3
Date: Fri, 26 Feb 2010 15:35:32 -0800
Message-ID: <1267227339-8076-1-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31595 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966560Ab0BZXlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 18:41:07 -0500
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o1QNf4oY019999
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2010 15:41:04 -0800
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id o1QNZdhg008123
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2010 15:35:39 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id o1QNZdin008122
	for netdev@vger.kernel.org; Fri, 26 Feb 2010 15:35:39 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is V3 of the cxgb4 patches, which is V2 with reworked macro names.

 drivers/net/Kconfig            |   25 +
 drivers/net/Makefile           |    1 +
 drivers/net/cxgb4/Makefile     |    7 +
 drivers/net/cxgb4/cxgb4.h      |  735 +++++++
 drivers/net/cxgb4/cxgb4_main.c | 4234 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/cxgb4/cxgb4_uld.h  |  230 +++
 drivers/net/cxgb4/l2t.c        |  626 ++++++
 drivers/net/cxgb4/l2t.h        |  110 ++
 drivers/net/cxgb4/sge.c        | 2461 +++++++++++++++++++++++
 drivers/net/cxgb4/t4_hw.c      | 3119 +++++++++++++++++++++++++++++
 drivers/net/cxgb4/t4_hw.h      |  100 +
 drivers/net/cxgb4/t4_msg.h     |  649 ++++++
 drivers/net/cxgb4/t4_regs.h    |  873 +++++++++
 drivers/net/cxgb4/t4fw_api.h   | 1535 +++++++++++++++
 14 files changed, 14705 insertions(+), 0 deletions(-)
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
