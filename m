From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next v2 0/6] FUJITSU Extended Socket driver version 1.2
Date: Fri, 14 Oct 2016 20:25:44 +0900
Message-ID: <1476444345-28673-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm04.jp.fujitsu.com ([202.219.69.171]:11172 "EHLO
        mgwkm04.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753423AbcJNLiL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 07:38:11 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
        by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 78E52AC0228
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 20:36:46 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset updates FUJITSU Extended Socket network driver into version 1.2.
This includes the following enhancements:
  - ethtool -d support
  - ethtool -S enhancement
  - ethtool -w/-W support
  - Add some debugging feature (tracepoints etc)

v1 -> v2:
  - Use u64 instead of phys_addr_t as TP_STRUCT__entry
  - Use ethtool facility to achieve debug mode instead of using debugfs


Taku Izumi (6):
  fjes: ethtool -d support for fjes driver
  fjes: Enhance ethtool -S for fjes driver
  fjes: Add tracepoints in fjes driver
  fjes: ethtool -w and -W support for fjes driver
  fjes: Add debugfs entry for EP status information in fjes driver
  fjes: Update fjes driver version : 1.2

 drivers/net/fjes/Makefile       |   2 +-
 drivers/net/fjes/fjes.h         |  16 ++
 drivers/net/fjes/fjes_debugfs.c | 117 +++++++++++++
 drivers/net/fjes/fjes_ethtool.c | 181 ++++++++++++++++++-
 drivers/net/fjes/fjes_hw.c      | 171 +++++++++++++++++-
 drivers/net/fjes/fjes_hw.h      |  34 ++++
 drivers/net/fjes/fjes_main.c    |  63 ++++++-
 drivers/net/fjes/fjes_trace.c   |  30 ++++
 drivers/net/fjes/fjes_trace.h   | 380 ++++++++++++++++++++++++++++++++++++++++
 9 files changed, 983 insertions(+), 11 deletions(-)
 create mode 100644 drivers/net/fjes/fjes_debugfs.c
 create mode 100644 drivers/net/fjes/fjes_trace.c
 create mode 100644 drivers/net/fjes/fjes_trace.h

-- 
2.6.6
