From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next 00/11] FUJITSU Extended Socket driver version 1.1
Date: Mon, 11 Apr 2016 17:08:56 +0900
Message-ID: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym02.jp.fujitsu.com ([211.128.242.41]:36171 "EHLO
	mgwym02.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136AbcDKIRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 04:17:20 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by yt-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 2BC1AAC0057
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 17:17:15 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchsets update FUJITSU Extended Socket network driver into version 1.1.
This mainly includes debugging feature and some minor bugfix. 


Taku Izumi (11):
  fjes: Add trace-gathering facility
  fjes: Add setting/getting register value feature via ioctl
  fjes: Add debugs facility for fjes module
  fjes: Add debugfs entry for statistics
  fjes: show EP stats at statistics file in debugfs
  fjes: optimize timeout value
  fjes: fix incorrect statistics information in fjes_xmit_frame()
  fjes: fix bitwise check bug in fjes_raise_intr_rxdata_task
  fjes: Enhance changing MTU related work
  fjes: Introduce spinlock for rx_status
  fjes: Update fjes driver version : 1.1

 drivers/net/fjes/Makefile       |   2 +-
 drivers/net/fjes/fjes.h         |  16 ++
 drivers/net/fjes/fjes_debugfs.c | 212 +++++++++++++++++++++
 drivers/net/fjes/fjes_hw.c      | 179 +++++++++++++++++-
 drivers/net/fjes/fjes_hw.h      |  43 ++++-
 drivers/net/fjes/fjes_ioctl.h   |  93 ++++++++++
 drivers/net/fjes/fjes_main.c    | 400 +++++++++++++++++++++++++++++++++++++---
 7 files changed, 909 insertions(+), 36 deletions(-)
 create mode 100644 drivers/net/fjes/fjes_debugfs.c
 create mode 100644 drivers/net/fjes/fjes_ioctl.h

-- 
2.4.3
