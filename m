From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net-next 0/5] qed*: Dcbx/dcbnl enhancements.
Date: Thu, 20 Apr 2017 22:31:15 -0700
Message-ID: <20170421053120.12980-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>,
        "Sudarsana Reddy Kalluru" <Sudarsana.Kalluru@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0073.outbound.protection.outlook.com ([104.47.33.73]:3424
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1035348AbdDUFbq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Apr 2017 01:31:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>

The series has set of enhancements for dcbx/dcbnl implementation of
qed/qede drivers.
 - Patches (1) & (3) capture the sematic and debug changes.
 - Patch (2) adds the driver support for populating RoCEv2 dcb data.
 - Patch (4) adds the required support for reading/configuring the
   IEEE selection field (SF).
 - Patch (5) adds the support for configuring the static dcbx mode.

Please consider applying this to 'net-next' branch.

Sudarsana Reddy Kalluru (5):
  qed: Cleanup DCBx unnecessary parameters.
  qed: Separate RoCE DCBx support for V2.
  qed: Add additional DCBx debug messages.
  qed: Support dcbnl IEEE selector field.
  qed: Add support for static dcbx.

 drivers/net/ethernet/qlogic/qed/qed_dcbx.c    | 143 +++++++++++++++++---------
 drivers/net/ethernet/qlogic/qed/qed_dcbx.h    |   2 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c     |   2 +-
 drivers/net/ethernet/qlogic/qede/qede_dcbnl.c |   5 +
 include/linux/qed/qed_if.h                    |   1 +
 5 files changed, 100 insertions(+), 53 deletions(-)

-- 
1.8.3.1
