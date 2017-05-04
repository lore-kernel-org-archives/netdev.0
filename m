From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net 0/3] qed*: Bug fix series.
Date: Wed, 3 May 2017 23:52:06 -0700
Message-ID: <20170504065209.26106-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>,
        "Sudarsana Reddy Kalluru" <Sudarsana.Kalluru@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0085.outbound.protection.outlook.com ([104.47.34.85]:54699
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751303AbdEDGwg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 02:52:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>

The series contains minor bug fixes for qed/qede drivers.

Please consider applying it to 'net' branch.

Sudarsana Reddy Kalluru (3):
  qed*: Fix possible overflow for status block id field.
  qed: Fix overriding of supported autoneg value.
  qede: Fix possible misconfiguration of advertised autoneg value.

 drivers/net/ethernet/qlogic/qed/qed_dev.c       | 11 +++++++----
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h   |  4 ++--
 drivers/net/ethernet/qlogic/qed/qed_main.c      |  8 ++++++--
 drivers/net/ethernet/qlogic/qed/qed_mcp.h       |  1 +
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 10 +++++++---
 include/linux/qed/qed_if.h                      |  2 +-
 6 files changed, 24 insertions(+), 12 deletions(-)

-- 
1.8.3.1
