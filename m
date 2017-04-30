From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 0/6] qed: RoCE related pseudo-fixes
Date: Sun, 30 Apr 2017 11:49:04 +0300
Message-ID: <1493542150-21826-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ram.Amrani@cavium.com>, Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0065.outbound.protection.outlook.com ([104.47.34.65]:34486
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S969789AbdD3ItY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 04:49:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains multiple small corrections to the RoCE logic
in qed plus some debug information and inter-module parameter
meant to prevent issues further along.

 - #1, #6 Share information with protocol driver
   [either new or filling missing bits in existing API].
 - #2, #3 correct error flows in qed.
 - #4 add debug related information.
 - #5 fixes a minor issue in the HW configuration.

Dave,

Please consider applying the series to `net-next'.

Thanks,
Yuval

Ram Amrani (6):
  qed: configure the RoCE max message size
  qed: remove unused SQ error state
  qed: add error handling flow to TID deregistratin posting failure
  qed: verify RoCE resource bitmaps are released
  qed: align DPI configuration to HW requirements
  qed: output the DPM status and WID count

 drivers/net/ethernet/qlogic/qed/qed.h      |   2 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c  |  16 ++--
 drivers/net/ethernet/qlogic/qed/qed_roce.c | 116 +++++++++++++++++++++--------
 drivers/net/ethernet/qlogic/qed/qed_roce.h |   2 +
 include/linux/qed/qed_roce_if.h            |   2 +
 5 files changed, 101 insertions(+), 37 deletions(-)

-- 
1.9.3
