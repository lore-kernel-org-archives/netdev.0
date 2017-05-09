From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 0/5] qed*: General fixes
Date: Tue, 9 May 2017 15:07:46 +0300
Message-ID: <1494331671-16273-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0069.outbound.protection.outlook.com ([104.47.34.69]:22896
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753431AbdEIMII (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 9 May 2017 08:08:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contain several fixes for qed and qede.

 - #1 [and ~#5] relate to XDP cleanups
 - #2 and #5 correct VF behavior
 - #3 and #4 fix and add missing configurations needed for RoCE & storage

Dave,

Please consider applying the series to 'net'.

Thanks,
Yuval

Sudarsana Reddy Kalluru (1):
  qede: Fix XDP memory leak on unload

Ram Amrani (1):
  qed: Correct doorbell configuration for !4Kb pages

Yuval Mintz (3):
  qed: Fix VF removal sequence
  qed: Tell QM the number of tasks
  qede: Split PF/VF ndos

 drivers/net/ethernet/qlogic/qed/qed_cxt.c      |  1 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c      |  2 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c     |  6 ++++--
 drivers/net/ethernet/qlogic/qede/qede_filter.c |  5 -----
 drivers/net/ethernet/qlogic/qede/qede_main.c   | 25 ++++++++++++++++++++++++-
 5 files changed, 30 insertions(+), 9 deletions(-)

-- 
1.9.3
