From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 0/9] cxgb4 updates
Date: Mon,  2 Aug 2010 16:19:15 -0700
Message-ID: <1280791164-14181-1-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:26108 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727Ab0HBXTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 19:19:25 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o72NJOCN025620
	for <netdev@vger.kernel.org>; Mon, 2 Aug 2010 16:19:24 -0700
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id o72NJODw014224
	for <netdev@vger.kernel.org>; Mon, 2 Aug 2010 16:19:24 -0700
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id o72NJOIC014223
	for netdev@vger.kernel.org; Mon, 2 Aug 2010 16:19:24 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Following are 9 patches for cxgb4.  A few small fixes, new PCI ids, and a
couple features.

 drivers/net/cxgb4/cxgb4.h      |    3 +-
 drivers/net/cxgb4/cxgb4_main.c |  172 +++++++++++++++++++++++++--------------
 drivers/net/cxgb4/cxgb4_uld.h  |    4 +
 drivers/net/cxgb4/sge.c        |   67 +++++++++-------
 drivers/net/cxgb4/t4_hw.c      |    2 +-
 drivers/net/cxgb4/t4_hw.h      |    2 +-
 drivers/net/cxgb4/t4_msg.h     |    2 +
 drivers/net/cxgb4/t4_regs.h    |    1 +
 drivers/net/cxgb4/t4fw_api.h   |    2 +
 9 files changed, 161 insertions(+), 94 deletions(-)
