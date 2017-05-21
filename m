From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 00/10] qed/qede updates
Date: Sun, 21 May 2017 12:10:51 +0300
Message-ID: <1495357860-28280-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0058.outbound.protection.outlook.com ([104.47.34.58]:43779
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751068AbdEUJLO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 21 May 2017 05:11:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains some general minor fixes and enhancements:

 - #1, #2 and #9 correct small missing ethtool functionality.
 - #3, #6  and #8 correct minor issues in driver, but those are either
   print-related or unexposed in existing code.
 - #4 adds proper support to TLB mode bonding.
 - #10 is meant to improve performance on varying cache-line sizes.

Dave,

Please consider applying this to `net-next'.

Thanks,
Yuval

Sudarsana Reddy Kalluru (3):
  qede: Support 1G advertisment
  qede: Honor user request for Tx buffers
  qede: Add missing Status-block free

Tomer Tayar (2):
  qed: Revise alloc/setup/free flow
  qed: Fix setting of Management bitfields

Yuval Mintz (5):
  qede: Allow WoL to activate by default
  qede: Don't use an internal MAC field
  qed: Correct print in iscsi error-flow
  qede: qedr closure after setting state
  qed: Cache alignemnt padding to match host

 drivers/net/ethernet/qlogic/qed/qed.h           |  2 +-
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c      |  1 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c       | 94 ++++++++++++-------------
 drivers/net/ethernet/qlogic/qed/qed_fcoe.c      | 23 +++---
 drivers/net/ethernet/qlogic/qed/qed_fcoe.h      | 22 ++----
 drivers/net/ethernet/qlogic/qed/qed_init_ops.c  |  4 ++
 drivers/net/ethernet/qlogic/qed/qed_int.c       |  3 +
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c     | 24 ++++---
 drivers/net/ethernet/qlogic/qed/qed_iscsi.h     | 23 +++---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c       | 21 +++---
 drivers/net/ethernet/qlogic/qed/qed_ll2.h       | 13 ++--
 drivers/net/ethernet/qlogic/qed/qed_mcp.c       |  1 +
 drivers/net/ethernet/qlogic/qed/qed_ooo.c       | 30 ++++----
 drivers/net/ethernet/qlogic/qed/qed_ooo.h       | 26 +++----
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h  |  1 +
 drivers/net/ethernet/qlogic/qed/qed_sp.h        | 32 +++------
 drivers/net/ethernet/qlogic/qed/qed_spq.c       | 54 ++++++++------
 drivers/net/ethernet/qlogic/qede/qede.h         |  1 -
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 14 +++-
 drivers/net/ethernet/qlogic/qede/qede_filter.c  | 62 +++++++++-------
 drivers/net/ethernet/qlogic/qede/qede_fp.c      | 18 ++---
 drivers/net/ethernet/qlogic/qede/qede_main.c    | 29 +++++---
 22 files changed, 269 insertions(+), 229 deletions(-)

-- 
1.9.3
