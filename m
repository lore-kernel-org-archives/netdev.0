From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 0/7] cxgb4: new driver submission
Date: Wed, 17 Feb 2010 17:37:35 -0800
Message-ID: <1266457062-31150-1-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:27087 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851Ab0BRBhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 20:37:43 -0500
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o1I1bhh2024558
	for <netdev@vger.kernel.org>; Wed, 17 Feb 2010 17:37:43 -0800
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id o1I1bgAm031199
	for <netdev@vger.kernel.org>; Wed, 17 Feb 2010 17:37:42 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id o1I1bgox031198
	for netdev@vger.kernel.org; Wed, 17 Feb 2010 17:37:42 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The following 7 patches add a new driver cxgb4 for Chelsio's new 1G and 10G
cards.  At this time this is for review and comments, I'll be sending an
updated patch series once any review comments are incorporated.

 drivers/net/Kconfig            |   25 +
 drivers/net/Makefile           |    1 +
 drivers/net/cxgb4/Makefile     |    7 +
 drivers/net/cxgb4/cxgb4.h      |  754 +++++++
 drivers/net/cxgb4/cxgb4_main.c | 4203 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/cxgb4/cxgb4_uld.h  |  230 +++
 drivers/net/cxgb4/l2t.c        |  627 ++++++
 drivers/net/cxgb4/l2t.h        |  110 ++
 drivers/net/cxgb4/sge.c        | 2463 +++++++++++++++++++++++
 drivers/net/cxgb4/t4_hw.c      | 3116 +++++++++++++++++++++++++++++
 drivers/net/cxgb4/t4_hw.h      |  129 ++
 drivers/net/cxgb4/t4_msg.h     | 1353 +++++++++++++
 drivers/net/cxgb4/t4_regs.h    | 2428 +++++++++++++++++++++++
 drivers/net/cxgb4/t4fw_api.h   | 3727 +++++++++++++++++++++++++++++++++++
 14 files changed, 19173 insertions(+), 0 deletions(-)
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
