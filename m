From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH net-next 0/6] be2net: patch-set
Date: Wed,  7 Sep 2016 19:57:48 +0530
Message-ID: <20160907142754.13284-1-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:51437 "EHLO
        CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S935930AbcIGOqA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 10:46:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patch set contains an error recovery feature and a few
bug fixes. Please consider applying this to the net-next tree. Thanks.

Patch-1 Supports HW error recovery in Skyhawk/BEx adapters
Patch-2 Fixes driver unload to issue function reset FW command
Patch-3 Avoids issuing GET_EXT_FAT_CAPABILITIES command for VFs
Patch-4 Avoids redundant addition of mac address in HW
Patch-5 Fixes mac address collision in some configurations
Patch-6 Updates driver version

******

Somnath Kotur (2):
  be2net: Issue COMMON_RESET_FUNCTION cmd during driver unload
  be2net: Add privilege level check for
    OPCODE_COMMON_GET_EXT_FAT_CAPABILITIES SLI cmd.

Sriharsha Basavapatna (2):
  be2net: Support UE recovery in BEx/Skyhawk adapters
  be2net: Update the driver version to 11.1.0.0

Suresh Reddy (2):
  be2net: Avoid redundant addition of mac address in HW
  be2net: Fix mac address collision in some configurations

 drivers/net/ethernet/emulex/benet/be.h         |  71 ++++-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |  66 ++++-
 drivers/net/ethernet/emulex/benet/be_cmds.h    |  45 +++-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |  40 +++
 drivers/net/ethernet/emulex/benet/be_hw.h      |   7 +-
 drivers/net/ethernet/emulex/benet/be_main.c    | 349 +++++++++++++++++++++----
 6 files changed, 517 insertions(+), 61 deletions(-)

-- 
2.10.0.rc2.20.g5b18e70
