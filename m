From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net v2 0/3] qed*: Bug fix series.
Date: Thu, 4 May 2017 08:15:02 -0700
Message-ID: <20170504151505.4407-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>,
        "Sudarsana Reddy Kalluru" <Sudarsana.Kalluru@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0050.outbound.protection.outlook.com ([104.47.40.50]:45024
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752780AbdEDPP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 11:15:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>

The series contains minor bug fixes for qed/qede drivers.

Please consider applying it to 'net' branch.

Changes from previous versions:
-------------------------------
v2: Removed the incorrect comment message.

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
