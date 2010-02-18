From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 0/7] cxgb4 patches V2
Date: Thu, 18 Feb 2010 13:24:09 -0800
Message-ID: <1266528256-20873-1-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:4515 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752452Ab0BRVYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 16:24:30 -0500
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o1ILOUfn032165
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 13:24:30 -0800
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id o1ILOGOw020940
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 13:24:16 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id o1ILOGvt020939
	for netdev@vger.kernel.org; Thu, 18 Feb 2010 13:24:16 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is V2 of the cxgb4 patches.

Changes since V1:
- Whitespace fixed as well as some additional checkpatch issues.
- I removed the CH_* logging wrappers.  I used the new netdev_* in a handful of
  places but mostly stayed with the dev_* functions.
- I added some comments to describe the register macro scheme.  As a macro
  change would involve a rather large number of LOCs I'd really like to avoid
  changing them.

Patches are against net-next 6457d26.

 drivers/net/Kconfig            |   25 +
 drivers/net/Makefile           |    1 +
 drivers/net/cxgb4/Makefile     |    7 +
 drivers/net/cxgb4/cxgb4.h      |  735 +++++++
 drivers/net/cxgb4/cxgb4_main.c | 4217 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/cxgb4/cxgb4_uld.h  |  230 +++
 drivers/net/cxgb4/l2t.c        |  628 ++++++
 drivers/net/cxgb4/l2t.h        |  110 ++
 drivers/net/cxgb4/sge.c        | 2464 +++++++++++++++++++++++
 drivers/net/cxgb4/t4_hw.c      | 3128 +++++++++++++++++++++++++++++
 drivers/net/cxgb4/t4_hw.h      |  128 ++
 drivers/net/cxgb4/t4_msg.h     | 1353 +++++++++++++
 drivers/net/cxgb4/t4_regs.h    | 2109 ++++++++++++++++++++
 drivers/net/cxgb4/t4fw_api.h   | 3727 +++++++++++++++++++++++++++++++++++
 14 files changed, 18862 insertions(+), 0 deletions(-)
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
