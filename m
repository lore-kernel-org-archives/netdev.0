From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net 0/4] qed: Dcbx bug fixes
Date: Wed, 19 Apr 2017 03:19:51 -0700
Message-ID: <20170419101955.26444-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>,
        "Sudarsana Reddy Kalluru" <Sudarsana.Kalluru@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0088.outbound.protection.outlook.com ([104.47.37.88]:11536
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1761967AbdDSKU3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 06:20:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>

The series has set of bug fixes for dcbx implementation of qed driver.
Please consider applying this to 'net' branch.

Sudarsana Reddy Kalluru (4):
  qed: Fix possible error in populating max_tc field.
  qed: Fix sending an invalid PFC error mask to MFW.
  qed: Fix possible system hang in the dcbnl-getdcbx() path.
  qed: Fix issue in populating the PFC config paramters.

 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

-- 
1.8.3.1
