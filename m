From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next v2 0/6] FUJITSU Extended Socket driver version 1.1
Date: Fri, 15 Apr 2016 11:20:00 +0900
Message-ID: <1460686800-26427-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: jiri@resnulli.us, isimatu.yasuaki@jp.fujitsu.com,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym03.jp.fujitsu.com ([211.128.242.42]:42321 "EHLO
	mgwym03.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752866AbcDOC2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 22:28:33 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by yt-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id BCFB1AC004F
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 11:28:26 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchsets update FUJITSU Extended Socket network driver into version 1.1.
This mainly includes some improvements and minor bugfix.

v1->v2:
  - Remove ioctl and debugfs facility according to David comment

Taku Izumi (6):
  fjes: optimize timeout value
  fjes: fix incorrect statistics information in fjes_xmit_frame()
  fjes: fix bitwise check bug in fjes_raise_intr_rxdata_task
  fjes: Enhance changing MTU related work
  fjes: Introduce spinlock for rx_status
  fjes: Update fjes driver version : 1.1

 drivers/net/fjes/fjes_hw.c   |  30 +++++++++-
 drivers/net/fjes/fjes_hw.h   |   9 ++-
 drivers/net/fjes/fjes_main.c | 132 +++++++++++++++++++++++++++++++++++--------
 3 files changed, 141 insertions(+), 30 deletions(-)

-- 
2.4.3
