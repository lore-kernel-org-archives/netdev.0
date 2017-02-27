From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH 0/2] qed: Bug fixes
Date: Mon, 27 Feb 2017 11:06:31 +0200
Message-ID: <1488186393-3938-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:57046 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751614AbdB0JGw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 04:06:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Patch #1 addresses a day-one race which is dependent on the number of Vfs
[I.e., more child VFs from a single PF make it more probable].
Patch #2 corrects a race that got introduced in the last set of fixes for
qed, one that would happen each time PF transitions to UP state.

I've built & tested those against current net-next.
Please consider applying the series there.

Thanks,
Yuval

Yuval Mintz (2):
  qed: Fix race with multiple VFs
  qed: Don't use attention PTT for configuring BW

 drivers/net/ethernet/qlogic/qed/qed.h       |  4 ++-
 drivers/net/ethernet/qlogic/qed/qed_dev.c   |  6 ++---
 drivers/net/ethernet/qlogic/qed/qed_mcp.c   |  3 ++-
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 39 +++++++++++++++++------------
 drivers/net/ethernet/qlogic/qed/qed_sriov.h |  4 ++-
 5 files changed, 34 insertions(+), 22 deletions(-)

-- 
1.9.3
