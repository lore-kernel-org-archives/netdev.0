From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 0/5] bnxt_en: Misc. updates for net-next.
Date: Fri, 13 Jan 2017 01:31:59 -0500
Message-ID: <1484289124-28853-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34667 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750700AbdAMGcO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 01:32:14 -0500
Received: by mail-pf0-f171.google.com with SMTP id 127so26014509pfg.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 22:32:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Miscellaneous updates including firmware spec update, ethtool -p blinking
LED support, RDMA SRIOV config callback, and minor fixes.

v2: Dropped the DCBX RoCE app TLV patch until the ETH_P_IBOE RDMA patch
is merged.

Michael Chan (5):
  bnxt_en: Fix compiler warnings when CONFIG_RFS_ACCEL is not defined.
  bnxt_en: Clear TPA flags when BNXT_FLAG_NO_AGG_RINGS is set.
  bnxt_en: Update to firmware interface spec to 1.6.1.
  bnxt_en: Add support for ethtool -p.
  bnxt_en: Add the ulp_sriov_cfg hooks for bnxt_re RDMA driver.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  44 ++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  17 ++
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  44 +++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h |  23 ++
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     | 261 ++++++++++++++++++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c   |   5 +
 6 files changed, 369 insertions(+), 25 deletions(-)

-- 
1.8.3.1
