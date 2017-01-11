From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 0/6] bnxt_en:  Misc. updates for net-next.
Date: Tue, 10 Jan 2017 20:12:33 -0500
Message-ID: <1484097159-21575-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33636 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756647AbdAKBM5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 20:12:57 -0500
Received: by mail-pf0-f177.google.com with SMTP id y143so34975532pfb.0
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 17:12:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Miscellaneous updates including firmware spec update, ethtool -p blinking
LED support, RDMA SRIOV and app TLV support, and minor fixes.

Michael Chan (6):
  bnxt_en: Fix compiler warnings when CONFIG_RFS_ACCEL is not defined.
  bnxt_en: Clear TPA flags when BNXT_FLAG_NO_AGG_RINGS is set.
  bnxt_en: Update to firmware interface spec to 1.6.1.
  bnxt_en: Add support for ethtool -p.
  bnxt_en: Pass RoCE app priority to firmware.
  bnxt_en: Add the ulp_sriov_cfg hooks for bnxt_re RDMA driver.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  44 ++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  17 ++
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c     | 106 ++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h     |   3 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  44 +++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h |  23 ++
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     | 261 ++++++++++++++++++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c   |   5 +
 8 files changed, 477 insertions(+), 26 deletions(-)

-- 
1.8.3.1
