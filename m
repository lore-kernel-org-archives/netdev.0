From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH net-next 0/5] be2net: patch-set
Date: Sun,  9 Oct 2016 09:58:48 +0530
Message-ID: <20161009042853.20601-1-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:1200 "EHLO
        CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751011AbcJIE3d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 00:29:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patch set contains a few bug fixes.
Please consider applying this to the net-next tree.
Thanks.

Patch-1 Obtains proper PF number for BEx chips
Patch-2 Fixes a FW update issue seen with BEx chips
Patch-3 Updates copyright string
Patch-4 Fixes TX stats for TSO packets
Patch-5 Enables VF link state setting for BE3

******

Sriharsha Basavapatna (4):
  be2net: Provide an alternate way to read pf_num for BEx chips
  be2net: NCSI FW section should be properly updated with ethtool for
    BE3
  be2net: Update Copyright string in be_hw.h
  be2net: Fix TX stats for TSO packets

Suresh Reddy (1):
  be2net: Enable VF link state setting for BE3

 drivers/net/ethernet/emulex/benet/be_cmds.c | 31 +++++++++++++++++++++++++++--
 drivers/net/ethernet/emulex/benet/be_cmds.h |  6 +++++-
 drivers/net/ethernet/emulex/benet/be_hw.h   |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c | 14 +++++++++++--
 4 files changed, 47 insertions(+), 6 deletions(-)

-- 
2.10.0.478.g3ef7618
