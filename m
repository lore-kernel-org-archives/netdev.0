From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next 0/6] FUJITSU Extended Socket driver version 1.2
Date: Tue, 11 Oct 2016 17:54:07 +0900
Message-ID: <1476176047-18670-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym01.jp.fujitsu.com ([211.128.242.40]:31803 "EHLO
        mgwym01.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752446AbcJKJ1W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 05:27:22 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
        by yt-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id B994BAC00F8
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 18:05:05 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Taku <izumi.taku@jp.fujitsu.com>

This patchset updates FUJITSU Extended Socket network driver into version 1.2.
This includes the following enhancements:
  - ethtool -d support
  - ethtool -S enhancement
  - Add some debugging feature (tracepoints etc)

Taku Izumi (6):
  fjes: ethtool -d support for fjes driver
  fjes: Enhance ethtool -S for fjes driver
  fjes: Add tracepoints in fjes driver
  fjes: Implement debug mode for fjes driver
  fjes: Add debugfs entry for EP status information in fjes driver
  fjes: Update fjes driver version : 1.2

 drivers/net/fjes/Makefile       |   2 +-
 drivers/net/fjes/fjes.h         |  18 ++
 drivers/net/fjes/fjes_debugfs.c | 220 +++++++++++++++++++++++
 drivers/net/fjes/fjes_ethtool.c | 118 ++++++++++++-
 drivers/net/fjes/fjes_hw.c      | 156 +++++++++++++++-
 drivers/net/fjes/fjes_hw.h      |  34 ++++
 drivers/net/fjes/fjes_main.c    |  63 ++++++-
 drivers/net/fjes/fjes_trace.c   |  30 ++++
 drivers/net/fjes/fjes_trace.h   | 381 ++++++++++++++++++++++++++++++++++++++++
 9 files changed, 1011 insertions(+), 11 deletions(-)
 create mode 100644 drivers/net/fjes/fjes_debugfs.c
 create mode 100644 drivers/net/fjes/fjes_trace.c
 create mode 100644 drivers/net/fjes/fjes_trace.h

-- 
2.6.6
