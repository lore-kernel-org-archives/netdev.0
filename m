From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/3] qed*: Janitorial series [semantic & prints]
Date: Tue, 26 Jul 2016 16:58:34 +0300
Message-ID: <1469541517-29934-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:55314 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752056AbcGZN6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 09:58:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Some day 1 slips in coding style exist in the qed* code
[incorrect alignments, conditions using (== 0), etc.].
This series comes to address those, and do some additional
cosmetic changes along the way [such as reducing the number of lines
for function declerations].

The series is broken to 3 parts - purely semantic changes, cosmetic
changes that required minor changes in the code, and print-related
changes. All-in-all, no real change in driver behavior is expected.

Please consider applying this to `net-next'.

Thanks,
Yuval

Yuval Mintz (3):
  qed*: Semantic changes
  qed*: Trivial modifications
  qed*: Add and modify some prints

 drivers/net/ethernet/qlogic/qed/qed_cxt.c         |  47 ++---
 drivers/net/ethernet/qlogic/qed/qed_dev.c         | 115 +++++------
 drivers/net/ethernet/qlogic/qed/qed_hw.c          | 137 +++++-------
 drivers/net/ethernet/qlogic/qed/qed_init_ops.c    |  93 ++++-----
 drivers/net/ethernet/qlogic/qed/qed_int.c         | 132 +++++-------
 drivers/net/ethernet/qlogic/qed/qed_l2.c          | 241 ++++++++++------------
 drivers/net/ethernet/qlogic/qed/qed_main.c        |  34 +--
 drivers/net/ethernet/qlogic/qed/qed_mcp.c         |  78 +++----
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c |  15 +-
 drivers/net/ethernet/qlogic/qed/qed_spq.c         |  95 ++++-----
 drivers/net/ethernet/qlogic/qed/qed_sriov.c       |  56 +++--
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c   |   6 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c      | 144 ++++++-------
 13 files changed, 484 insertions(+), 709 deletions(-)

-- 
1.9.3
