From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 00/11] qed/qede: Mostly-cleanup series
Date: Mon, 22 May 2017 14:32:00 +0300
Message-ID: <1495452731-27171-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0065.outbound.protection.outlook.com ([104.47.42.65]:63840
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752680AbdEVLc3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 07:32:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains some cleanup of the qed and qede code:
 - #1 contains mostly static/endian changes in order to allow qede to
   pass sparse compilation cleanly.
 - #2, #5 and #6 are either semantic or remove dead-code from driver.
 - #9, #10 and #11 relate to printing and slightly change some APIs
   between qed and the protocol drivers for that end [sharing the
   interface names and information regarding device].

The rest of the patches are minor changes/fixes to various flows
in qed.

Dave,

Please consider applying this series to net-next.

Thanks,
Yuval

Manish Chopra (2):
  qede: Fix sparse warnings
  qed: !main_ptt for tunnel configuration

Michal Kalderon (1):
  qed: Enable RoCE parser searching on fp init

Tomer Tayar (4):
  qed: Log incorrectly installed board
  qed: Drop the 's' from num_ports_in_engines
  qed: Flush slowpath tasklet on stop
  qed: Provide MBI information in dev_info

Yuval Mintz (4):
  qed: Align DP_ERR style with other DP macros
  qed: Remove BB_A0 references
  qede: Log probe of PCI device
  qed: Replace set_id() api with set_name()

 drivers/net/ethernet/qlogic/qed/qed.h             |  9 +---
 drivers/net/ethernet/qlogic/qed/qed_dev.c         | 57 +++++++++++++----------
 drivers/net/ethernet/qlogic/qed/qed_hsi.h         |  8 ++++
 drivers/net/ethernet/qlogic/qed/qed_l2.c          | 17 ++++++-
 drivers/net/ethernet/qlogic/qed/qed_main.c        | 26 ++++++++---
 drivers/net/ethernet/qlogic/qed/qed_mcp.c         | 30 ++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.h         | 14 +++++-
 drivers/net/ethernet/qlogic/qed/qed_ptp.c         |  4 +-
 drivers/net/ethernet/qlogic/qed/qed_sp.h          |  3 ++
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c | 14 ++++--
 drivers/net/ethernet/qlogic/qed/qed_sriov.c       |  2 +-
 drivers/net/ethernet/qlogic/qede/qede_dcbnl.c     |  1 -
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c   | 10 ++--
 drivers/net/ethernet/qlogic/qede/qede_fp.c        | 25 +++++-----
 drivers/net/ethernet/qlogic/qede/qede_main.c      | 44 +++++++++++++++--
 drivers/net/ethernet/qlogic/qede/qede_roce.c      |  4 +-
 drivers/scsi/qedf/qedf_main.c                     |  2 +-
 drivers/scsi/qedi/qedi_main.c                     |  2 +-
 include/linux/qed/qed_if.h                        | 33 +++++++++----
 19 files changed, 223 insertions(+), 82 deletions(-)

-- 
1.9.3
